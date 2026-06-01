import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:http_parser/http_parser.dart';

class LibraryPlantApiService {
  LibraryPlantApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  // ── Cấu hình service URL ───────────────────────────────────────────────────
  static String? _resolvedUrl;

  static Future<String> _initServiceUrl() async {
    // ignore: avoid_print
    print('[LibraryPlantApiService] _initServiceUrl starting, rawEnv: ${dotenv.env['LIBRARY_PLANTS_SERVICE_URL']}');
    if (_resolvedUrl != null) return _resolvedUrl!;

    final String? rawEnvUrl = dotenv.env['LIBRARY_PLANTS_SERVICE_URL'];
    String envUrl = rawEnvUrl ?? '';
    if (envUrl.isEmpty) {
      envUrl = kIsWeb ? 'http://localhost:5000/library-plants' : 'http://localhost:5000/library-plants';
    }

    if (envUrl.endsWith('/')) {
      envUrl = envUrl.substring(0, envUrl.length - 1);
    }

    if (!kIsWeb && Platform.isAndroid && (envUrl.contains('localhost') || envUrl.contains('127.0.0.1'))) {
      try {
        // Thử kết nối nhanh tới 10.0.2.2 (máy ảo Android). Dùng thêm .timeout() của Dart để chắc chắn không bị nghẽn mạng trên máy thật.
        final socket = await Socket.connect('10.0.2.2', 5000)
            .timeout(const Duration(milliseconds: 200));
        socket.destroy();
        // Nếu thành công -> Bạn đang dùng máy ảo (Emulator)
        _resolvedUrl = envUrl
            .replaceAll('localhost', '10.0.2.2')
            .replaceAll('127.0.0.1', '10.0.2.2');
      } catch (_) {
        // Nếu thất bại hoặc quá thời gian -> Sử dụng 127.0.0.1 (máy thật + adb reverse)
        _resolvedUrl = envUrl.replaceAll('localhost', '127.0.0.1');
      }
    } else {
      _resolvedUrl = envUrl;
    }

    // ignore: avoid_print
    print('[LibraryPlantApiService] Resolved service URL: $_resolvedUrl');

    return _resolvedUrl!;
  }

  static const Duration _timeout = Duration(seconds: 15);

  // ── Lấy toàn bộ danh sách cây (có hỗ trợ filter) ─────────────────────────
  Future<List<LibraryPlantItem>> getAllPlants({
    String? category,
    bool? isTrending,
    bool? isRare,
    String approvalStatus = 'approved',
  }) async {
    final Map<String, String> params = {'approvalStatus': approvalStatus};
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    if (isTrending != null) {
      params['isTrending'] = isTrending.toString();
    }
    if (isRare != null) {
      params['isRare'] = isRare.toString();
    }

    final String baseUrl = await _initServiceUrl();
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: params);

    final http.Response response = await _client.get(uri).timeout(_timeout);

    _assertOk(response);

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = body['data'] as List<dynamic>? ?? [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(LibraryPlantItem.fromJson)
        .toList();
  }

  // ── Lấy chi tiết một cây theo ID ──────────────────────────────────────────
  Future<LibraryPlantItem> getPlantById(String id) async {
    final String baseUrl = await _initServiceUrl();
    final Uri uri = Uri.parse('$baseUrl/$id');
    final http.Response response = await _client.get(uri).timeout(_timeout);

    _assertOk(response);

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryPlantItem.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── Kiểm tra sự tồn tại của cây ──────────────────────────────────────────
  Future<Map<String, dynamic>> checkPlantExistence({
    required String name,
    required String scientificName,
  }) async {
    final Map<String, String> params = {
      'name': name,
      'scientificName': scientificName,
    };
    final String baseUrl = await _initServiceUrl();
    final Uri uri = Uri.parse('$baseUrl/check-existence').replace(queryParameters: params);
    final http.Response response = await _client.get(uri).timeout(_timeout);

    _assertOk(response);

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>? ?? {'exists': false};
  }

  // ── Đóng góp cây mới vào thư viện ─────────────────────────────────────────
  Future<Map<String, dynamic>> contributePlant({
    required String name,
    required String scientificName,
    required String category,
    required String shortDescription,
    required String description,
    required String lightLevel,
    required String waterNeed,
    required String difficulty,
    String? temperature,
    String? humidity,
    String? toxicity,
    List<String> funFacts = const [],
    List<Map<String, dynamic>> careGuide = const [],
    String? imagePath,
  }) async {
    // Tạo ID đề xuất dựa trên tên tiếng Việt không dấu hoặc slug
    final String cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    final String id = 'proposal-$cleanName-${DateTime.now().millisecondsSinceEpoch}';

    final String baseUrl = await _initServiceUrl();
    final Uri uri = Uri.parse('$baseUrl/contribute');
    final request = http.MultipartRequest('POST', uri);

    // Gửi fake user ID trong header
    request.headers['x-user-id'] = 'fake-user-123';

    // Thêm các trường text
    request.fields['id'] = id;
    request.fields['name'] = name;
    request.fields['scientificName'] = scientificName;
    request.fields['category'] = category;
    request.fields['shortDescription'] = shortDescription;
    request.fields['description'] = description;
    request.fields['lightLevel'] = lightLevel;
    request.fields['waterNeed'] = waterNeed;
    request.fields['difficulty'] = difficulty;
    request.fields['temperature'] = temperature ?? '';
    request.fields['humidity'] = humidity ?? '';
    request.fields['toxicity'] = toxicity ?? '';
    request.fields['funFacts'] = jsonEncode(funFacts);
    request.fields['careGuide'] = jsonEncode(careGuide);

    // Thêm file ảnh nếu có
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final String extension = imagePath.split('.').last.toLowerCase();
        String mimeSubtype = 'jpeg';
        if (extension == 'png') {
          mimeSubtype = 'png';
        } else if (extension == 'gif') {
          mimeSubtype = 'gif';
        } else if (extension == 'webp') {
          mimeSubtype = 'webp';
        }

        final multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: imagePath.split('/').last,
          contentType: MediaType('image', mimeSubtype),
        );
        request.files.add(multipartFile);
      }
    }

    final streamedResponse = await _client.send(request).timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    _assertOk(response);

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    return body;
  }

  // ── Kiểm tra status code ──────────────────────────────────────────────────
  void _assertOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LibraryPlantApiException(
        statusCode: response.statusCode,
        message: _extractMessage(response.body),
      );
    }
  }

  String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['message'] as String? ?? 'Lỗi không xác định';
    } catch (_) {
      return body;
    }
  }
}

/// Exception được ném khi server trả về status code lỗi.
class LibraryPlantApiException implements Exception {
  const LibraryPlantApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'LibraryPlantApiException($statusCode): $message';
}
