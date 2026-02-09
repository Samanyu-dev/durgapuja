import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

import '../config/api_keys.dart';
import '../models/generated_image.dart';

/// Service to generate/edit images using OpenAI Images API.
///
/// This replaces all previous Krea-based image generation.
class OpenAIImageService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _defaultImageModel = 'dall-e-2';

  final String _apiKey = ApiKeys.openAIKey;

  OpenAIImageService() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'OpenAI API key missing. Please set ApiKeys.openAIKey in lib/config/api_keys.dart.',
      );
    }
  }

  /// Generates a single image from a text prompt (no reference image).
  Future<GeneratedImage> generateImage(String prompt) async {
    final images = await generateImages(prompt, count: 1);
    return images.first;
  }

  /// Generates multiple images from a text prompt.
  Future<List<GeneratedImage>> generateImages(String prompt, {int count = 1}) async {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'Must be >= 1');
    }

    final uri = Uri.parse('$_baseUrl/images/generations');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _defaultImageModel,
        'prompt': prompt,
        'n': count,
        'size': '1024x1024',
        'response_format': 'url',
      }),
    );

    if (response.statusCode != 200) {
      throw _buildException('Image generation failed', response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> items = data['data'] as List<dynamic>? ?? const [];
    if (items.isEmpty) {
      throw Exception('OpenAI did not return any images.');
    }

    final now = DateTime.now();
    final results = <GeneratedImage>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i] as Map<String, dynamic>;
      final url = item['url'] as String?;
      if (url == null || url.isEmpty) {
        continue;
      }
      results.add(
        GeneratedImage(
          id: '${now.millisecondsSinceEpoch}_$i',
          url: url,
          prompt: prompt,
          createdAt: now,
        ),
      );
    }

    if (results.isEmpty) {
      throw Exception('OpenAI response did not contain valid image URLs.');
    }

    return results;
  }

  /// OpenAI edits endpoint requires PNG in RGBA (not RGB). Converts and ensures RGBA.
  Future<File> _ensurePngRgbaFile(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode image. Use a PNG or JPEG file.');
    }
    // API requires format in ['RGBA', 'LA', 'L'] - convert to RGBA if needed
    final rgba = decoded.numChannels == 4
        ? decoded
        : decoded.convert(numChannels: 4, alpha: 255);
    final pngBytes = img.encodePng(rgba);
    final tempDir = Directory.systemTemp;
    final pngFile = File('${tempDir.path}/openai_edit_${DateTime.now().millisecondsSinceEpoch}.png');
    await pngFile.writeAsBytes(pngBytes);
    return pngFile;
  }

  /// Edits an image using a reference image + prompt.
  ///
  /// This uses the OpenAI Images "edits" endpoint (PNG only).
  Future<GeneratedImage> generateImageWithReference({
    required File referenceImage,
    required String prompt,
  }) async {
    if (!referenceImage.existsSync()) {
      throw Exception('Reference image not found at path: ${referenceImage.path}');
    }

    File pngFile;
    try {
      pngFile = await _ensurePngRgbaFile(referenceImage);
    } catch (e) {
      rethrow;
    }

    try {
      final uri = Uri.parse('$_baseUrl/images/edits');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..fields['model'] = _defaultImageModel
        ..fields['prompt'] = prompt
        ..fields['n'] = '1'
        ..fields['size'] = '1024x1024'
        ..fields['response_format'] = 'url';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          pngFile.path,
          contentType: MediaType('image', 'png'),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw _buildException('Image edit failed', response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> items = data['data'] as List<dynamic>? ?? const [];
      if (items.isEmpty) {
        throw Exception('OpenAI did not return any edited images.');
      }

      final url = (items.first as Map<String, dynamic>)['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('OpenAI response did not contain an image URL.');
      }

      final now = DateTime.now();
      return GeneratedImage(
        id: '${now.millisecondsSinceEpoch}_edit',
        url: url,
        prompt: prompt,
        createdAt: now,
      );
    } finally {
      if (pngFile.existsSync()) {
        try {
          pngFile.deleteSync();
        } catch (_) {}
      }
    }
  }

  /// Edits an image at [imagePath] with [prompt] and returns the result image URL.
  /// Convenience for image-to-image flows.
  Future<String> editImageAndReturnUrl({
    required String imagePath,
    required String prompt,
  }) async {
    final file = File(imagePath);
    final result = await generateImageWithReference(
      referenceImage: file,
      prompt: prompt,
    );
    return result.url;
  }

  Exception _buildException(String message, http.Response response) {
    String detail = response.body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          detail = error['message']?.toString() ?? detail;
        }
      }
    } catch (_) {
      // keep raw body
    }
    return Exception('$message (status ${response.statusCode}): $detail');
  }
}

