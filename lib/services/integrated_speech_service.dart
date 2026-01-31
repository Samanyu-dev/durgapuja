import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'openai_speech_service.dart';
import '../config/api_keys.dart';

/// Integrated speech service that handles recording and transcription
/// Uses OpenAI's Whisper API for excellent Bengali speech recognition
class IntegratedSpeechService {
  final OpenAISpeechService _openAIService;
  final AudioRecorder _recorder = AudioRecorder();
  
  File? _recordedAudioFile;
  bool _isRecording = false;
  StreamSubscription<RecordState>? _recordStateSubscription;
  
  IntegratedSpeechService()
      : _openAIService = OpenAISpeechService(ApiKeys.openAI);

  /// Checks if recording permission is granted
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  /// Starts recording audio from the microphone
  /// 
  /// Returns true if recording started successfully
  Future<bool> startRecording() async {
    try {
      if (_isRecording) {
        print('Already recording');
        return false;
      }

      // Check permission
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        print('No microphone permission');
        return false;
      }

      // Create a temporary file path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(tempDir.path, 'audio_$timestamp.m4a');

      // Start recording with configuration
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // Good quality, widely supported
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1, // Mono is fine for speech
        ),
        path: filePath,
      );

      _isRecording = true;
      _recordedAudioFile = File(filePath);
      
      print('Recording started: $filePath');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Stops recording and returns the audio file path
  /// 
  /// Returns the File object of the recorded audio, or null if recording failed
  Future<File?> stopRecording() async {
    if (!_isRecording) {
      print('Not currently recording');
      return null;
    }

    try {
      final recordPath = await _recorder.stop();
      _isRecording = false;

      if (recordPath != null && recordPath.isNotEmpty) {
        _recordedAudioFile = File(recordPath);
        print('Recording stopped: $recordPath');
        
        // Validate file
        if (await _recordedAudioFile!.exists()) {
          final fileSize = await _recordedAudioFile!.length();
          print('Recorded file size: ${fileSize / 1024} KB');
          
          if (fileSize == 0) {
            print('Warning: Recorded file is empty');
            return null;
          }
          
          return _recordedAudioFile;
        } else {
          print('Error: Recorded file does not exist');
          return null;
        }
      }

      print('No recording path returned');
      return null;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancels the current recording without saving
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _recorder.stop();
      _isRecording = false;
      
      // Delete the file if it exists
      if (_recordedAudioFile != null && await _recordedAudioFile!.exists()) {
        await _recordedAudioFile!.delete();
      }
      
      _recordedAudioFile = null;
      print('Recording cancelled');
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  /// Records audio and transcribes it to Bengali using OpenAI Whisper
  /// 
  /// [maxDuration] - Optional maximum recording duration
  /// 
  /// Returns the Bengali transcription text
  Future<String> recordAndTranscribeBengali({
    Duration maxDuration = const Duration(seconds: 30),
  }) async {
    try {
      // Start recording
      final started = await startRecording();
      if (!started) {
        return '';
      }

      // Wait for max duration (in real app, you'd have a UI button to stop)
      await Future.delayed(maxDuration);

      // Stop recording
      final audioFile = await stopRecording();
      if (audioFile == null) {
        return '';
      }

      // Transcribe to Bengali
      return await _openAIService.transcribeToBengali(audioFile);
    } catch (e) {
      print('Error in recordAndTranscribeBengali: $e');
      return '';
    }
  }

  /// Records audio and gets both Bengali and English versions
  /// 
  /// [maxDuration] - Optional maximum recording duration
  /// 
  /// Returns a map with 'bengali' and 'english' keys
  Future<Map<String, String>> recordAndTranscribe({
    Duration maxDuration = const Duration(seconds: 30),
  }) async {
    try {
      // Start recording
      final started = await startRecording();
      if (!started) {
        return {'bengali': '', 'english': ''};
      }

      // Wait for max duration (in real app, use UI button to stop)
      await Future.delayed(maxDuration);

      // Stop recording
      final audioFile = await stopRecording();
      if (audioFile == null) {
        return {'bengali': '', 'english': ''};
      }

      // Transcribe and translate
      return await _openAIService.transcribeAndTranslate(audioFile);
    } catch (e) {
      print('Error in recordAndTranscribe: $e');
      return {'bengali': '', 'english': ''};
    }
  }

  /// Transcribes an existing audio file to Bengali
  /// 
  /// [audioFile] - The audio file to transcribe
  /// [prompt] - Optional context to improve accuracy
  /// 
  /// Returns the Bengali transcription
  Future<String> transcribeAudioFile(
    File audioFile, {
    String? prompt,
  }) async {
    try {
      // Validate format
      if (!OpenAISpeechService.isFormatSupported(audioFile.path)) {
        print('Unsupported audio format: ${path.extension(audioFile.path)}');
        return '';
      }

      // Validate size
      if (!await OpenAISpeechService.isFileSizeValid(audioFile)) {
        print('Audio file is too large (max 25 MB)');
        return '';
      }

      return await _openAIService.transcribeToBengali(
        audioFile,
        prompt: prompt,
      );
    } catch (e) {
      print('Error transcribing audio file: $e');
      return '';
    }
  }

  /// Transcribes audio file and provides both Bengali and English
  /// 
  /// [audioFile] - The audio file to transcribe
  /// 
  /// Returns a map with 'bengali' and 'english' keys
  Future<Map<String, String>> transcribeAudioFileBoth(File audioFile) async {
    try {
      // Validate format
      if (!OpenAISpeechService.isFormatSupported(audioFile.path)) {
        print('Unsupported audio format: ${path.extension(audioFile.path)}');
        return {'bengali': '', 'english': ''};
      }

      // Validate size
      if (!await OpenAISpeechService.isFileSizeValid(audioFile)) {
        print('Audio file is too large (max 25 MB)');
        return {'bengali': '', 'english': ''};
      }

      return await _openAIService.transcribeAndTranslate(audioFile);
    } catch (e) {
      print('Error transcribing audio file: $e');
      return {'bengali': '', 'english': ''};
    }
  }

  /// Translates Bengali text to English using OpenAI
  /// 
  /// [bengaliText] - The Bengali text to translate
  /// 
  /// Returns the English translation
  Future<String> translateBengaliText(String bengaliText) async {
    try {
      return await _openAIService.translateBengaliTextToEnglish(bengaliText);
    } catch (e) {
      print('Error translating text: $e');
      return '';
    }
  }

  /// Gets the current recording state
  bool get isRecording => _isRecording;

  /// Gets the path of the last recorded audio file
  String? get recordedAudioPath => _recordedAudioFile?.path;

  /// Gets the last recorded audio file
  File? get recordedAudioFile => _recordedAudioFile;

  /// Gets list of supported audio formats
  List<String> get supportedFormats => OpenAISpeechService.getSupportedFormats();

  /// Listen specifically in Bangla (convenience method)
  /// Records audio and transcribes it to Bengali
  Future<String> listenBangla() async {
    return await recordAndTranscribeBengali();
  }

  /// Stop listening (convenience method)
  /// Stops the current recording and returns the transcribed text
  Future<String> stopListening() async {
    final audioFile = await stopRecording();
    if (audioFile == null) {
      return '';
    }
    
    return await _openAIService.transcribeToBengali(audioFile);
  }

  /// Start listening for speech (convenience method)
  /// This is a wrapper around startRecording for compatibility
  Future<bool> startListening() async {
    return await startRecording();
  }

  /// Cleans up resources
  void dispose() {
    _recordStateSubscription?.cancel();
    _recorder.dispose();
    _recordedAudioFile = null;
    _isRecording = false;
  }
}
