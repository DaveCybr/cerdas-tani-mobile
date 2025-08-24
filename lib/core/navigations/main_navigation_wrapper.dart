// main_navigation_wrapper.dart - Persistent bottom navigation
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/navigations/widgets/navbar.dart';
import '../../presentation/calculator/screens/calculate_screen.dart';
import '../../presentation/dashboard/articles/screens/article_list.dart';
import '../../presentation/dashboard/home/screens/home_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const MainNavigationWrapper({Key? key, this.initialIndex = 0})
    : super(key: key);

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeScreenContent(), // Content only, without bottom nav
          ArticlePageContent(), // Content only, without bottom nav
          CalculatorScreenContent(), // Content only
          ProfileScreen(), // Content only
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: _getBottomNavItems(),
      ),
    );
  }

  List<BottomNavItem> _getBottomNavItems() {
    return [
      BottomNavItem(icon: Icons.home_rounded, label: 'Beranda'),
      BottomNavItem(icon: Icons.article_rounded, label: 'Artikel'),
      BottomNavItem(icon: Icons.calculate_rounded, label: 'Kalkulator'),
      BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
    ];
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
