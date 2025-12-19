import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class DesignWelcomeScreen extends StatefulWidget {
  const DesignWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<DesignWelcomeScreen> createState() => _DesignWelcomeScreenState();
}

class _DesignWelcomeScreenState extends State<DesignWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(l10n.welcomeArtisan),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppConstants.mediumPadding,
              crossAxisSpacing: AppConstants.mediumPadding,
              children: [
                _buildFeatureCard(
                  icon: Icons.lightbulb_outline,
                  title: l10n.ideaGeneration,
                  subtitle: l10n.ideaGenerationDesc,
                  onTap: () => context.go('/design/idea-generation'),
                ),
                _buildFeatureCard(
                  icon: Icons.build_circle_outlined,
                  title: l10n.idolBuild,
                  subtitle: l10n.idolBuildDesc,
                  onTap: () => context.go('/design/sculpting'),
                ),
                _buildFeatureCard(
                  icon: Icons.palette_outlined,
                  title: l10n.decorationDetailing,
                  subtitle: l10n.decorationDetailingDesc,
                  onTap: () => context.go('/design/detailing'),
                ),
                _buildFeatureCard(
                  icon: Icons.preview_outlined,
                  title: l10n.idolPreviews,
                  subtitle: l10n.idolPreviewsDesc,
                  onTap: () => context.go('/design/preview'),
                ),
                _buildFeatureCard(
                  icon: Icons.image_outlined,
                  title: l10n.generateBackdrop,
                  subtitle: l10n.generateBackdropDesc,
                  onTap: () => context.go('/design/backdrop'),
                ),
                _buildFeatureCard(
                  icon: Icons.lightbulb_circle_outlined,
                  title: l10n.tryLights,
                  subtitle: l10n.tryLightsDesc,
                  onTap: () => context.go('/design/lighting'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(
              icon,
              size: 40,
              color: AppColors.primaryBrown,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
