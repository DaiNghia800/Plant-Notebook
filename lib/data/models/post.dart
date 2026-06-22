class PostAuthor {
  final String id;
  final String fullName;

  PostAuthor({required this.id, required this.fullName});

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Người dùng',
    );
  }
}

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String createdAt;
  final PostAuthor? author;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      author: json['author'] != null ? PostAuthor.fromJson(json['author']) : null,
    );
  }
}

class Post {
  final String id;
  final String userId;
  final String? title;
  final String content;
  final String? imageUrl;
  final String createdAt;
  final PostAuthor? author;
  final List<PostComment> comments;
  int likeCount;
  int commentCount;
  bool isLiked;

  Post({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.author,
    this.comments = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final commentsList = <PostComment>[];
    if (json['comments'] != null) {
      for (final c in json['comments'] as List) {
        commentsList.add(PostComment.fromJson(c));
      }
    }
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString(),
      content: json['content']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      author: json['author'] != null ? PostAuthor.fromJson(json['author']) : null,
      comments: commentsList,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Post copyWith({
    int? likeCount,
    bool? isLiked,
    int? commentCount,
    List<PostComment>? comments,
  }) {
    return Post(
      id: id,
      userId: userId,
      title: title,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      author: author,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
