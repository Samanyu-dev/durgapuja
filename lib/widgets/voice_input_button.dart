import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/logging_service.dart';

class VoiceInputButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const VoiceInputButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isListening ? _scaleAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.isListening ? AppColors.accentOrange : AppColors.primaryBrown,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening ? AppColors.accentOrange : AppColors.primaryBrown)
                      // ignore: deprecated_member_use
                      .withOpacity(0.3),
                  blurRadius: widget.isListening ? 20 : 12,
                  spreadRadius: widget.isListening ? 4 : 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                widget.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 28,
              ),
              onPressed: widget.onPressed,
            ),
          ),
        );
      },
    );
  }
}
