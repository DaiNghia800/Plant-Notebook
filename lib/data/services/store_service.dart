import 'package:dio/dio.dart';
import 'package:plant_notebook/data/models/store.dart';
import 'package:plant_notebook/data/network/dio_client.dart';

class StoreService {
  StoreService({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  final Dio _dio;

  Future<List<Store>> getStores({String? type}) async {
    try {
      final Map<String, dynamic>? queryParameters = 
          type != null && type != 'Tất cả' ? {'type': type} : null;

      final response = await _dio.get(
        '/store',
        queryParameters: queryParameters,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        final List data = body['data'] ?? [];
        return data.map((json) => Store.fromJson(json)).toList();
      }
      throw Exception('Failed to load stores: ${response.data}');
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối server: ${e.message}');
    }
  }

  Future<Store> getStoreById(String id) async {
    try {
      final response = await _dio.get('/store/$id');

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return Store.fromJson(body['data']);
      }
      throw Exception('Failed to load store details: ${response.data}');
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối server: ${e.message}');
    }
  }

  Future<StoreReview> createReview({
    required String storeId,
    required int rating,
    required String comment,
    String? userId,
  }) async {
    try {
      final response = await _dio.post(
        '/store/$storeId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
          'userId': userId,
        },
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return StoreReview.fromJson(body['data']);
      }
      throw Exception('Failed to create review: ${response.data}');
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối server: ${e.message}');
    }
  }

  Future<bool> seedStores() async {
    try {
      final response = await _dio.post('/store/seed');
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
