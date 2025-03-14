import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/home/pages/detail_article_page.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllArticlesScreen extends StatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  _AllArticlesScreenState createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Artikel",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari artikel...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<ArticleProvider>(
                  builder: (context, articleProvider, child) {
                    if (articleProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredArticles =
                        articleProvider.articles.where((article) {
                      return article.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredArticles.isEmpty) {
                      return const Center(
                          child: Text("Tidak ada artikel tersedia"));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];

                        return InkWell(
                          onTap: () => context
                              .push(DetailArticlePage(artikelId: article.id)),
                          child: Container(
                            margin:
                                const EdgeInsets.only(right: 15, bottom: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.card
                                  : Colors.white,
                              border: Border.all(
                                  color: Colors.grey.withOpacity(.5), width: 2),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      topRight: Radius.circular(11),
                                    ),
                                    color: Colors.green[200],
                                    image: DecorationImage(
                                      image: NetworkImage(article.image ??
                                          'https://via.placeholder.com/300x120'), // Gambar artikel
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    article.name, // Judul artikel
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 3,
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
