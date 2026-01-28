import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../models/generated_image.dart';
import '../../models/editable_element.dart';
import '../config/api_keys.dart';
import 'replicate_sam_service.dart';
import 'krea_generative_fill_service.dart';
import 'krea_enhancement_service.dart';

class TapToEditService {
  final ReplicateSAMService _samService = ReplicateSAMService();
  final KreaGenerativeFillService _kreaFillService = KreaGenerativeFillService();
  final KreaEnhancementService _kreaEnhanceService = KreaEnhancementService();

  /// Complete Tap-to-Edit workflow
  Future<GeneratedImage> completeTapToEditWorkflow({
    required GeneratedImage originalImage,
    required double tapX,
    required double tapY,
    required double imageWidth,
    required double imageHeight,
    required String editPrompt,
    required ElementType elementType,
    bool applyRelighting = true,
    bool preserveColors = true,
  }) async {
    try {
      // Step 1: Generate mask from tap coordinates using SAM 2
      final maskImageUrl = await _samService.generateMaskFromTap(
        imageUrl: originalImage.url,
        x: tapX,
        y: tapY,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      // Step 2: Apply generative fill using Krea
      final editedImageUrl = await _kreaFillService.completeGenerativeFill(
        originalImageUrl: originalImage.url,
        maskImageUrl: maskImageUrl,
        prompt: editPrompt,
      );

      // Step 3: Enhance and polish using Krea (replaces Photoroom)
      String finalImageUrl = editedImageUrl;
      if (applyRelighting) {
        finalImageUrl = await _kreaEnhanceService.completeEnhancement(
          imageUrl: editedImageUrl,
          applyAutoEnhancement: true,
          applyProfessionalPolish: true,
        );
      }

      // Step 4: Create the final edited image
      final editedImage = GeneratedImage(
        id: '${originalImage.id}_edited_${DateTime.now().millisecondsSinceEpoch}',
        url: finalImageUrl,
        prompt: originalImage.prompt,
        createdAt: DateTime.now(),
      );

      return editedImage;
    } catch (e) {
      debugPrint('Tap-to-Edit workflow failed: $e');
      throw Exception('Tap-to-Edit workflow failed: $e');
    }
  }

  /// Generate element-specific edit prompt
  String generateElementEditPrompt(ElementType elementType, String editDescription, String originalPrompt) {
    final elementDetails = EditableElement.fromType(elementType);
    
    return '''
Edit the ${elementDetails?.type.displayName.toLowerCase() ?? 'selected element'} of this Durga idol design:
Original design: $originalPrompt

Edit request: $editDescription

Requirements:
- Only modify the ${elementDetails?.type.displayName.toLowerCase() ?? 'selected element'}
- Keep all other elements exactly the same
- Maintain the overall composition and style
- Ensure seamless integration with existing elements
- Preserve the traditional Bengali Durga Puja aesthetic
- Focus specifically on: ${elementDetails?.description ?? 'the selected element'}
''';
  }

  /// Validate edit parameters
  bool validateEditParameters({
    required String editDescription,
    required double tapX,
    required double tapY,
    required double imageWidth,
    required double imageHeight,
  }) {
    // Check edit description
    if (editDescription.trim().isEmpty || editDescription.trim().length < 5) {
      return false;
    }

    // Check coordinates are within image bounds
    if (tapX < 0 || tapX > imageWidth || tapY < 0 || tapY > imageHeight) {
      return false;
    }

    return true;
  }

  /// Get element guidance for editing
  String getElementGuidance(ElementType elementType) {
    final element = EditableElement.fromType(elementType);
    return '''
Selected: ${element?.type.displayName ?? 'Element'}

${element?.description ?? 'Edit this element of your Durga idol design.'}

Tip: Be specific about what you want to change. For example:
- "Make the expression more serene"
- "Add more gold detailing to the jewelry"
- "Change the saree color to red and gold"
''';
  }

  /// Get example prompts for an element type
  List<String> getExamplePrompts(ElementType elementType) {
    final element = EditableElement.fromType(elementType);
    return element?.examplePrompts ?? [];
  }
}