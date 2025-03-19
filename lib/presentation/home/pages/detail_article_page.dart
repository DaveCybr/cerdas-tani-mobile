import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fertilizer_calculator/presentation/home/models/article_response.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
import 'package:provider/provider.dart';

class DetailArticlePage extends StatefulWidget {
  final int artikelId;
  const DetailArticlePage({super.key, required this.artikelId});

  @override
  _DetailArticlePageState createState() => _DetailArticlePageState();
}

class _DetailArticlePageState extends State<DetailArticlePage> {
  Article? _article;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    final articleProvider = context.read<ArticleProvider>();
    final article = await articleProvider.fetchArticle(widget.artikelId);

    setState(() {
      _article = article;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_article?.name ?? 'Artikel'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _article == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _article!.name,
                          style: textTheme.headlineLarge, // Gaya H1
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _article!.image ??
                                'https://via.placeholder.com/300x150',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 100),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _article!.intro,
                          style: textTheme.bodyMedium, // Gaya P2
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                        HtmlWidget(
                          _article!.content,
                          textStyle: textTheme.bodyMedium, // Gaya P1
                          customStylesBuilder: (element) {
                            return {
                              'p': 'margin-bottom: 16px; text-align: justify;',
                              'h1': 'font-size: 24px; font-weight: bold;',
                              'h2': 'font-size: 20px; font-weight: bold;',
                              'h3': 'font-size: 18px; font-weight: bold;',
                            };
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            "Artikel tidak ditemukan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Kembali"),
          ),
        ],
      ),
    );
  }
}
