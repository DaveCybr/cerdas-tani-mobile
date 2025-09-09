// presentation/dashboard/home/screens/home_screen.dart - Updated with Module Section
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/navigations/app_navigator.dart';
import '../../articles/providers/article_provider.dart';
import '../../articles/screens/article_section.dart';

import '../../chats/screens/chat_screen.dart';
import '../../modules/providers/module_provider.dart';
import '../../modules/screens/module_section.dart';
import '../../modules/screens/module_detail.dart';
import '../widgets/calculator_card.dart';
import '../widgets/feature_grid.dart';
import '../widgets/feature_item.dart';
import '../widgets/header.dart';
import '../widgets/weather_card.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize article provider
      Provider.of<ArticleProvider>(context, listen: false).getArticles();
      // Initialize module provider
      Provider.of<ModuleProvider>(context, listen: false).loadModules();
    });
  }

  void _onModuleTap(module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleDetailScreen(module: module),
      ),
    );
  }

  void _onModuleDownload(module) async {
    final provider = Provider.of<ModuleProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Downloading...'),
              ],
            ),
          ),
    );

    final success = await provider.downloadModuleAttachment(module) != null;

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Module downloaded successfully' : 'Download failed',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      HomeHeader(),
                      const SizedBox(height: 20),

                      // Calculator Card
                      CalculatorCard(
                        onTap: () {
                          AppNavigator.push('/main/calculator');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Weather Card
                      WeatherCard(
                        onViewPressed: () {
                          print('Weather view tapped');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Feature Grid
                      FeatureGrid(features: _getFeatureItems()),
                      const SizedBox(height: 20),

                      // Article Section with provider integration
                      ArticleSection(
                        articles: context.watch<ArticleProvider>().articles,
                        onSeeAllPressed: () {
                          AppNavigator.push('/home/articles');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Module Section with provider integration
                      Consumer<ModuleProvider>(
                        builder: (context, moduleProvider, child) {
                          return ModuleSection(
                            modules: moduleProvider.modules,
                            onSeeAllPressed: () {
                              AppNavigator.push('/home/modules');
                            },
                            onModuleTap: _onModuleTap,
                            onModuleDownload: _onModuleDownload,
                          );
                        },
                      ),

                      // Extra space for bottom nav
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Enhanced Floating Action Button for Chatbot
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 22,
          ),
          label: const Text(
            'GrowBot',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<FeatureItem> _getFeatureItems() {
    return [
      FeatureItem(
        title: 'Program\nPemupukan',
        icon: Icons.eco,
        iconColor: AppColors.secondary,
        onTap: () => AppNavigator.push('/home/recipe'),
      ),
      FeatureItem(
        title: 'Data\nPupuk',
        icon: Icons.agriculture,
        iconColor: AppColors.primary,
        onTap: () => AppNavigator.push('/home/nutrient'),
      ),
    ];
  }
}
