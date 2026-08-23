import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has completed the onboarding flow so it only
/// shows on first launch. [load] must be awaited before the app's router
/// is first used (e.g. at the start of `main()`).
class OnboardingService {
  static const _prefsKey = 'has_seen_onboarding';

  static bool hasSeenOnboarding = false;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hasSeenOnboarding = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      // If preferences can't be read, default to showing onboarding.
      hasSeenOnboarding = false;
    }
  }

  static Future<void> markSeen() async {
    hasSeenOnboarding = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
    } catch (_) {
      // Non-fatal: onboarding will simply show again next launch.
    }
  }
}
