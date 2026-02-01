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
            // Welcome section
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
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
              child: Column(
                children: [
                  Icon(
                    Icons.design_services_outlined,
                    size: 64,
                    color: AppColors.primaryBrown,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Durga Idol Design Studio',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create beautiful Durga Puja designs with AI assistance',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            // Main options
            Text(
              'Choose Your Design Path',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            Column(
              children: [
                _buildMainOption(
                  icon: Icons.auto_awesome,
                  title: 'Create New Design',
                  subtitle: 'Generate a new Durga idol design using text or voice prompts',
                  onTap: () => context.go('/design/create'),
                  color: AppColors.primaryBrown,
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                _buildMainOption(
                  icon: Icons.image_search,
                  title: 'Image-to-Image Generation',
                  subtitle: 'Transform existing images with AI enhancement and style transfer',
                  onTap: () => context.go('/design/image-to-image'),
                  color: AppColors.accentOrange,
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                _buildMainOption(
                  icon: Icons.edit_outlined,
                  title: 'Edit Existing Design',
                  subtitle: 'Modify and enhance previously created designs',
                  onTap: () => context.go('/design/edit'),
                  color: AppColors.primaryBrown,
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                _buildMainOption(
                  icon: Icons.touch_app,
                  title: 'Tap-to-Edit',
                  subtitle: 'Trace and edit specific elements in your designs',
                  onTap: () => context.go('/design/tap-to-edit'),
                  color: AppColors.accentOrange,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Quick tips
            Container(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design Tips',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTip('Use descriptive prompts for better results'),
                  _buildTip('Try voice input for natural language descriptions'),
                  _buildTip('Upload reference images for image-to-image generation'),
                  _buildTip('Use tap-to-edit for precise element modifications'),
                  _buildTip('Experiment with different styles and themes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.cardCream.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryBrown,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}