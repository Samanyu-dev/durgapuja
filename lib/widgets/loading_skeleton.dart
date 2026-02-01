import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../services/logging_service.dart';

class LoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const LoadingSkeleton({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.cardCream,
              AppColors.cardCream.withOpacity(0.5),
              _animation.value,
            ),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
          ),
        );
      },
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LoadingSkeleton(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    LoadingSkeleton(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          LoadingSkeleton(width: double.infinity, height: 80, borderRadius: BorderRadius.all(Radius.circular(8))),
        ],
      ),
    );
  }
}

class LoadingGrid extends StatelessWidget {
  final int itemCount;

  const LoadingGrid({Key? key, this.itemCount = 6}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.mediumPadding,
      crossAxisSpacing: AppConstants.mediumPadding,
      children: List.generate(
        itemCount,
        (index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingSkeleton(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
              const SizedBox(height: AppConstants.mediumPadding),
              LoadingSkeleton(width: double.infinity, height: 14),
              const SizedBox(height: 4),
              LoadingSkeleton(width: double.infinity, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
