import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Top-level helper để chạy trong isolate riêng, tránh block UI thread
String _encodeToBase64(Uint8List bytes) => base64Encode(bytes);

// ─────────────────────────────────────────────────────────────────────────────
//  PlantScannerService
//  Chỉ sử dụng Gemini để phân tích hình ảnh cây trồng
// ─────────────────────────────────────────────────────────────────────────────
class PlantScannerService {
  // ── Cấu hình chung ──────────────────────────────────────────────────────
  static const int _maxOuterAttempts = 3;
  static const Duration _rateLimitCooldown = Duration(seconds: 30);

  // ── Gemini state ────────────────────────────────────────────────────────
  static final Map<String, DateTime> _geminiCooldownUntil = {};
  static int _nextGeminiStartIndex = 0;

  // ── Keys (lazy-loaded once) ──────────────────────────────────────────────
  final List<String> _geminiApiKeys;
  final String _geminiModel;

  PlantScannerService()
    : _geminiApiKeys = _buildGeminiApiKeys(),
      _geminiModel = dotenv.env['GEMINI_MODEL']?.trim().isNotEmpty == true
          ? dotenv.env['GEMINI_MODEL']!.trim()
          : 'gemini-2.5-flash' {
    _devLog('=== PlantScannerService init ===');
    _devLog('Gemini keys loaded: ${_geminiApiKeys.length}');
    _devLog('Gemini model      : $_geminiModel');
  }

  // ── Public API ───────────────────────────────────────────────────────────

  Future<PlantAnalysisResult> analyzePlantImage(File imageFile) async {
    _devLog('--- analyzePlantImage START ---');

    if (_geminiApiKeys.isEmpty) {
      _devLog('[ERROR] Không có Gemini API key nào được cấu hình trong .env!');
      throw const PlantScannerException('missing_ai_api_key');
    }

    Object? lastError;

    for (var attempt = 1; attempt <= _maxOuterAttempts; attempt++) {
      _devLog('Attempt $attempt / $_maxOuterAttempts');
      try {
        final data = await _analyzeWithGemini(imageFile);
        _devLog('--- analyzePlantImage SUCCESS ---');
        return PlantAnalysisResult.fromJson(data);
      } catch (e) {
        lastError = e;
        _devLog('[WARN] Attempt $attempt failed: $e');

        if (e is PlantScannerException) rethrow; // Lỗi cứng, không retry

        final isTransient = _isTransientError(e.toString().toLowerCase());
        if (attempt < _maxOuterAttempts && isTransient) {
          final wait = Duration(seconds: attempt * 3);
          _devLog('Waiting ${wait.inSeconds}s before retry...');
          await Future.delayed(wait);
          continue;
        }
        rethrow;
      }
    }

    throw lastError ?? const PlantScannerException('unknown_error');
  }

