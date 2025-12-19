import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class ModuleSelectionScreen extends StatelessWidget {
  const ModuleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
              Container(
                width: double.infinity,
                height: 140,
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                    onTap: () => context.go('/finance'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.mediumPadding),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBrown.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primaryBrown,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: AppConstants.mediumPadding),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.finance,
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.financeDescription,
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
                            color: AppColors.primaryBrown,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Design Module Button
              Container(
                width: double.infinity,
                height: 140,
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                    onTap: () => context.go('/design'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.mediumPadding),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            ),
                            child: const Icon(
                              Icons.palette_outlined,
                              color: AppColors.accentOrange,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: AppConstants.mediumPadding),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.design,
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.designDescription,
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
                            color: AppColors.accentOrange,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
