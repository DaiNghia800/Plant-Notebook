import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

/// Controller chuyên xử lý việc upload ảnh lên server để tạo AI scan task.
/// Tách biệt hoàn toàn với PlantScannerController (camera).
/// Upload xong trả về taskId ngay, không polling, không chờ AI.
class ScanUploadController extends ChangeNotifier {
  final Dio _dio = DioClient.createDio();

  bool isUploading = false;
  String? lastError;

  /// Upload ảnh lên server → nhận về taskId (202 Accepted)
  /// Gọi [onSuccess] khi upload thành công, [onError] khi thất bại
  Future<void> uploadAndScan({
    required String imagePath,
    required Function(String taskId) onSuccess,
    required Function(String error) onError,
  }) async {
    if (isUploading) return;

    isUploading = true;
    lastError = null;
    notifyListeners();

    try {
      final file = File(imagePath);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await _dio.post(
        '/library-plants/scan',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true || data['taskId'] == null) {
        throw Exception(data['message'] ?? 'Lỗi khi gửi ảnh lên server');
      }

      final taskId = data['taskId'].toString();
      isUploading = false;
      notifyListeners();
      onSuccess(taskId);
    } on DioException catch (e) {
      final msg = _extractMessage(e.response?.data) ?? 'Lỗi kết nối server';
      isUploading = false;
      lastError = msg;
      notifyListeners();
      onError(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      isUploading = false;
      lastError = msg;
      notifyListeners();
      onError(msg);
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

}
