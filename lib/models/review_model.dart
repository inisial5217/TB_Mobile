// model ulasan produk
class ReviewModel {
  final String id; // param review id
  final int rating; // param rating 1-5
  final String? comment; // param komentar
  final ReviewerModel? reviewer; // param reviewer info
  final String? createdAt; // param tanggal dibuat

  // constructor init
  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    this.reviewer,
    this.createdAt,
  });

  // parse json review
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      reviewer: json['reviewer'] != null
          ? ReviewerModel.fromJson(json['reviewer'])
          : null,
      createdAt: json['created_at'],
    );
  }
}

// model info reviewer
class ReviewerModel {
  final String? id;
  final String? fullName;
  final String? avatarUrl;

  ReviewerModel({this.id, this.fullName, this.avatarUrl});

  // parse json reviewer
  factory ReviewerModel.fromJson(Map<String, dynamic> json) {
    return ReviewerModel(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}
