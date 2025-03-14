import 'dart:convert';

class ArticleResponseModel {
  final List<Article> data;

  ArticleResponseModel({required this.data});

  factory ArticleResponseModel.fromJson(String str) =>
      ArticleResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ArticleResponseModel.fromMap(Map<String, dynamic> json) {
    return ArticleResponseModel(
      data: json["data"] != null
          ? List<Article>.from(json["data"].map((x) => Article.fromMap(x)))
          : [], // Jika data kosong, return List kosong
    );
  }

  Map<String, dynamic> toMap() => {
        "data": data.map((x) => x.toMap()).toList(),
      };
}

class Article {
  final int id;
  final String name;
  final String intro;
  final String content;
  final String type;
  final String? categoryName;
  final String? image;
  final String? metaOgImage;
  final String status;
  final String createdByName;
  final String? createdByAlias;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.name,
    required this.intro,
    required this.content,
    required this.type,
    this.categoryName,
    this.image,
    this.metaOgImage,
    required this.status,
    required this.createdByName,
    this.createdByAlias,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(String str) => Article.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Article.fromMap(Map<String, dynamic> json) {
    return Article(
      id: json["id"],
      name: json["name"] ?? "Tanpa Judul",
      intro: json["intro"] ?? "",
      content: json["content"] ?? "",
      type: json["type"] ?? "unknown",
      categoryName: json["category_name"],
      image: json["image"],
      metaOgImage: json["meta_og_image"],
      status: json["status"] ?? "unknown",
      createdByName: json["created_by_name"] ?? "unknown",
      createdByAlias: json["created_by_alias"],
      createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "intro": intro,
        "content": content,
        "type": type,
        "category_name": categoryName,
        "image": image,
        "meta_og_image": metaOgImage,
        "status": status,
        "created_by_name": createdByName,
        "created_by_alias": createdByAlias,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
