import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class ModuleSelectionScreen extends StatelessWidget {
  const ModuleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding.clamp(12.0, 24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: size.height * 0.02),

              // Logo/Icon - screen-aware size
              Container(
                width: size.width * 0.28,
                height: size.width * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrown.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dashboard,
                  size: size.width * 0.14,
                  color: AppColors.primaryBrown,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Title
              Text(
                l10n.chooseYourModule,
                style: TextStyle(
                  fontSize: (size.width * 0.07).clamp(20.0, 28.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * 0.01),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                child: Text(
                  l10n.selectModuleDescription,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // Design Module Card
              _buildModuleCard(
                context: context,
                title: l10n.designModule,
                description: l10n.designModuleDescription,
                icon: Icons.palette_outlined,
                color: AppColors.primaryBrown,
                onTap: () => context.push('/design/welcome'),
              ),

              SizedBox(height: size.height * 0.02),

              // Finance Module Card
              _buildModuleCard(
                context: context,
                title: l10n.financeModule,
                description: l10n.financeModuleDescription,
                icon: Icons.wallet_outlined,
                color: AppColors.successGreen,
                onTap: () => context.push('/finance/dashboard'),
              ),

              SizedBox(height: size.height * 0.02),

              // Skip for now option
              TextButton(
                onPressed: () => context.push('/design/welcome'),
                child: Text(
                  l10n.continueWithDesign,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
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
    final size = MediaQuery.of(context).size;
    final cardPad = (size.width * 0.04).clamp(12.0, 20.0);
    final iconSize = (size.width * 0.12).clamp(44.0, 56.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPad),
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
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: iconSize * 0.55,
                color: color,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      color: AppColors.textLight,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.fade,
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
      ),
    );
  }
}