import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/generated_image.dart';

/// OpenAI API service for image editing using GPT-4 Vision + DALL-E 3
/// 
/// Two-step approach:
/// 1. GPT-4 Vision analyzes images and creates detailed editing prompt
/// 2. DALL-E 3 generates the edited image based on that prompt
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  final String _apiKey;

  OpenAIService() : _apiKey = ApiKeys.openAI;

  /// Step 1: Analyze images and create editing prompt using GPT-4 Vision
  /// 
  /// [baseImageUrl] - The original/generated image to edit
  /// [referenceImageUrl] - Optional reference image to incorporate
  /// [editInstruction] - User's editing instruction
  Future<String> analyzeAndCreatePrompt({
    required String baseImageUrl,
    String? referenceImageUrl,
    required String editInstruction,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your-open-ai-key') {
      throw Exception('OpenAI API key not configured. Add your key to lib/config/api_keys.dart');
    }

    // Prepare messages for GPT-4 Vision
    List<Map<String, dynamic>> content = [
      {
        'type': 'text',
        'text': 'You are an expert at analyzing images and creating detailed prompts for DALL-E 3. '
            'I will show you a base image and possibly a reference image. '
            'Your job is to create a detailed DALL-E 3 prompt that will recreate the base image '
            'with the modifications I specify.\n\n'
            'Editing instruction: $editInstruction'
      },
      {
        'type': 'image_url',
        'image_url': {'url': baseImageUrl}
      },
    ];
    
    if (referenceImageUrl != null && referenceImageUrl.isNotEmpty) {
      content.add({
        'type': 'text',
        'text': 'Here is the reference image to incorporate:'
      });
      content.add({
        'type': 'image_url',
        'image_url': {'url': referenceImageUrl}
      });
    }
    
    content.add({
      'type': 'text',
      'text': 'Now create a detailed DALL-E 3 prompt that maintains the composition and elements '
          'of the base image while incorporating the requested changes. '
          'Be extremely detailed and specific about colors, lighting, style, and any specific elements. '
          'Output ONLY the prompt, nothing else.'
    });
    
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o', // or 'gpt-4-vision-preview'
        'messages': [
          {
            'role': 'user',
            'content': content,
          }
        ],
        'max_tokens': 600,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prompt = data['choices'][0]['message']['content'] as String;
      
      // Clean up prompt - remove any markdown formatting
      String cleanedPrompt = prompt.trim();
      if (cleanedPrompt.startsWith('"') && cleanedPrompt.endsWith('"')) {
        cleanedPrompt = cleanedPrompt.substring(1, cleanedPrompt.length - 1);
      }
      cleanedPrompt = cleanedPrompt.replaceAll('```', '').trim();
      return cleanedPrompt;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Failed to analyze images: ${error['error']?['message'] ?? response.body}');
    }
  }
  
  /// Step 2: Generate edited image using DALL-E 3
  /// 
  /// [prompt] - The detailed prompt from GPT-4 Vision analysis
  /// [quality] - 'hd' or 'standard'
  /// [size] - Image size: '1024x1024', '1792x1024', or '1024x1792'
  Future<String> generateEditedImage({
    required String prompt,
    String quality = 'hd',
    String size = '1024x1024',
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your-open-ai-key') {
      throw Exception('OpenAI API key not configured. Add your key to lib/config/api_keys.dart');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/images/generations'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': size,
        'quality': quality,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Failed to generate image: ${error['error']?['message'] ?? response.body}');
    }
  }
  
  /// Combined: Analyze + Generate in one call
  /// 
  /// This is the main method for editing images with reference guidance
  Future<String> editImageWithReference({
    required String baseImageUrl,
    String? referenceImageUrl,
    required String editInstruction,
    String quality = 'hd',
    String size = '1024x1024',
  }) async {
    print('Starting OpenAI edit workflow...');
    print('Base image: $baseImageUrl');
    if (referenceImageUrl != null) {
      print('Reference image: $referenceImageUrl');
    }
    print('Instruction: $editInstruction');

    // Step 1: Analyze and create prompt
    final dallePrompt = await analyzeAndCreatePrompt(
      baseImageUrl: baseImageUrl,
      referenceImageUrl: referenceImageUrl,
      editInstruction: editInstruction,
    );
    
    print('Generated DALL-E prompt: $dallePrompt');
    
    // Step 2: Generate new image
    final editedImageUrl = await generateEditedImage(
      prompt: dallePrompt,
      quality: quality,
      size: size,
    );
    
    print('Edited image generated: $editedImageUrl');
    return editedImageUrl;
  }

  /// Quick edit: Make expression more fierce/powerful
  Future<String> makeExpressionFiercer(String imageUrl) async {
    return editImageWithReference(
      baseImageUrl: imageUrl,
      editInstruction: 'Make the facial expression more fierce and powerful - '
          'intense focused eyes, stronger eyebrows angled with determination, '
          'powerful divine energy radiating from the face. Keep everything else exactly the same.',
    );
  }

  /// Quick edit: Make expression more serene/peaceful
  Future<String> makeExpressionSerene(String imageUrl) async {
    return editImageWithReference(
      baseImageUrl: imageUrl,
      editInstruction: 'Make the facial expression more serene and peaceful - '
          'gentle closed eyes with a compassionate smile, calm and benevolent demeanor. '
          'Keep everything else exactly the same.',
    );
  }

  /// Replace face with reference image features
  Future<String> replaceFaceWithReference({
    required String baseImageUrl,
    required String faceReferenceUrl,
  }) async {
    return editImageWithReference(
      baseImageUrl: baseImageUrl,
      referenceImageUrl: faceReferenceUrl,
      editInstruction: 'Replace the face in the base image with facial features, '
          'structure, skin tone, and expression similar to the reference image. '
          'Match the facial structure, eye shape, nose, lips, and overall look. '
          'Keep all other elements (clothing, ornaments, pose, background) identical.',
    );
  }

  /// Update specific element with reference image
  Future<String> updateElement({
    required String baseImageUrl,
    required String element, // e.g., 'lion', 'weapons', 'ornaments', 'saree'
    String? referenceImageUrl,
    String? customDescription,
  }) async {
    String instruction = 'Update the $element in the image';
    
    if (referenceImageUrl != null) {
      instruction += ' to match the style, appearance, and details of the $element in the reference image';
    }
    
    if (customDescription != null) {
      instruction += ': $customDescription';
    }
    
    instruction += '. Keep all other elements exactly the same. Maintain the overall composition and scene layout.';
    
    return editImageWithReference(
      baseImageUrl: baseImageUrl,
      referenceImageUrl: referenceImageUrl,
      editInstruction: instruction,
    );
  }

  /// Add/enhance ornaments and jewelry
  Future<String> enhanceOrnaments({
    required String imageUrl,
    String type = 'gold',
    bool addMore = true,
  }) async {
    String instruction = addMore
        ? 'Add more elaborate and ornate gold jewelry and ornaments - detailed necklaces, earrings, armlets, bangles, waist belt, crown with gemstones, and traditional decorative elements'
        : 'Enhance the existing jewelry and ornaments with more detail, intricate gold work, and gemstone accents';
    
    instruction += '. Make the ornaments more detailed and magnificent while keeping the overall design authentic.';
    
    return editImageWithReference(
      baseImageUrl: imageUrl,
      editInstruction: instruction,
    );
  }

  /// Enhance the lion/vahana
  Future<String> enhanceLion({
    required String imageUrl,
    bool makeMoreMajestic = true,
    String? referenceUrl,
  }) async {
    String instruction = makeMoreMajestic
        ? 'Make the lion (vahana) more majestic and powerful - fuller mane with detailed fur texture, fierce expressive eyes, strong noble stance, regal appearance befitting the divine vehicle'
        : 'Enhance the lion details - improve fur texture, expression, and overall appearance';
    
    if (referenceUrl != null) {
      instruction = 'Update the lion to match the majestic and powerful appearance in the reference image - '
          'matching the mane style, fur texture, expression, and overall look';
    }
    
    instruction += '. Keep Goddess Durga and all other elements exactly the same.';
    
    return editImageWithReference(
      baseImageUrl: imageUrl,
      referenceImageUrl: referenceUrl,
      editInstruction: instruction,
    );
  }

  /// Change or enhance the saree/dress
  Future<String> enhanceSaree({
    required String imageUrl,
    String? color,
    String? style,
  }) async {
    String instruction = 'Enhance the saree/clothing with more detail, rich fabric texture, and intricate patterns';
    
    if (color != null) {
      instruction += '. Make the saree in vibrant $color color with gold accents';
    }
    
    if (style != null) {
      instruction += '. Style: $style';
    }
    
    instruction += '. Keep the goddess figure, pose, ornaments, and background exactly the same.';
    
    return editImageWithReference(
      baseImageUrl: imageUrl,
      editInstruction: instruction,
    );
  }

  /// Improve overall quality and detail
  Future<String> enhanceOverallQuality({
    required String imageUrl,
    bool hd = true,
  }) async {
    return editImageWithReference(
      baseImageUrl: imageUrl,
      editInstruction: 'Enhance the overall image quality - sharper details, better lighting, '
          'more vivid colors, improved contrast, and professional finishing. '
          'Maintain the exact same composition and elements.',
      quality: hd ? 'hd' : 'standard',
    );
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': 'Hello'}
          ],
          'max_tokens': 5,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('OpenAI API test failed: $e');
      return false;
    }
  }
}
