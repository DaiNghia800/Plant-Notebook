import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmailAuthService {
  static const String _defaultBackendUrl = 'http://10.0.2.2:5000';
  static const String _tokenStorageKey = 'auth_jwt_token';
  static const String _userStorageKey = 'auth_user_profile';

  String get _backendBaseUrl {
    final String defaultUrl = kIsWeb ? 'http://localhost:5000' : _defaultBackendUrl;
    return dotenv.env['GOOGLE_AUTH_BACKEND_URL']?.trim().isNotEmpty == true
        ? dotenv.env['GOOGLE_AUTH_BACKEND_URL']!.trim()
        : defaultUrl;
  }

  Future<void> register({
    required String identifier,
    required String password,
    required String name,
  }) async {
    final Uri endpoint = Uri.parse('$_backendBaseUrl/auth/register');
    final bool isEmail = identifier.contains('@');
    
    final http.Response response = await http.post(
      endpoint,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (isEmail) 'email': identifier else 'phone': identifier,
        'password': password,
        'name': name,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Lỗi đăng ký');
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final Uri endpoint = Uri.parse('$_backendBaseUrl/auth/login');
    final bool isEmail = identifier.contains('@');
    
    final http.Response response = await http.post(
      endpoint,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (isEmail) 'email': identifier else 'phone': identifier,
        'password': password,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Lỗi đăng nhập');
    }

    final String backendToken = data['token'] as String;
    final Map<String, dynamic> user = Map<String, dynamic>.from(data['user'] as Map);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenStorageKey, backendToken);
    await preferences.setString(_userStorageKey, jsonEncode(user));
  }
}
