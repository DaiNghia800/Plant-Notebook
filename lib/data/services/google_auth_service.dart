import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

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
  GoogleAuthService({GoogleSignIn? googleSignIn, Dio? dio})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            clientId:
                '511657699751-53gb2g7jui4htd28k2l7befoe2b59omf.apps.googleusercontent.com',
            scopes: const ['email', 'openid', 'profile'],
          ),
      _dio = dio ?? DioClient.createDio();

  static const String _tokenStorageKey = 'auth_jwt_token';
  static const String _userStorageKey = 'auth_user_profile';

  final GoogleSignIn _googleSignIn;
  final Dio _dio;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<GoogleAuthResult?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    return handleGoogleAuthResult(googleUser);
  }

  Future<GoogleAuthResult> handleGoogleAuthResult(
    GoogleSignInAccount googleUser,
  ) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('missing_google_id_token');
    }

    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data?.toString() ?? 'Lỗi xác thực Google');
      }

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final String backendToken = data['token'] as String;
      final Map<String, dynamic> user = Map<String, dynamic>.from(
        data['user'] as Map,
      );

      final SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenStorageKey, backendToken);
      await preferences.setString(_userStorageKey, jsonEncode(user));
      await preferences.setString('userId', user['id'].toString());

      return GoogleAuthResult(
        googleUser: googleUser,
        backendToken: backendToken,
        user: user,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String? ?? responseData?.toString() ?? 'Lỗi xác thực Google'
          : e.message ?? 'Lỗi xác thực Google';
      throw Exception(message);
    }
  }
}
