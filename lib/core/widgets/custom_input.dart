import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool autocorrect;
  final bool enableSuggestions;

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.inputFormatters,
    this.maxLength,
    this.autocorrect = false,
    this.enableSuggestions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          autocorrect: !isPassword && autocorrect,
          enableSuggestions: !isPassword && enableSuggestions,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            filled: true,
            counterText: '',
            fillColor: AppColors.cardWhite,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderFocus),
            ),
          ),
        ),
      ],
    );
  }
}
