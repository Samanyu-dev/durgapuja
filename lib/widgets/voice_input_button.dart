import 'package:flutter/material.dart';
import '../utils/colors.dart';

class VoiceInputButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const VoiceInputButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isListening ? AppColors.accentOrange : AppColors.primaryBrown,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isListening ? AppColors.accentOrange : AppColors.primaryBrown)
                // ignore: deprecated_member_use
                .withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
