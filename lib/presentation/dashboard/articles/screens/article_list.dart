// article_page.dart - Updated with provider integration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../models/article_model.dart';
import '../widgets/article_card.dart';
import '../providers/article_provider.dart';

class ArticlePageContent extends StatefulWidget {
  const ArticlePageContent({Key? key}) : super(key: key);

  @override
  State<ArticlePageContent> createState() => _ArticlePageContentState();
}

class _ArticlePageContentState extends State<ArticlePageContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Article> _filteredArticles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadArticles() async {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    await provider.getArticles();
    _filterArticles(_searchController.text);
  }

  void _filterArticles(String query) {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    setState(() {
      _filteredArticles = provider.searchArticles(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Page Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Artikel',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      controller: _searchController,
                      onChanged: _filterArticles,
                      decoration: InputDecoration(
                        hintText: 'Cari artikel...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        hintStyle: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Articles List
            Expanded(
              child: Consumer<ArticleProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (provider.errorMessage.isNotEmpty &&
                      _filteredArticles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            provider.errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadArticles,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredArticles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada artikel ditemukan',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredArticles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ArticleCard(
                          article: _filteredArticles[index],
                          onTap:
                              () => _navigateToArticleDetail(
                                _filteredArticles[index],
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToArticleDetail(Article article) {
    // Navigate to article detail page
    Navigator.pushNamed(context, '/article/detail', arguments: article);
    print('Navigate to article: ${article.title}');
  }
}
