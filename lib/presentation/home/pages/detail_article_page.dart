import 'package:fertilizer_calculator/presentation/home/models/article_response.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _article == null
              ? const Center(child: Text("Artikel tidak ditemukan"))
              : SingleChildScrollView(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.04),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _article!.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _article!.image ??
                                'https://via.placeholder.com/300x120',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 100),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _article!.intro,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10),
                        HtmlWidget(
                          _article!.content,
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                          customStylesBuilder: (element) {
                            return {
                              'text-align': 'justify',
                            };
                          },
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
