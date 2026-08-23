class Concept {
  final String id;
  final String title;
  final String dateCreated;
  final String imageUrl;
  final String theme;
  final String? prompt;

  Concept({
    required this.id,
    required this.title,
    required this.dateCreated,
    required this.imageUrl,
    required this.theme,
    this.prompt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'theme': theme,
      'prompt': prompt,
      'created_at': dateCreated,
    };
  }

  factory Concept.fromMap(Map<String, dynamic> map) {
    return Concept(
      id: map['id'] as String,
      title: map['title'] as String,
      dateCreated: map['created_at'] as String,
      imageUrl: map['image_url'] as String,
      theme: (map['theme'] as String?) ?? 'Traditional',
      prompt: map['prompt'] as String?,
    );
  }
}
