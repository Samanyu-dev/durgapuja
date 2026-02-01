import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Resolves original image to a local File for Krea reference-based generation.
  /// Handles http(s) URLs (download), asset paths (rootBundle), and local file paths.
  Future<File> _originalImageToFile(String originalImageUrl) async {
    if (originalImageUrl.startsWith('http://') || originalImageUrl.startsWith('https://')) {
      final response = await http.get(Uri.parse(originalImageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download original image');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/element_edit_original_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    }
    if (originalImageUrl.startsWith('assets/')) {
      final bytes = await rootBundle.load(originalImageUrl);
      final buffer = bytes.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/element_edit_asset_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(buffer);
      return file;
    }
    final file = File(originalImageUrl);
    if (file.existsSync()) {
      return file;
    }
    throw Exception('Original image not found: $originalImageUrl');
  }

  /// Performs element-specific editing using Krea AI with the original image as reference
  /// so the result preserves composition and style while applying the edit.
  Future<GeneratedImage> editElement(
    String originalImageUrl,
    ElementType elementType,
    String editDescription,
    String originalPrompt,
  ) async {
    try {
      final editPrompt = createElementEditPrompt(elementType, editDescription, originalPrompt);
      final originalFile = await _originalImageToFile(originalImageUrl);
      try {
        final images = await _kreaService.generateImageWithReferences(editPrompt, [originalFile]);
        return images;
      } finally {
        try {
          if (await originalFile.exists()) await originalFile.delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Element edit failed: $e');
      throw Exception('Failed to edit element: $e');
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