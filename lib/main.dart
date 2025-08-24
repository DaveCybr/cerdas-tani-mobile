// main.dart - UPDATED WITH CHATBOT PROVIDER
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/nutrients/providers/nutrient_provider.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/recipes/providers/recipe_provider.dart';
import 'package:fertilizer_calculator_mobile_v2/presentation/dashboard/weathers/providers/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/navigations/app_navigator.dart';
import 'core/navigations/route_generator.dart';
import 'core/theme/provider/theme_provider.dart';
import 'presentation/auth/providers/auth_provider.dart';
import 'presentation/dashboard/articles/providers/article_provider.dart';
import 'presentation/dashboard/chats/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // Icon gelap
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Create providers
  final authProvider = AuthProvider();
  final weatherProvider = WeatherProvider();
  final recipeProvider = RecipeProvider();
  final nutrientProvider = NutrientProvider();
  final articleProvider = ArticleProvider();
  final chatbotProvider = ChatbotProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: weatherProvider),
        ChangeNotifierProvider.value(value: recipeProvider),
        ChangeNotifierProvider.value(value: nutrientProvider),
        ChangeNotifierProvider.value(value: articleProvider),
        ChangeNotifierProvider.value(value: chatbotProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Cerdas Tani App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          navigatorKey: AppNavigator.navigatorKey,
          home: const AuthWrapper(),
          onGenerateRoute: RouteGenerator.generateRoute,
        );
      },
    );
  }
}

// CLEAN AuthWrapper - No email verification logic
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasCheckedInitialState = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
  }

  Future<void> _checkInitialAuthState() async {
    if (_hasCheckedInitialState) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatbotProvider = Provider.of<ChatbotProvider>(
      context,
      listen: false,
    );
    debugPrint('AuthWrapper: Checking initial auth state...');

    await authProvider.checkInitialAuthState();

    // Set user ID for chatbot if authenticated
    if (authProvider.isAuthenticated && authProvider.user != null) {
      chatbotProvider.setUserId(authProvider.user!.uid, authProvider.user!.uid);
    }

    if (mounted) {
      setState(() {
        _hasCheckedInitialState = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint(
          'AuthWrapper build - Status: ${authProvider.status}, Authenticated: ${authProvider.isAuthenticated}',
        );

        // Show loading while checking initial state or during auth operations
        if (!_hasCheckedInitialState ||
            authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Prevent multiple navigation calls
        if (!_hasNavigated) {
          _hasNavigated = true;

          // Use post frame callback to avoid navigation during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            debugPrint(
              'AuthWrapper navigation - isAuthenticated: ${authProvider.isAuthenticated}',
            );

            if (authProvider.isAuthenticated) {
              // Authenticated - go directly to home (NO email verification check)
              debugPrint('Navigating to home');
              Navigator.of(context).pushReplacementNamed('/home');
            } else {
              // Not authenticated - show login
              debugPrint('Navigating to login');
              Navigator.of(context).pushReplacementNamed('/auth/login');
            }
          });
        }

        return const SplashScreen();
      },
    );
  }
}

// Simple Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 120),
            SizedBox(height: 24),
            Text(
              'Cerdas Tani',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
