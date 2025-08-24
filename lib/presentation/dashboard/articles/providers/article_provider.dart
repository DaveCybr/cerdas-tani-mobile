// article_provider.dart - Updated provider
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../models/article_response.dart';

class ArticleProvider with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  // Get featured articles (limited)
  List<Article> get featuredArticles => _articles.take(3).toList();

  Future<void> getArticles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _dio.get(
        'http://sirangga.satelliteorbit.cloud/api/posts',
      );

      print("Response Status: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          // If response has a 'data' key
          final articleResponse = ArticleResponseModel.fromMap(response.data);
          _articles = articleResponse.data;
        } else if (response.data is List) {
          // If response is directly a list
          _articles = List<Article>.from(
            response.data.map((x) => Article.fromMap(x)),
          );
        } else {
          throw Exception('Unexpected response format');
        }

        print("Parsed Articles: ${_articles.length} artikel ditemukan");
      } else {
        _errorMessage = response.statusMessage ?? 'Terdapat kesalahan';
        print("Error Status: $_errorMessage");
      }
    } catch (e, stacktrace) {
      _errorMessage = 'Gagal mengambil data: ${e.toString()}';
      print('Error: $e');
      print('Stacktrace: $stacktrace');

      // Fallback to mock data for development
      _articles = _getMockArticles();
      print("Using mock data: ${_articles.length} articles");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Article?> fetchArticleById(String articleId) async {
    try {
      final response = await _dio.get(
        'http://sirangga.satelliteorbit.cloud/api/posts/$articleId',
      );

      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final article = Article.fromMap(response.data);
        print("Fetched Article: ${article.title}");
        return article;
      } else {
        print("Error fetching article: ${response.statusMessage}");
        return null;
      }
    } catch (e, stacktrace) {
      print('Error: $e');
      print('Stacktrace: $stacktrace');
      return null;
    }
  }

  List<Article> searchArticles(String query) {
    if (query.isEmpty) return _articles;

    return _articles
        .where(
          (article) =>
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              article.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Mock data for development/fallback
  List<Article> _getMockArticles() {
    return [
      Article.fromLocal(
        id: '1',
        title:
            'Pupuk Tunggal vs Pupuk Majemuk: Mana yang Tepat untuk Tanaman Kita?',
        imageUrl: 'https://example.com/fertilizer-image.jpg',
        category: 'PEMUPUKAN',
        publishedAt: DateTime.now().subtract(Duration(days: 2)),
        readTime: '5 min',
        isHighlighted: true,
        intro:
            'Memahami perbedaan antara pupuk tunggal dan majemuk untuk hasil optimal.',
        content:
            'Dalam dunia pertanian, pemilihan jenis pupuk yang tepat sangat penting...',
      ),
      Article.fromLocal(
        id: '2',
        title: 'Pemupukan Awal Hingga Generatif',
        imageUrl: 'https://example.com/plant-care.jpg',
        category: 'PELAJARAN GPS 185',
        publishedAt: DateTime.now().subtract(Duration(days: 3)),
        readTime: '7 min',
        isHighlighted: true,
        intro: 'Panduan lengkap pemupukan dari fase awal hingga generatif.',
        content:
            'Setiap fase pertumbuhan tanaman membutuhkan nutrisi yang berbeda...',
      ),
      Article.fromLocal(
        id: '3',
        title: 'Cara Menentukan Dosis Pupuk yang Tepat untuk Tanaman Sayuran',
        imageUrl: 'https://example.com/vegetable.jpg',
        category: 'TIPS & TRIK',
        publishedAt: DateTime.now().subtract(Duration(days: 5)),
        readTime: '4 min',
        isHighlighted: false,
        intro:
            'Tips praktis menentukan dosis pupuk yang optimal untuk sayuran.',
        content:
            'Dosis pupuk yang tepat adalah kunci keberhasilan budidaya sayuran...',
      ),
      Article.fromLocal(
        id: '4',
        title: 'Mengenal Jenis-Jenis Pupuk Organik dan Cara Penggunaannya',
        imageUrl: 'https://example.com/organic.jpg',
        category: 'PEMUPUKAN',
        publishedAt: DateTime.now().subtract(Duration(days: 7)),
        readTime: '6 min',
        isHighlighted: false,
        intro: 'Eksplorasi berbagai jenis pupuk organik dan aplikasinya.',
        content:
            'Pupuk organik menjadi pilihan utama untuk pertanian berkelanjutan...',
      ),
      Article.fromLocal(
        id: '5',
        title: 'Waktu Terbaik untuk Melakukan Pemupukan pada Tanaman Padi',
        imageUrl: 'https://example.com/rice.jpg',
        category: 'PERAWATAN',
        publishedAt: DateTime.now().subtract(Duration(days: 10)),
        readTime: '5 min',
        isHighlighted: false,
        intro: 'Mengetahui timing yang tepat untuk pemupukan padi.',
        content: 'Timing pemupukan padi sangat mempengaruhi hasil panen...',
      ),
    ];
  }
}
