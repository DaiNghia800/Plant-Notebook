import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:plant_notebook/data/models/plant_analysis_result.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PlantScannerService
//  Gọi Backend API để phân tích hình ảnh cây trồng thay vì gọi trực tiếp Gemini
// ─────────────────────────────────────────────────────────────────────────────
class PlantScannerService {
  static final http.Client _client = http.Client();

  // ── Service URL ─────────────────────────────────────────────────────────
  static String? _resolvedUrl;

  static Future<String> _initServiceUrl() async {
    if (_resolvedUrl != null) return _resolvedUrl!;

    final String? rawEnvUrl = dotenv.env['LIBRARY_PLANTS_SERVICE_URL'];
    String envUrl = rawEnvUrl ?? '';
    if (envUrl.isEmpty) {
      envUrl = 'http://localhost:5000/library-plants';
    }

    if (envUrl.endsWith('/')) {
      envUrl = envUrl.substring(0, envUrl.length - 1);
    }

    if (!kIsWeb &&
        Platform.isAndroid &&
        (envUrl.contains('localhost') || envUrl.contains('127.0.0.1'))) {
      try {
        final socket = await Socket.connect(
          '10.0.2.2',
          5000,
        ).timeout(const Duration(milliseconds: 200));
        socket.destroy();
        _resolvedUrl = envUrl
            .replaceAll('localhost', '10.0.2.2')
            .replaceAll('127.0.0.1', '10.0.2.2');
      } catch (_) {
        _resolvedUrl = envUrl;
      }
    } else {
      _resolvedUrl = envUrl;
    }

    return _resolvedUrl!;
  }

  Future<PlantAnalysisResult> analyzePlantImage(File imageFile) async {
    final String baseUrl = await _initServiceUrl();
    final Uri uri = Uri.parse('$baseUrl/scan');

    final request = http.MultipartRequest('POST', uri);

    // Đọc file ảnh dưới dạng stream
    final stream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final String extension = imageFile.path.split('.').last.toLowerCase();
    String mimeSubtype = 'jpeg';
    if (extension == 'png') {
      mimeSubtype = 'png';
    } else if (extension == 'webp') {
      mimeSubtype = 'webp';
    }

    final multipartFile = http.MultipartFile(
      'image',
      stream,
      length,
      filename: imageFile.path.split('/').last,
      contentType: MediaType('image', mimeSubtype),
    );
    request.files.add(multipartFile);

    final streamedResponse = await _client
        .send(request)
        .timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return PlantAnalysisResult.fromJson(decoded);
    } else if (response.statusCode == 429) {
      throw const PlantScannerException('all_ai_keys_rate_limited');
    } else {
      final String errMsg = _extractMessage(response.body);
      if (errMsg.contains('api_key') ||
          errMsg.contains('banned') ||
          errMsg.contains('invalid')) {
        throw const PlantScannerException('api_key_invalid');
      }
      throw Exception('Server error ${response.statusCode}: $errMsg');
    }
  }

  /// Khử hoạt động cooldown (Backend tự quản lý nên client không cần tự xử lý)
  static void clearCooldowns() {
    // Không làm gì, giữ hàm này để tránh lỗi compile ở màn hình kết quả
  }

  String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['message'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PlantScannerException
// ─────────────────────────────────────────────────────────────────────────────
class PlantScannerException implements Exception {
  final String code;
  const PlantScannerException(this.code);

  @override
  String toString() => 'PlantScannerException($code)';
}
