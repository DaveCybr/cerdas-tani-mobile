import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:fertilizer_calculator/presentation/auth/provider/user_provider.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_back_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_texfield.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/dialog_auth.dart';
import 'package:fertilizer_calculator/presentation/home/pages/dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../../core/constans/colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool obscure = false;
  final key = GlobalKey<FormState>();
  bool isLoading = false; // Tambahkan state loading

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _containsANumber = false;
  bool _numberofDigits = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi validasi email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Invalid email format";
    }
    return null;
  }

  // Fungsi validasi password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one number";
    }
    return null;
  }

  Future<void> _signUp() async {
    if (!key.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      showCustomDialog(
        context: context,
        isSuccess: true,
        message: "Sign Up Success!",
        onConfirm: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        },
      );
    } catch (e) {
      showCustomDialog(
        context: context,
        isSuccess: false,
        message: "Email is already registered or signup failed",
        onConfirm: () {},
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double paddingSize = width > 600 ? 40 : 20; // Padding responsif

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(paddingSize),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Memberikan jarak atas;
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: CustomBackButton(
                        context: context,
                        destination: const LoginPage(),
                      ),
                    ),
                  ),
                  // SizedBox(height: width > 600 ? 50 : 20), // Spasi dinamis
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(fontSize: width > 600 ? 32 : 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Please enter your account here",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: width > 600 ? 18 : 14),
                    ),
                  ),
                  SizedBox(height: width > 600 ? 50 : 20),
                  Form(
                    key: key,
                    child: Column(
                      children: [
                        CustomTextFormFild(
                          controller: _emailController,
                          validator: validateEmail,
                          hint: "Email",
                          prefixIcon: IconlyBroken.message,
                        ),
                        SizedBox(height: width > 600 ? 50 : 20),
                        CustomTextFormFild(
                          controller: _passwordController,
                          onChanged: (value) {
                            setState(() {
                              _numberofDigits = value.length >= 6;
                              _containsANumber =
                                  RegExp(r'[0-9]').hasMatch(value);
                            });
                          },
                          validator: validatePassword,
                          obscureText: obscure,
                          hint: "Password",
                          prefixIcon: IconlyBroken.lock,
                          suffixIcon:
                              obscure ? IconlyBroken.show : IconlyBroken.hide,
                          onTapSuffixIcon: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                        SizedBox(height: width > 600 ? 50 : 20),
                        passwordTerms(
                          contains: _containsANumber,
                          atLeast6: _numberofDigits,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: width > 600 ? 30 : 20), // Spasi dinamis
                  CustomButton(
                    text: "Sign Up",
                    color: AppColors.primary,
                    isLoading: isLoading, // Tambahkan ini
                    onTap: () {
                      _signUp();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Password requirement widget
  Widget passwordTerms({required bool contains, required bool atLeast6}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your password must contain:",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: AppColors.mainText),
        ),
        const SizedBox(height: 15),
        passwordRequirement("At least 6 characters", atLeast6),
        const SizedBox(height: 15),
        passwordRequirement("Contains a number", contains),
      ],
    );
  }

  Widget passwordRequirement(String text, bool isValid) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isValid ? Color(0xFFE3FFF1) : AppColors.outline,
          child: Icon(
            Icons.done,
            size: 12,
            color: isValid ? AppColors.primary : AppColors.SecondaryText,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isValid ? AppColors.mainText : AppColors.SecondaryText,
              ),
        ),
      ],
    );
  }
}
