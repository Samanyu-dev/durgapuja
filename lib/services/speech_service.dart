import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool isListening = false;
  String _recognizedText = "";

  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech initialization error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    return _isInitialized;
  }

  /// Starts listening in Bangla and updates [isListening].
  /// Returns true if listening successfully started.
  Future<bool> startListening() async {
    final available = await _ensureInitialized();
    if (!available || isListening) return false;

    _recognizedText = "";
    isListening = true;

    // Check if Bengali locale is available, otherwise use default
    final locales = await _speech.locales();
    final hasBengali = locales.any((locale) => locale.localeId == 'bn_IN');
    final localeToUse = hasBengali ? 'bn_IN' : 'en_US';

    print('Available locales: ${locales.map((l) => l.localeId).join(', ')}');
    print('Using locale: $localeToUse');

    await _speech.listen(
      localeId: localeToUse,
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        print('Recognized text: $_recognizedText');
      },
      onSoundLevelChange: (level) {
        print('Sound level: $level');
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
    );

    return true;
  }

  /// Stops listening and returns the last recognized Bangla text.
  Future<String> stopListening() async {
    if (!isListening) return "";

    await _speech.stop();
    isListening = false;
    return _recognizedText;
  }

  /// Backwards-compatible helper: starts listening, waits briefly, then stops.
  /// Prefer using [startListening] and [stopListening] with a UI toggle.
  Future<String> listenBangla() async {
    final started = await startListening();
    if (!started) return "";

    await Future.delayed(const Duration(seconds: 10));
    return await stopListening();
  }
}
