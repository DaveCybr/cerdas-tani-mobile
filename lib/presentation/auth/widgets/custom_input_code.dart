import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomPinCode extends StatelessWidget {
  final Function(String) onChanged;

  const CustomPinCode({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: PinCodeTextField(
        keyboardType: TextInputType.number,
        appContext: context,
        length: 6,
        onChanged: onChanged, // Teruskan nilai ke widget induk
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(15),
          borderWidth: 2,
          fieldHeight: 40,
          fieldWidth: 40,
          selectedColor: AppColors.primary,
          activeColor: AppColors.outline,
          inactiveColor: AppColors.outline,
        ),
      ),
    );
  }
}
