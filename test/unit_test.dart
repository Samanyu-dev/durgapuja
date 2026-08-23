import 'package:flutter_test/flutter_test.dart';

/// Test helper function to enhance Durga idol prompts
String enhanceDurgaIdolPrompt(String prompt) {
  final lowerPrompt = prompt.toLowerCase();

  // Check if this is a simple Durga idol request
  final durgaKeywords = ['durga', 'durgapuja', 'durga puja', 'durgotsav', 'idol', 'murt'];
  final isDurgaRelated = durgaKeywords.any((keyword) => lowerPrompt.contains(keyword));

  // If it's a simple Durga-related prompt (less than 50 characters), enhance it
  if (isDurgaRelated && prompt.length < 50) {
    final enhancedPrompt = '''
Create a magnificent Durga idol with intricate details:
- Goddess Durga with divine golden skin texture, realistic facial structure, and benevolent expression
- Traditional Bengali features with almond-shaped eyes, arched eyebrows, and serene smile
- Elaborate gold jewelry including necklace, earrings, armlets, and crown with detailed gemstone work
- Rich traditional Bengali saree with golden borders and intricate patterns
- Multiple arms holding weapons (trident, mace, discus, conch) and blessing hand
- Lion vahana (vehicle) beneath her feet with detailed fur texture and fierce expression
- Decorative backdrop with traditional Bengali motifs, flowers, and ornamental elements
- High quality, photorealistic rendering with proper lighting and shadows
- Traditional Durga Puja color scheme with gold, red, and white accents
Original theme: $prompt
    '''.trim();

    return enhancedPrompt;
  }

  return prompt;
}

void main() {
  group('KreaAIService Prompt Enhancement', () {
    test('enhances simple Durga idol prompt', () {
      // Test simple Durga-related prompts
      final testPrompts = [
        'durga idol',
        'generate a durga',
        'durga puja murt',
        'durgotsav idol',
      ];

      for (final prompt in testPrompts) {
        final enhanced = enhanceDurgaIdolPrompt(prompt);
        expect(enhanced, isNot(equals(prompt)), reason: 'Prompt "$prompt" should be enhanced');
        expect(enhanced.contains('golden skin texture'), isTrue, reason: 'Enhanced prompt should contain detailed specifications');
        expect(enhanced.contains('jewelry'), isTrue, reason: 'Enhanced prompt should contain jewelry details');
      }
    });

    test('leaves complex prompts unchanged', () {
      final complexPrompt = 'Create a beautiful Durga idol with intricate details and gold ornaments';
      final enhanced = enhanceDurgaIdolPrompt(complexPrompt);
      expect(enhanced, equals(complexPrompt), reason: 'Complex prompts should remain unchanged');
    });

    test('leaves non-Durga prompts unchanged', () {
      final nonDurgaPrompts = [
        'a beautiful landscape',
        'modern abstract art',
        'portrait of a person',
      ];

      for (final prompt in nonDurgaPrompts) {
        final enhanced = enhanceDurgaIdolPrompt(prompt);
        expect(enhanced, equals(prompt), reason: 'Non-Durga prompts should remain unchanged');
      }
    });
  });
}
