import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';
import '../services/speech_service.dart';
import '../services/translation_service.dart';
import 'dynamic_island_nav.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavTap;
  final VoidCallback? onFabTap;
  final Widget? floatingActionButton;
  final bool showHomeIcon;
  final bool isDesignModule;
  final bool isFinanceSubModule;
  final List<NavItem>? customNavItems;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
    this.onFabTap,
    this.floatingActionButton,
    this.showHomeIcon = false,
    this.isDesignModule = false,
    this.isFinanceSubModule = false,
    this.customNavItems,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    // Use custom nav items if provided
    List<NavItem> navItems = widget.customNavItems ?? [];

    if (navItems.isEmpty) {
      // Define navigation items based on the module
      if (widget.showHomeIcon) {
        if (widget.isDesignModule) {
          // Design module: Studio, My Concepts
          navItems = [
            const NavItem(icon: Icons.palette_outlined, label: 'Studio'),
            const NavItem(
              icon: Icons.photo_library_outlined,
              label: 'My Concepts',
            ),
          ];
        } else {
          // Finance module: Dashboard, Orders, Reports (no design parts)
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
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/main');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              // Scrolling down -> hide the bottom bar
              if (_isVisible) {
                setState(() => _isVisible = false);
              }
            } else if (notification.direction == ScrollDirection.forward) {
              // Scrolling up -> show the bottom bar
              if (!_isVisible) {
                setState(() => _isVisible = true);
              }
            }
            return false;
          },
          child: Stack(
            children: [
              widget.body,
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: _isVisible ? 20 : -90,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isVisible ? 1.0 : 0.0,
                  child: DynamicIslandNav(
                    currentIndex: widget.currentIndex,
                    onTap: widget.onNavTap,
                    onVoiceTap:
                        widget.onFabTap ?? () => _showVoiceBottomSheet(context),
                    navItems: navItems,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.floatingActionButton,
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
              'Record voice notes for quick updates',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  iconSize: 32,
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBrown,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _handleVoiceRecording(context),
                    icon: const Icon(Icons.mic, color: Colors.white),
                    iconSize: 32,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceRecording(BuildContext context) async {
    try {
      final speechService = SpeechService();
      final translationService = TranslationService();

      final String banglaText = await speechService.listenBangla();
      if (banglaText.isNotEmpty) {
        final String englishText = await translationService.translateToEnglish(
          banglaText,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Voice Note: $englishText')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Recording failed: $e')));
      }
    }
  }
}
