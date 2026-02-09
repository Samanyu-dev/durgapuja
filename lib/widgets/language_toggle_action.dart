import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageToggleAction extends StatelessWidget {
  const LanguageToggleAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        final isBn = languageService.currentLanguage == AppLanguage.bn;

        return IconButton(
          icon: Text(
            isBn ? 'বাংলা' : 'EN',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          onPressed: () {
            languageService.toggleLanguage();
          },
          tooltip: isBn ? 'Switch to English' : 'বাংলা তে বদলান',
        );
      },
    );
  }
}

