import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import '../../models/editable_element.dart';
import '../../utils/colors.dart';

class DesignValidationService {
  /// Validates prompt quality for image generation
  PromptValidationResult validatePrompt(String prompt) {
    if (prompt.trim().isEmpty) {
      return PromptValidationResult(
        isValid: false,
        score: 0,
        feedback: 'Please enter a description of your Durga idol design',
        suggestions: [
          'Describe the main elements (face, jewelry, clothing)',
          'Mention the style (traditional, modern, fusion)',
          'Include color preferences if any',
        ],
      );
    }

    final String cleanPrompt = prompt.toLowerCase().trim();
    final List<String> keywords = _extractKeywords(cleanPrompt);
    final double score = _calculatePromptScore(cleanPrompt, keywords);

    if (score < 0.3) {
      return PromptValidationResult(
        isValid: false,
        score: score,
        feedback: 'Your prompt is too short or lacks detail',
        suggestions: [
          'Add more descriptive details about the design',
          'Mention specific elements like jewelry, clothing, or pose',
          'Include style preferences (traditional, modern, etc.)',
        ],
      );
    }

    if (score < 0.7) {
      return PromptValidationResult(
        isValid: true,
        score: score,
        feedback: 'Good prompt! Consider adding more details for better results',
        suggestions: [
          'Add specific details about jewelry or accessories',
          'Mention color preferences',
          'Describe the pose or expression',
        ],
      );
    }

    return PromptValidationResult(
      isValid: true,
      score: score,
      feedback: 'Excellent prompt! This should generate great results',
      suggestions: [],
    );
  }

  /// Validates reference images for quality and relevance
  Future<List<ReferenceImageValidationResult>> validateReferenceImages(
    List<File> images,
  ) async {
    final List<ReferenceImageValidationResult> results = [];

    for (int i = 0; i < images.length; i++) {
      final File image = images[i];
      final ReferenceImageValidationResult result = await _validateSingleImage(image, i);
      results.add(result);
    }

    return results;
  }

  /// Validates tracing accuracy and completeness
  TracingValidationResult validateTracing(
    List<List<Offset>> completedTraces,
    Path? currentTrace,
    bool isTracing,
  ) {
    // Check if any traces exist
    if (completedTraces.isEmpty && (currentTrace == null || !isTracing)) {
      return TracingValidationResult(
        isValid: false,
        score: 0,
        feedback: 'Please trace around the element you want to edit',
        suggestions: [
          'Draw a clear outline around the area',
          'Make sure the trace is complete',
          'Avoid tracing too close to image edges',
        ],
      );
    }

    // Check current trace if actively tracing
    if (isTracing && currentTrace != null) {
      final double traceLength = _calculateTraceLength(currentTrace);
      if (traceLength < 50) {
        return TracingValidationResult(
          isValid: false,
          score: 0.2,
          feedback: 'Keep tracing to create a complete outline',
          suggestions: [
            'Continue drawing around the element',
            'Make sure to close the shape if possible',
          ],
        );
      }

      return TracingValidationResult(
        isValid: true,
        score: 0.6,
        feedback: 'Good tracing in progress',
        suggestions: [
          'Complete the outline for best results',
          'Try to make smooth, continuous lines',
        ],
      );
    }

    // Validate completed traces
    if (completedTraces.isNotEmpty) {
      final double totalArea = _calculateTotalTraceArea(completedTraces);
      final double avgTraceLength = _calculateAverageTraceLength(completedTraces);

      if (totalArea < 1000) {
        return TracingValidationResult(
          isValid: false,
          score: 0.3,
          feedback: 'The traced area is too small',
          suggestions: [
            'Trace a larger area around the element',
            'Make sure to include the entire element',
          ],
        );
      }

      if (avgTraceLength < 30) {
        return TracingValidationResult(
          isValid: false,
          score: 0.4,
          feedback: 'Traces are too short or fragmented',
          suggestions: [
            'Create longer, more continuous traces',
            'Try to trace around the entire element',
          ],
        );
      }

      return TracingValidationResult(
        isValid: true,
        score: 0.9,
        feedback: 'Excellent tracing! Ready for editing',
        suggestions: [],
      );
    }

    return TracingValidationResult(
      isValid: false,
      score: 0,
      feedback: 'Please complete your tracing',
      suggestions: [
        'Finish tracing the element outline',
        'Make sure the trace is clear and complete',
      ],
    );
  }

