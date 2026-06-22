import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:plant_notebook/data/models/post.dart';
import 'package:plant_notebook/utils/url_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostApiService {
  static final String _rawBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/';

  static String _postsBaseUrl() {
    final base = _rawBaseUrl.endsWith('/') ? _rawBaseUrl : '$_rawBaseUrl/';
    return '${base}posts';
  }

  static const Duration _timeout = Duration(seconds: 20);

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_jwt_token');
  }

  static Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Lấy danh sách bài viết ────────────────────────────────────────────────
  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();

    final uri = Uri.parse(resolvedBase).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (userId != null) 'userId': userId,
    });

    final response = await http.get(uri, headers: await _authHeaders()).timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Không thể tải bài viết');
  }

  // ── Lấy chi tiết bài viết ─────────────────────────────────────────────────
  Future<Post> getPostById(String id) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();

    final uri = Uri.parse('$resolvedBase/$id').replace(
      queryParameters: {if (userId != null) 'userId': userId},
    );

    final response = await http.get(uri, headers: await _authHeaders()).timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(body['data']);
    }
    throw Exception('Không thể tải chi tiết bài viết');
  }

  // ── Tạo bài viết mới ──────────────────────────────────────────────────────
  Future<Post> createPost({required String content, String? imagePath}) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == null) throw Exception('Cần đăng nhập để đăng bài');

    final uri = Uri.parse(resolvedBase);
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['userId'] = userId;
    request.fields['content'] = content;

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final ext = imagePath.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'png' : 'jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ));
      }
    }

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(body['data']);
    }
    throw Exception('Không thể tạo bài viết');
  }

  // ── Xóa bài viết ──────────────────────────────────────────────────────────
  Future<void> deletePost(String postId) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final headers = await _authHeaders();

    final uri = Uri.parse('$resolvedBase/$postId');
    final response = await http.delete(
      uri,
      headers: headers,
      body: jsonEncode({'userId': userId}),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa bài viết');
    }
  }

  // ── Thích / bỏ thích bài viết ─────────────────────────────────────────────
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final headers = await _authHeaders();

    final uri = Uri.parse('$resolvedBase/$postId/like');
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'userId': userId}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>;
    }
    throw Exception('Không thể thực hiện thao tác thích');
  }

  // ── Viết bình luận ────────────────────────────────────────────────────────
  Future<PostComment> createComment({
    required String postId,
    required String content,
  }) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final headers = await _authHeaders();

    final uri = Uri.parse('$resolvedBase/$postId/comments');
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'userId': userId, 'content': content}),
    ).timeout(_timeout);

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return PostComment.fromJson(body['data']);
    }
    throw Exception('Không thể gửi bình luận');
  }

  // ── Xóa bình luận ─────────────────────────────────────────────────────────
  Future<void> deleteComment(String commentId) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final headers = await _authHeaders();

    final resolvedUri = Uri.parse('$resolvedBase/comments/$commentId');
    final response = await http.delete(
      resolvedUri,
      headers: headers,
      body: jsonEncode({'userId': userId}),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa bình luận');
    }
  }
  // ── Sửa bài viết ──────────────────────────────────────────────────────────
  Future<Post> updatePost({
    required String postId,
    String? content,
    String? imagePath,
  }) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == null) throw Exception('Cần đăng nhập để sửa bài');

    final uri = Uri.parse('$resolvedBase/$postId');
    final request = http.MultipartRequest('PUT', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['userId'] = userId;
    if (content != null) {
      request.fields['content'] = content;
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final ext = imagePath.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'png' : 'jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ));
      }
    }

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(body['data']);
    }
    throw Exception('Không thể sửa bài viết');
  }

  // ── Sửa bình luận ─────────────────────────────────────────────────────────
  Future<PostComment> updateComment({
    required String commentId,
    required String content,
  }) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final userId = await _getUserId();
    final headers = await _authHeaders();

    final uri = Uri.parse('$resolvedBase/comments/$commentId');
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({'userId': userId, 'content': content}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return PostComment.fromJson(body['data']);
    }
    throw Exception('Không thể sửa bình luận');
  }

  // ── Lấy danh sách bài viết theo User ──────────────────────────────────────
  Future<List<Post>> getPostsByUserId({
    required String targetUserId,
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedBase = await UrlResolver.resolve(_postsBaseUrl());
    final currentUserId = await _getUserId();

    final uri = Uri.parse('$resolvedBase/user/$targetUserId').replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (currentUserId != null) 'currentUserId': currentUserId,
    });

    final response = await http.get(uri, headers: await _authHeaders()).timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Không thể tải bài viết của người dùng');
  }
}
