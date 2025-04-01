import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:fertilizer_calculator/core/helpers/navigation.dart';

class CustomBackButton extends StatelessWidget {
  final BuildContext context;
  final Widget destination;

  const CustomBackButton({
    super.key,
    required this.context,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(52, 31, 204, 120),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () {
          NavigatorHelper.slideFrom(context, destination);
        },
      ),
    );
  }
}
