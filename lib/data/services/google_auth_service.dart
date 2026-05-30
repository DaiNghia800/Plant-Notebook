import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthResult {
  GoogleAuthResult({
    required this.googleUser,
    required this.backendToken,
    required this.user,
  });

  final GoogleSignInAccount googleUser;
  final String backendToken;
  final Map<String, dynamic> user;
}

class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn =
            googleSignIn ??
            GoogleSignIn(
              clientId: '511657699751-53gb2g7jui4htd28k2l7befoe2b59omf.apps.googleusercontent.com',
              scopes: const ['email', 'openid', 'profile'],
            );

  static const String _defaultBackendUrl = 'http://10.0.2.2:5000';
  static const String _tokenStorageKey = 'auth_jwt_token';
  static const String _userStorageKey = 'auth_user_profile';

  final GoogleSignIn _googleSignIn;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;

  Future<GoogleAuthResult?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    return handleGoogleAuthResult(googleUser);
  }

  Future<GoogleAuthResult> handleGoogleAuthResult(GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('missing_google_id_token');
    }

    final String defaultUrl = kIsWeb ? 'http://localhost:5000' : _defaultBackendUrl;
    final String backendBaseUrl =
        dotenv.env['GOOGLE_AUTH_BACKEND_URL']?.trim().isNotEmpty == true
            ? dotenv.env['GOOGLE_AUTH_BACKEND_URL']!.trim()
            : defaultUrl;

    final Uri endpoint = Uri.parse('$backendBaseUrl/auth/google');
    final http.Response response = await http.post(
      endpoint,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final String backendToken = data['token'] as String;
    final Map<String, dynamic> user = Map<String, dynamic>.from(
      data['user'] as Map,
    );

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenStorageKey, backendToken);
    await preferences.setString(_userStorageKey, jsonEncode(user));

    return GoogleAuthResult(
      googleUser: googleUser,
      backendToken: backendToken,
      user: user,
    );
  }
}