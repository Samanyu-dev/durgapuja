import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config/api_keys.dart';
import '../../models/generated_image.dart';

class KreaGenerativeFillService {
  static const String _baseUrl = 'https://api.krea.ai';

  final String _apiToken;

  KreaGenerativeFillService()
      : _apiToken = dotenv.env['KREA_API_TOKEN'] ?? ApiKeys.kreaApiKey;

  /// Performs generative fill using Krea's inpainting capabilities.
  /// When [referenceImage] is provided, the prompt is expected to already reference it
  /// (e.g. "Match the style of the reference image. ...").
  Future<String> performGenerativeFill({
    required String originalImageUrl,
    required String maskImageUrl,
    required String prompt,
    File? referenceImage,
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

      // Step 1: Submit the inpainting job (Krea may use a different path; if 404, we show a clear message)
      final generateUrl = Uri.parse('$_baseUrl/generate/inpainting/$model');
      final generateResponse = await http.post(
        generateUrl,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'image_url': originalImageUrl,
          'mask_url': maskImageUrl,
          'steps': steps,
        }),
      );

      print('Inpainting submit response status: ${generateResponse.statusCode}');
      final body = generateResponse.body;
      if (body.length < 500) print('Inpainting submit response body: $body');

      if (generateResponse.statusCode != 200) {
        String errorMessage = 'Failed to submit inpainting job';
        if (body.trim().toLowerCase().startsWith('<!doctype') ||
            body.trim().toLowerCase().startsWith('<html')) {
          errorMessage = 'Generative fill (inpainting) is not available for this account or endpoint. '
              'Try using Image-to-Image enhancement instead.';
        } else {
          try {
            final error = jsonDecode(body) as Map<String, dynamic>?;
            if (error != null) {
              errorMessage = error['message']?.toString() ??
                  error['detail']?.toString() ??
                  error['error']?.toString() ??
                  (body.length > 200 ? '${body.substring(0, 200)}...' : body);
            }
          } catch (_) {
            errorMessage = body.length > 200 ? '${body.substring(0, 200)}...' : body;
          }
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
            'Accept': 'application/json',
          },
        );

        if (statusResponse.statusCode != 200) {
          final sb = statusResponse.body;
          final msg = (sb.trim().toLowerCase().startsWith('<!doctype') || sb.trim().toLowerCase().startsWith('<html'))
              ? 'Service returned an error. Please try again.'
              : sb;
          throw Exception('Failed to check inpainting job status: $msg');
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

  /// Complete generative fill workflow using Krea.
  /// [referenceImage] is optional; when provided, the prompt should guide the model to use it.
  Future<String> completeGenerativeFill({
    required String originalImageUrl,
    required String maskImageUrl,
    required String prompt,
    File? referenceImage,
    String model = 'bfl/flux-1-dev',
    int steps = 30,
  }) async {
    try {
      return await performGenerativeFill(
        originalImageUrl: originalImageUrl,
        maskImageUrl: maskImageUrl,
        prompt: prompt,
        referenceImage: referenceImage,
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