import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/new_password_page.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/password_recovery_page.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_button.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_input_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class VerificationCode extends StatelessWidget {
  const VerificationCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  "check your email",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "We.ve sent the code to your email",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const CustomPinCode(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "code expires in  ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '3:10',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: AppColors.Secondary),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                CustomButton(
                  onTap: () {},
                  text: "Send again",
                  colorBorder: AppColors.outline,
                  color: Colors.transparent,
                  textColor: AppColors.SecondaryText,
                ),
                CustomButton(
                  onTap: () {
                    NavigatorHelper.slideTo(context, NewPasswordPage());
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => PasswordRecoveryScreen(),
                    //     ));
                  },
                  text: "Verify",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
