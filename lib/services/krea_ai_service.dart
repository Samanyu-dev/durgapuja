import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_keys.dart';
import '../models/generated_image.dart';
import 'logging_service.dart';

class KreaAIService {
  static const String _baseUrl = 'https://api.krea.ai';

  final String _apiToken;

  KreaAIService()
      : _apiToken = ApiKeys.kreaApiKey;

  /// Debug helper to log detailed request/response information
  void _logRequest(String method, Uri url, Map<String, String>? headers, dynamic body) {
    LoggingService.logDebug('=== KREA API DEBUG ===');
    LoggingService.logDebug('Method: $method');
    LoggingService.logDebug('URL: $url');
    LoggingService.logDebug('Headers: ${headers ?? {}}');
    if (body != null) {
      LoggingService.logDebug('Body: ${body is String ? body : jsonEncode(body)}');
    }
    LoggingService.logDebug('=====================');
  }

  /// Debug helper to log response details
  void _logResponse(int statusCode, String body) {
    LoggingService.logDebug('=== KREA API RESPONSE ===');
    LoggingService.logDebug('Status: $statusCode');
    LoggingService.logDebug('Response starts with: ${body.substring(0, math.min(200, body.length))}${body.length > 200 ? '...' : ''}');
    
    // Check if response is HTML (the error we're trying to fix)
    if (body.trim().startsWith('<!doctype html') || body.trim().startsWith('<html')) {
      LoggingService.logDebug('⚠️  WARNING: Received HTML response instead of JSON!');
      LoggingService.logDebug('This usually means:');
      LoggingService.logDebug('  1. Wrong endpoint URL (missing /v1/ prefix)');
      LoggingService.logDebug('  2. Missing Accept: application/json header');
      LoggingService.logDebug('  3. Invalid API key or permissions');
      LoggingService.logDebug('  4. Using UI endpoint instead of API endpoint');
    }
    LoggingService.logDebug('========================');
  }

  /// Enhances simple prompts for Durga idols with detailed specifications
  String enhanceDurgaIdolPrompt(String prompt) {
    final lowerPrompt = prompt.toLowerCase();

    // Check if this is a simple Durga idol request
    final durgaKeywords = ['durga', 'durgapuja', 'durga puja', 'durgotsav', 'idol', 'murt'];
    final isDurgaRelated = durgaKeywords.any((keyword) => lowerPrompt.contains(keyword));

   
    if (isDurgaRelated && prompt.length < 50) {
      final enhancedPrompt = '''
Create a magnificent Durga idol with intricate details:
- Goddess Durga with divine golden skin texture, realistic facial structure, and benevolent expression
- Traditional Bengali features with almond-shaped eyes, arched eyebrows, and serene smile
- Elaborate gold jewelry including necklace, earrings, armlets, and crown with detailed gemstone work
- Rich traditional Bengali saree with golden borders and intricate patterns
- Multiple arms holding weapons (trident, mace, discus, conch) and blessing hand
- Lion vahana (vehicle) beneath her feet with detailed fur texture and fierce expression
- Decorative backdrop with traditional Bengali motifs, flowers, and ornamental elements
- High quality, photorealistic rendering with proper lighting and shadows
- Traditional Durga Puja color scheme with gold, red, and white accents
Original theme: $prompt
      '''.trim();

      return enhancedPrompt;
    }

    return prompt;
  }

  /// Generates an image from a text prompt using Krea's official API
  Future<GeneratedImage> generateImage(String prompt) async {
    final images = await generateImages(prompt, count: 1);
    return images.first;
  }

  /// Generates an image from a text prompt with reference images using Krea's official API
  Future<GeneratedImage> generateImageWithReferences(String prompt, List<File> referenceImages) async {
    final images = await generateImagesWithReferences(prompt, referenceImages, count: 1);
    return images.first;
  }

