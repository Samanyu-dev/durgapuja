class GeneratedImage {
  final String id;
  final String url;
  final String prompt;
  final DateTime createdAt;

  GeneratedImage({
    required this.id,
    required this.url,
    required this.prompt,
    required this.createdAt,
  });

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      prompt: json['prompt'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'prompt': prompt,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
