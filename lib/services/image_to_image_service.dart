import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config/api_keys.dart';
import '../../models/generated_image.dart';
import 'krea_ai_service.dart';
import 'krea_enhancement_service.dart';

class ImageToImageService {
  static const String _baseUrl = 'https://api.krea.ai';
  static const String _tokenError =
      'Krea API token not found. Set KREA_API_TOKEN in .env or add kreaApiKey in lib/config/api_keys.dart. Get token at: https://krea.ai/settings/api-tokens';

  final String _apiToken;

  ImageToImageService()
      : _apiToken = dotenv.env['KREA_API_TOKEN'] ?? ApiKeys.kreaApiKey;

  /// Uploads a local image to Krea assets and returns the public image URL.
  Future<String> _uploadAsset(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw Exception('Image file not found: $imagePath');
    }
    final uri = Uri.parse('$_baseUrl/assets');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_apiToken'
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      String msg = response.body;
      try {
        final err = jsonDecode(response.body);
        msg = err['message'] ?? err['detail'] ?? err['error'] ?? msg;
      } catch (_) {}
      throw Exception('Failed to upload image: $msg');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final imageUrl = data['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Upload response missing image_url');
    }
    return imageUrl;
  }

  /// Performs image-to-image generation (upload + enhance). Reference image optional.
  Future<String> generateImageToImage({
    required String originalImagePath,
    required String prompt,
    String enhancementType = 'enhance',
    String? referenceImagePath,
    double strength = 0.7,
    int steps = 30,
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);
    try {
      print('Starting Krea image-to-image (upload + enhance)...');
      final imageUrl = await _uploadAsset(originalImagePath);
      return await KreaEnhancementService().enhanceImage(
        imageUrl: imageUrl,
        enhancementType: 'auto',
        polishLevel: 'professional',
      );
    } catch (e) {
      print('Error in Krea image-to-image generation: $e');
      rethrow;
    }
  }

  /// Enhances an existing image with AI improvements (upload to Krea + enhance).
  Future<String> enhanceExistingImage({
    required String imagePath,
    String? prompt,
    String enhancementType = 'auto',
    bool enhanceDetails = true,
    bool enhanceColors = true,
    bool enhanceLighting = true,
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);

    try {
      print('Starting Krea image enhancement (upload + enhance)...');
      final imageUrl = await _uploadAsset(imagePath);
      final enhancedUrl = await KreaEnhancementService().enhanceImage(
        imageUrl: imageUrl,
        enhancementType: enhancementType,
        polishLevel: 'professional',
      );
      return enhancedUrl;
    } catch (e) {
      print('Error in Krea image enhancement: $e');
      rethrow;
    }
  }

  /// Applies style transfer from reference image to original image.
  /// Uses Krea reference-based generation: original + reference as references so the result
  /// preserves composition of the original while matching style/mood of the reference.
  Future<String> applyStyleTransfer({
    required String originalImagePath,
    required String referenceImagePath,
    String styleStrength = 'medium',
    String styleType = 'artistic',
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);

    try {
      print('Starting Krea style transfer (original + reference as references)...');
      final originalFile = File(originalImagePath);
      final referenceFile = File(referenceImagePath);
      if (!originalFile.existsSync()) throw Exception('Original image file not found');
      if (!referenceFile.existsSync()) throw Exception('Reference image file not found');

      const prompt = 'Transform the first image to match the style, mood and color palette of the second reference image. '
          'Preserve the composition and main subject of the first image. '
          'Apply the artistic style of the reference.';

      final result = await KreaAIService().generateImageWithReferences(
        prompt,
        [originalFile, referenceFile],
      );
      return result.url;
    } catch (e) {
      print('Error in Krea style transfer: $e');
      rethrow;
    }
  }

  /// Applies style transfer with Krea AI using reference images as context for the image being designed.
  /// This method uses the enhanced Krea AI API to apply style transfer with better context understanding.
  Future<String> applyStyleTransferWithContext({
    required String originalImagePath,
    required String referenceImagePath,
    String prompt = '',
    String styleStrength = 'medium',
    String styleType = 'artistic',
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);

    try {
      print('Starting Krea style transfer with context (original + reference as references)...');
      final originalFile = File(originalImagePath);
      final referenceFile = File(referenceImagePath);
      if (!originalFile.existsSync()) throw Exception('Original image file not found');
      if (!referenceFile.existsSync()) throw Exception('Reference image file not found');

      // Build enhanced prompt based on user input and style transfer requirements
      String enhancedPrompt;
      if (prompt.isNotEmpty) {
        enhancedPrompt = 'Apply the style and mood from the reference image to the original image. '
            'Incorporate the following user requirements: "$prompt". '
            'Preserve the composition and main subject of the original image while matching '
            'the artistic style, color palette, and mood of the reference image.';
      } else {
        enhancedPrompt = 'Transform the original image to match the style, mood and color palette '
            'of the reference image. Preserve the composition and main subject of the original image. '
            'Apply the artistic style of the reference image with $styleStrength strength and $styleType style type.';
      }

      print('Using enhanced prompt: $enhancedPrompt');

      // Use Krea AI service to generate image with references
      final result = await KreaAIService().generateImageWithReferences(
        enhancedPrompt,
        [originalFile, referenceFile],
      );
      
      print('Style transfer completed successfully');
      return result.url;
    } catch (e) {
      print('Error in Krea style transfer with context: $e');
      rethrow;
    }
  }

  /// Creative transformation of image with text prompt (upload + enhance).
  Future<String> applyCreativeTransformation({
    required String imagePath,
    required String prompt,
    String transformationType = 'creative',
    double creativityLevel = 0.8,
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);

    try {
      print('Starting Krea creative transformation (upload + enhance)...');
      final imageUrl = await _uploadAsset(imagePath);
      return await KreaEnhancementService().enhanceImage(
        imageUrl: imageUrl,
        enhancementType: 'auto',
        polishLevel: 'professional',
      );
    } catch (e) {
      print('Error in Krea creative transformation: $e');
      rethrow;
    }
  }

  /// Quick preset enhancements
  Future<String> applyPresetEnhancement({
    required String imagePath,
    required String presetType,
  }) async {
    switch (presetType) {
      case 'enhance_details':
        return enhanceExistingImage(
          imagePath: imagePath,
          enhancementType: 'details',
          enhanceDetails: true,
          enhanceColors: false,
          enhanceLighting: false,
        );
      case 'color_boost':
        return enhanceExistingImage(
          imagePath: imagePath,
          enhancementType: 'color',
          enhanceDetails: false,
          enhanceColors: true,
          enhanceLighting: false,
        );
      case 'artistic_style':
        return applyCreativeTransformation(
          imagePath: imagePath,
          prompt: 'Apply artistic style with vibrant colors and brush strokes',
          transformationType: 'artistic',
        );
      case 'vintage':
        return applyCreativeTransformation(
          imagePath: imagePath,
          prompt: 'Give this image a vintage, old photograph look with sepia tones',
          transformationType: 'vintage',
        );
      case 'high_contrast':
        return enhanceExistingImage(
          imagePath: imagePath,
          enhancementType: 'contrast',
          enhanceDetails: true,
          enhanceColors: true,
          enhanceLighting: true,
        );
      case 'soft_focus':
        return applyCreativeTransformation(
          imagePath: imagePath,
          prompt: 'Apply soft focus effect with dreamy, blurred background',
          transformationType: 'soft_focus',
        );
      default:
        return enhanceExistingImage(
          imagePath: imagePath,
          enhancementType: 'auto',
        );
    }
  }
}