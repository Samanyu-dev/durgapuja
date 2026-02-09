import 'dart:io';
import 'krea_ai_service.dart';
import 'openai_service.dart';
import '../models/generated_image.dart';

/// Unified image processing service that combines Krea API (generation) and OpenAI API (editing)
///
/// Workflow:
/// 1. Generate initial image with Krea API (text-to-image)
/// 2. Edit/refine image with OpenAI API (GPT-4 Vision + DALL-E 3)
///
/// This provides a complete pipeline for creating and iterating on Durga idol designs
class ImageProcessingService {
  final KreaAIService _kreaService;
  final OpenAIService _openAIService;

  ImageProcessingService()
      : _kreaService = KreaAIService(),
        _openAIService = OpenAIService();

  // ==================== KREA GENERATION METHODS ====================

  /// Generate initial image from text prompt using Krea API
  Future<GeneratedImage> generateInitialImage(String prompt) async {
    print('=== GENERATING INITIAL IMAGE ===');
    print('Prompt: $prompt');
    return await _kreaService.generateImage(prompt);
  }

  /// Generate multiple variations of initial image
  Future<List<GeneratedImage>> generateInitialVariations(
    String prompt, {
    int count = 4,
  }) async {
    print('=== GENERATING $count VARIATIONS ===');
    print('Prompt: $prompt');
    return await _kreaService.generateImages(prompt, count: count);
  }

  /// Generate image with reference images using Krea API
  Future<GeneratedImage> generateWithReferences(
    String prompt,
    List<File> referenceImages,
  ) async {
    print('=== GENERATING WITH ${referenceImages.length} REFERENCES ===');
    return await _kreaService.generateImageWithReferences(prompt, referenceImages);
  }

  // ==================== OPENAI EDITING METHODS ====================

  /// Edit image with reference guidance using OpenAI API
  /// 
  /// This is the main editing method - combines GPT-4 Vision analysis
  /// with DALL-E 3 generation for precise image modifications
  Future<String> editImage({
    required String baseImageUrl,
    String? referenceImageUrl,
    required String editInstruction,
    String quality = 'hd',
    String size = '1024x1024',
  }) async {
    print('=== EDITING IMAGE ===');
    print('Base: $baseImageUrl');
    print('Reference: ${referenceImageUrl ?? "none"}');
    print('Instruction: $editInstruction');

    return await _openAIService.editImageWithReference(
      baseImageUrl: baseImageUrl,
      referenceImageUrl: referenceImageUrl,
      editInstruction: editInstruction,
      quality: quality,
      size: size,
    );
  }

  /// Quick edit: Make expression more fierce
  Future<String> makeExpressionFiercer(String imageUrl) async {
    return await _openAIService.makeExpressionFiercer(imageUrl);
  }

  /// Quick edit: Make expression more serene
  Future<String> makeExpressionSerene(String imageUrl) async {
    return await _openAIService.makeExpressionSerene(imageUrl);
  }

  /// Replace face with reference image features
  Future<String> replaceFace({
    required String baseImageUrl,
    required String faceReferenceUrl,
  }) async {
    return await _openAIService.replaceFaceWithReference(
      baseImageUrl: baseImageUrl,
      faceReferenceUrl: faceReferenceUrl,
    );
  }

  /// Update specific element (lion, weapons, ornaments, etc.)
  Future<String> updateElement({
    required String baseImageUrl,
    required String element,
    String? referenceImageUrl,
    String? customDescription,
  }) async {
    return await _openAIService.updateElement(
      baseImageUrl: baseImageUrl,
      element: element,
      referenceImageUrl: referenceImageUrl,
      customDescription: customDescription,
    );
  }

  /// Enhance ornaments and jewelry
  Future<String> enhanceOrnaments({
    required String imageUrl,
    String type = 'gold',
    bool addMore = true,
  }) async {
    return await _openAIService.enhanceOrnaments(
      imageUrl: imageUrl,
      type: type,
      addMore: addMore,
    );
  }

  /// Enhance lion/vahana
  Future<String> enhanceLion({
    required String imageUrl,
    bool makeMoreMajestic = true,
    String? referenceUrl,
  }) async {
    return await _openAIService.enhanceLion(
      imageUrl: imageUrl,
      makeMoreMajestic: makeMoreMajestic,
      referenceUrl: referenceUrl,
    );
  }

