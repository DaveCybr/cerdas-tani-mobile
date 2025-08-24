// article_model.dart - Updated unified model
import 'dart:convert';

class Article {
  final String id;
  final String title;
  final String intro;
  final String content;
  final String imageUrl;
  final String category;
  final String? categoryName;
  final DateTime publishedAt;
  final String readTime;
  final bool isHighlighted;
  final String status;
  final String createdByName;
  final String? createdByAlias;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.intro,
    required this.content,
    required this.imageUrl,
    required this.category,
    this.categoryName,
    required this.publishedAt,
    required this.readTime,
    this.isHighlighted = false,
    required this.status,
    required this.createdByName,
    this.createdByAlias,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for API response
  factory Article.fromMap(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now();
    final updatedAt =
        DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now();

    return Article(
      id: json["id"].toString(),
      title: json["name"] ?? "Tanpa Judul",
      intro: json["intro"] ?? "",
      content: json["content"] ?? "",
      imageUrl: json["image"] ?? json["meta_og_image"] ?? "",
      category: json["category_name"] ?? json["type"] ?? "ARTIKEL",
      categoryName: json["category_name"],
      publishedAt: createdAt,
      readTime: _calculateReadTime(json["content"] ?? ""),
      isHighlighted: json["status"] == "published",
      status: json["status"] ?? "unknown",
      createdByName: json["created_by_name"] ?? "unknown",
      createdByAlias: json["created_by_alias"],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Factory constructor for local/mock data
  factory Article.fromLocal({
    required String id,
    required String title,
    required String imageUrl,
    required String category,
    required DateTime publishedAt,
    required String readTime,
    bool isHighlighted = false,
    String intro = "",
    String content = "",
  }) {
    final now = DateTime.now();
    return Article(
      id: id,
      title: title,
      intro: intro,
      content: content,
      imageUrl: imageUrl,
      category: category,
      categoryName: category,
      publishedAt: publishedAt,
      readTime: readTime,
      isHighlighted: isHighlighted,
      status: "published",
      createdByName: "System",
      createdByAlias: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  get image => null;

  static String _calculateReadTime(String content) {
    final wordCount = content.split(' ').length;
    final readTimeMinutes = (wordCount / 200).ceil(); // Average reading speed
    return '$readTimeMinutes min';
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": title,
    "intro": intro,
    "content": content,
    "image": imageUrl,
    "category_name": categoryName,
    "status": status,
    "created_by_name": createdByName,
    "created_by_alias": createdByAlias,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  String toJson() => json.encode(toMap());
}
