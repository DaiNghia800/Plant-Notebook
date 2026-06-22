import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

class LibraryPlantApiService {
  LibraryPlantApiService({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  final Dio _dio;

  // ── Lấy toàn bộ danh sách cây (có hỗ trợ filter) ─────────────────────────
  Future<List<LibraryPlantItem>> getAllPlants({
    String? category,
    bool? isTrending,
    bool? isRare,
    String approvalStatus = 'approved',
  }) async {
    final Map<String, dynamic> params = {'approvalStatus': approvalStatus};
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    if (isTrending != null) {
      params['isTrending'] = isTrending.toString();
    }
    if (isRare != null) {
      params['isRare'] = isRare.toString();
    }

    try {
      final Response response = await _dio.get(
        '/library-plants',
        queryParameters: params,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(LibraryPlantItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw LibraryPlantApiException(
        statusCode: e.response?.statusCode ?? -1,
        message: _extractMessage(e.response?.data),
      );
    }
  }

  // ── Lấy chi tiết một cây theo ID ──────────────────────────────────────────
  Future<LibraryPlantItem> getPlantById(String id) async {
    try {
      final Response response = await _dio.get('/library-plants/$id');
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return LibraryPlantItem.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw LibraryPlantApiException(
        statusCode: e.response?.statusCode ?? -1,
        message: _extractMessage(e.response?.data),
      );
    }
  }

  // ── Kiểm tra sự tồn tại của cây ──────────────────────────────────────────
  Future<Map<String, dynamic>> checkPlantExistence({
    required String name,
    required String scientificName,
  }) async {
    final Map<String, dynamic> params = {
      'name': name,
      'scientificName': scientificName,
    };
    try {
      final Response response = await _dio.get(
        '/library-plants/check-existence',
        queryParameters: params,
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>? ?? {'exists': false};
    } on DioException catch (e) {
      throw LibraryPlantApiException(
        statusCode: e.response?.statusCode ?? -1,
        message: _extractMessage(e.response?.data),
      );
    }
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
    List<Map<String, dynamic>> growthTimeline = const [],
    String? imagePath,
  }) async {
    // Tạo ID đề xuất dựa trên tên tiếng Việt không dấu hoặc slug
    final String cleanName = name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '-',
    );
    final String id =
        'proposal-$cleanName-${DateTime.now().millisecondsSinceEpoch}';

    final Map<String, dynamic> fields = {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'category': category,
      'shortDescription': shortDescription,
      'description': description,
      'lightLevel': lightLevel,
      'waterNeed': waterNeed,
      'difficulty': difficulty,
      'temperature': temperature ?? '',
      'humidity': humidity ?? '',
      'toxicity': toxicity ?? '',
      'funFacts': jsonEncode(funFacts),
      'careGuide': jsonEncode(careGuide),
      'growthTimeline': jsonEncode(growthTimeline),
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        fields['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }
    }

    final FormData formData = FormData.fromMap(fields);

    try {
      final Response response = await _dio.post(
        '/library-plants/contribute',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw LibraryPlantApiException(
        statusCode: e.response?.statusCode ?? -1,
        message: _extractMessage(e.response?.data),
      );
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'Lỗi không xác định';
    }
    return data?.toString() ?? 'Lỗi không xác định';
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
