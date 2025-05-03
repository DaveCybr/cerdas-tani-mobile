import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/calculator_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/fertilizer_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/recipe_page.dart';
import 'package:fertilizer_calculator/presentation/history/pages/history_page.dart';
import 'package:fertilizer_calculator/presentation/home/pages/all_articles.dart';
import 'package:fertilizer_calculator/presentation/home/pages/detail_article_page.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final articleProvider = context.read<ArticleProvider>();
      await articleProvider.getArticle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.04,
                bottom: MediaQuery.of(context).padding.bottom + 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.grey[300],
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child:
                                        Image.asset(Assets.images.farmer.path),
                                  ))),
                          const SpaceWidth(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selamat Datang Kembali',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${GetStorage().read('google_account_name')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.light
                                      : AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SpaceHeight(20),
                  InkWell(
                    onTap: () => context.push(const CalculatorPage()),
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.card
                              : Colors.white,
                          borderRadius: BorderRadius.circular(11)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            'Kalkulator\nHara',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            Assets.images.calculator.path,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SpaceHeight(15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push(const RecipePage()),
                          child: Container(
                            height: 180,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.card
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(11)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  'Tanaman',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SpaceHeight(5),
                                Image.asset(
                                  Assets.images.plant.path,
                                  height: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SpaceWidth(20),
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push(const FertilizerPage()),
                          child: Container(
                            height: 180,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.card
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(11)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  'Pupuk',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SpaceHeight(5),
                                Image.asset(
                                  Assets.images.fertilizer.path,
                                  height: 100,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(15),
                  InkWell(
                    onTap: () => context.push(const HistoryPage()),
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.card
                              : Colors.white,
                          borderRadius: BorderRadius.circular(11)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            'Riwayat\nKalkulator',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            Assets.images.history.path,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SpaceHeight(15),
                  Row(
                    children: [
                      const Text(
                        'Artikel Terbaru',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AllArticlesScreen()));
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(10),
                  SizedBox(
                    height: 210,
                    child: Consumer<ArticleProvider>(
                      builder: (context, articleProvider, child) {
                        if (articleProvider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (articleProvider.articles.isEmpty) {
                          return const Center(
                              child: Text("Tidak ada artikel tersedia"));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: articleProvider.articles.length,
                          itemBuilder: (context, index) {
                            final article = articleProvider.articles[index];

                            return GestureDetector(
                              onTap: () => context.push(
                                  DetailArticlePage(artikelId: article.id)),
                              child: Container(
                                width: 300,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.card
                                      : Colors.white,
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
                                        image: DecorationImage(
                                          image: NetworkImage(article.image ??
                                              'https://via.placeholder.com/300x120'), // Gambar artikel
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(9.0),
                                      child: Text(
                                        article.name, // Judul artikel
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
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
                  SizedBox(
                    height: 210,
                    child: Consumer<ArticleProvider>(
                      builder: (context, articleProvider, child) {
                        if (articleProvider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (articleProvider.articles.isEmpty) {
                          return const Center(
                              child: Text("Tidak ada artikel tersedia"));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: articleProvider.articles.length,
                          itemBuilder: (context, index) {
                            final article = articleProvider.articles[index];

                            return GestureDetector(
                              onTap: () => context.push(
                                  DetailArticlePage(artikelId: article.id)),
                              child: Container(
                                width: 300,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.card
                                      : Colors.white,
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
                                        image: DecorationImage(
                                          image: NetworkImage(article.image ??
                                              'https://via.placeholder.com/300x120'), // Gambar artikel
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(9.0),
                                      child: Text(
                                        article.name, // Judul artikel
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
