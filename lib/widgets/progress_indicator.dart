import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../services/logging_service.dart';

class AppProgressIndicator extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const AppProgressIndicator({
    Key? key,
    this.message,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: AppConstants.fontSizeBody,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: AppProgressIndicator(message: message),
            ),
          ),
      ],
    );
  }
}

class LinearProgressWithLabel extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? backgroundColor;
  final Color? progressColor;

  const LinearProgressWithLabel({
    Key? key,
    required this.progress,
    this.label,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: backgroundColor ?? AppColors.cardCream,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.primaryBrown,
            ),
          ),
        ),
      ],
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.successGreen
                      : isCurrent
                          ? AppColors.primaryBrown
                          : AppColors.cardCream,
                  border: Border.all(
                    color: isCurrent ? AppColors.primaryBrown : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              if (index < totalSteps - 1) ...[
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentStep - 1
                        ? AppColors.successGreen
                        : AppColors.cardCream,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
