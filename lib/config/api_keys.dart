import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API keys, loaded from the `.env` file (see `.env.example`) at runtime
/// via `flutter_dotenv`. `main.dart` calls `dotenv.load()` before the app
/// starts, so these are populated by the time any service reads them.
class ApiKeys {
  static String get openAI => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Replicate API for SAM 2 (Interactive Selection)
  static String get replicateApiKey => dotenv.env['REPLICATE_API_KEY'] ?? '';

  // Krea AI API for image generation
  static String get kreaApiKey => dotenv.env['KREA_API_KEY'] ?? '';
}
