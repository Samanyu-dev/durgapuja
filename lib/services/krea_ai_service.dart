import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/generated_image.dart';

class KreaAIService {
  static const String _baseUrl = 'https://api.krea.ai'; // Replace with actual API endpoint
  static const String _generateEndpoint = '/v1/images/generate'; // Replace with actual endpoint

  final String _apiKey;

  KreaAIService() : _apiKey = dotenv.env['KREA_AI_API_KEY'] ?? '';

  /// Generates an image from a text prompt
  /// Returns a GeneratedImage object
  Future<GeneratedImage> generateImage(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('Krea AI API key not found. Please set KREA_AI_API_KEY in .env file.');
    }

    final url = Uri.parse('$_baseUrl$_generateEndpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'model': 'krea-v1', // Replace with actual model if needed
        'num_images': 1,
        'width': 512,
        'height': 512,
        // Add other parameters as per API documentation
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the response structure - adjust based on actual API response
      return GeneratedImage.fromJson(data['image'] ?? data);
    } else {
      throw Exception('Failed to generate image: ${response.statusCode} - ${response.body}');
    }
  }

  /// Generates multiple images from a prompt
  Future<List<GeneratedImage>> generateImages(String prompt, {int count = 4}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Krea AI API key not found. Please set KREA_AI_API_KEY in .env file.');
    }

    final url = Uri.parse('$_baseUrl$_generateEndpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'model': 'krea-v1',
        'num_images': count,
        'width': 512,
        'height': 512,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming response has 'images' array - adjust based on API
      final images = data['images'] as List? ?? [data];
      return images.map((img) => GeneratedImage.fromJson(img)).toList();
    } else {
      throw Exception('Failed to generate images: ${response.statusCode} - ${response.body}');
    }
  }
}
