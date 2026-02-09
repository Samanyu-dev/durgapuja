import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config/api_keys.dart';
import '../../models/generated_image.dart';
import 'krea_ai_service.dart';
import 'image_to_image_service.dart';

/// Core service for AI image generation with style transfer and image prompts
/// Supports iterative refinement by incorporating reference elements while maintaining composition
class AIImageGenerationService {
  static const String _baseUrl = 'https://api.krea.ai';
  static const String _tokenError =
      'Krea API token not found. Set KREA_API_TOKEN in .env or add kreaApiKey in lib/config/api_keys.dart. Get token at: https://krea.ai/settings/api-tokens';

  final String _apiToken;
  final KreaAIService _kreaService;
  final ImageToImageService _imageToImageService;

  AIImageGenerationService()
      : _apiToken = dotenv.env['KREA_API_TOKEN'] ?? ApiKeys.kreaApiKey,
        _kreaService = KreaAIService(),
        _imageToImageService = ImageToImageService();

  /// Enhances prompts for Durga idol generation with detailed specifications
  String enhanceDurgaIdolPrompt(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    final durgaKeywords = ['durga', 'durgapuja', 'durga puja', 'durgotsav', 'idol', 'murt'];
    final isDurgaRelated = durgaKeywords.any((keyword) => lowerPrompt.contains(keyword));

    if (isDurgaRelated && prompt.length < 50) {
      return '''
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
    }
    return prompt;
  }

  /// Generates initial image from text prompt
  Future<GeneratedImage> generateInitialImage(String prompt) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);
    
    final enhancedPrompt = enhanceDurgaIdolPrompt(prompt);
    print('Generating initial image with prompt: $enhancedPrompt');
    
    return await _kreaService.generateImage(enhancedPrompt);
  }

  /// Generates multiple variations of initial image
  Future<List<GeneratedImage>> generateInitialVariations(String prompt, {int count = 4}) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);
    
    final enhancedPrompt = enhanceDurgaIdolPrompt(prompt);
    print('Generating $count variations with prompt: $enhancedPrompt');
    
    return await _kreaService.generateImages(enhancedPrompt, count: count);
  }

  /// Core method for iterative refinement with image prompts
  /// Preserves composition while incorporating reference elements
  Future<GeneratedImage> refineWithImagePrompts({
    required String basePrompt,
    required List<File> referenceImages,
    String? elementToReplace,
    double compositionPreservation = 0.7,
    double referenceInfluence = 0.8,
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);
    if (referenceImages.isEmpty) throw Exception('At least one reference image is required');

    try {
      print('Starting iterative refinement with ${referenceImages.length} reference images');
      print('Element to replace: ${elementToReplace ?? 'all elements'}');
      print('Composition preservation: $compositionPreservation');
      print('Reference influence: $referenceInfluence');

      // Build enhanced prompt focusing on specific element if specified
      String enhancedPrompt;
      if (elementToReplace != null) {
        enhancedPrompt = '''
        $basePrompt, focusing on $elementToReplace matching reference images.
        Preserve the overall composition and scene layout.
        Incorporate visual features from reference images while maintaining the original design structure.
        Element to modify: $elementToReplace
        Composition preservation level: $compositionPreservation
        Reference influence level: $referenceInfluence
        ''';
      } else {
        enhancedPrompt = '''
        $basePrompt, incorporating visual elements from reference images.
        Preserve the overall composition and scene layout.
        Selectively integrate features from references while maintaining design coherence.
        Composition preservation level: $compositionPreservation
        Reference influence level: $referenceInfluence
        ''';
      }

      print('Using enhanced prompt: ${enhancedPrompt.substring(0, math.min(200, enhancedPrompt.length))}...');

      // Use Krea AI with reference images
      final result = await _kreaService.generateImageWithReferences(
        enhancedPrompt,
        referenceImages,
      );

      print('Iterative refinement completed successfully');
      return result;
    } catch (e) {
      print('Error in iterative refinement: $e');
      rethrow;
    }
  }

  /// Applies style transfer while preserving composition
  Future<GeneratedImage> applyStyleTransfer({
    required String originalImagePath,
    required String referenceImagePath,
    String styleStrength = 'medium',
    String styleType = 'artistic',
    String? customPrompt,
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);

    try {
      print('Starting style transfer from $referenceImagePath to $originalImagePath');
      print('Style strength: $styleStrength, Style type: $styleType');

      final originalFile = File(originalImagePath);
      final referenceFile = File(referenceImagePath);
      
      if (!originalFile.existsSync()) throw Exception('Original image file not found');
      if (!referenceFile.existsSync()) throw Exception('Reference image file not found');

      // Build style transfer prompt
      String stylePrompt;
      if (customPrompt != null && customPrompt.isNotEmpty) {
        stylePrompt = '''
        Apply the style and mood from the reference image to the original image.
        Incorporate the following requirements: "$customPrompt".
        Preserve the composition and main subject of the original image while matching
        the artistic style, color palette, and mood of the reference image.
        Style strength: $styleStrength
        Style type: $styleType
        ''';
      } else {
        stylePrompt = '''
        Transform the original image to match the style, mood and color palette
        of the reference image. Preserve the composition and main subject of the original image.
        Apply the artistic style of the reference image with $styleStrength strength and $styleType style type.
        ''';
      }

      print('Using style transfer prompt: ${stylePrompt.substring(0, math.min(200, stylePrompt.length))}...');

      // Use Krea AI with both images as references
      final result = await _kreaService.generateImageWithReferences(
        stylePrompt,
        [originalFile, referenceFile],
      );

      print('Style transfer completed successfully');
      return result;
    } catch (e) {
      print('Error in style transfer: $e');
      rethrow;
    }
  }

  /// Combines multiple reference images for comprehensive refinement
  Future<GeneratedImage> combineMultipleReferences({
    required String basePrompt,
    required List<File> referenceImages,
    required List<String> elementMappings,
    String compositionStrategy = 'balanced',
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);
    if (referenceImages.length != elementMappings.length) {
      throw Exception('Number of reference images must match number of element mappings');
    }

    try {
      print('Combining ${referenceImages.length} reference images with strategy: $compositionStrategy');
      
      // Build comprehensive prompt
      final elementDescriptions = elementMappings.map((element) => '- $element').join('\n');
      final combinedPrompt = '''
      $basePrompt
      
      Incorporate elements from multiple reference images:
      $elementDescriptions
      
      Composition strategy: $compositionStrategy
      - Maintain overall scene coherence
      - Selectively integrate features from each reference
      - Ensure visual harmony between combined elements
      - Preserve the original design structure
      ''';

      print('Using combined prompt: ${combinedPrompt.substring(0, math.min(300, combinedPrompt.length))}...');

      // Use Krea AI with all reference images
      final result = await _kreaService.generateImageWithReferences(
        combinedPrompt,
        referenceImages,
      );

      print('Multi-reference combination completed successfully');
      return result;
    } catch (e) {
      print('Error in multi-reference combination: $e');
      rethrow;
    }
  }

  /// Quick preset transformations
  Future<GeneratedImage> applyPresetTransformation({
    required String imagePath,
    required String presetType,
    String? customPrompt,
  }) async {
    String enhancedUrl;
    
    switch (presetType) {
      case 'enhance_details':
        enhancedUrl = await _imageToImageService.enhanceExistingImage(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Enhance details and sharpness',
          enhancementType: 'details',
        );
        break;
      case 'color_boost':
        enhancedUrl = await _imageToImageService.enhanceExistingImage(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Boost colors and vibrancy',
          enhancementType: 'color',
        );
        break;
      case 'artistic_style':
        enhancedUrl = await _imageToImageService.applyCreativeTransformation(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Apply artistic style with vibrant colors and brush strokes',
          transformationType: 'artistic',
        );
        break;
      case 'vintage':
        enhancedUrl = await _imageToImageService.applyCreativeTransformation(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Give this image a vintage, old photograph look with sepia tones',
          transformationType: 'vintage',
        );
        break;
      case 'high_contrast':
        enhancedUrl = await _imageToImageService.enhanceExistingImage(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Increase contrast and definition',
          enhancementType: 'contrast',
        );
        break;
      case 'soft_focus':
        enhancedUrl = await _imageToImageService.applyCreativeTransformation(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Apply soft focus effect with dreamy, blurred background',
          transformationType: 'soft_focus',
        );
        break;
      default:
        enhancedUrl = await _imageToImageService.enhanceExistingImage(
          imagePath: imagePath,
          prompt: customPrompt ?? 'Auto enhancement',
          enhancementType: 'auto',
        );
    }
    
    return GeneratedImage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      url: enhancedUrl,
      prompt: customPrompt ?? presetType,
      createdAt: DateTime.now(),
    );
  }

  /// Validates reference images for quality and relevance
  Future<Map<String, dynamic>> validateReferenceImages(List<File> images) async {
    final validationResults = <String, dynamic>{};
    
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final result = <String, dynamic>{
        'index': i,
        'exists': image.existsSync(),
        'size': image.existsSync() ? await image.length() : 0,
        'valid': false,
        'issues': <String>[],
      };

      if (!image.existsSync()) {
        result['issues'].add('File does not exist');
      } else {
        final size = await image.length();
        if (size < 1024) {
          result['issues'].add('File too small (< 1KB)');
        } else if (size > 10 * 1024 * 1024) {
          result['issues'].add('File too large (> 10MB)');
        }

        // Check file extension
        final extension = image.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
          result['issues'].add('Unsupported file format. Use JPG, PNG, or WebP');
        }
      }

      result['valid'] = result['issues'].isEmpty;
      validationResults['image_$i'] = result;
    }

    return validationResults;
  }

  /// Generates transformation suggestions based on reference images
  Future<List<String>> generateSuggestions(List<File> referenceImages) async {
    final suggestions = <String>[];
    
    if (referenceImages.length == 1) {
      suggestions.addAll([
        'Apply this style to your current design',
        'Use this color palette for enhancement',
        'Incorporate these visual elements',
        'Match the artistic technique shown',
      ]);
    } else if (referenceImages.length == 2) {
      suggestions.addAll([
        'Combine elements from both references',
        'Use first reference for style, second for details',
        'Blend the color schemes harmoniously',
        'Integrate the best features from each',
      ]);
    } else {
      suggestions.addAll([
        'Prioritize key elements from each reference',
        'Create a balanced composition using all references',
        'Focus on the most relevant visual features',
        'Ensure cohesive integration of all elements',
      ]);
    }

    return suggestions;
  }

  /// Batch processing for multiple transformations
  Future<List<GeneratedImage>> batchTransform({
    required String basePrompt,
    required List<File> referenceImages,
    required List<String> transformations,
  }) async {
    if (_apiToken.isEmpty) throw Exception(_tokenError);
    
    final results = <GeneratedImage>[];
    
    for (int i = 0; i < transformations.length; i++) {
      try {
        print('Processing transformation ${i + 1} of ${transformations.length}: ${transformations[i]}');
        
        final result = await refineWithImagePrompts(
          basePrompt: basePrompt,
          referenceImages: referenceImages,
          elementToReplace: transformations[i],
        );
        
        results.add(result);
      } catch (e) {
        print('Failed to process transformation ${i + 1}: $e');
        // Continue with remaining transformations
      }
    }
    
    return results;
  }

  /// Test API connection and validate setup
  Future<bool> testConnection() async {
    try {
      await _kreaService.testApiConnection();
      return true;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }
}