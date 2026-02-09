import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/language_service.dart';
import '../../widgets/language_toggle_action.dart';

class DesignWelcomeScreen extends StatefulWidget {
  const DesignWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<DesignWelcomeScreen> createState() => _DesignWelcomeScreenState();
}

class _DesignWelcomeScreenState extends State<DesignWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(lang.getText('welcome_artisan')),
          elevation: 0,
          actions: const [
            LanguageToggleAction(),
          ],
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
                    lang.getText('durga_idol_design_studio'),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.getText('create_beautiful_with_ai'),
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
              lang.getText('choose_design_path'),
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
                  title: lang.getText('create_new_design'),
                  subtitle: lang.getText('new_design_subtitle'),
                  onTap: () => context.push('/design/create'),
                  color: AppColors.primaryBrown,
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                _buildMainOption(
                  icon: Icons.image_search,
                  title: lang.getText('image_to_image'),
                  subtitle: lang.getText('image_to_image_subtitle'),
                  onTap: () => context.push('/design/image-to-image'),
                  color: AppColors.accentOrange,
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                _buildMainOption(
                  icon: Icons.edit_outlined,
                  title: lang.getText('edit_existing_design'),
                  subtitle: lang.getText('edit_existing_subtitle'),
                  onTap: () => context.go('/design/edit'),
                  color: AppColors.primaryBrown,
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                _buildMainOption(
                  icon: Icons.touch_app,
                  title: lang.getText('tap_to_edit'),
                  subtitle: lang.getText('tap_to_edit_subtitle'),
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
                    lang.getText('design_tips'),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTip(lang.getText('tip_descriptive')),
                  _buildTip(lang.getText('tip_voice')),
                  _buildTip(lang.getText('tip_upload')),
                  _buildTip(lang.getText('tip_tap_edit')),
                  _buildTip(lang.getText('tip_experiment')),
                ],
              ),
            ),
          ],
        ),
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