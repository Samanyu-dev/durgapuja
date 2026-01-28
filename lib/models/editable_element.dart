enum ElementType {
  face('Face & Expression'),
  ornaments('Ornaments & Jewelry'),
  clothing('Clothing & Saree'),
  pose('Pose & Posture'),
  background('Background & Environment'),
  lighting('Lighting & Shadows');

  final String displayName;
  const ElementType(this.displayName);
}

class EditableElement {
  final ElementType type;
  final String description;
  final String promptSuggestion;
  final List<String> examplePrompts;

  EditableElement({
    required this.type,
    required this.description,
    required this.promptSuggestion,
    required this.examplePrompts,
  });

  static List<EditableElement> get allElements => [
        EditableElement(
          type: ElementType.face,
          description: 'Modify facial features, expressions, and divine attributes',
          promptSuggestion: 'Change the facial expression to...',
          examplePrompts: [
            'Make the expression more serene and peaceful',
            'Add a gentle smile to the face',
            'Make the eyes more compassionate',
            'Change the expression to fierce and powerful',
          ],
        ),
        EditableElement(
          type: ElementType.ornaments,
          description: 'Edit jewelry, crowns, and decorative accessories',
          promptSuggestion: 'Modify the ornaments to...',
          examplePrompts: [
            'Add more intricate gold detailing to the jewelry',
            'Change the crown design to traditional Bengali style',
            'Add more gemstones to the necklace',
            'Make the ornaments more elaborate and ornate',
          ],
        ),
        EditableElement(
          type: ElementType.clothing,
          description: 'Change saree patterns, colors, and fabric details',
          promptSuggestion: 'Update the clothing to...',
          examplePrompts: [
            'Change the saree color to red and gold',
            'Add traditional Bengali patterns to the saree',
            'Make the fabric more flowing and elegant',
            'Add more intricate embroidery details',
          ],
        ),
        EditableElement(
          type: ElementType.pose,
          description: 'Adjust body posture, hand gestures, and positioning',
          promptSuggestion: 'Modify the pose to...',
          examplePrompts: [
            'Make the posture more dynamic and powerful',
            'Change the hand gesture to blessing pose',
            'Adjust the body angle for better composition',
            'Make the pose more graceful and elegant',
          ],
        ),
        EditableElement(
          type: ElementType.background,
          description: 'Edit the backdrop, environment, and decorative elements',
          promptSuggestion: 'Change the background to...',
          examplePrompts: [
            'Add traditional Bengali motifs to the background',
            'Create a more festive and colorful atmosphere',
            'Add flowers and decorative elements',
            'Make the background more elaborate and detailed',
          ],
        ),
        EditableElement(
          type: ElementType.lighting,
          description: 'Modify lighting effects, shadows, and illumination',
          promptSuggestion: 'Adjust the lighting to...',
          examplePrompts: [
            'Add warm golden lighting effects',
            'Create dramatic shadow play',
            'Make the lighting more divine and ethereal',
            'Add soft, ambient lighting for a peaceful feel',
          ],
        ),
      ];

  static EditableElement? fromType(ElementType type) {
    return allElements.firstWhere((element) => element.type == type, orElse: () => allElements.first);
  }
}