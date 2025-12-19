import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final int maxLines;
  final bool hasVoiceInput;
  final VoidCallback? onVoicePressed;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.controller,
    this.maxLines = 1,
    this.hasVoiceInput = false,
    this.onVoicePressed,
    this.keyboardType,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: hasVoiceInput
              ? IconButton(
                  icon: Icon(
                    Icons.mic_outlined,
                    color: AppColors.primaryBrown,
                  ),
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
