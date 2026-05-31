class StoreReviewUser {
  final String fullName;
  final String email;

  StoreReviewUser({required this.fullName, required this.email});

  factory StoreReviewUser.fromJson(Map<String, dynamic> json) {
    return StoreReviewUser(
      fullName: json['fullName'] ?? 'Người dùng',
      email: json['email'] ?? '',
    );
  }
}

class StoreReview {
  final String id;
  final String storeId;
  final String userId;
  final int rating;
  final String? comment;
  final String createdAt;
  final StoreReviewUser? user;

  StoreReview({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.user,
  });

  factory StoreReview.fromJson(Map<String, dynamic> json) {
    return StoreReview(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      userId: json['userId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] ?? '',
      user: json['user'] != null ? StoreReviewUser.fromJson(json['user']) : null,
    );
  }
}

class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? description;
  final String type; // 'nursery' or 'store'
  final String? imageUrl;
  final double rating;
  final List<StoreReview> reviews;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.description,
    required this.type,
    this.imageUrl,
    required this.rating,
    this.reviews = const [],
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    var reviewsList = <StoreReview>[];
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .map((r) => StoreReview.fromJson(r))
          .toList();
    }

    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'],
      description: json['description'],
      type: json['type'] ?? 'store',
      imageUrl: json['imageUrl'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: reviewsList,
    );
  }
}
