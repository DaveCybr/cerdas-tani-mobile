import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/calculator_page.dart';
import 'package:fertilizer_calculator/presentation/home/pages/home_page.dart';
import 'package:fertilizer_calculator/presentation/user/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const UserPage(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.card
            : Colors.white,
        option: DotBarOptions(
          dotStyle: DotStyle.tile,
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            selectedColor: AppColors.lightgreen,
            unSelectedColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.light
                : AppColors.card,
            title: const Text(
              'Home',
              style: TextStyle(fontSize: 13),
            ),
          ),
          BottomBarItem(
            icon: const Icon(Icons.person),
            selectedColor: AppColors.lightgreen,
            unSelectedColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.light
                : AppColors.card,
            title: const Text('User'),
          ),
        ],
        hasNotch: true,
        currentIndex: _selectedIndex,
        notchStyle: NotchStyle.circle,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalculatorPage()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.darkgreen,
        elevation: 5,
        child: SvgPicture.asset(
          Assets.icons.calculator.path,
          colorFilter: const ColorFilter.mode(AppColors.light, BlendMode.srcIn),
          height: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
