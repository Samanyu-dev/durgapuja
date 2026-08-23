import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_keys.dart';

class ReplicateSAMService {
  final String _apiKey = ApiKeys.replicateApiKey;
  final String _baseUrl = 'https://api.replicate.com/v1';

  /// Generate a mask from tap coordinates using SAM 2
  Future<String> generateMaskFromTap({
    required String imageUrl,
    required double x,
    required double y,
    required double imageWidth,
    required double imageHeight,
  }) async {
    try {
      // Normalize coordinates to 0-1 range
      final normalizedX = x / imageWidth;
      final normalizedY = y / imageHeight;

      final response = await http.post(
        Uri.parse('$_baseUrl/predictions'),
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': 'meta/sam-2', // Using Meta SAM 2 model
          'input': {
            'image': imageUrl,
            'points': [[normalizedX, normalizedY]],
            'point_labels': [1], // 1 indicates positive point
            'box': null,
            'mask_input': null,
            'multimask_output': false,
            'return_extra_metrics': false,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final predictionId = data['id'];
        
        // Poll for completion
        return await _pollForCompletion(predictionId);
      } else {
        throw Exception('Failed to generate mask: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SAM 2 mask generation failed: $e');
      throw Exception('Mask generation failed: $e');
    }
  }

  /// Poll for prediction completion
  Future<String> _pollForCompletion(String predictionId) async {
    final Uri uri = Uri.parse('$_baseUrl/predictions/$predictionId');
    
    while (true) {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        if (status == 'succeeded') {
          final output = data['output'];
          if (output != null && output is List && output.isNotEmpty) {
            return output[0]; // Return mask image URL
          } else {
            throw Exception('No mask output received');
          }
        } else if (status == 'failed' || status == 'canceled') {
          throw Exception('Prediction failed or was canceled');
        }
        // Continue polling if pending
      } else {
        throw Exception('Failed to check prediction status: ${response.statusCode}');
      }

      // Wait before polling again
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// Alternative method using lucataco/segment-anything-2 model
  Future<String> generateMaskFromTapAlternative({
    required String imageUrl,
    required double x,
    required double y,
    required double imageWidth,
    required double imageHeight,
  }) async {
    try {
      // Normalize coordinates to 0-1 range
      final normalizedX = x / imageWidth;
      final normalizedY = y / imageHeight;

      final response = await http.post(
        Uri.parse('$_baseUrl/predictions'),
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': 'lucataco/segment-anything-2', // Alternative SAM 2 model
          'input': {
            'image': imageUrl,
            'points': [[normalizedX, normalizedY]],
            'point_labels': [1],
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final predictionId = data['id'];
        
        return await _pollForCompletion(predictionId);
      } else {
        throw Exception('Failed to generate mask: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Alternative SAM 2 mask generation failed: $e');
      throw Exception('Alternative mask generation failed: $e');
    }
  }
}