import 'dart:io';
import 'logging_service.dart';
import 'krea_ai_service.dart';

/// Performs image-to-image style transformations by submitting the
/// source (and, for style transfer, a reference) image to Krea via
/// [KreaAIService.generateImagesWithReferences] — the same request/poll
/// pipeline already proven to work for text-to-image generation
/// elsewhere in the app.
class ImageToImageService {
  final KreaAIService _kreaService = KreaAIService();

  Future<String> _runWithReferences({
    required String prompt,
    required List<String> imagePaths,
  }) async {
    final referenceImages = imagePaths.map((path) => File(path)).toList();
    final images = await _kreaService.generateImagesWithReferences(
      prompt,
      referenceImages,
      count: 1,
    );
    return images.first.url;
  }

  /// Enhances an existing image with AI improvements
  Future<String> enhanceExistingImage({
    required String imagePath,
    String? prompt,
    String enhancementType = 'auto',
    bool enhanceDetails = true,
    bool enhanceColors = true,
    bool enhanceLighting = true,
  }) async {
    try {
      LoggingService.logDebug('Starting Krea image enhancement...');
      LoggingService.logDebug('Image path: $imagePath');
      LoggingService.logDebug('Enhancement type: $enhancementType');

      final aspects = <String>[
        if (enhanceDetails) 'sharper fine details',
        if (enhanceColors) 'richer, more vibrant colors',
        if (enhanceLighting) 'improved, natural lighting',
      ];
      final enhancePrompt = '''
Enhance this Durga idol design image: improve ${aspects.isEmpty ? 'overall quality' : aspects.join(', ')}.
Keep the composition, pose and identity of the idol exactly the same.
${prompt != null && prompt.trim().isNotEmpty ? 'Additional guidance: ${prompt.trim()}' : ''}
'''.trim();

      return await _runWithReferences(prompt: enhancePrompt, imagePaths: [imagePath]);
    } catch (e) {
      LoggingService.logDebug('Error in Krea image enhancement: $e');
      throw Exception('Image enhancement failed: $e');
    }
  }

  /// Applies style transfer from reference image to original image
  Future<String> applyStyleTransfer({
    required String originalImagePath,
    required String referenceImagePath,
    String styleStrength = 'medium',
    String styleType = 'artistic',
  }) async {
    try {
      LoggingService.logDebug('Starting Krea style transfer...');
      LoggingService.logDebug('Original image: $originalImagePath');
      LoggingService.logDebug('Reference image: $referenceImagePath');
      LoggingService.logDebug('Style strength: $styleStrength');

      final stylePrompt = '''
Redraw the first reference image (the original Durga idol design), applying the visual style ($styleType style) of the second reference image with $styleStrength strength.
Preserve the pose, composition and identity of the idol from the first image; only its artistic style should change.
'''.trim();

      return await _runWithReferences(
        prompt: stylePrompt,
        imagePaths: [originalImagePath, referenceImagePath],
      );
    } catch (e) {
      LoggingService.logDebug('Error in Krea style transfer: $e');
      throw Exception('Style transfer failed: $e');
    }
  }

  /// Creative transformation of image with text prompt
  Future<String> applyCreativeTransformation({
    required String imagePath,
    required String prompt,
    String transformationType = 'creative',
    double creativityLevel = 0.8,
  }) async {
    try {
      LoggingService.logDebug('Starting Krea creative transformation...');
      LoggingService.logDebug('Image path: $imagePath');
      LoggingService.logDebug('Prompt: $prompt');
      LoggingService.logDebug('Transformation type: $transformationType');

      final creativePrompt = '''
Creatively transform this Durga idol design image ($transformationType transformation): $prompt
'''.trim();

      return await _runWithReferences(prompt: creativePrompt, imagePaths: [imagePath]);
    } catch (e) {
      LoggingService.logDebug('Error in Krea creative transformation: $e');
      throw Exception('Creative transformation failed: $e');
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
