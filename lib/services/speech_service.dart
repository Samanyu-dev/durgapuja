import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Service for handling speech recognition and text-to-speech functionality
class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  
  // Callbacks for UI updates
  ValueChanged<String>? onSpeechResult;
  ValueChanged<bool>? onRecordingStateChanged;
  ValueChanged<double>? onRecordingProgress;

  /// Initialize the speech service
  Future<void> initialize() async {
    // Initialize speech to text
    final hasSpeech = await _speechToText.initialize(
      onError: (error) {
        debugPrint('Speech recognition error: $error');
      },
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
      },
    );
    
    if (!hasSpeech) {
      throw Exception('Speech recognition not available');
    }
  }

  /// Start listening for speech
  Future<void> startListening({String? locale}) async {
    if (_isListening) return;
    
    try {
      _isListening = true;
      if (onRecordingStateChanged != null) {
        onRecordingStateChanged!(true);
      }

      await _speechToText.listen(
        localeId: locale ?? 'bn-BD',
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            if (onSpeechResult != null) {
              onSpeechResult!(result.recognizedWords);
            }
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
      
    } catch (e) {
      _isListening = false;
      if (onRecordingStateChanged != null) {
        onRecordingStateChanged!(false);
      }
      rethrow;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      _isListening = false;
      if (onRecordingStateChanged != null) {
        onRecordingStateChanged!(false);
      }

      await _speechToText.stop();
      
    } catch (e) {
      _isListening = false;
      if (onRecordingStateChanged != null) {
        onRecordingStateChanged!(false);
      }
      rethrow;
    }
  }

  /// Listen specifically in Bangla
  Future<String> listenBangla() async {
    if (_isListening) {
      await stopListening();
    }
    
    final completer = Completer<String>();
    String recognizedText = '';
    
    // Set up the result callback
    final originalCallback = onSpeechResult;
    onSpeechResult = (text) {
      recognizedText = text;
      completer.complete(text);
    };
    
    try {
      await startListening(locale: 'bn-BD');
      
      // Wait for result or timeout
      final result = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          stopListening();
          return '';
        },
      );
      
      return result;
    } catch (e) {
      return '';
    } finally {
      // Restore original callback
      onSpeechResult = originalCallback;
      await stopListening();
    }
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    return await _speechToText.initialize();
  }
  
  /// Get available locales
  Future<List<String>> getAvailableLocales() async {
    try {
      final locales = await _speechToText.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      return ['en-US', 'bn-BD'];
    }
  }
  
  /// Get current locale
  Future<String> getCurrentLocale() async {
    try {
      final locales = await _speechToText.locales();
      return locales.firstWhere(
        (locale) => locale.localeId == 'bn-BD',
        orElse: () => locales.first,
      ).localeId;
    } catch (e) {
      return 'bn-BD';
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isListening) {
      await stopListening();
    }
    // No specific dispose method for SpeechToText
  }
}