  /// Generates multiple images from a prompt with reference images
  /// Uses Flux model by default (fast and high quality)
  Future<List<GeneratedImage>> generateImagesWithReferences(String prompt, List<File> referenceImages, {int count = 1}) async {
    if (_apiToken.isEmpty) {
      throw Exception(
        'Krea API token not found. Please add KREA_API_TOKEN to your .env file.\n'
        'Generate your token at: https://krea.ai/settings/api-tokens'
      );
    }

    // Enhance prompt for Durga idols if needed
    final enhancedPrompt = enhanceDurgaIdolPrompt(prompt);

    final images = <GeneratedImage>[];

    // Generate images sequentially
    for (int i = 0; i < count; i++) {
      try {
        LoggingService.logDebug('Generating image ${i + 1} of $count with ${referenceImages.length} reference images...');
        LoggingService.logDebug('Using prompt: ${enhancedPrompt.substring(0, math.min(100, enhancedPrompt.length))}${enhancedPrompt.length > 100 ? '...' : ''}');

        // Step 1: Submit the generation job with reference images (using Flux model)
        final generateUrl = Uri.parse('$_baseUrl/generate/image/bfl/flux-1-dev');
        
        // Log the request details
        _logRequest('POST', generateUrl, {
          'Authorization': 'Bearer $_apiToken',
          'Accept': 'application/json',
        }, 'Multipart request with ${referenceImages.length} images');

        final request = http.MultipartRequest('POST', generateUrl)
          ..headers['Authorization'] = 'Bearer $_apiToken'
          ..headers['Accept'] = 'application/json' // Add Accept header for multipart requests too
          ..fields['prompt'] = enhancedPrompt;

        // Add reference images
        for (int j = 0; j < referenceImages.length; j++) {
          final imageFile = referenceImages[j];
          final imageBytes = await imageFile.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'reference_images',
            imageBytes,
            filename: 'reference_$j.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        }

        final response = await request.send();
        final responseString = await response.stream.bytesToString();

        // Log the response details
        _logResponse(response.statusCode, responseString);

        LoggingService.logDebug('Submit response status: ${response.statusCode}');
        LoggingService.logDebug('Submit response body: $responseString');

        if (response.statusCode != 200) {
          String errorMessage = 'Failed to submit job';
          try {
            final error = jsonDecode(responseString);
            errorMessage = error['message'] ?? error['detail'] ?? error['error'] ?? responseString;
          } catch (_) {
            errorMessage = responseString;
          }
          throw Exception('Failed to submit job: $errorMessage');
        }

        final jobData = jsonDecode(responseString);
        final jobId = jobData['job_id'] as String;
        LoggingService.logDebug('Job submitted: $jobId');

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
          
          LoggingService.logDebug('Job $jobId status: $status');

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

        LoggingService.logDebug('Image ${i + 1} generated successfully');
      } catch (e) {
        LoggingService.logDebug('Error generating image ${i + 1}: $e');
        rethrow;
      }
    }

    return images;
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

    // Enhance prompt for Durga idols if needed
    final enhancedPrompt = enhanceDurgaIdolPrompt(prompt);

    final images = <GeneratedImage>[];

    // Generate images sequentially
    for (int i = 0; i < count; i++) {
      try {
        LoggingService.logDebug('Generating image ${i + 1} of $count...');
        LoggingService.logDebug('Using prompt: ${enhancedPrompt.substring(0, math.min(100, enhancedPrompt.length))}${enhancedPrompt.length > 100 ? '...' : ''}');

        // Step 1: Submit the generation job (using Flux model)
        final generateUrl = Uri.parse('$_baseUrl/generate/image/bfl/flux-1-dev');
        
        // Log the request details
        _logRequest('POST', generateUrl, {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }, {
          'prompt': enhancedPrompt,
        });

        final generateResponse = await http.post(
          generateUrl,
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json', // This is CRITICAL to fix the HTML response issue
          },
          body: jsonEncode({
            'prompt': enhancedPrompt,
          }),
        );

        // Log the response details
        final responseString = generateResponse.body;
        _logResponse(generateResponse.statusCode, responseString);

        LoggingService.logDebug('Submit response status: ${generateResponse.statusCode}');
        LoggingService.logDebug('Submit response body: $responseString');

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
        LoggingService.logDebug('Job submitted: $jobId');

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
          
          LoggingService.logDebug('Job $jobId status: $status');

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

        LoggingService.logDebug('Image ${i + 1} generated successfully');
      } catch (e) {
        LoggingService.logDebug('Error generating image ${i + 1}: $e');
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

    // Enhance prompt for Durga idols if needed
    final enhancedPrompt = enhanceDurgaIdolPrompt(prompt);

    final images = <GeneratedImage>[];

    for (int i = 0; i < count; i++) {
      try {
        LoggingService.logDebug('Generating image ${i + 1} of $count with $model...');

        // Build endpoint URL
        final generateUrl = Uri.parse('$_baseUrl/generate/image/$model');

        // Build request body
        final requestBody = <String, dynamic>{
          'prompt': enhancedPrompt,
        };
        
        if (width != null) requestBody['width'] = width;
        if (height != null) requestBody['height'] = height;
        if (steps != null) requestBody['steps'] = steps;

        // Log the request details
        _logRequest('POST', generateUrl, {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }, requestBody);

        final generateResponse = await http.post(
          generateUrl,
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json', // Add missing Accept header
          },
          body: jsonEncode(requestBody),
        );

        // Log the response details
        final responseString = generateResponse.body;
        _logResponse(generateResponse.statusCode, responseString);

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
            
            LoggingService.logDebug('Image ${i + 1} generated successfully');
            break;
          } else if (status == 'failed') {
            throw Exception('Generation failed: ${statusData['error']}');
          }
        }
      } catch (e) {
        LoggingService.logDebug('Error generating image ${i + 1}: $e');
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

  /// Test function to verify Krea API is working correctly
  /// This helps debug the HTML response issue
  Future<void> testApiConnection() async {
    if (_apiToken.isEmpty) {
      throw Exception('Krea API token not found. Please add KREA_API_TOKEN to your .env file.');
    }

    LoggingService.logDebug('=== TESTING KREA API CONNECTION ===');
    LoggingService.logDebug('Testing with a simple prompt...');

    try {
      // Test with a simple prompt
      final testPrompt = 'A simple test image';
      final generateUrl = Uri.parse('$_baseUrl/generate/image/bfl/flux-1-dev');
      
      _logRequest('POST', generateUrl, {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }, {
        'prompt': testPrompt,
      });

      final response = await http.post(
        generateUrl,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'prompt': testPrompt,
        }),
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        LoggingService.logDebug('✅ API connection successful!');
        LoggingService.logDebug('The HTML response issue has been fixed.');
        
        // Try to parse the response to make sure it's valid JSON
        try {
          final jobData = jsonDecode(response.body);
          if (jobData.containsKey('job_id')) {
            LoggingService.logDebug('✅ Response contains valid job data');
            LoggingService.logDebug('Job ID: ${jobData['job_id']}');
          } else {
            LoggingService.logDebug('⚠️  Response structure unexpected');
          }
        } catch (e) {
          LoggingService.logDebug('❌ Response is not valid JSON: $e');
        }
      } else {
        LoggingService.logDebug('❌ API connection failed');
        LoggingService.logDebug('Status: ${response.statusCode}');
        LoggingService.logDebug('Response: ${response.body}');
      }
    } catch (e) {
      LoggingService.logDebug('❌ Test failed with error: $e');
    }
  }

  /// Verify API key and project status
  Future<void> verifyApiKey() async {
    if (_apiToken.isEmpty) {
      throw Exception('Krea API token not found. Please add KREA_API_TOKEN to your .env file.');
    }

    LoggingService.logDebug('=== VERIFYING API KEY ===');
    
    try {
      // Try to make a simple request to check if the API key is valid
      final testUrl = Uri.parse('$_baseUrl/generate/image/bfl/flux-1-dev');
      
      final response = await http.post(
        testUrl,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'prompt': 'test',
        }),
      );

      if (response.statusCode == 200) {
        LoggingService.logDebug('✅ API key is valid and working');
      } else if (response.statusCode == 401) {
        LoggingService.logDebug('❌ Invalid API key');
        LoggingService.logDebug('Please check your KREA_API_TOKEN in .env file');
      } else if (response.statusCode == 403) {
        LoggingService.logDebug('❌ API key valid but project not enabled');
        LoggingService.logDebug('Please check your Krea dashboard to ensure your project is active');
      } else {
        LoggingService.logDebug('❌ Unexpected status: ${response.statusCode}');
        LoggingService.logDebug('Response: ${response.body}');
      }
    } catch (e) {
      LoggingService.logDebug('❌ Verification failed: $e');
    }
  }
}