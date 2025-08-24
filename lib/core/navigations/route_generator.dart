// core/navigations/route_generator.dart - UPDATED with MainNavigationWrapper
// import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/articles/screens/article_list.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/articles/models/article_model.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/chats/screens/chat_screen.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/nutrients/screens/nutrient_screen.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/recipes/screens/recipe_screens.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/weathers/screens/forecast_weather_screen.dart';
import 'package:flutter/material.dart';
import '../../presentation/auth/screens/forgot_password_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/calculator/screens/result_screen.dart';
import '../../presentation/dashboard/articles/screens/article_detail.dart';
import '../../presentation/error/screens/not_found_screen.dart';
// import '../../presentation/dashboard/home/screens/home_screen.dart';
import 'app_route.dart';
import 'main_navigation_wrapper.dart';
import 'page_transitions.dart';
import 'route_middleware.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Module Routes - Guest Only (redirect if authenticated)
      case AppRoutes.login:
        return RouteMiddleware.guestOnly(
          PageTransitions.slideFromBottom(const LoginScreen(), settings),
        );

      case AppRoutes.register:
        return RouteMiddleware.guestOnly(
          PageTransitions.slideFromRight(const RegisterScreen(), settings),
        );

      case AppRoutes.forgotPassword:
        return RouteMiddleware.guestOnly(
          PageTransitions.slideFromRight(
            const ForgotPasswordScreen(),
            settings,
          ),
        );

      // Main Navigation Routes - Menggunakan MainNavigationWrapper
      case AppRoutes.home:
        return RouteMiddleware.requireAuth(
          PageTransitions.fadeTransition(
            const MainNavigationWrapper(initialIndex: 0),
            settings,
          ),
        );

      case AppRoutes.articles:
        return RouteMiddleware.requireAuth(
          PageTransitions.fadeTransition(
            const MainNavigationWrapper(initialIndex: 1),
            settings,
          ),
        );

      // Jika ada route untuk calculator di main nav
      case '/main/calculator':
        return RouteMiddleware.requireAuth(
          PageTransitions.fadeTransition(
            const MainNavigationWrapper(initialIndex: 2),
            settings,
          ),
        );

      // Jika ada route untuk profile di main nav
      case '/main/profile':
        return RouteMiddleware.requireAuth(
          PageTransitions.fadeTransition(
            const MainNavigationWrapper(initialIndex: 3),
            settings,
          ),
        );

      case AppRoutes.chat:
        return RouteMiddleware.requireAuth(
          PageTransitions.fadeTransition(const ChatbotScreen(), settings),
        );

      // // Secondary Pages - Tidak menggunakan MainNavigationWrapper
      // case AppRoutes.nutrientCalculator:
      //   return RouteMiddleware.requireAuth(
      //     PageTransitions.slideFromRight(const CalculatorScreen(), settings),
      //   );

      case AppRoutes.nutrientCalculatorResult:
        return RouteMiddleware.requireAuth(
          PageTransitions.slideFromRight(const ResultScreen(), settings),
        );

      case AppRoutes.weathers:
        return RouteMiddleware.requireAuth(
          PageTransitions.slideFromRight(
            const WeatherForecastScreen(),
            settings,
          ),
        );

      case AppRoutes.nutrient:
        return RouteMiddleware.requireAuth(
          PageTransitions.slideFromRight(const NutrientListScreen(), settings),
        );

      case AppRoutes.recipe:
        return RouteMiddleware.requireAuth(
          PageTransitions.slideFromRight(const RecipeScreen(), settings),
        );

      // Article Detail - Secondary page dengan back button
      case '/article/detail':
        final article = settings.arguments as Article?;
        if (article != null) {
          return RouteMiddleware.requireAuth(
            PageTransitions.slideFromRight(
              ArticleDetailPage(article: article),
              settings,
            ),
          );
        } else {
          // Handle error case when no article is passed
          return PageTransitions.slideFromRight(
            ErrorPage(
              routeName: settings.name,
              errorMessage: 'Article data not found',
            ),
            settings,
          );
        }

      // // Profile related pages - Secondary pages
      // case '/profile/edit':
      //   return RouteMiddleware.requireAuth(
      //     PageTransitions.slideFromRight(const EditProfilePage(), settings),
      //   );

      // case '/profile/settings':
      //   return RouteMiddleware.requireAuth(
      //     PageTransitions.slideFromRight(const SettingsPage(), settings),
      //   );

      // Error handling
      default:
        return PageTransitions.slideFromRight(
          ErrorPage(routeName: settings.name),
          settings,
        );
    }
  }
}
