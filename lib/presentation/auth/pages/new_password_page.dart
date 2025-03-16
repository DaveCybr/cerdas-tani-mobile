import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_texfield.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({Key? key}) : super(key: key);

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  bool obscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _containsNumber = false;
  bool _atLeast6Chars = false;

  void _validatePassword(String value) {
    setState(() {
      _atLeast6Chars = value.length >= 6;
      _containsNumber = RegExp(r'[0-9]').hasMatch(value);
    });
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (!_atLeast6Chars) {
      return "Password must be at least 6 characters";
    }
    if (!_containsNumber) {
      return "Password must contain at least one number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Reset Your Password",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Please enter your new password",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              CustomTextFormFild(
                onChanged: _validatePassword,
                validator: _passwordValidator,
                controller: _passwordController,
                obscureText: obscure,
                hint: "Password",
                prefixIcon: IconlyBroken.lock,
                suffixIcon: obscure ? IconlyBroken.show : IconlyBroken.hide,
                onTapSuffixIcon: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
              ),
              const SizedBox(height: 20),
              PasswordRequirements(
                atLeast6: _atLeast6Chars,
                containsNumber: _containsNumber,
              ),
              const SizedBox(height: 20),
              CustomButton(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    print("Password: ${_passwordController.text}");
                    NavigatorHelper.slideTo(context, const LoginPage());
                  }
                },
                text: "Done",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordRequirements extends StatelessWidget {
  final bool atLeast6;
  final bool containsNumber;

  const PasswordRequirements({
    super.key,
    required this.atLeast6,
    required this.containsNumber,
  });

  Widget requirementItem(String text, bool isValid) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor:
              isValid ? const Color(0xFFE3FFF1) : AppColors.outline,
          child: Icon(
            Icons.done,
            size: 12,
            color: isValid ? AppColors.primary : AppColors.SecondaryText,
          ),
        ),
        Text(
          "  $text",
          style: TextStyle(
            color: isValid ? AppColors.mainText : AppColors.SecondaryText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Your password must contain:",
            style: TextStyle(color: AppColors.mainText),
          ),
        ),
        const SizedBox(height: 15),
        requirementItem("At least 6 characters", atLeast6),
        const SizedBox(height: 10),
        requirementItem("Contains a number", containsNumber),
      ],
    );
  }
}
