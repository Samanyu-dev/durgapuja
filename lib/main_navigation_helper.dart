import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'widgets/custom_bottom_nav.dart';
import 'screens/finance/finance_home_screen.dart';
import 'screens/orders/clients_screen.dart';
import 'screens/finance/material_tracker_screen.dart';
import 'screens/reports/reports_screen.dart';

// Helper class to access MainNavigationScreen state from child screens
class MainNavigationHelper {
  static MainNavigationScreenState? navState;

  static void navigateToTab(int index) {
    navState?.switchToTab(index);
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Store reference to this state for navigation from child screens
    MainNavigationHelper.navState = this;
  }

  @override
  void dispose() {
    MainNavigationHelper.navState = null;
    super.dispose();
  }

  void switchToTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const FinanceHomeScreen(); // Home - shows finance home screen (1st picture)
      case 1:
        return const ClientsScreen(); // Orders - shows clients/orders screen
      case 2:
        return const MaterialTrackerScreen(); // Material Tracker
      case 3:
        return const ReportsScreen(
          showBottomNav: false,
        ); // Reports - profits dashboard
      default:
        return const FinanceHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          switchToTab(index);
        },
      ),
    );
  }
}
