import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:fertilizer_calculator/presentation/auth/provider/user_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/calculate_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/calculator_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/fertilizer_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/recipe_provider.dart';
import 'package:fertilizer_calculator/presentation/history/provider/history_provider.dart';
import 'package:fertilizer_calculator/presentation/home/pages/modules/provider/module_provider.dart';
import 'package:fertilizer_calculator/presentation/home/pages/splash_page.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
import 'package:fertilizer_calculator/presentation/user/provider/profile_provider.dart';
import 'package:fertilizer_calculator/presentation/user/provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()..loadRecipes()),
        ChangeNotifierProvider(create: (_) => FertilizerProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()..fetchModules()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CalculateProvider()),
        ChangeNotifierProvider(
            create: (_) => HistoryProvider()..loadHistories()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Ubah warna status bar dan indikator berdasarkan tema sistem atau tema aplikasi
        final Brightness systemBrightness =
            MediaQuery.of(context).platformBrightness;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white, // Membuat status bar transparan
          statusBarIconBrightness: systemBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ));

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.currentTheme,
          theme: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black, // warna kursor (line)
              selectionColor: Colors.grey, // warna teks yang di-select
              selectionHandleColor: Colors.black, // warna tetesan itu
            ),
            textTheme: TextTheme(
              //this Font we will use later 'H1'

              headlineLarge: GoogleFonts.poppins(
                color: AppColors.mainText,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),

              //this font we will use later 'H2'

              headlineMedium: GoogleFonts.poppins(
                color: AppColors.mainText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              //this font we will use  later 'H3'

              headlineSmall: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),

              //this font we will use later 'P1'

              bodyLarge: GoogleFonts.poppins(
                color: AppColors.SecondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),

              //this font we will use later 'P2'

              bodyMedium: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              //this font we will use later 'S'
              bodySmall: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.SecondaryText,
                letterSpacing: 0.5,
              ),
              //thus we have added all the fonts used in the projct ..
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.light,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          darkTheme: ThemeData.dark(),
          home: const LoginPage(),
        );
      },
    );
  }
}
