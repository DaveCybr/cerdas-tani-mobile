import 'dart:async';

import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/presentation/home/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double opacity = 0.0;
  @override
  void initState() {
    super.initState();

    // Animasi fade-in logo
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1.0;
      });
    });

    // Navigasi setelah 3 detik
    Future.delayed(const Duration(seconds: 3)).then((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacity,
          curve: Curves.easeInOut,
          child: Image.asset(
            Assets.images.logo.path,
            width: 350,
            height: 350,
          ),
        ),
      ),
    );
  }
}
