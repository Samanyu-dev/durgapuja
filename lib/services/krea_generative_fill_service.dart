import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/generated_image.dart';

class KreaGenerativeFillService {
  static const String _baseUrl = 'https://api.krea.ai';

  final String _apiToken;

  KreaGenerativeFillService()
      : _apiToken = dotenv.env['KREA_API_TOKEN'] ?? '';

  /// Performs generative fill using Krea's inpainting capabilities
  /// This replaces Adobe Firefly for a more cost-effective solution
  Future<String> performGenerativeFill({
    required String originalImageUrl,
    required String maskImageUrl,
    required String prompt,
    String model = 'bfl/flux-1-dev', // Fast and high quality
    int steps = 30,
  }) async {
    if (_apiToken.isEmpty) {
      throw Exception(
        'Krea API token not found. Please add KREA_API_TOKEN to your .env file.\n'
        'Generate your token at: https://krea.ai/settings/api-tokens'
      );
    }

    try {
      print('Starting Krea generative fill...');
      print('Original image: $originalImageUrl');
      print('Mask image: $maskImageUrl');
      print('Prompt: $prompt');

      // Step 1: Submit the inpainting job
      final generateUrl = Uri.parse('$_baseUrl/generate/inpainting/$model');
      final generateResponse = await http.post(
        generateUrl,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'image_url': originalImageUrl,
          'mask_url': maskImageUrl,
          'steps': steps,
        }),
      );

      print('Inpainting submit response status: ${generateResponse.statusCode}');
      print('Inpainting submit response body: ${generateResponse.body}');

      if (generateResponse.statusCode != 200) {
        String errorMessage = 'Failed to submit inpainting job';
        try {
          final error = jsonDecode(generateResponse.body);
          errorMessage = error['message'] ?? error['detail'] ?? error['error'] ?? generateResponse.body;
        } catch (_) {
          errorMessage = generateResponse.body;
        }
        throw Exception('Failed to submit inpainting job: $errorMessage');
      }

      final jobData = jsonDecode(generateResponse.body);
      final jobId = jobData['job_id'] as String;
      print('Inpainting job submitted: $jobId');

      // Step 2: Poll for completion
      final jobUrl = Uri.parse('$_baseUrl/jobs/$jobId');
      String status = 'queued';
      Map<String, dynamic>? result;
      
      // Poll for up to 180 seconds (3 minutes) for inpainting
      for (int attempt = 0; attempt < 90; attempt++) {
        await Future.delayed(Duration(seconds: 2));
        
        final statusResponse = await http.get(
          jobUrl,
          headers: {
            'Authorization': 'Bearer $_apiToken',
          },
        );

        if (statusResponse.statusCode != 200) {
          throw Exception('Failed to check inpainting job status: ${statusResponse.body}');
        }

        final statusData = jsonDecode(statusResponse.body);
        status = statusData['status'] as String;
        
        print('Inpainting job $jobId status: $status');

        if (status == 'completed') {
          result = statusData['result'] as Map<String, dynamic>?;
          break;
        } else if (status == 'failed') {
          final error = statusData['error'] ?? 'Unknown error';
          throw Exception('Inpainting failed: $error');
        }
        // Continue polling if status is queued, backlogged, or in_progress
      }

      if (status != 'completed' || result == null) {
        throw Exception('Inpainting job timed out after 3 minutes');
      }

      // Step 3: Extract the edited image URL
      final urls = result['urls'] as List?;
      if (urls == null || urls.isEmpty) {
        throw Exception('No edited image URL in response');
      }

      final editedImageUrl = urls[0] as String;
      print('Inpainting completed successfully: $editedImageUrl');
      
      return editedImageUrl;
    } catch (e) {
      print('Error in Krea generative fill: $e');
      throw Exception('Generative fill failed: $e');
    }
  }

  /// Complete generative fill workflow using Krea
  Future<String> completeGenerativeFill({
    required String originalImageUrl,
    required String maskImageUrl,
    required String prompt,
    String model = 'bfl/flux-1-dev',
    int steps = 30,
  }) async {
    try {
      return await performGenerativeFill(
        originalImageUrl: originalImageUrl,
        maskImageUrl: maskImageUrl,
        prompt: prompt,
        model: model,
        steps: steps,
      );
    } catch (e) {
      print('Krea generative fill workflow failed: $e');
      throw Exception('Krea generative fill workflow failed: $e');
    }
  }

  /// Enhanced prompt for Durga idol editing
  String enhanceEditPrompt(String basePrompt, String elementType, String originalPrompt) {
    final enhancedPrompt = '''
Edit the ${elementType.toLowerCase()} of this Durga idol design:

Original design: $originalPrompt

Edit request: $basePrompt

Requirements:
- Only modify the ${elementType.toLowerCase()}
- Keep all other elements exactly the same
- Maintain the overall composition and style
- Ensure seamless integration with existing elements
- Preserve the traditional Bengali Durga Puja aesthetic
- Focus specifically on: $basePrompt

Please make the edit look natural and professional, as if it was part of the original design.
''';

    return enhancedPrompt;
  }

  /// Quick generative fill using Flux model (recommended)
  Future<String> performQuickFill({
    required String originalImageUrl,
    required String maskImageUrl,
    required String prompt,
  }) async {
    return performGenerativeFill(
      originalImageUrl: originalImageUrl,
      maskImageUrl: maskImageUrl,
      prompt: prompt,
      model: 'bfl/flux-1-dev',
      steps: 25,
    );
  }

  /// High quality generative fill using Imagen 4
  Future<String> performHighQualityFill({
    required String originalImageUrl,
    required String maskImageUrl,
    required String prompt,
  }) async {
    return performGenerativeFill(
      originalImageUrl: originalImageUrl,
      maskImageUrl: maskImageUrl,
      prompt: prompt,
      model: 'google/imagen-4',
      steps: 50,
    );
  }
}