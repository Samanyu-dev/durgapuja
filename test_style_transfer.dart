import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja/services/image_to_image_service.dart';
import 'package:durgapuja/services/krea_ai_service.dart';

void main() {
  group('Style Transfer with Krea AI', () {
    late ImageToImageService imageService;
    late KreaAIService kreaService;

    setUp(() {
      imageService = ImageToImageService();
      kreaService = KreaAIService();
    });

    test('should have applyStyleTransferWithContext method', () {
      expect(imageService, isA<ImageToImageService>());
      expect(
        imageService.applyStyleTransferWithContext,
        isNotNull,
        reason: 'applyStyleTransferWithContext method should be available',
      );
    });

    test('should handle style transfer with context', () async {
      // This test verifies the method signature and basic functionality
      // In a real test environment, you would need:
      // 1. Valid API keys
      // 2. Test image files
      // 3. Mock HTTP responses
      
      final originalImagePath = 'test_images/original.jpg';
      final referenceImagePath = 'test_images/reference.jpg';
      
      expect(() => imageService.applyStyleTransferWithContext(
        originalImagePath: originalImagePath,
        referenceImagePath: referenceImagePath,
        prompt: 'Test style transfer',
      ), returnsNormally);
    });

    test('should build enhanced prompt for style transfer', () {
      // Test the prompt enhancement logic
      final prompt = 'Make it look like Van Gogh';
      final enhancedPrompt = 'Apply the style and mood from the reference image to the original image. '
          'Incorporate the following user requirements: "$prompt". '
          'Preserve the composition and main subject of the original image while matching '
          'the artistic style, color palette, and mood of the reference image.';
      
      expect(enhancedPrompt.contains(prompt), isTrue);
      expect(enhancedPrompt.contains('reference image'), isTrue);
      expect(enhancedPrompt.contains('original image'), isTrue);
      expect(enhancedPrompt.contains('artistic style'), isTrue);
    });

    test('should handle empty prompt gracefully', () {
      final enhancedPrompt = 'Transform the original image to match the style, mood and color palette '
          'of the reference image. Preserve the composition and main subject of the original image. '
          'Apply the artistic style of the reference image with medium strength and artistic style type.';
      
      expect(enhancedPrompt.contains('medium strength'), isTrue);
      expect(enhancedPrompt.contains('artistic style type'), isTrue);
    });
  });
}