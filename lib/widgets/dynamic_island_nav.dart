// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({
    required this.icon,
    required this.label,
  });
}

class DynamicIslandNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onVoiceTap;
  final List<NavItem>? navItems;

  const DynamicIslandNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.onVoiceTap,
    this.navItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default navigation items if none provided
    final defaultNavItems = [
      const NavItem(icon: Icons.home_outlined, label: 'Home'),
      const NavItem(icon: Icons.palette_outlined, label: 'Design'),
      const NavItem(icon: Icons.shopping_bag_outlined, label: 'Orders'),
      const NavItem(icon: Icons.wallet_outlined, label: 'Finance'),
      const NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
    ];

    final items = navItems ?? defaultNavItems;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.backgroundCream.withOpacity(0.3),
              AppColors.backgroundCream,
            ],
          ),
        ),
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildNavigationItems(items),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(List<NavItem> items) {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      // Add voice button in the middle for navigation lists with more than 2 items
      if (i == (items.length ~/ 2) && items.length > 2) {
        widgets.add(_buildVoiceButton());
      }
      widgets.add(_buildNavItem(
        icon: items[i].icon,
        label: items[i].label,
        index: i,
      ));
    }

    return widgets;
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textLight,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 24,
        ),
        onPressed: onVoiceTap ?? () => _showVoiceBottomSheet(),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
      ),
    );
  }

  void _showVoiceBottomSheet() {
    // This will be handled by the parent widget
  }
}
