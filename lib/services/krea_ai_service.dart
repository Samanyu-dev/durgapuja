import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/generated_image.dart';

class KreaAIService {
  static const String _baseUrl = 'https://api.krea.ai';
  
  final String _apiToken;

  KreaAIService()
      : _apiToken = dotenv.env['KREA_API_TOKEN'] ?? '';

  /// Generates an image from a text prompt using Krea's official API
  Future<GeneratedImage> generateImage(String prompt) async {
    final images = await generateImages(prompt, count: 1);
    return images.first;
  }

  /// Generates multiple images from a prompt
  /// Uses Flux model by default (fast and high quality)
  Future<List<GeneratedImage>> generateImages(String prompt, {int count = 1}) async {
    if (_apiToken.isEmpty) {
      throw Exception(
        'Krea API token not found. Please add KREA_API_TOKEN to your .env file.\n'
        'Generate your token at: https://krea.ai/settings/api-tokens'
      );
    }

    final images = <GeneratedImage>[];
    
    // Generate images sequentially
    for (int i = 0; i < count; i++) {
      try {
        print('Generating image ${i + 1} of $count...');
        
        // Step 1: Submit the generation job (using Flux model)
        final generateUrl = Uri.parse('$_baseUrl/generate/image/bfl/flux-1-dev');
        final generateResponse = await http.post(
          generateUrl,
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'prompt': prompt,
          }),
        );

        print('Submit response status: ${generateResponse.statusCode}');
        print('Submit response body: ${generateResponse.body}');

        if (generateResponse.statusCode != 200) {
          String errorMessage = 'Failed to submit job';
          try {
            final error = jsonDecode(generateResponse.body);
            errorMessage = error['message'] ?? error['detail'] ?? error['error'] ?? generateResponse.body;
          } catch (_) {
            errorMessage = generateResponse.body;
          }
          throw Exception('Failed to submit job: $errorMessage');
        }

        final jobData = jsonDecode(generateResponse.body);
        final jobId = jobData['job_id'] as String;
        print('Job submitted: $jobId');

        // Step 2: Poll for completion
        final jobUrl = Uri.parse('$_baseUrl/jobs/$jobId');
        String status = 'queued';
        Map<String, dynamic>? result;
        
        // Poll for up to 120 seconds (2 minutes)
        for (int attempt = 0; attempt < 60; attempt++) {
          await Future.delayed(Duration(seconds: 2));
          
          final statusResponse = await http.get(
            jobUrl,
            headers: {
              'Authorization': 'Bearer $_apiToken',
            },
          );

          if (statusResponse.statusCode != 200) {
            throw Exception('Failed to check job status: ${statusResponse.body}');
          }

          final statusData = jsonDecode(statusResponse.body);
          status = statusData['status'] as String;
          
          print('Job $jobId status: $status');

          if (status == 'completed') {
            result = statusData['result'] as Map<String, dynamic>?;
            break;
          } else if (status == 'failed') {
            final error = statusData['error'] ?? 'Unknown error';
            throw Exception('Generation failed: $error');
          }
          // Continue polling if status is queued, backlogged, or in_progress
        }

        if (status != 'completed' || result == null) {
          throw Exception('Job timed out after 2 minutes');
        }

        // Step 3: Extract the image URL
        final urls = result['urls'] as List?;
        if (urls == null || urls.isEmpty) {
          throw Exception('No image URL in response');
        }

        final currentTime = DateTime.now();
        images.add(GeneratedImage(
          id: '${currentTime.millisecondsSinceEpoch}_$i',
          url: urls[0] as String,
          prompt: prompt,
          createdAt: currentTime,
        ));

        print('Image ${i + 1} generated successfully');
      } catch (e) {
        print('Error generating image ${i + 1}: $e');
        rethrow;
      }
    }

    return images;
  }

  /// Generate images using specific models
  /// Available models:
  /// - 'bfl/flux-1-dev' (recommended - fast and high quality)
  /// - 'google/imagen-4-fast' (Google's Imagen 4 - fast)
  /// - 'google/imagen-4' (Google's Imagen 4 - high quality)
  /// - 'ideogram/ideogram-3' (Ideogram v3)
  /// - 'google/nano-banana-pro' (Nano Banana Pro)
  Future<List<GeneratedImage>> generateImagesWithModel(
    String prompt, {
    int count = 1,
    String model = 'bfl/flux-1-dev',
    int? width,
    int? height,
    int? steps,
  }) async {
    if (_apiToken.isEmpty) {
      throw Exception('Krea API token not found');
    }

    final images = <GeneratedImage>[];
    
    for (int i = 0; i < count; i++) {
      try {
        print('Generating image ${i + 1} of $count with $model...');
        
        // Build endpoint URL
        final generateUrl = Uri.parse('$_baseUrl/generate/image/$model');
        
        // Build request body
        final requestBody = <String, dynamic>{
          'prompt': prompt,
        };
        
        if (width != null) requestBody['width'] = width;
        if (height != null) requestBody['height'] = height;
        if (steps != null) requestBody['steps'] = steps;

        final generateResponse = await http.post(
          generateUrl,
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (generateResponse.statusCode != 200) {
          String errorMessage = 'Failed to submit job';
          try {
            final error = jsonDecode(generateResponse.body);
            errorMessage = error['message'] ?? error['detail'] ?? error['error'] ?? generateResponse.body;
          } catch (_) {
            errorMessage = generateResponse.body;
          }
          throw Exception(errorMessage);
        }

        final jobData = jsonDecode(generateResponse.body);
        final jobId = jobData['job_id'] as String;

        // Poll for completion
        final jobUrl = Uri.parse('$_baseUrl/jobs/$jobId');
        
        for (int attempt = 0; attempt < 60; attempt++) {
          await Future.delayed(Duration(seconds: 2));
          
          final statusResponse = await http.get(
            jobUrl,
            headers: {
              'Authorization': 'Bearer $_apiToken',
            },
          );

          if (statusResponse.statusCode != 200) {
            throw Exception('Failed to check job status: ${statusResponse.body}');
          }

          final statusData = jsonDecode(statusResponse.body);
          final status = statusData['status'] as String;

          if (status == 'completed') {
            final result = statusData['result'] as Map<String, dynamic>?;
            final urls = result?['urls'] as List?;
            
            if (urls == null || urls.isEmpty) {
              throw Exception('No image URL in response');
            }

            final currentTime = DateTime.now();
            images.add(GeneratedImage(
              id: '${currentTime.millisecondsSinceEpoch}_$i',
              url: urls[0] as String,
              prompt: prompt,
              createdAt: currentTime,
            ));
            
            print('Image ${i + 1} generated successfully');
            break;
          } else if (status == 'failed') {
            throw Exception('Generation failed: ${statusData['error']}');
          }
        }
      } catch (e) {
        print('Error generating image ${i + 1}: $e');
        rethrow;
      }
    }

    return images;
  }

  /// Quick generation with Imagen 4 Fast (fastest option)
  Future<List<GeneratedImage>> generateImagesFast(String prompt, {int count = 1}) async {
    return generateImagesWithModel(
      prompt,
      count: count,
      model: 'google/imagen-4-fast',
    );
  }

  /// High quality generation with Imagen 4
  Future<List<GeneratedImage>> generateImagesHighQuality(String prompt, {int count = 1}) async {
    return generateImagesWithModel(
      prompt,
      count: count,
      model: 'google/imagen-4',
    );
  }
}