import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_notebook/data/models/plant_analysis_result.dart';

class GeminiScannerService {
  static const int _maxAttempts = 3;
  static const Duration _rateLimitCooldown = Duration(seconds: 30);
  static final Map<String, DateTime> _geminiCooldownUntil =
      <String, DateTime>{};
  static int _nextGeminiStartIndex = 0;

  final List<String> _geminiApiKeys;

  GeminiScannerService() : _geminiApiKeys = _buildGeminiApiKeys();

  Future<PlantAnalysisResult> analyzePlantImage(File imageFile) async {
    print(
      '[GeminiService] analyzePlantImage called. Keys: ${_geminiApiKeys.length}, Cooldowns: ${_geminiCooldownUntil.length}',
    );
    if (_geminiApiKeys.isEmpty) {
      throw Exception('missing_ai_api_key');
    }

    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final data = await _analyzeWithGeminiFallback(imageFile);
        return PlantAnalysisResult.fromJson(data);
      } catch (e) {
        lastError = e;
        final errorMessage = e.toString().toLowerCase();

        final canRetry =
            attempt < _maxAttempts && _isTransientError(errorMessage);
        if (!canRetry) rethrow;

        await Future.delayed(Duration(seconds: attempt * 3));
      }
    }

    throw lastError ?? Exception('Lỗi không xác định khi phân tích ảnh');
  }

  /// Xóa toàn bộ cooldown (gọi khi user bấm retry)
  static void clearCooldowns() {
    _geminiCooldownUntil.clear();
  }

  Future<Map<String, dynamic>> _analyzeWithGeminiFallback(
    File imageFile,
  ) async {
    _pruneExpiredCooldowns();

    // Safety valve: nếu tất cả key bị block, xóa cooldown và thử lại
    // (tránh bị stuck do cooldown sai từ session trước)
    var availableKeys = _availableKeys(
      keys: _geminiApiKeys,
      cooldownMap: _geminiCooldownUntil,
      startIndex: _nextGeminiStartIndex,
    );

    // Safety valve: nếu tất cả key bị cooldown (có thể do lỗi logic session trước)
    // → xóa cooldown và thử lại thay vì báo sai
    if (availableKeys.isEmpty) {
      _geminiCooldownUntil.clear();
      availableKeys = _availableKeys(
        keys: _geminiApiKeys,
        cooldownMap: _geminiCooldownUntil,
        startIndex: _nextGeminiStartIndex,
      );
    }

    if (availableKeys.isEmpty) {
      throw Exception('all_ai_keys_rate_limited');
    }

    // Models theo thứ tự ưu tiên
    final modelsToTry = [
      'gemini-2.5-flash', // Thử 2.5 flash (GA name)
      'gemini-1.5-flash', // Fallback: luôn available trên free tier
    ];

    Object? lastError;

    for (final apiKey in availableKeys) {
      _nextGeminiStartIndex =
          (_geminiApiKeys.indexOf(apiKey) + 1) % _geminiApiKeys.length;

      for (final modelName in modelsToTry) {
        try {
          return await _callGemini(
            imageFile: imageFile,
            modelName: modelName,
            apiKey: apiKey,
          );
        } catch (e) {
          final msg = e.toString().toLowerCase();

          // 429 per-key limit → cooldown key này, thử key tiếp theo
          if (_isPerKeyRateLimitError(msg)) {
            print('[GeminiService] Key rate limited (429): $e');
            _geminiCooldownUntil[apiKey] = DateTime.now().add(
              _rateLimitCooldown,
            );
            lastError = e;
            break; // thoát vòng model, chuyển sang key tiếp
          }

          // 503 overload hoặc lỗi khác → thử model tiếp theo
          print(
            '[GeminiService] Error for $modelName (will try next model): $e',
          );
          lastError = e;
          continue;
        }
      }
    }

    // Nếu tất cả key đều bị cooldown 429 → báo rate limited
    final allInCooldown = _availableKeys(
      keys: _geminiApiKeys,
      cooldownMap: _geminiCooldownUntil,
      startIndex: 0,
    ).isEmpty;

    if (allInCooldown) {
      throw Exception('all_ai_keys_rate_limited');
    }

    // Throw lỗi thực sự để debug được
    throw lastError ?? Exception('Không có Gemini model nào phản hồi');
  }

  Future<Map<String, dynamic>> _callGemini({
    required File imageFile,
    required String modelName,
    required String apiKey,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final client = HttpClient();

    try {
      final uri = Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models/$modelName:generateContent',
        {'key': apiKey},
      );

      final request = await client.postUrl(uri);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );

      final payload = {
        'contents': [
          {
            'parts': [
              {'text': _analysisPrompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1024},
      };

      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();

      // DEBUG: in ra kết quả thực tế từ Gemini
      print('[GeminiService] $modelName → HTTP ${response.statusCode}');
      if (response.statusCode >= 400) {
        print(
          '[GeminiService] ERROR BODY: ${body.substring(0, body.length.clamp(0, 500))}',
        );
        throw Exception(
          'Gemini HTTP ${response.statusCode} [$modelName]: $body',
        );
      }

      final decoded = jsonDecode(body);
      final content =
          decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (content is! String || content.trim().isEmpty) {
        throw Exception('Gemini trả về dữ liệu rỗng');
      }

      return _decodeAiJson(content);
    } finally {
      client.close(force: true);
    }
  }

  Map<String, dynamic> _decodeAiJson(String text) {
    var clean = text;
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      clean = clean.substring(start, end + 1);
    } else {
      clean = clean.replaceAll('```json', '').replaceAll('```', '').trim();
    }

    final decoded = jsonDecode(clean);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Dữ liệu AI không đúng định dạng JSON');
    }
    return decoded;
  }

  static List<String> _buildGeminiApiKeys() {
    const prefix = 'GEMINI';
    final all = <String>[];
    final primaryName = '${prefix}_API_KEY';

    final primary = _readEnvValue(primaryName);
    if (primary.isNotEmpty) all.add(primary);

    final extras =
        dotenv.env.entries
            .where(
              (e) =>
                  e.key.trim().toUpperCase().startsWith(prefix) &&
                  e.key.endsWith('API_KEY') &&
                  e.key.trim().toUpperCase() != primaryName,
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    for (final e in extras) {
      final v = e.value.trim();
      if (v.isNotEmpty && !all.contains(v)) all.add(v);
    }

    return all;
  }

  static String _readEnvValue(String targetKey) {
    final direct = dotenv.env[targetKey];
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();

    for (final entry in dotenv.env.entries) {
      if (entry.key.trim().toUpperCase() == targetKey &&
          entry.value.trim().isNotEmpty) {
        return entry.value.trim();
      }
    }
    return '';
  }

  static List<String> _availableKeys({
    required List<String> keys,
    required Map<String, DateTime> cooldownMap,
    required int startIndex,
  }) {
    if (keys.isEmpty) return const [];
    final now = DateTime.now();
    final ordered = <String>[];
    final start = startIndex % keys.length;
    for (var i = 0; i < keys.length; i++) {
      ordered.add(keys[(start + i) % keys.length]);
    }
    return ordered.where((k) {
      final t = cooldownMap[k];
      return t == null || now.isAfter(t);
    }).toList();
  }

  void _pruneExpiredCooldowns() {
    final now = DateTime.now();
    _geminiCooldownUntil.removeWhere((_, t) => now.isAfter(t));
  }

  bool _isPerKeyRateLimitError(String msg) =>
      msg.contains('429') || msg.contains('resource_exhausted');

  bool _isModelOverloadedError(String msg) =>
      msg.contains('503') ||
      msg.contains('overloaded') ||
      msg.contains('high demand') ||
      msg.contains('too many requests');

  bool _isTransientError(String msg) =>
      _isModelOverloadedError(msg) ||
      _isPerKeyRateLimitError(msg) ||
      msg.contains('all_ai_keys_rate_limited') ||
      msg.contains('timeout') ||
      msg.contains('deadline exceeded');

  static const String _analysisPrompt = '''
Ban la mot chuyen gia nong nghiep hang dau. Hay phan tich hinh anh cay nay va tra ve ket qua theo chuan format JSON.
Luu y KHONG dung markdown hay block dinh dang code, chi tra ve dung chuoi JSON thuan tuy co cac thuoc tinh sau:
- "ten_pho_thong": Ten goi pho bien cua giong cay trong tieng Viet.
- "ten_khoa_hoc": Ten khoa hoc hoc thuat (tieng Latin).
- "tinh_trang_suc_khoe": Danh gia "Tot", "Kem", "Dang mac benh", v.v...
- "benh_dang_gap": Ten benh, nguyen nhan neu co. Neu cay khoe manh thi ghi "Khong phat hien benh".
- "loi_khuyen_cham_soc": Cach cham soc, hoac cach tri benh cu the.
- "ban_co_biet": Mot thong tin thu vi ngan ve cay (1-2 cau), bat dau bang "Ban co biet...".

Hay tra loi bang tieng Viet than thien, de hieu cho nguoi nong dan.
''';
}
