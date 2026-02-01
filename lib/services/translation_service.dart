import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  late final OnDeviceTranslator _translator;

  TranslationService() {
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.bengali,
      targetLanguage: TranslateLanguage.english,
    );
  }

  Future<String> translateToEnglish(String banglaText) async {
    if (banglaText.isEmpty) return "";

    final translatedText = await _translator.translateText(banglaText);
    return translatedText;
  }

  void dispose() {
    _translator.close();
  }
}