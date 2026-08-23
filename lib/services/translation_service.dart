import 'gpt_service.dart';

/// Translates Bengali text to English via GPT (see [GPTService.translateToEnglish]).
///
/// Previously used google_mlkit_translation's on-device translator, but that
/// plugin doesn't ship arm64 simulator binaries and pulls in a very large
/// native SDK, making iOS builds fail/flaky. GPT-based translation avoids
/// that dependency entirely and this class was already constructed fresh
/// per-use at every call site, so a stateless API-backed implementation is a
/// drop-in replacement.
class TranslationService {
  Future<String> translateToEnglish(String banglaText) {
    return GPTService.translateToEnglish(banglaText);
  }

  void dispose() {}
}