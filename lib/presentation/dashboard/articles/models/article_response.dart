// article_response.dart - Response model
import 'dart:convert';

import 'article_model.dart';

class ArticleResponseModel {
  final List<Article> data;

  ArticleResponseModel({required this.data});

  factory ArticleResponseModel.fromJson(String str) =>
      ArticleResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ArticleResponseModel.fromMap(Map<String, dynamic> json) {
    return ArticleResponseModel(
      data:
          json["data"] != null
              ? List<Article>.from(json["data"].map((x) => Article.fromMap(x)))
              : [],
    );
  }

  Map<String, dynamic> toMap() => {"data": data.map((x) => x.toMap()).toList()};
}
