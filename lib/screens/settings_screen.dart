import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: AppColors.primaryBrown),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
            tooltip: l10n.backToModuleSelection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                  ListTile(
                    title: Text(l10n.english),
                    trailing: localeProvider.locale.languageCode == 'en'
                        ? const Icon(Icons.check, color: AppColors.primaryBrown)
                        : null,
                    onTap: () => localeProvider.setLocale(const Locale('en')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.bengali),
                    trailing: localeProvider.locale.languageCode == 'bn'
                        ? const Icon(Icons.check, color: AppColors.primaryBrown)
                        : null,
                    onTap: () => localeProvider.setLocale(const Locale('bn')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
