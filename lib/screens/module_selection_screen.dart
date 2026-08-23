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
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppConstants.largePadding * 2),

              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrown.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dashboard,
                  size: 60,
                  color: AppColors.primaryBrown,
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Title
              Text(
                l10n.chooseYourModule,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.mediumPadding),

              // Subtitle
              Text(
                l10n.selectModuleDescription,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.largePadding * 3),

              // Module Cards
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Design Module Card
                    _buildModuleCard(
                      context: context,
                      title: l10n.designModule,
                      description: l10n.designModuleDescription,
                      icon: Icons.palette_outlined,
                      color: AppColors.primaryBrown,
                      onTap: () => context.go('/design'),
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // Finance Module Card
                    _buildModuleCard(
                      context: context,
                      title: l10n.financeModule,
                      description: l10n.financeModuleDescription,
                      icon: Icons.wallet_outlined,
                      color: AppColors.successGreen,
                      onTap: () => context.go('/finance'),
                    ),

                    if (isAdmin) ...[
                      const SizedBox(height: AppConstants.largePadding),

                      // Admin Panel Card (admins only)
                      _buildModuleCard(
                        context: context,
                        title: 'Admin Panel',
                        description: 'Manage users, roles, and system settings',
                        icon: Icons.admin_panel_settings,
                        color: AppColors.errorRed,
                        onTap: () => context.go('/admin'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Skip for now option
              TextButton(
                onPressed: () => context.go('/design'),
                child: Text(
                  l10n.continueWithDesign,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.mediumPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeBody,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}