import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol kembali & Judul
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(52, 31, 204, 120),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.primary),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  // const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),

              // Input Pencarian
              Text(
                "Artikel",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari artikel...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 20),

              // Daftar Artikel
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
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];

                        return InkWell(
                          onTap: () => context
                              .push(DetailArticlePage(artikelId: article.id)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar Artikel
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: Image.network(
                                    article.image ??
                                        'https://via.placeholder.com/300x120',
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    article.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 15,
                                        ),
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
