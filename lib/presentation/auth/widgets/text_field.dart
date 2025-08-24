import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';

class CustomTextFormFild extends StatefulWidget {
  CustomTextFormFild({
    Key? key,
    required this.hint,
    this.suffixIcon,
    this.onTapSuffixIcon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.controller,
    required this.prefixIcon,
    this.filled = false,
    this.enabled = true,
    this.initialValue,
  }) : super(key: key);

  final String hint;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onTapSuffixIcon;
  final bool obscureText;
  final bool filled;
  final bool enabled;
  final String? initialValue;
  final TextEditingController? controller;
  final Function()? onEditingComplete;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  @override
  State<CustomTextFormFild> createState() => _CustomTextFormFildState();
}

class _CustomTextFormFildState extends State<CustomTextFormFild> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        autofocus: false,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
        initialValue: widget.initialValue,
        onEditingComplete: widget.onEditingComplete,
        controller: widget.controller,
        onChanged: widget.onChanged,
        validator: widget.validator,
        obscureText: widget.obscureText,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          hintText: widget.hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: AppColors.mainText,
            size: 20,
          ),
          suffixIcon:
              widget.suffixIcon != null
                  ? IconButton(
                    icon: Icon(
                      widget.suffixIcon,
                      color: AppColors.mainText,
                      size: 20,
                    ),
                    onPressed: widget.onTapSuffixIcon,
                  )
                  : null,
          filled: widget.filled,
          enabled: widget.enabled,
        ),
      ),
    );
  }
}
