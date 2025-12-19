import 'package:flutter/material.dart';
// Temporarily removed shared_preferences due to platform issues
// import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    // Temporarily disabled shared_preferences loading
    // _loadLocale();
  }

  // Temporarily disabled shared_preferences loading
  // Future<void> _loadLocale() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final languageCode = prefs.getString(_localeKey) ?? 'en';
  //     _locale = Locale(languageCode);
  //     notifyListeners();
  //   } catch (e) {
  //     // Fallback to default locale if shared_preferences fails
  //     print('Failed to load locale from shared_preferences: $e');
  //   }
  // }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    // Temporarily disabled shared_preferences saving
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setString(_localeKey, locale.languageCode);
    // } catch (e) {
    //   print('Failed to save locale to shared_preferences: $e');
    // }
  }

  void toggleLanguage() {
    final newLocale = _locale.languageCode == 'en'
        ? const Locale('bn')
        : const Locale('en');
    setLocale(newLocale);
  }
}
