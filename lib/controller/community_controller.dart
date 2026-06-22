import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/post.dart';
import 'package:plant_notebook/data/services/post_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityController extends ChangeNotifier {
  final PostApiService _service = PostApiService();

  List<Post> _posts = [];
  Post? _postDetail;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _currentUserId;

  int _currentPage = 1;
  bool _hasMorePosts = true;
  static const int _limit = 20;

  List<Post> get posts => _posts;
  Post? get postDetail => _postDetail;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  bool get hasMorePosts => _hasMorePosts;

  CommunityController() {
    _loadCurrentUserId();
    loadPosts();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    notifyListeners();
  }

  // ── Tải danh sách bài viết (làm mới) ───────────────────────────────────────
  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMorePosts = true;
    notifyListeners();

    try {
      _posts = await _service.getPosts(page: _currentPage, limit: _limit);
      if (_posts.length < _limit) {
        _hasMorePosts = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Tải thêm bài viết (phân trang) ─────────────────────────────────────────
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final newPosts = await _service.getPosts(page: _currentPage, limit: _limit);
      
      if (newPosts.isEmpty || newPosts.length < _limit) {
        _hasMorePosts = false;
      }
      _posts.addAll(newPosts);
    } catch (e) {
      // Nếu lỗi thì lùi trang lại
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Tải chi tiết bài viết ─────────────────────────────────────────────────
  Future<void> loadPostDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _postDetail = await _service.getPostById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Đăng bài viết mới ─────────────────────────────────────────────────────
  Future<bool> createPost({
    required String content,
    String? imagePath,
  }) async {
    if (content.trim().isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final newPost = await _service.createPost(
        content: content.trim(),
        imagePath: imagePath,
      );
      _posts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Sửa bài viết ──────────────────────────────────────────────────────────
  Future<bool> updatePost({
    required String postId,
    String? content,
    String? imagePath,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final updatedPost = await _service.updatePost(
        postId: postId,
        content: content?.trim(),
        imagePath: imagePath,
      );

      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = updatedPost.copyWith(
          likeCount: _posts[idx].likeCount,
          commentCount: _posts[idx].commentCount,
          isLiked: _posts[idx].isLiked,
        );
      }
      if (_postDetail?.id == postId) {
        _postDetail = updatedPost.copyWith(
          comments: _postDetail!.comments,
          likeCount: _postDetail!.likeCount,
          commentCount: _postDetail!.commentCount,
          isLiked: _postDetail!.isLiked,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Xóa bài viết ──────────────────────────────────────────────────────────
  Future<bool> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      if (_postDetail?.id == postId) _postDetail = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Thích / bỏ thích (Optimistic Update) ─────────────────────────────────
  Future<void> toggleLike(String postId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _posts[idx];
      _posts[idx] = post.copyWith(
        isLiked: !post.isLiked,
        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
      );
    }
    if (_postDetail?.id == postId) {
      final p = _postDetail!;
      _postDetail = p.copyWith(
        isLiked: !p.isLiked,
        likeCount: p.isLiked ? p.likeCount - 1 : p.likeCount + 1,
      );
    }
    notifyListeners();

    try {
      final result = await _service.toggleLike(postId);
      final isLiked = result['isLiked'] as bool;
      final likeCount = (result['likeCount'] as num).toInt();

      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(isLiked: isLiked, likeCount: likeCount);
      }
      if (_postDetail?.id == postId) {
        _postDetail = _postDetail!.copyWith(isLiked: isLiked, likeCount: likeCount);
      }
      notifyListeners();
    } catch (e) {
      if (idx != -1) {
        final post = _posts[idx];
        _posts[idx] = post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      notifyListeners();
    }
  }

  // ── Viết bình luận ────────────────────────────────────────────────────────
  Future<bool> createComment({
    required String postId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final comment = await _service.createComment(postId: postId, content: content.trim());
      if (_postDetail?.id == postId) {
        final updated = List<PostComment>.from(_postDetail!.comments)..add(comment);
        _postDetail = _postDetail!.copyWith(
          comments: updated,
          commentCount: _postDetail!.commentCount + 1,
        );
      }
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(commentCount: _posts[idx].commentCount + 1);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Sửa bình luận ─────────────────────────────────────────────────────────
  Future<bool> updateComment({
    required String commentId,
    required String postId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final updatedComment = await _service.updateComment(
        commentId: commentId,
        content: content.trim(),
      );
      if (_postDetail?.id == postId) {
        final idx = _postDetail!.comments.indexWhere((c) => c.id == commentId);
        if (idx != -1) {
          final updatedList = List<PostComment>.from(_postDetail!.comments);
          updatedList[idx] = updatedComment;
          _postDetail = _postDetail!.copyWith(comments: updatedList);
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Xóa bình luận ─────────────────────────────────────────────────────────
  Future<bool> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      await _service.deleteComment(commentId);
      if (_postDetail?.id == postId) {
        final updated = List<PostComment>.from(_postDetail!.comments)
          ..removeWhere((c) => c.id == commentId);
        _postDetail = _postDetail!.copyWith(
          comments: updated,
          commentCount: _postDetail!.commentCount - 1,
        );
      }
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(
          commentCount: (_posts[idx].commentCount - 1).clamp(0, 9999),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