  /// Enhance saree/dress
  Future<String> enhanceSaree({
    required String imageUrl,
    String? color,
    String? style,
  }) async {
    return await _openAIService.enhanceSaree(
      imageUrl: imageUrl,
      color: color,
      style: style,
    );
  }

  /// Improve overall image quality
  Future<String> enhanceOverallQuality({
    required String imageUrl,
    bool hd = true,
  }) async {
    return await _openAIService.enhanceOverallQuality(
      imageUrl: imageUrl,
      hd: hd,
    );
  }

  // ==================== COMPLETE WORKFLOW METHODS ====================

  /// Complete workflow: Generate with Krea, then edit with OpenAI
  /// 
  /// Example: Generate Durga idol, then make expression fiercer
  Future<String> generateAndEdit({
    required String prompt,
    required String editInstruction,
    String? referenceImageUrl,
  }) async {
    // Step 1: Generate initial image with Krea
    print('=== COMPLETE WORKFLOW: GENERATE + EDIT ===');
    print('Step 1: Generating initial image...');
    final generatedImage = await generateInitialImage(prompt);
    
    // Step 2: Edit with OpenAI
    print('Step 2: Editing image...');
    final editedUrl = await editImage(
      baseImageUrl: generatedImage.url,
      referenceImageUrl: referenceImageUrl,
      editInstruction: editInstruction,
    );
    
    return editedUrl;
  }

  /// Generate, then make expression fiercer
  Future<String> generateAndMakeFiercer(String prompt) async {
    final generatedImage = await generateInitialImage(prompt);
    return await makeExpressionFiercer(generatedImage.url);
  }

  /// Generate, then enhance lion
  Future<String> generateAndEnhanceLion(String prompt, {bool majestic = true}) async {
    final generatedImage = await generateInitialImage(prompt);
    return await enhanceLion(imageUrl: generatedImage.url, makeMoreMajestic: majestic);
  }

  /// Generate with Krea, then apply multiple OpenAI edits sequentially
  Future<String> generateWithEdits(
    String prompt, {
    bool makeFiercer = false,
    bool lionEnhancement = false,
    bool ornamentEnhancement = false,
    String? sareeColor,
  }) async {
    // Generate initial image
    final generatedImage = await generateInitialImage(prompt);
    String currentUrl = generatedImage.url;

    // Apply edits sequentially
    if (makeFiercer) {
      currentUrl = await makeExpressionFiercer(currentUrl);
    }
    if (lionEnhancement) {
      currentUrl = await enhanceLion(imageUrl: currentUrl, makeMoreMajestic: true);
    }
    if (ornamentEnhancement) {
      currentUrl = await enhanceOrnaments(imageUrl: currentUrl, addMore: true);
    }
    if (sareeColor != null) {
      currentUrl = await enhanceSaree(imageUrl: currentUrl, color: sareeColor);
    }

    return currentUrl;
  }

  // ==================== REFERENCE-BASED ITERATION ====================

  /// Iterate on design by referencing previous generations
  /// 
  /// Use this to progressively improve a design using earlier versions as reference
  Future<String> iterateWithReference({
    required String currentImageUrl,
    required String previousImageUrl,
    required String editInstruction,
  }) async {
    return await editImage(
      baseImageUrl: currentImageUrl,
      referenceImageUrl: previousImageUrl,
      editInstruction: editInstruction,
    );
  }

  /// Combine elements from two images
  Future<String> combineElements({
    required String baseImageUrl,
    required String referenceImageUrl,
    String element = 'style',
  }) async {
    return await updateElement(
      baseImageUrl: baseImageUrl,
      element: element,
      referenceImageUrl: referenceImageUrl,
      customDescription: 'Incorporate the style and visual elements from the reference image',
    );
  }

  // ==================== UTILITY METHODS ====================

  /// Test both API connections
  Future<Map<String, bool>> testConnections() async {
    final results = <String, bool>{};
    
    try {
      await _kreaService.testApiConnection();
      results['krea'] = true;
    } catch (e) {
      print('Krea API test failed: $e');
      results['krea'] = false;
    }

    try {
      results['openai'] = await _openAIService.testConnection();
    } catch (e) {
      print('OpenAI API test failed: $e');
      results['openai'] = false;
    }

    return results;
  }
}
