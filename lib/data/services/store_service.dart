import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:plant_notebook/data/models/store.dart';

class StoreService {
  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/';
    // Clean up trailing slash
    return url.endsWith('/') ? url : '$url/';
  }

  Future<List<Store>> getStores({String? type}) async {
    try {
      final uri = Uri.parse('${_baseUrl}store').replace(
        queryParameters: type != null && type != 'Tất cả' ? {'type': type} : null,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List data = body['data'] ?? [];
          return data.map((json) => Store.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load stores: ${response.body}');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  Future<Store> getStoreById(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}store/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return Store.fromJson(body['data']);
        }
      }
      throw Exception('Failed to load store details: ${response.body}');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  Future<StoreReview> createReview({
    required String storeId,
    required int rating,
    required String comment,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}store/$storeId/reviews');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
          'userId': userId,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return StoreReview.fromJson(body['data']);
        }
      }
      throw Exception('Failed to create review: ${response.body}');
    } catch (e) {
      throw Exception('Lỗi kết nối server: $e');
    }
  }

  Future<bool> seedStores() async {
    try {
      final uri = Uri.parse('${_baseUrl}store/seed');
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
