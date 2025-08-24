// Update app_route.dart untuk menambahkan routes baru
class AppRoutes {
  // Root routes
  static const String initial = '/';
  static const String splash = '/splash';

  // Auth module routes
  static const String authWrapper = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String emailVerify = '/auth/email-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Main Navigation Routes (dengan persistent bottom nav)
  static const String home = '/home';
  static const String articles = '/home/articles';
  static const String mainCalculator = '/main/calculator';
  static const String mainProfile = '/main/profile';

  // Secondary Routes (tanpa persistent bottom nav)
  static const String dashboard = '/home/dashboard';
  static const String weathers = '/home/weather';
  static const String nutrient = '/home/nutrient';
  static const String recipe = '/home/recipe';
  static const String nutrientCalculator = '/home/nutrient/calculator';
  static const String nutrientCalculatorResult =
      '/home/nutrient/calculator/result';
  static const String articleDetail = '/article/detail';
  static const String chat = '/chat'; // New chat route

  // Profile module routes (secondary)
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String changePassword = '/profile/change-password';

  // Feature specific routes
  static const String onboarding = '/onboarding';
  static const String notifications = '/notifications';

  // Helper methods
  static bool isMainNavigationRoute(String? routeName) {
    return [home, articles, mainCalculator, mainProfile].contains(routeName);
  }

  static bool isSecondaryRoute(String? routeName) {
    return [
      nutrientCalculator,
      nutrientCalculatorResult,
      articleDetail,
      editProfile,
      settings,
      weathers,
      nutrient,
      recipe,
    ].contains(routeName);
  }
}
