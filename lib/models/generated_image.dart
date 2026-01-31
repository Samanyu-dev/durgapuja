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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'prompt': prompt,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    try {
      return GeneratedImage(
        id: json['id'] as String,
        url: json['url'] as String,
        prompt: json['prompt'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (e) {
      // Return a default image if parsing fails
      return GeneratedImage(
        id: json['id'] ?? '',
        url: json['url'] ?? '',
        prompt: json['prompt'] ?? 'Unknown prompt',
        createdAt: DateTime.now(),
      );
    }
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty && 
           url.isNotEmpty && 
           prompt.isNotEmpty &&
           createdAt.isBefore(DateTime.now().add(const Duration(hours: 1)));
  }

  // Helper methods
  String getFormattedDate() {
    return createdAt.toLocal().toString().split(' ').first;
  }
  
  bool isRecent() => createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)));
}
