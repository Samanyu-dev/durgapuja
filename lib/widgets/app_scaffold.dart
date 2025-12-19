import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'dynamic_island_nav.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavTap;
  final VoidCallback? onFabTap;
  final bool showHomeIcon;
  final bool isDesignModule;

  const AppScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
    this.onFabTap,
    this.showHomeIcon = false,
    this.isDesignModule = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define navigation items based on the module
    List<NavItem> navItems;
    if (showHomeIcon) {
      if (isDesignModule) {
        // Design module: Dashboard, Design, Orders, Reports
        navItems = [
          const NavItem(icon: Icons.home_outlined, label: 'Dashboard'),
          const NavItem(icon: Icons.palette_outlined, label: 'Design'),
          const NavItem(icon: Icons.shopping_bag_outlined, label: 'Orders'),
          const NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
        ];
      } else {
        // Finance module: Dashboard, Orders, Reports
        navItems = [
          const NavItem(icon: Icons.home_outlined, label: 'Dashboard'),
          const NavItem(icon: Icons.shopping_bag_outlined, label: 'Orders'),
          const NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
        ];
      }
    } else {
      // Default or combined navigation
      navItems = [
        const NavItem(icon: Icons.home_outlined, label: 'Home'),
        const NavItem(icon: Icons.palette_outlined, label: 'Design'),
        const NavItem(icon: Icons.shopping_bag_outlined, label: 'Orders'),
        const NavItem(icon: Icons.wallet_outlined, label: 'Finance'),
        const NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
      ];
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Stack(
        children: [
          body,
          DynamicIslandNav(
            currentIndex: currentIndex,
            onTap: onNavTap,
            onVoiceTap: onFabTap ?? () => _showVoiceBottomSheet(context),
            navItems: navItems,
          ),
        ],
      ),
    );
  }



  void _showVoiceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voice Recording',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to start recording your voice note',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
