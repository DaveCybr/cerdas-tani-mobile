import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/calculator_page.dart';
import 'package:fertilizer_calculator/presentation/home/pages/all_articles.dart';
import 'package:fertilizer_calculator/presentation/home/pages/components/header.dart';
import 'package:fertilizer_calculator/presentation/home/pages/components/menu_card.dart';
import 'package:fertilizer_calculator/presentation/home/pages/components/nutrition_calculator_card.dart';
import 'package:fertilizer_calculator/presentation/home/pages/components/wheather_card.dart';
import 'package:fertilizer_calculator/presentation/home/pages/detail_article_page.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
// import 'package:fertilizer_calculator/presentation/home/pages/home_page.dart';
import 'package:fertilizer_calculator/presentation/user/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
// import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final articleProvider = context.read<ArticleProvider>();
      await articleProvider.getArticle();
    });
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const CalculatorPage(),
    const UserPage(),
  ];
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut, // Efek transisi smooth
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // Efek bouncing saat di swipe
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ), // Menampilkan halaman sesuai index

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // Warna navbar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Warna shadow
              blurRadius: 10, // Efek blur
              spreadRadius: 2, // Sebaran shadow
              offset: Offset(0, -2), // Posisi shadow ke atas
            ),
          ],
        ),
        child: CurvedNavigationBar(
          backgroundColor: Colors
              .transparent, // Background transparan agar menyatu dengan UI
          color: Colors.white, // Warna navbar putih
          buttonBackgroundColor:
              Color(0xFF1FCC79), // Warna latar ikon aktif hijau
          animationDuration: Duration(milliseconds: 300),
          height: 60,
          index: _selectedIndex,

          items: [
            Icon(Icons.home,
                size: 30,
                color: _selectedIndex == 0
                    ? Colors.white
                    : Color(0xFFA0A0A0)), // Ikon home
            Icon(Icons.calculate,
                size: 30,
                color: _selectedIndex == 1
                    ? Colors.white
                    : Color(0xFFA0A0A0)), // Ikon user
            Icon(Icons.person,
                size: 30,
                color: _selectedIndex == 2
                    ? Colors.white
                    : Color(0xFFA0A0A0)), // Ikon user
          ],

          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  static const Color primary = Color(0xFF1FCC79);
  static const Color bgcard = Color.fromARGB(255, 236, 248, 242);

  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => context.push(const CalculatorPage()),
            child: NutritionCalculatorCard(),
          ),
          const SizedBox(height: 20),
          WeatherCard(),
          const SizedBox(height: 20),
          // Daftar card dalam bentuk grid responsif
          MenuCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Artikel Terbaru',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: screenWidth * 0.05,
                    ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AllArticlesScreen()));
                },
                child: Text(
                  'Lihat Semua',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: screenWidth * 0.04,
                      ),
                ),
              ),
            ],
          ),
          const SpaceHeight(10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.36,
            child: Consumer<ArticleProvider>(
              builder: (context, articleProvider, child) {
                if (articleProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                      onTap: () => context
                          .push(DetailArticlePage(artikelId: article.id)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.only(
                            left: 5, right: 20, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.card
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
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
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Image.network(
                                article.image ??
                                    'https://via.placeholder.com/300x120',
                                width: double.infinity,
                                height: 150,
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
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 20)
        ],
      ),
    ));
  }
}
