import 'dart:io';
import 'package:dio/dio.dart';
import 'package:plant_notebook/data/models/plant_analysis_result.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

class PlantScannerService {
  PlantScannerService({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  final Dio _dio;

  Future<PlantAnalysisResult> analyzePlantImage(File imageFile) async {
    final FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    try {
      final Response response = await _dio.post(
        '/library-plants/scan',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      return PlantAnalysisResult.fromJson(response.data);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final int statusCode = e.response?.statusCode ?? -1;

      if (statusCode == 429) {
        throw const PlantScannerException('all_ai_keys_rate_limited');
      }

      final String errMsg = _extractMessage(responseData);
      if (errMsg.contains('api_key') ||
          errMsg.contains('banned') ||
          errMsg.contains('invalid')) {
        throw const PlantScannerException('api_key_invalid');
      }
      throw Exception('Server error $statusCode: $errMsg');
    }
  }

  static void clearCooldowns() {}

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data.toString();
    }
    return data?.toString() ?? 'Lỗi không xác định';
  }
}

class PlantScannerException implements Exception {
  final String code;
  const PlantScannerException(this.code);

  @override
  String toString() => 'PlantScannerException($code)';
}