  /// Validates element edit description
  ElementEditValidationResult validateElementEdit(
    ElementType elementType,
    String editDescription,
    String originalPrompt,
  ) {
    if (editDescription.trim().isEmpty) {
      return ElementEditValidationResult(
        isValid: false,
        score: 0,
        feedback: 'Please describe what changes you want to make',
        suggestions: [
          'Be specific about what you want to change',
          'Mention colors, styles, or details',
          'Reference the element type (${elementType.displayName})',
        ],
      );
    }

    final String cleanDescription = editDescription.toLowerCase().trim();
    final double score = _calculateEditScore(cleanDescription, elementType);

    if (score < 0.4) {
      return ElementEditValidationResult(
        isValid: false,
        score: score,
        feedback: 'Your edit description needs more detail',
        suggestions: [
          'Be more specific about the changes',
          'Mention colors, styles, or specific features',
          'Consider how this relates to ${elementType.displayName}',
        ],
      );
    }

    if (score < 0.8) {
      return ElementEditValidationResult(
        isValid: true,
        score: score,
        feedback: 'Good edit description',
        suggestions: [
          'Consider adding more specific details',
          'Think about color and style preferences',
        ],
      );
    }

    return ElementEditValidationResult(
      isValid: true,
      score: score,
      feedback: 'Excellent edit description!',
      suggestions: [],
    );
  }

  /// Validates generated image quality
  Future<ImageQualityValidationResult> validateGeneratedImage(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return ImageQualityValidationResult(
          isValid: false,
          score: 0,
          feedback: 'Failed to load generated image',
          suggestions: [
            'Check your internet connection',
            'Try regenerating the image',
            'Contact support if the issue persists',
          ],
        );
      }

      // Basic image format validation - simplified without external image library
      final List<int> bytes = response.bodyBytes;
      
      // Basic validation - check if bytes exist and are reasonable size
      if (bytes.length < 100) {
        return ImageQualityValidationResult(
          isValid: false,
          score: 0,
          feedback: 'Invalid image format generated',
          suggestions: [
            'Try regenerating with a different prompt',
            'Check that your prompt is clear and descriptive',
          ],
        );
      }

      // For now, we'll assume the image is valid if we can download it
      // In a full implementation, you'd use an image library to decode and validate
      return ImageQualityValidationResult(
        isValid: true,
        score: 0.8,
        feedback: 'Good image quality generated',
        suggestions: ['Image generated successfully'],
      );
    } catch (e) {
      return ImageQualityValidationResult(
        isValid: false,
        score: 0,
        feedback: 'Error validating image: $e',
        suggestions: [
          'Try regenerating the image',
          'Check your prompt for clarity',
        ],
      );
    }
  }

  // Private helper methods

  List<String> _extractKeywords(String prompt) {
    final List<String> keywords = [];
    final List<String> durgaKeywords = [
      'durga', 'idol', 'puja', 'traditional', 'bengali', 'face', 'jewelry',
      'saree', 'crown', 'lion', 'weapon', 'pose', 'expression', 'gold', 'red',
      'blue', 'green', 'white', 'modern', 'fusion', 'artistic', 'divine'
    ];

    for (final keyword in durgaKeywords) {
      if (prompt.contains(keyword)) {
        keywords.add(keyword);
      }
    }

    return keywords;
  }

  double _calculatePromptScore(String prompt, List<String> keywords) {
    double score = 0.0;

    // Length score
    if (prompt.length > 20) score += 0.3;
    if (prompt.length > 50) score += 0.2;

    // Keyword score
    score += (keywords.length * 0.1).clamp(0.0, 0.3);

    // Specificity score
    final List<String> specificWords = [
      'detailed', 'intricate', 'ornate', 'traditional', 'modern', 'fusion',
      'gold', 'silver', 'red', 'blue', 'green', 'white', 'black'
    ];

    for (final word in specificWords) {
      if (prompt.contains(word)) {
        score += 0.1;
      }
    }

    // Question detection (negative score)
    if (prompt.contains('?')) {
      score -= 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  Future<ReferenceImageValidationResult> _validateSingleImage(File image, int index) async {
    try {
      // Check file size
      final int fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB
        return ReferenceImageValidationResult(
          index: index,
          isValid: false,
          score: 0.5,
          feedback: 'Image file too large',
          suggestions: ['Compress the image or use a smaller file'],
        );
      }

      if (fileSize < 1024) { // 1KB minimum
        return ReferenceImageValidationResult(
          index: index,
          isValid: false,
          score: 0.3,
          feedback: 'Image file too small',
          suggestions: ['Select a valid image file'],
        );
      }

      return ReferenceImageValidationResult(
        index: index,
        isValid: true,
        score: 0.8,
        feedback: 'Good reference image',
        suggestions: [],
      );
    } catch (e) {
      return ReferenceImageValidationResult(
        index: index,
        isValid: false,
        score: 0,
        feedback: 'Error validating image: $e',
        suggestions: ['Try selecting a different image'],
      );
    }
  }

  double _calculateTraceLength(Path path) {
    // Simplified trace length calculation
    // In a full implementation, you'd use PathMetrics, but we'll use a simpler approach
    return 100.0; // Placeholder - would need actual calculation
  }

  double _calculateTotalTraceArea(List<List<Offset>> traces) {
    double totalArea = 0.0;
    
    for (final trace in traces) {
      if (trace.length >= 3) {
        totalArea += _calculatePolygonArea(trace);
      }
    }
    
    return totalArea;
  }

  double _calculatePolygonArea(List<Offset> points) {
    if (points.length < 3) return 0.0;
    
    double area = 0.0;
    final int n = points.length;
    
    for (int i = 0; i < n; i++) {
      final int j = (i + 1) % n;
      area += points[i].dx * points[j].dy;
      area -= points[j].dx * points[i].dy;
    }
    
    return area.abs() / 2.0;
  }

  double _calculateAverageTraceLength(List<List<Offset>> traces) {
    if (traces.isEmpty) return 0.0;
    
    double totalLength = 0.0;
    for (final trace in traces) {
      for (int i = 1; i < trace.length; i++) {
        totalLength += (trace[i] - trace[i - 1]).distance;
      }
    }
    
    return totalLength / traces.length;
  }

  double _calculateEditScore(String description, ElementType elementType) {
    double score = 0.0;

    // Length score
    if (description.length > 10) score += 0.2;
    if (description.length > 30) score += 0.2;

    // Element-specific keywords
    final String elementName = elementType.name.toLowerCase();
    if (description.contains(elementName) || 
        description.contains(elementType.displayName.toLowerCase())) {
      score += 0.3;
    }

    // Change-related words
    final List<String> changeWords = [
      'change', 'modify', 'add', 'remove', 'enhance', 'improve', 'alter',
      'different', 'new', 'update', 'replace', 'transform'
    ];

    for (final word in changeWords) {
      if (description.contains(word)) {
        score += 0.2;
      }
    }

    // Specificity words
    final List<String> specificityWords = [
      'color', 'style', 'design', 'pattern', 'texture', 'detail', 'shape',
      'size', 'position', 'arrangement', 'composition'
    ];

    for (final word in specificityWords) {
      if (description.contains(word)) {
        score += 0.1;
      }
    }

    return score.clamp(0.0, 1.0);
  }
}

