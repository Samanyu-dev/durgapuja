import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_keys.dart';

class ReplicateSAMService {
  final String _apiKey = ApiKeys.replicateApiKey;
  final String _baseUrl = 'https://api.replicate.com/v1';

  /// Replicate requires the full 64-char version hash for meta/sam-2 (not just "meta/sam-2").
  static const String _sam2Version =
      'meta/sam-2:fe97b453a6455861e3bac769b441ca1f1086110da7466dbb65cf1eecfd60dc83';

  /// Maximum points to send to SAM (improves region detection for weapons, face, etc.)
  static const int _maxPoints = 12;

  /// Generate a mask from multiple points (e.g. from user trace) for better region detection.
  /// SAM 2 segments the region containing these points - works for face, weapons, ornaments, lion, etc.
  Future<String> generateMaskFromPoints({
    required String imageUrl,
    required List<List<double>> imagePoints,
    required double imageWidth,
    required double imageHeight,
  }) async {
    if (imagePoints.isEmpty) {
      throw Exception('At least one point is required');
    }
    // Normalize to 0-1 and limit count
    final normalized = <List<double>>[];
    final take = imagePoints.length > _maxPoints
        ? _maxPoints
        : imagePoints.length;
    final step = imagePoints.length > _maxPoints
        ? (imagePoints.length / _maxPoints).floor()
        : 1;
    for (var i = 0; i < take; i++) {
      final idx = (i * step).clamp(0, imagePoints.length - 1);
      final p = imagePoints[idx];
      if (p.length >= 2) {
        normalized.add([
          (p[0] / imageWidth).clamp(0.0, 1.0),
          (p[1] / imageHeight).clamp(0.0, 1.0),
        ]);
      }
    }
    if (normalized.isEmpty) throw Exception('No valid points');
    return _runMaskPrediction(imageUrl: imageUrl, points: normalized);
  }

  /// Generate a mask from a single tap (center of trace).
  Future<String> generateMaskFromTap({
    required String imageUrl,
    required double x,
    required double y,
    required double imageWidth,
    required double imageHeight,
  }) async {
    final normalizedX = (x / imageWidth).clamp(0.0, 1.0);
    final normalizedY = (y / imageHeight).clamp(0.0, 1.0);
    return _runMaskPrediction(
      imageUrl: imageUrl,
      points: [[normalizedX, normalizedY]],
    );
  }

  Future<String> _runMaskPrediction({
    required String imageUrl,
    required List<List<double>> points,
  }) async {
    try {
      final pointLabels = List<int>.filled(points.length, 1);

      final response = await http.post(
        Uri.parse('$_baseUrl/predictions'),
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'version': _sam2Version,
          'input': {
            'image': imageUrl,
            'points': points,
            'point_labels': pointLabels,
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
        final body = response.body;
        String msg = 'Failed to generate mask (${response.statusCode})';
        if (body.trim().toLowerCase().startsWith('<!doctype') ||
            body.trim().toLowerCase().startsWith('<html')) {
          msg = 'Segment service returned an error. Check your Replicate API key and image URL.';
        } else if (body.isNotEmpty && body.length < 300) {
          try {
            final err = jsonDecode(body);
            if (err is Map && (err['detail'] != null || err['message'] != null)) {
              msg = err['detail']?.toString() ?? err['message']?.toString() ?? msg;
            }
          } catch (_) {}
        }
        throw Exception(msg);
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
          'Accept': 'application/json',
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
          'Accept': 'application/json',
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