  /// Xóa toàn bộ cooldown (gọi khi user bấm Thử Lại)
  static void clearCooldowns() {
    _geminiCooldownUntil.clear();
    _devLog('[INFO] Cooldowns cleared by user retry.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GEMINI
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _analyzeWithGemini(File imageFile) async {
    _pruneExpiredCooldowns();

    var available = _availableKeys(
      keys: _geminiApiKeys,
      cooldownMap: _geminiCooldownUntil,
      startIndex: _nextGeminiStartIndex,
    );

    // Safety valve: nếu tất cả đang cooldown thì xóa và thử lại
    if (available.isEmpty) {
      _geminiCooldownUntil.clear();
      available = _availableKeys(
        keys: _geminiApiKeys,
        cooldownMap: _geminiCooldownUntil,
        startIndex: _nextGeminiStartIndex,
      );
    }

    if (available.isEmpty) {
      _devLog('[Gemini] ❌ Tất cả Gemini keys bị rate limit');
      throw const PlantScannerException('all_ai_keys_rate_limited');
    }

    Object? lastError;

    for (final apiKey in available) {
      _nextGeminiStartIndex =
          (_geminiApiKeys.indexOf(apiKey) + 1) % _geminiApiKeys.length;

      _devLog(
        '[Gemini] Thử key #${_geminiApiKeys.indexOf(apiKey) + 1} / ${_geminiApiKeys.length} (model: $_geminiModel)...',
      );

      try {
        final result = await _callGemini(
          imageFile: imageFile,
          modelName: _geminiModel,
          apiKey: apiKey,
        );
        _devLog(
          '[Gemini] ✅ Thành công với key #${_geminiApiKeys.indexOf(apiKey) + 1}',
        );
        return result;
      } catch (e) {
        final msg = e.toString().toLowerCase();

        if (_isPerKeyRateLimitError(msg)) {
          _devLog(
            '[Gemini] ⚠️  Rate limit (429) key #${_geminiApiKeys.indexOf(apiKey) + 1}: $e',
          );
          _geminiCooldownUntil[apiKey] = DateTime.now().add(_rateLimitCooldown);
          lastError = e;
          continue; // chuyển sang key tiếp theo
        }

        _devLog(
          '[Gemini] ⚠️  Lỗi key #${_geminiApiKeys.indexOf(apiKey) + 1}: $e',
        );
        lastError = e;
        continue;
      }
    }

    final allCooled = _availableKeys(
      keys: _geminiApiKeys,
      cooldownMap: _geminiCooldownUntil,
      startIndex: 0,
    ).isEmpty;

    if (allCooled) {
      _devLog('[Gemini] ❌ Tất cả Gemini keys bị rate limit');
      throw const PlantScannerException('all_ai_keys_rate_limited');
    }

    throw lastError ?? const PlantScannerException('gemini_unknown');
  }

  Future<Map<String, dynamic>> _callGemini({
    required File imageFile,
    required String modelName,
    required String apiKey,
  }) async {
    final bytes = await imageFile.readAsBytes();
    // Encode base64 trong isolate riêng để không block UI thread
    final base64Image = await compute(_encodeToBase64, bytes);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

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

      // Build + encode payload trong isolate để không block UI
      final payload = await compute(
        _buildGeminiPayload,
        _GeminiPayloadArgs(
          userPrompt: _analysisPrompt,
          base64Image: base64Image,
        ),
      );

      request.add(payload);
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();

      _devLog('[Gemini] $modelName → HTTP ${response.statusCode}');

      if (response.statusCode >= 400) {
        _devLog(
          '[Gemini] ERROR BODY: ${body.substring(0, body.length.clamp(0, 600))}',
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

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────

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

    final primary = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (primary.isNotEmpty) all.add(primary);

    final extras =
        dotenv.env.entries
            .where(
              (e) =>
                  e.key.trim().toUpperCase().startsWith(prefix) &&
                  e.key.endsWith('API_KEY') &&
                  e.key.trim().toUpperCase() != 'GEMINI_API_KEY',
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    for (final e in extras) {
      final v = e.value.trim();
      if (v.isNotEmpty && !all.contains(v)) all.add(v);
    }

    return all;
  }

  static List<String> _availableKeys({
    required List<String> keys,
    required Map<String, DateTime> cooldownMap,
    required int startIndex,
  }) {
    if (keys.isEmpty) return const [];
    final now = DateTime.now();
    final start = startIndex % keys.length;
    final ordered = <String>[];
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
      msg.contains('429') ||
      msg.contains('rate_limit_exceeded') ||
      msg.contains('resource_exhausted');

  bool _isTransientError(String msg) =>
      _isPerKeyRateLimitError(msg) ||
      msg.contains('503') ||
      msg.contains('overloaded') ||
      msg.contains('high demand') ||
      msg.contains('too many requests') ||
      msg.contains('timeout') ||
      msg.contains('deadline exceeded') ||
      msg.contains('all_ai_keys_rate_limited');

  // Dev-only logger – chỉ in ra terminal, không hiện lên UI
  static void _devLog(String message) {
    // ignore: avoid_print
    print('[PlantScannerService] $message');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Prompt
  // ─────────────────────────────────────────────────────────────────────────

  /// User prompt: ngắn gọn, chỉ định rõ format và yêu cầu chất lượng.
  static const String _analysisPrompt =
      'Nhan dien va phan tich cay trong anh nay.\n'
      'Neu khong chac chan ve loai cay, hay ghi ten pho thong la "Chua xac dinh duoc loai cay" va ten khoa hoc la "Khong ro".\n'
      'Tra ve JSON (KHONG markdown, KHONG text ngoai JSON):\n'
      '{"ten_pho_thong":"<ten tieng Viet>","ten_khoa_hoc":"<Ten Latin>","tinh_trang_suc_khoe":"<Tot|Kha tot|Trung binh|Dang yeu|Dang mac benh>","benh_dang_gap":"<ten benh + nguyen nhan ngan, hoac Khong phat hien benh>","loi_khuyen_cham_soc":"<2-3 cau cu the: nuoc, anh sang, dat, phan bon>","ban_co_biet":"Ban co biet... <1-2 cau thu vi ve cay nay>"}\n'
      'TAT CA noi dung PHAI la tieng Viet co dau. KHONG chen bat ky chu nuoc ngoai nao.';
}

// ─────────────────────────────────────────────────────────────────────────────
//  PlantScannerException – lỗi có mã code rõ ràng
// ─────────────────────────────────────────────────────────────────────────────
class PlantScannerException implements Exception {
  final String code;
  const PlantScannerException(this.code);

  @override
  String toString() => 'PlantScannerException($code)';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Isolate helpers – build + JSON-encode payload ngoài UI thread
//  (compute() chỉ chấp nhận top-level hoặc static function)
// ─────────────────────────────────────────────────────────────────────────────

class _GeminiPayloadArgs {
  final String userPrompt;
  final String base64Image;
  const _GeminiPayloadArgs({
    required this.userPrompt,
    required this.base64Image,
  });
}

List<int> _buildGeminiPayload(_GeminiPayloadArgs args) {
  final map = {
    'contents': [
      {
        'parts': [
          {'text': args.userPrompt},
          {
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': args.base64Image,
            },
          },
        ],
      },
    ],
    'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1024},
  };
  return utf8.encode(jsonEncode(map));
}
