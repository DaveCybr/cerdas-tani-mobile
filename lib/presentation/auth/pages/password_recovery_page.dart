import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/verification_page.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      print("Email: ${_emailController.text}");
      NavigatorHelper.slideTo(context, const VerificationCode());
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Link reset password telah dikirim ke email")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
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
                const SizedBox(height: 20),
                Text(
                  'Password recovery',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Enter your email to recover your password",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextFormFild(
                  controller: _emailController,
                  validator: _validateEmail,
                  hint: "Email",
                  prefixIcon: IconlyBroken.message,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onTap: _submit,
                  text: "Next",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
