// core/navigation/app_navigator.dart - UPDATED with MainNavigationWrapper support
import 'package:flutter/material.dart';
import 'app_route.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get _navigator => navigatorKey.currentState;
  static BuildContext? get context => _navigator?.context;

  // Base navigation methods
  static Future<T?> push<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return _navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return _navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return _navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return _navigator!.pop<T>(result);
  }

  static void popUntil(String routeName) {
    return _navigator!.popUntil(ModalRoute.withName(routeName));
  }

  static bool canPop() {
    return _navigator!.canPop();
  }

  // Auth-specific navigation methods
  static Future<void> toLogin({bool clearStack = false}) {
    if (clearStack) {
      return pushAndClearStack(AppRoutes.login);
    }
    return pushReplacement(AppRoutes.login);
  }

  static Future<void> toRegister() {
    return push(AppRoutes.register);
  }

  static Future<void> toHome({bool clearStack = true}) {
    if (clearStack) {
      return pushAndClearStack(AppRoutes.home);
    }
    return pushReplacement(AppRoutes.home);
  }

  static Future<void> toForgotPassword() {
    return push(AppRoutes.forgotPassword);
  }

  // Main Navigation methods - untuk persistent bottom nav
  static Future<void> toMainNavigation({
    int initialIndex = 0,
    bool clearStack = false,
  }) {
    final route = _getMainNavigationRoute(initialIndex);
    if (clearStack) {
      return pushAndClearStack(route);
    }
    return pushReplacement(route);
  }

  static String _getMainNavigationRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.home;
      case 1:
        return AppRoutes.articles;
      case 2:
        return AppRoutes.mainCalculator;
      case 3:
        return AppRoutes.mainProfile;
      default:
        return AppRoutes.home;
    }
  }

  // Quick navigation to main tabs
  static Future<void> toHomeTab() => toMainNavigation(initialIndex: 0);
  static Future<void> toArticlesTab() => toMainNavigation(initialIndex: 1);
  static Future<void> toCalculatorTab() => toMainNavigation(initialIndex: 2);
  static Future<void> toProfileTab() => toMainNavigation(initialIndex: 3);

  // Secondary page navigation - untuk halaman dengan back button
  static Future<void> toSecondaryPage(String routeName, {Object? arguments}) {
    return push(routeName, arguments: arguments);
  }

  // Specific secondary pages
  static Future<void> toArticleDetail(dynamic article) {
    return toSecondaryPage('/article/detail', arguments: article);
  }

  static Future<void> toNutrientCalculator() {
    return toSecondaryPage(AppRoutes.nutrientCalculator);
  }

  static Future<void> toCalculatorResult(dynamic result) {
    return toSecondaryPage(
      AppRoutes.nutrientCalculatorResult,
      arguments: result,
    );
  }

  static Future<void> toWeatherForecast() {
    return toSecondaryPage(AppRoutes.weathers);
  }

  static Future<void> toNutrientList() {
    return toSecondaryPage(AppRoutes.nutrient);
  }

  static Future<void> toRecipeList() {
    return toSecondaryPage(AppRoutes.recipe);
  }

  static Future<void> toSettings() {
    return toSecondaryPage('/profile/settings');
  }

  static Future<void> toEditProfile() {
    return toSecondaryPage('/profile/edit');
  }

  // SIMPLIFIED: Direct navigation to home after login/register
  static Future<void> handleSuccessfulLogin({
    bool? isEmailVerified,
    String? email,
  }) {
    debugPrint('Handling successful login - navigating to home');
    return toHome();
  }

  static Future<void> handleSuccessfulRegistration({required String email}) {
    debugPrint('Handling successful registration - navigating to home');
    return toHome();
  }

  static Future<void> handleLogout() {
    return toLogin(clearStack: true);
  }

  // Navigation helpers for widgets
  static void popToMainNavigation() {
    // Pop until we reach a main navigation route
    _navigator!.popUntil((route) {
      return AppRoutes.isMainNavigationRoute(route.settings.name);
    });
  }

  static void popToHome() {
    _navigator!.popUntil((route) {
      return route.settings.name == AppRoutes.home;
    });
  }

  // Utility methods
  static String? getCurrentRoute() {
    String? currentRoute;
    _navigator!.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    return currentRoute;
  }

  static bool isCurrentRoute(String routeName) {
    return getCurrentRoute() == routeName;
  }

  static bool isMainNavigationActive() {
    final currentRoute = getCurrentRoute();
    return AppRoutes.isMainNavigationRoute(currentRoute);
  }

  // Snackbar helper
  static void showSnackBar({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context!);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
