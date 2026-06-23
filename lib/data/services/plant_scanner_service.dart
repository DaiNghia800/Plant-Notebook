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

      final Map<String, dynamic> data = response.data;
      if (data['success'] != true || data['taskId'] == null) {
        throw Exception(data['message'] ?? 'Lỗi khi gửi ảnh phân tích');
      }

      final String taskId = data['taskId'].toString();
      final DateTime startTime = DateTime.now();
      const Duration pollInterval = Duration(seconds: 2);
      const Duration timeoutDuration = Duration(seconds: 90);

      while (true) {
        if (DateTime.now().difference(startTime) > timeoutDuration) {
          throw Exception('Timeout: Quá thời gian chờ phân tích AI');
        }

        try {
          final Response taskResponse = await _dio.get(
            '/library-plants/scan/$taskId',
          );
          final Map<String, dynamic> taskData = taskResponse.data;

          if (taskData['success'] == true && taskData['data'] != null) {
            final taskDetails = taskData['data'];
            final String status = taskDetails['status'] ?? 'PENDING';

            if (status == 'COMPLETED') {
              final aiResult = taskDetails['aiResult'];
              if (aiResult == null) {
                throw Exception('Kết quả phân tích AI trống');
              }
              return PlantAnalysisResult.fromJson(aiResult);
            } else if (status == 'FAILED') {
              final aiResult = taskDetails['aiResult'];
              final String errMsg =
                  (aiResult is Map && aiResult['error'] != null)
                  ? aiResult['error'].toString()
                  : 'Lỗi trong quá trình phân tích AI';
              throw Exception(errMsg);
            }
          }
        } on DioException catch (de) {
          final statusCode = de.response?.statusCode ?? -1;
          if (statusCode == 404) {
            throw Exception('Không tìm thấy tiến trình phân tích trên máy chủ');
          }
        }

        await Future.delayed(pollInterval);
      }
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

  Future<Response> getTaskResult(String taskId) async {
    return await _dio.get('/library-plants/scan/$taskId');
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
