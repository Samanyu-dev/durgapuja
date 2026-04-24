import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify Krea API works outside of Flutter
/// Run this with: dart test_krea_api.dart
void main() async {
  // Use the API token from the config
  const String apiToken = '98a5ee01-a1e6-4144-a83d-79855a93ab1f:7uxYb9TaYmWIjlB-a9S_fIEtGynunykZ';
  
  if (apiToken == 'YOUR_KREA_API_TOKEN_HERE') {
    print('❌ Please replace YOUR_KREA_API_TOKEN_HERE with your actual Krea API token');
    return;
  }

  print('=== TESTING KREA API OUTSIDE FLUTTER ===');
  print('This will help verify if the HTML response issue is fixed\n');

  try {
    // Test different possible endpoint formats
    final possibleUrls = [
      'https://api.krea.ai/v1/generate/image/bfl/flux-1-dev',
      'https://api.krea.ai/generate/image/bfl/flux-1-dev',
      'https://api.krea.ai/v1/generate/bfl/flux-1-dev',
      'https://api.krea.ai/generate/bfl/flux-1-dev',
    ];

    for (final urlString in possibleUrls) {
      final url = Uri.parse(urlString);
      print('Testing request to: $urlString');
      
      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $apiToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'prompt': 'test image',
          }),
        );

        print('Status Code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('✅ SUCCESS! Found working endpoint: $urlString');
          print('Response: ${response.body.substring(0, 200)}${response.body.length > 200 ? '...' : ''}');
          return;
        } else if (response.statusCode == 401) {
          print('❌ Invalid API key');
          return;
        } else if (response.statusCode == 403) {
          print('❌ Project not enabled');
          return;
        } else {
          print('❌ Status: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error: $e');
      }
      
      print('---');
    }

    print('❌ None of the tested endpoints worked');
    print('Please check the Krea API documentation for the correct endpoint URL');

  } catch (e) {
    print('❌ FAILED: Exception occurred');
    print('Error: $e');
  }

  print('\n=== CURL COMMAND FOR MANUAL TESTING ===');
  print('You can also test manually with this curl command:');
  print('curl -X POST https://api.krea.ai/v1/generate/image/bfl/flux-1-dev \\');
  print('  -H "Authorization: Bearer $apiToken" \\');
  print('  -H "Content-Type: application/json" \\');
  print('  -H "Accept: application/json" \\');
  print('  -d \'{"prompt": "test image"}\'');
}
