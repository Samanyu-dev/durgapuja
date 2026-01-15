import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class ModuleSelectionScreen extends StatelessWidget {
  const ModuleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - AppConstants.defaultPadding * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBrown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Welcome Text
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              Text(
                l10n.chooseModule,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largePadding * 2),

              // Finance Module Button
              _ModuleCard(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.finance,
                description: l10n.financeDescription,
                color: AppColors.primaryBrown,
                onTap: () => context.go('/finance'),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Design Module Button
              _ModuleCard(
                icon: Icons.palette_outlined,
                title: l10n.design,
                description: l10n.designDescription,
                color: AppColors.accentOrange,
                onTap: () => context.go('/design'),
              ),

              // Admin Module Button (only for admins)
              ...authProvider.isAdmin ? [
                const SizedBox(height: AppConstants.largePadding),
                _ModuleCard(
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Panel',
                  description: 'Manage users, roles, and system settings',
                  color: Colors.red.shade600,
                  onTap: () => context.go('/admin'),
                ),
              ] : [],
              ],
          ),
        ),
      ),
      ));
  }
}

class _ModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 140,
        transform: _isPressed
            ? Matrix4.translationValues(0, 4, 0)
            : Matrix4.translationValues(0, 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPressed
                ? [
                    widget.color.withOpacity(0.1),
                    Colors.white,
                  ]
                : [
                    Colors.white,
                    AppColors.cardCream.withOpacity(0.8),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: _isPressed
                ? widget.color.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isPressed
                      ? widget.color.withOpacity(0.25)
                      : widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: widget.color.withOpacity(_isPressed ? 0.4 : 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: _isPressed ? 42 : 40,
                ),
              ),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        color: AppColors.textLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: _isPressed
                    ? Matrix4.translationValues(4, 0, 0)
                    : Matrix4.translationValues(0, 0, 0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: widget.color,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
