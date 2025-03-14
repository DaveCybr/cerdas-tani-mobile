import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/verification_page.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_texfield.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30), // Memberikan jarak atas
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomBackButton(
                      context: context,
                      destination: const LoginPage(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    "assets/images/logo.png",
                    width: 130,
                    height: 120,
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
      ),
    );
  }
}
