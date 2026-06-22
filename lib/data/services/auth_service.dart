import 'package:dio/dio.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

class AuthService {
  static final Dio _dio = DioClient.createDio();

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? 'Login failed'
          : 'Login failed';
      throw Exception(message);
    }
  }
}
