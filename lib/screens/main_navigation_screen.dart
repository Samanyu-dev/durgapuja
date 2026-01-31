import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/app_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'home/home_dashboard_screen.dart';
import 'design/design_welcome_screen.dart';
import 'orders/add_client_screen.dart';
import 'finance/finance_home_screen.dart';
import 'reports/reports_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<String> _routes = ['/', '/design', '/orders', '/finance', '/reports'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(l10n.welcomeArtisan),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: Container(
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
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                  isActive: _currentIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.palette_outlined,
                  label: 'Design',
                  index: 1,
                  isActive: _currentIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Orders',
                  index: 2,
                  isActive: _currentIndex == 2,
                ),
                _buildNavItem(
                  icon: Icons.wallet_outlined,
                  label: 'Finance',
                  index: 3,
                  isActive: _currentIndex == 3,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  index: 4,
                  isActive: _currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomeDashboardScreen();
      case 1:
        return const DesignWelcomeScreen();
      case 2:
        return const AddClientScreen();
      case 3:
        return const FinanceHomeScreen();
      case 4:
        return const ReportsScreen();
      default:
        return const HomeDashboardScreen();
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
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
}