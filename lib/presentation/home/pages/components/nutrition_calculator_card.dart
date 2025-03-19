import 'package:flutter/material.dart';
import 'package:fertilizer_calculator/core/assets/assets.gen.dart';

class NutritionCalculatorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0xFF1FCC79).withOpacity(1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
        color: Color.fromARGB(255, 236, 248, 242),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.1),
              child: Text(
                'Kalkulator Hara',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: screenWidth * 0.05,
                    ),
              ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.3,
            height: screenHeight * 0.15,
            child: Image.asset(
              Assets.images.calculator.path,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
