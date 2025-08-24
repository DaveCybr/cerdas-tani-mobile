import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onTap,
    this.color = AppColors.primary,
    required this.text,
    this.colorBorder,
    this.textColor,
    this.height = 56,
    this.isLoading = false, // Tambahkan parameter isLoading
    Key? key,
  }) : super(key: key);

  final String text;
  final Color? color;
  final Function() onTap;
  final Color? colorBorder;
  final Color? textColor;
  final double height;
  final bool isLoading; // Tambahkan variabel isLoading

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: InkWell(
        onTap: isLoading ? null : onTap, // Disable tombol saat loading
        child: Container(
          alignment: Alignment.center,
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isLoading ? color : color, // Ubah warna saat loading
            borderRadius: BorderRadius.circular(30),
            border:
                colorBorder == null
                    ? null
                    : Border.all(color: colorBorder!, width: 2),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(1, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
