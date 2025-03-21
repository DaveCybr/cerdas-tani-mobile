import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/home/pages/detail_article_page.dart';
import 'package:fertilizer_calculator/presentation/home/provider/article_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_texfield.dart';
import 'package:iconly/iconly.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _containsANumber = false;
  bool _numberofDigits = false;

  @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 20, top: 40, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol kembali & Judul
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(52, 31, 204, 120),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.primary),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "Change Password",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextFormFild(
                  controller: _currentPasswordController,
                  obscureText: _isCurrentPasswordVisible,
                  hint: "Current Password",
                  prefixIcon: IconlyBroken.lock,
                  suffixIcon: _isCurrentPasswordVisible
                      ? IconlyBroken.hide
                      : IconlyBroken.show,
                  onTapSuffixIcon: () => setState(() =>
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                  // validator: validatePassword,
                ),
                const SizedBox(height: 15),

                CustomTextFormFild(
                  controller: _newPasswordController,
                  obscureText: _isNewPasswordVisible,
                  hint: "New Password",
                  prefixIcon: IconlyBroken.lock,
                  suffixIcon: _isNewPasswordVisible
                      ? IconlyBroken.hide
                      : IconlyBroken.show,
                  onTapSuffixIcon: () => setState(
                      () => _isNewPasswordVisible = !_isNewPasswordVisible),
                  validator: validatePassword,
                  onChanged: (value) {
                    setState(() {
                      _numberofDigits = value.length >= 6;
                      _containsANumber = RegExp(r'[0-9]').hasMatch(value);
                    });
                  },
                ),

                const SizedBox(height: 15),

                CustomTextFormFild(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordVisible,
                  hint: "Confirm New Password",
                  prefixIcon: IconlyBroken.lock,
                  suffixIcon: _isConfirmPasswordVisible
                      ? IconlyBroken.hide
                      : IconlyBroken.show,
                  onTapSuffixIcon: () => setState(() =>
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  validator: validatePassword,
                  onChanged: (value) {
                    setState(() {}); // Ini agar passwordsMatch diperbarui
                  },
                ),

                const SizedBox(height: 20),

                passwordTerms(
                  context: context,
                  contains: _containsANumber,
                  atLeast6: _numberofDigits,
                  passwordsMatch: _newPasswordController.text.isNotEmpty &&
                      _confirmPasswordController.text.isNotEmpty &&
                      _newPasswordController.text ==
                          _confirmPasswordController.text,
                ),

                const SizedBox(height: 15),

                CustomButton(
                  text: "Change Password",
                  color: AppColors.primary,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password changed successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please correct the errors in the form"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget passwordTerms({
  required BuildContext context,
  required bool contains,
  required bool atLeast6,
  required bool passwordsMatch, // Tambahkan validasi untuk confirm password
}) {
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
      passwordRequirement(
          context, "At least 6 characters", atLeast6), // Tambahkan context
      const SizedBox(height: 15),
      passwordRequirement(
          context, "Contains a number", contains), // Tambahkan context
      const SizedBox(height: 15),
      passwordRequirement(context, "Confirm password matches",
          passwordsMatch), // Tambahkan validasi kecocokan password
    ],
  );
}

Widget passwordRequirement(BuildContext context, String text, bool isValid) {
  // Tambahkan context
  return Row(
    children: [
      CircleAvatar(
        radius: 10,
        backgroundColor: isValid ? const Color(0xFFE3FFF1) : AppColors.outline,
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
