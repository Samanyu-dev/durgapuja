import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Service for speech-to-text using OpenAI's Whisper API
/// Provides excellent Bengali speech recognition
class OpenAISpeechService {
  final String apiKey;
  static const String _whisperEndpoint = 'https://api.openai.com/v1/audio/transcriptions';
  static const String _translationEndpoint = 'https://api.openai.com/v1/audio/translations';
  static const String _chatEndpoint = 'https://api.openai.com/v1/chat/completions';

  OpenAISpeechService(this.apiKey);

  /// Transcribes audio file to Bengali text using Whisper API
  /// 
  /// [audioFile] - Audio file (supports mp3, mp4, mpeg, mpga, m4a, wav, webm)
  /// [language] - Optional language code (e.g., 'bn' for Bengali)
  /// [prompt] - Optional context to improve accuracy
  /// 
  /// Returns the transcribed text in Bengali
  Future<String> transcribeToBengali(
    File audioFile, {
    String? language,
    String? prompt,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_whisperEndpoint));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $apiKey';
      
      // Add audio file
      final fileStream = http.ByteStream(audioFile.openRead());
      final fileLength = await audioFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: path.basename(audioFile.path),
      );
      request.files.add(multipartFile);
      
      // Add parameters
      request.fields['model'] = 'whisper-1';
      request.fields['response_format'] = 'json';
      
      if (language != null) {
        request.fields['language'] = language;
      } else {
        request.fields['language'] = 'bn'; // Default to Bengali
      }
      
      if (prompt != null) {
        request.fields['prompt'] = prompt;
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['text'] ?? '';
      } else {
        print('OpenAI Whisper API error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in transcribeToBengali: $e');
      rethrow;
    }
  }

  /// Translates audio file to English using Whisper API
  /// This directly transcribes and translates to English
  /// 
  /// [audioFile] - Audio file in any language
  /// 
  /// Returns the translated text in English
  Future<String> translateToEnglish(File audioFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_translationEndpoint));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $apiKey';
      
      // Add audio file
      final fileStream = http.ByteStream(audioFile.openRead());
      final fileLength = await audioFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: path.basename(audioFile.path),
      );
      request.files.add(multipartFile);
      
      // Add parameters
      request.fields['model'] = 'whisper-1';
      request.fields['response_format'] = 'json';
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['text'] ?? '';
      } else {
        print('OpenAI Translation API error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to translate audio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in translateToEnglish: $e');
      rethrow;
    }
  }

  /// Transcribes audio and provides both Bengali and English versions
  /// 
  /// [audioFile] - Audio file to transcribe
  /// [prompt] - Optional context for better accuracy
  /// 
  /// Returns a map with 'bengali' and 'english' keys
  Future<Map<String, String>> transcribeAndTranslate(
    File audioFile, {
    String? prompt,
  }) async {
    try {
      // Get Bengali transcription
      final bengaliText = await transcribeToBengali(
        audioFile,
        language: 'bn',
        prompt: prompt,
      );
      
      // Get English translation
      final englishText = await translateToEnglish(audioFile);
      
      return {
        'bengali': bengaliText,
        'english': englishText,
      };
    } catch (e) {
      print('Error in transcribeAndTranslate: $e');
      return {
        'bengali': '',
        'english': '',
      };
    }
  }

  /// Translates Bengali text to English using ChatGPT
  /// Use this when you already have Bengali text and need translation
  /// 
  /// [bengaliText] - Bengali text to translate
  /// 
  /// Returns English translation
  Future<String> translateBengaliTextToEnglish(String bengaliText) async {
    if (bengaliText.isEmpty) return '';
    
    try {
      final response = await http.post(
        Uri.parse(_chatEndpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional Bengali to English translator. Translate the following Bengali text to English accurately.',
            },
            {
              'role': 'user',
              'content': bengaliText,
            },
          ],
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['choices'][0]['message']['content'] ?? '';
      } else {
        print('OpenAI Chat API error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to translate text: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in translateBengaliTextToEnglish: $e');
      return '';
    }
  }

  /// Gets supported audio formats
  static List<String> getSupportedFormats() {
    return ['mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm'];
  }

  /// Validates if the audio file format is supported
  static bool isFormatSupported(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceAll('.', '');
    return getSupportedFormats().contains(extension);
  }

  /// Gets the maximum file size allowed (25 MB)
  static int getMaxFileSizeBytes() {
    return 25 * 1024 * 1024; // 25 MB
  }

  /// Validates if the file size is within limits
  static Future<bool> isFileSizeValid(File file) async {
    final fileSize = await file.length();
    return fileSize <= getMaxFileSizeBytes();
  }
}