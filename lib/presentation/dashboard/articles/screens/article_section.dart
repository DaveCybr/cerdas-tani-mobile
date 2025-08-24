// article_section.dart - For home screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../models/article_model.dart';
import '../widgets/article_card.dart';
import '../providers/article_provider.dart';

class ArticleSection extends StatelessWidget {
  final List<Article> articles;
  final VoidCallback onSeeAllPressed;

  const ArticleSection({
    Key? key,
    required this.articles,
    required this.onSeeAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Artikel Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Articles List
        Consumer<ArticleProvider>(
          builder: (context, provider, child) {
            final displayArticles =
                provider.isLoading ? articles : provider.featuredArticles;

            if (provider.isLoading) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            return Column(
              children:
                  displayArticles.map((article) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ArticleCard(
                        article: article,
                        onTap: () => _navigateToArticleDetail(context, article),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _navigateToArticleDetail(BuildContext context, Article article) {
    Navigator.pushNamed(context, '/article/detail', arguments: article);
    print('Navigate to article: ${article.title}');
  }
}
