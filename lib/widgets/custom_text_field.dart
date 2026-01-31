import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/logging_service.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final int maxLines;
  final bool hasVoiceInput;
  final VoidCallback? onVoicePressed;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.maxLines = 1,
    this.hasVoiceInput = false,
    this.onVoicePressed,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(color: AppColors.textLight, fontSize: 16),
          labelStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: prefixIcon,
          suffixIcon: hasVoiceInput
              ? IconButton(
                  icon: Icon(Icons.mic_outlined, color: AppColors.primaryBrown),
                  onPressed: onVoicePressed,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