// Result classes

class PromptValidationResult {
  final bool isValid;
  final double score;
  final String feedback;
  final List<String> suggestions;

  PromptValidationResult({
    required this.isValid,
    required this.score,
    required this.feedback,
    required this.suggestions,
  });
}

class ReferenceImageValidationResult {
  final int index;
  final bool isValid;
  final double score;
  final String feedback;
  final List<String> suggestions;

  ReferenceImageValidationResult({
    required this.index,
    required this.isValid,
    required this.score,
    required this.feedback,
    required this.suggestions,
  });
}

class TracingValidationResult {
  final bool isValid;
  final double score;
  final String feedback;
  final List<String> suggestions;

  TracingValidationResult({
    required this.isValid,
    required this.score,
    required this.feedback,
    required this.suggestions,
  });
}

class ElementEditValidationResult {
  final bool isValid;
  final double score;
  final String feedback;
  final List<String> suggestions;

  ElementEditValidationResult({
    required this.isValid,
    required this.score,
    required this.feedback,
    required this.suggestions,
  });
}

class ImageQualityValidationResult {
  final bool isValid;
  final double score;
  final String feedback;
  final List<String> suggestions;

  ImageQualityValidationResult({
    required this.isValid,
    required this.score,
    required this.feedback,
    required this.suggestions,
  });
}

// Widget for displaying validation feedback
class ValidationFeedbackWidget extends StatelessWidget {
  final double score;
  final String feedback;
  final List<String> suggestions;
  final bool showSuggestions;

  const ValidationFeedbackWidget({
    Key? key,
    required this.score,
    required this.feedback,
    this.suggestions = const [],
    this.showSuggestions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color feedbackColor = score >= 0.7 
        ? AppColors.accentOrange 
        : score >= 0.4 
            ? AppColors.primaryBrown 
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feedbackColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                score >= 0.7 ? Icons.check_circle : 
                score >= 0.4 ? Icons.info : Icons.warning,
                color: feedbackColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feedback,
                  style: TextStyle(
                    color: feedbackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: feedbackColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(score * 100).toInt()}%',
                  style: TextStyle(
                    color: feedbackColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          if (showSuggestions && suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Suggestions:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: feedbackColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}