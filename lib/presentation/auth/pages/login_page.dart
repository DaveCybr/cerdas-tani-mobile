import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/password_recovery_page.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/signup_page.dart';
import 'package:fertilizer_calculator/presentation/auth/provider/user_provider.dart';
import 'package:fertilizer_calculator/presentation/home/pages/dashboard_page.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/helpers/navigation.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? _user;
  final box = GetStorage();
  bool obscure = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    // Membersihkan controller saat halaman ditutup
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() {
    if (box.hasData('google_account_id')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      });
    }
  }

  void _handleGoogleSignIn() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
      (route) => false,
    );
    // final userProvider =
    //     await context.read<UserProvider>().signInWithGoogle(context: context);
    // setState(() {
    //   _user = userProvider;
    // });
    // context.push(const DashboardPage());
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Invalid email format";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  final key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Mengizinkan halaman untuk bisa ditutup
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Welcome Back!",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 5),
                        Text("Please enter your account here",
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 20),
                        Form(
                          key: key,
                          child: Column(
                            children: [
                              CustomTextFormFild(
                                validator: _validateEmail,
                                hint: "Email",
                                controller: _emailController,
                                prefixIcon: IconlyBroken.message,
                              ),
                              const SizedBox(height: 20),
                              CustomTextFormFild(
                                controller: _passwordController,
                                validator: (value) => _validatePassword(value),
                                obscureText: obscure,
                                hint: "Password",
                                prefixIcon: IconlyBroken.lock,
                                suffixIcon: obscure
                                    ? IconlyBroken.show
                                    : IconlyBroken.hide,
                                onTapSuffixIcon: () =>
                                    setState(() => obscure = !obscure),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    NavigatorHelper.slideTo(
                                      context,
                                      PasswordRecoveryPage(),
                                    );
                                  },
                                  child: Text(
                                    "Forgot password?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: AppColors.dark,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                              CustomButton(
                                text: "Sign In",
                                color: AppColors.primary,
                                onTap: () {
                                  if (key.currentState!.validate()) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Text(
                                "Or continue with",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppColors.SecondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 17),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      onPressed: () {
                                        _handleGoogleSignIn();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            Assets.images.google.path,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 20),
                                          Text(
                                            "Sign in with Google",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : AppColors.card,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: AppColors.SecondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      NavigatorHelper.slideTo(
                                          context, const SignupPage());
                                    },
                                    child: Text(
                                      "Sign Up",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Image.asset(Assets.images.logo.path, width: 200, height: 200),
  //           const SizedBox(height: 20),
  //           Text(
  //             "Login menggunakan akun Google",
  //             style: TextStyle(
  //               fontSize: 15,
  //               color: Theme.of(context).brightness == Brightness.dark
  //                   ? Colors.white
  //                   : AppColors.card,
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: () {
  //               _handleGoogleSignIn();
  //             },
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Image.asset(
  //                   Assets.images.google.path,
  //                   height: 20,
  //                 ),
  //                 const SizedBox(width: 20),
  //                 Text(
  //                   "Login",
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     color: Theme.of(context).brightness == Brightness.dark
  //                         ? Colors.white
  //                         : AppColors.card,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
