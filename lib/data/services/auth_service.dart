import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:plant_notebook/utils/url_resolver.dart';

class AuthService {
  static String _baseUrl() {
    final String? url = dotenv.env['API_BASE_URL'];
    final String resolved = (url == null || url.isEmpty)
        ? 'http://localhost:5000'
        : url;
    return resolved.replaceFirst(RegExp(r'/+$'), '');
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final String resolvedBase = await UrlResolver.resolve(_baseUrl());
    final Uri uri = Uri.parse('$resolvedBase/auth/login');
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final Map<String, dynamic> errorBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{'message': 'Unknown error'};
    throw Exception(errorBody['message'] ?? 'Login failed');
  }
}
