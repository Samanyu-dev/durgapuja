import 'package:flutter/material.dart';

enum ElementType {
  face,
  jewelry,
  clothing,
  weapon,
  background,
  lion,
  ornament,
  ornaments,
  pose,
  lighting,
}

extension ElementTypeExtension on ElementType {
  String get displayName {
    switch (this) {
      case ElementType.face:
        return 'Face';
      case ElementType.jewelry:
        return 'Jewelry';
      case ElementType.clothing:
        return 'Clothing';
      case ElementType.weapon:
        return 'Weapon';
      case ElementType.background:
        return 'Background';
      case ElementType.lion:
        return 'Lion';
      case ElementType.ornament:
        return 'Ornament';
      case ElementType.ornaments:
        return 'Ornaments';
      case ElementType.pose:
        return 'Pose';
      case ElementType.lighting:
        return 'Lighting';
    }
  }

  // Get icon for the element type
  IconData get icon {
    switch (this) {
      case ElementType.face:
        return Icons.face;
      case ElementType.jewelry:
        return Icons.diamond;
      case ElementType.clothing:
        return Icons.checkroom;
      case ElementType.weapon:
        return Icons.extension;
      case ElementType.background:
        return Icons.photo_library;
      case ElementType.lion:
        return Icons.pets;
      case ElementType.ornament:
      case ElementType.ornaments:
        return Icons.star;
      case ElementType.pose:
        return Icons.accessibility;
      case ElementType.lighting:
        return Icons.lightbulb;
    }
  }

  // Get color for the element type
  Color get color {
    switch (this) {
      case ElementType.face:
        return const Color(0xFFE8D0B8);
      case ElementType.jewelry:
        return const Color(0xFFFFD700);
      case ElementType.clothing:
        return const Color(0xFFE57373);
      case ElementType.weapon:
        return const Color(0xFF90A4AE);
      case ElementType.background:
        return const Color(0xFF81C784);
      case ElementType.lion:
        return const Color(0xFFFFB74D);
      case ElementType.ornament:
      case ElementType.ornaments:
        return const Color(0xFFFF8A80);
      case ElementType.pose:
        return const Color(0xFF4FC3F7);
      case ElementType.lighting:
        return const Color(0xFFFFF176);
    }
  }
}

class EditableElement {
  final ElementType type;
  final String description;
  final List<String> examplePrompts;

  const EditableElement({
    required this.type,
    required this.description,
    required this.examplePrompts,
  });

  static EditableElement? fromType(ElementType type) {
    switch (type) {
      case ElementType.face:
        return const EditableElement(
          type: ElementType.face,
          description: 'Edit the facial features and expression',
          examplePrompts: [
            'Make the expression more serene',
            'Add a gentle smile',
            'Enhance the divine glow',
          ],
        );
      case ElementType.jewelry:
        return const EditableElement(
          type: ElementType.jewelry,
          description: 'Modify jewelry and ornaments',
          examplePrompts: [
            'Add more gold detailing',
            'Change to silver jewelry',
            'Add gemstones to the crown',
          ],
        );
      case ElementType.clothing:
        return const EditableElement(
          type: ElementType.clothing,
          description: 'Change the saree and attire',
          examplePrompts: [
            'Change to red and gold saree',
            'Add more intricate patterns',
            'Make the fabric shimmer',
          ],
        );
      case ElementType.weapon:
        return const EditableElement(
          type: ElementType.weapon,
          description: 'Edit weapons and held objects',
          examplePrompts: [
            'Make the trident more detailed',
            'Add golden shine to weapons',
            'Enhance the divine glow',
          ],
        );
      case ElementType.background:
        return const EditableElement(
          type: ElementType.background,
          description: 'Modify the background and backdrop',
          examplePrompts: [
            'Add traditional Bengali motifs',
            'Make it more elaborate',
            'Add golden decorations',
          ],
        );
      case ElementType.lion:
        return const EditableElement(
          type: ElementType.lion,
          description: 'Edit the lion vahana',
          examplePrompts: [
            'Make the lion more majestic',
            'Add more detailed fur',
            'Enhance the fierce expression',
          ],
        );
      case ElementType.ornament:
      case ElementType.ornaments:
        return const EditableElement(
          type: ElementType.ornament,
          description: 'Edit decorative ornaments',
          examplePrompts: [
            'Add more flowers',
            'Make decorations more elaborate',
            'Add traditional patterns',
          ],
        );
      case ElementType.pose:
        return const EditableElement(
          type: ElementType.pose,
          description: 'Edit the pose and posture',
          examplePrompts: [
            'Make the pose more dynamic',
            'Adjust the hand position',
            'Enhance the divine posture',
          ],
        );
      case ElementType.lighting:
        return const EditableElement(
          type: ElementType.lighting,
          description: 'Modify lighting and illumination',
          examplePrompts: [
            'Add divine glow',
            'Enhance lighting effects',
            'Make it more radiant',
          ],
        );
    }
  }
}
