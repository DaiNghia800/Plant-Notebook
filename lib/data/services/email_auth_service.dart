import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

class EmailAuthService {
  EmailAuthService({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  final Dio _dio;

  static const String _tokenStorageKey = 'auth_jwt_token';
  static const String _userStorageKey = 'auth_user_profile';

  Future<void> register({
    required String email,
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode != 201) {
        final data = response.data;
        throw Exception(data is Map<String, dynamic> ? data['message'] ?? 'Lỗi đăng ký' : 'Lỗi đăng ký');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? 'Lỗi đăng ký'
          : 'Lỗi đăng ký';
      throw Exception(message);
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final bool isEmail = identifier.contains('@');

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          if (isEmail) 'email': identifier else 'phone': identifier,
          'password': password,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Lỗi đăng nhập');
      }

      final String backendToken = data['token'] as String;
      final Map<String, dynamic> user = Map<String, dynamic>.from(
        data['user'] as Map,
      );

      final SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenStorageKey, backendToken);
      await preferences.setString(_userStorageKey, jsonEncode(user));
      await preferences.setString('userId', user['id'].toString());
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? 'Lỗi đăng nhập'
          : 'Lỗi đăng nhập';
      throw Exception(message);
    }
  }

  Future<void> sendForgotPasswordOtp({required String email}) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Lỗi gửi mã OTP');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? 'Lỗi gửi mã OTP'
          : 'Lỗi gửi mã OTP';
      throw Exception(message);
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Mã OTP không hợp lệ');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? 'Mã OTP không hợp lệ'
          : 'Mã OTP không hợp lệ';
      throw Exception(message);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Lỗi đặt lại mật khẩu');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? 'Lỗi đặt lại mật khẩu'
          : 'Lỗi đặt lại mật khẩu';
      throw Exception(message);
    }
  }
}
