import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/password_recovery_page.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/signup_page.dart';
import 'package:fertilizer_calculator/presentation/auth/provider/user_provider.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/dialog_auth.dart';
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
import 'package:google_sign_in/google_sign_in.dart';

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
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      box.write('google_account_id', userCredential.user?.uid);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e")),
      );
    }
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
  bool isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (!key.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      showCustomDialog(
        context: context,
        isSuccess: false,
        message: "Email or password is incorrect",
        onConfirm: () {},
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/images/logo.png",
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Welcome Back!",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Please enter your account here",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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
                              isLoading: isLoading,
                              onTap: () {
                                _login(context);
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
                                        borderRadius: BorderRadius.circular(30),
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
                                            color:
                                                Theme.of(context).brightness ==
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
    );
  }
}
