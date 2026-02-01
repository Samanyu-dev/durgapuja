import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool isListening = false;
  String _recognizedText = "";

  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  /// Starts listening in Bangla and updates [isListening].
  /// Returns true if listening successfully started.
  Future<bool> startListening() async {
    final available = await _ensureInitialized();
    if (!available || isListening) return false;

    _recognizedText = "";
    isListening = true;

    await _speech.listen(
      localeId: 'bn_IN',
      onResult: (result) {
        _recognizedText = result.recognizedWords;
      },
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
