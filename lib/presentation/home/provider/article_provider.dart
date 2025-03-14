import 'package:dio/dio.dart';
import 'package:fertilizer_calculator/presentation/home/models/article_response.dart';
import 'package:flutter/material.dart';

class ArticleProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    contentType: 'application/json',
  ));
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = 'Terjadi kesalahan';
  String get errorMessage => _errorMessage;

  List<Article> _article = [];
  List<Article> get articles => _article;
  // List<Article> get articles => _article.reversed.take(10).toList();

  Future<void> getArticle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _dio.get('http://sirangga.satelliteorbit.cloud/api/posts');
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final articleResponse = ArticleResponseModel.fromMap(response.data);
        _article = articleResponse.data;
        _isLoading = false;
        print("Parsed Articles: ${_article.length} artikel ditemukan");
        notifyListeners();
      } else {
        _errorMessage = response.statusMessage ?? 'Terdapat kesalahan';
        _isLoading = false;
        print("Else Condition: $_errorMessage");
        notifyListeners();
      }
    } catch (e, stacktrace) {
      _errorMessage = 'Gagal mengambil data: ${e.toString()}';
      _isLoading = false;
      print('Error: $e');
      print('Stacktrace: $stacktrace'); // Debugging Stacktrace
      notifyListeners();
    }
  }

  Future<Article?> fetchArticle(int articleId) async {
    try {
      final response = await _dio.get(
        'http://sirangga.satelliteorbit.cloud/api/posts?id=$articleId',
      );
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final article = Article.fromMap(response.data);
        print("Fetched Article: ${article.name}");
        return article;
      } else {
        _errorMessage = response.statusMessage ?? 'Terdapat kesalahan';
        print("Else Condition: $_errorMessage");
        return null;
      }
    } catch (e, stacktrace) {
      print('Error: $e');
      print('Stacktrace: $stacktrace'); // Debugging Stacktrace
      return null;
    }
  }
}
