import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logging_service.dart';

class KreaEnhancementService {
  static const String _baseUrl = 'https://api.krea.ai';

  final String _apiToken;

  KreaEnhancementService()
      : _apiToken = dotenv.env['KREA_API_KEY'] ?? '';

  /// Enhances image quality, lighting, and details using Krea's enhancement API
  Future<String> enhanceImage({
    required String imageUrl,
    String enhancementType = 'auto',
    String polishLevel = 'professional',
  }) async {
    if (_apiToken.isEmpty) {
      throw Exception(
        'Krea API token not found. Please add KREA_API_TOKEN to your .env file.\n'
        'Generate your token at: https://krea.ai/settings/api-tokens'
      );
    }

    try {
      LoggingService.logDebug('Starting Krea image enhancement...');
      LoggingService.logDebug('Original image: $imageUrl');

      // Step 1: Submit the enhancement job
      final enhanceUrl = Uri.parse('$_baseUrl/generate/enhance');
      final enhanceResponse = await http.post(
        enhanceUrl,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_url': imageUrl,
          'enhancement_type': enhancementType,
          'polish_level': polishLevel,
        }),
      );

      LoggingService.logDebug('Enhancement submit response status: ${enhanceResponse.statusCode}');
      LoggingService.logDebug('Enhancement submit response body: ${enhanceResponse.body}');

      if (enhanceResponse.statusCode != 200) {
        String errorMessage = 'Failed to submit enhancement job';
        try {
          final error = jsonDecode(enhanceResponse.body);
          errorMessage = error['message'] ?? error['detail'] ?? error['error'] ?? enhanceResponse.body;
        } catch (_) {
          errorMessage = enhanceResponse.body;
        }
        throw Exception('Failed to submit enhancement job: $errorMessage');
      }

      final jobData = jsonDecode(enhanceResponse.body);
      final jobId = jobData['job_id'] as String;
      LoggingService.logDebug('Enhancement job submitted: $jobId');

      // Step 2: Poll for completion
      final jobUrl = Uri.parse('$_baseUrl/jobs/$jobId');
      String status = 'queued';
      Map<String, dynamic>? result;
      
      // Poll for up to 120 seconds (2 minutes) for enhancement
      for (int attempt = 0; attempt < 60; attempt++) {
        await Future.delayed(Duration(seconds: 2));
        
        final statusResponse = await http.get(
          jobUrl,
          headers: {
            'Authorization': 'Bearer $_apiToken',
          },
        );

        if (statusResponse.statusCode != 200) {
          throw Exception('Failed to check enhancement job status: ${statusResponse.body}');
        }

        final statusData = jsonDecode(statusResponse.body);
        status = statusData['status'] as String;
        
        LoggingService.logDebug('Enhancement job $jobId status: $status');

        if (status == 'completed') {
          result = statusData['result'] as Map<String, dynamic>?;
          break;
        } else if (status == 'failed') {
          final error = statusData['error'] ?? 'Unknown error';
          throw Exception('Enhancement failed: $error');
        }
        // Continue polling if status is queued, backlogged, or in_progress
      }

      if (status != 'completed' || result == null) {
        throw Exception('Enhancement job timed out after 2 minutes');
      }

      // Step 3: Extract the enhanced image URL
      final urls = result['urls'] as List?;
      if (urls == null || urls.isEmpty) {
        throw Exception('No enhanced image URL in response');
      }

      final enhancedImageUrl = urls[0] as String;
      LoggingService.logDebug('Enhancement completed successfully: $enhancedImageUrl');
      
      return enhancedImageUrl;
    } catch (e) {
      LoggingService.logDebug('Error in Krea enhancement: $e');
      throw Exception('Image enhancement failed: $e');
    }
  }

  /// Complete enhancement workflow with auto-detection
  Future<String> completeEnhancement({
    required String imageUrl,
    bool applyAutoEnhancement = true,
    bool applyProfessionalPolish = true,
  }) async {
    try {
      String currentImageUrl = imageUrl;

      // Step 1: Auto-enhancement (lighting, color, details)
      if (applyAutoEnhancement) {
        currentImageUrl = await enhanceImage(
          imageUrl: currentImageUrl,
          enhancementType: 'auto',
          polishLevel: 'standard',
        );
      }

      // Step 2: Professional polish (quality improvement, sharpening)
      if (applyProfessionalPolish) {
        currentImageUrl = await enhanceImage(
          imageUrl: currentImageUrl,
          enhancementType: 'polish',
          polishLevel: 'professional',
        );
      }

      return currentImageUrl;
    } catch (e) {
      LoggingService.logDebug('Krea enhancement workflow failed: $e');
      throw Exception('Krea enhancement workflow failed: $e');
    }
  }

  /// Quick enhancement using standard settings
  Future<String> performQuickEnhancement(String imageUrl) async {
    return enhanceImage(
      imageUrl: imageUrl,
      enhancementType: 'auto',
      polishLevel: 'standard',
    );
  }

  /// High-quality enhancement for professional results
  Future<String> performHighQualityEnhancement(String imageUrl) async {
    return enhanceImage(
      imageUrl: imageUrl,
      enhancementType: 'professional',
      polishLevel: 'premium',
    );
  }

  /// Lighting-specific enhancement
  Future<String> enhanceLighting(String imageUrl) async {
    return enhanceImage(
      imageUrl: imageUrl,
      enhancementType: 'lighting',
      polishLevel: 'auto',
    );
  }

  /// Color correction and enhancement
  Future<String> enhanceColors(String imageUrl) async {
    return enhanceImage(
      imageUrl: imageUrl,
      enhancementType: 'color',
      polishLevel: 'auto',
    );
  }

  /// Detail enhancement and sharpening
  Future<String> enhanceDetails(String imageUrl) async {
    return enhanceImage(
      imageUrl: imageUrl,
      enhancementType: 'details',
      polishLevel: 'auto',
    );
  }
}