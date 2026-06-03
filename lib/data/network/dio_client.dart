import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_notebook/utils/url_resolver.dart';

class DioClient {
  static const Duration _timeout = Duration(seconds: 20);

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl(),
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final resolvedBase = await UrlResolver.resolve(options.baseUrl);
          options.baseUrl = resolvedBase;
          return handler.next(options);
        },
      ),
    );

    final token = dotenv.env['MY_GARDEN_API_TOKEN']?.trim();
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    return dio;
  }

  static String _baseUrl() {
    return dotenv.env['API_BASE_URL']?.trim() ??
        dotenv.env['MY_GARDEN_API_BASE_URL']?.trim() ??
        'http://localhost:5000';
  }
}
