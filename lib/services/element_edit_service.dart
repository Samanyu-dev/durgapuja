import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/generated_image.dart';
import '../../models/editable_element.dart';
import '../../services/krea_ai_service.dart';

class ElementEditService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final KreaAIService _kreaService = KreaAIService();

  /// Creates an element-specific edit prompt
  String createElementEditPrompt(ElementType elementType, String editDescription, String originalPrompt) {
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

  /// Performs element-specific editing using Krea AI
  Future<GeneratedImage> editElement(
    String originalImageUrl,
    ElementType elementType,
    String editDescription,
    String originalPrompt,
  ) async {
    try {
      // Create element-specific prompt
      final editPrompt = createElementEditPrompt(elementType, editDescription, originalPrompt);

      // Feed the original image in as a reference so the model has
      // something to preserve — without it, "editing an element" would
      // just be generating an unrelated new image from text alone.
      final referenceFile = await _resolveAsFile(originalImageUrl);
      final images = referenceFile != null
          ? await _kreaService.generateImagesWithReferences(editPrompt, [referenceFile], count: 1)
          : await _kreaService.generateImages(editPrompt, count: 1);

      if (images.isNotEmpty) {
        return images.first;
      } else {
        throw Exception('No images generated');
      }
    } catch (e) {
      debugPrint('Element edit failed: $e');
      throw Exception('Failed to edit element: $e');
    }
  }

  /// Resolves an image URL/path to a local [File] usable as a reference
  /// image, downloading it first if it's a remote URL.
  Future<File?> _resolveAsFile(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode != 200) return null;
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/edit_ref_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      final file = File(imageUrl);
      return await file.exists() ? file : null;
    } catch (e) {
      debugPrint('Failed to resolve reference image: $e');
      return null;
    }
  }

  /// Uploads edited image to cloud storage
  Future<String> uploadEditedImage(String imageUrl, String userId, String originalImageId, ElementType elementType) async {
    try {
      // Download edited image
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download edited image');
      }

      // Create storage reference with element type
      final fileName = '${userId}/edited_${elementType.name}_${originalImageId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('edited_designs/$fileName');

      // Upload file
      final uploadTask = ref.putData(response.bodyBytes);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload edited image failed: $e');
      throw Exception('Failed to upload edited image: $e');
    }
  }

  /// Gets example prompts for an element type
  List<String> getExamplePrompts(ElementType elementType) {
    final element = EditableElement.fromType(elementType);
    return element?.examplePrompts ?? [];
  }

  /// Validates edit description
  bool validateEditDescription(String description) {
    if (description.trim().isEmpty) {
      return false;
    }
    
    // Check for minimum length
    if (description.trim().length < 5) {
      return false;
    }
    
    return true;
  }

  /// Gets element selection guidance
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
}