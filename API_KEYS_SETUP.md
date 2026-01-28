# API Keys Setup Guide

## Required API Keys and Where to Get Them

### 1. Replicate API Key (for SAM 2 - Interactive Selection)

**Website**: https://replicate.com/

**Steps to Get API Key**:
1. Go to https://replicate.com/
2. Click "Sign Up" or "Log In"
3. Create a free account or log in to your existing account
4. Go to your account settings or dashboard
5. Look for "API Tokens" or "API Keys" section
6. Click "Create new token" or "Generate API key"
7. Copy the generated API key

**Pricing**: 
- Free tier available with limited credits
- Pay-as-you-go pricing: $0.02 per prediction for SAM 2
- Credits can be purchased as needed

**Usage**: Used for converting tap coordinates into precise selection masks using Meta SAM 2

---

### 2. Krea AI API Key (for Generative Fill)

**Website**: https://krea.ai/

**Steps to Get API Key**:
1. Go to https://krea.ai/
2. Click "Sign Up" or "Log In"
3. Create a free account or log in to your existing account
4. Go to your account settings or dashboard
5. Look for "API Tokens" or "API Keys" section
6. Click "Create new token" or "Generate API key"
7. Copy the generated API key

**Pricing**: 
- Free tier available with limited credits
- Pay-as-you-go pricing: Varies by model used
- Flux model is cost-effective for generative fill
- Credits can be purchased as needed

**Usage**: Used for generative fill (inpainting) to replace textures while respecting original lighting

**Alternative**: If Krea API is not available, you can use:
- **Leonardo.ai API**: https://leonardo.ai/ (Alternative generative fill)
- **OpenAI DALL-E API**: https://platform.openai.com/api-keys

---

### 3. Photoroom API Key (for AI Relighting)

**Website**: https://www.photoroom.com/

**Steps to Get API Key**:
1. Go to https://www.photoroom.com/
2. Click "API" or "Developers" in the menu
3. Sign up for API access
4. You may need to contact sales for API access approval
5. Once approved, you'll receive API credentials
6. Copy your API key

**Alternative**: If Photoroom API is not available, you can use:
- **Remove.bg API**: https://www.remove.bg/api (for background and lighting)
- **Cloudinary API**: https://cloudinary.com/ (for image enhancement)

**Pricing**:
- Photoroom: Contact sales for pricing (typically enterprise-level)
- Remove.bg: $199/month for 25,000 credits
- Cloudinary: Free tier available, paid plans start at $89/month

**Usage**: Used for AI relighting to ensure cohesive lighting across edited elements

---

## How to Configure API Keys

### Step 1: Update the API Keys File

Edit `lib/config/api_keys.dart` and add your keys:

```dart
class ApiKeys {
  static const String openAI = 'your_openai_key_here';
  
  // Replicate API for SAM 2 (Interactive Selection)
  static const String replicateApiKey = 'your_replicate_api_key_here';
  
  // Adobe Firefly API (Generative Fill)
  static const String adobeApiKey = 'your_adobe_firefly_api_key_here';
  
  // Photoroom API (AI Relighting)
  static const String photoroomApiKey = 'your_photoroom_api_key_here';
}
```

### Step 2: Add Required Dependencies

Update your `pubspec.yaml` to include any missing dependencies:

```yaml
dependencies:
  http: ^1.2.0
  flutter_dotenv: ^6.0.0
  image_picker: ^1.1.2
  photo_view: ^0.15.0
```

### Step 3: Environment Variables (Recommended)

For better security, consider using environment variables:

1. Create a `.env` file in your project root
2. Add your API keys:
   ```
   REPLICATE_API_KEY=your_replicate_key
   ADOBE_API_KEY=your_adobe_key
   PHOTOROOM_API_KEY=your_photoroom_key
   ```
3. Update the API keys file to read from environment:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   class ApiKeys {
     static String get replicateApiKey => dotenv.env['REPLICATE_API_KEY'] ?? '';
     static String get adobeApiKey => dotenv.env['ADOBE_API_KEY'] ?? '';
     static String get photoroomApiKey => dotenv.env['PHOTOROOM_API_KEY'] ?? '';
   }
   ```

## Testing Your Setup

### Test Each Service Individually

1. **Test Replicate SAM 2**:
   ```dart
   final samService = ReplicateSAMService();
   try {
     final maskUrl = await samService.generateMaskFromTap(
       imageUrl: 'https://example.com/image.jpg',
       x: 100.0,
       y: 100.0,
       imageWidth: 800.0,
       imageHeight: 600.0,
     );
     print('Mask generated: $maskUrl');
   } catch (e) {
     print('SAM 2 test failed: $e');
   }
   ```

2. **Test Adobe Firefly**:
   ```dart
   final fireflyService = AdobeFireflyService();
   try {
     final resultUrl = await fireflyService.completeGenerativeFill(
       originalImageUrl: 'https://example.com/image.jpg',
       maskImageUrl: 'https://example.com/mask.jpg',
       prompt: 'Make the expression more serene',
     );
     print('Firefly result: $resultUrl');
   } catch (e) {
     print('Firefly test failed: $e');
   }
   ```

3. **Test Photoroom**:
   ```dart
   final photoroomService = PhotoroomService();
   try {
     final resultUrl = await photoroomService.completeRelighting(
       imageUrl: 'https://example.com/image.jpg',
       preserveColors: true,
     );
     print('Photoroom result: $resultUrl');
   } catch (e) {
     print('Photoroom test failed: $e');
   }
   ```

## Troubleshooting

### Common Issues

1. **API Key Not Working**:
   - Double-check you copied the key correctly
   - Ensure no extra spaces or characters
   - Verify the key hasn't expired

2. **Rate Limiting**:
   - Check your API usage limits
   - Implement retry logic with exponential backoff
   - Consider caching results where possible

3. **Network Issues**:
   - Ensure internet connectivity
   - Check firewall settings
   - Verify API endpoints are accessible

4. **Authentication Errors**:
   - Confirm API key format is correct
   - Check if additional authentication headers are needed
   - Verify your account has the necessary permissions

### Getting Help

- **Replicate**: https://replicate.com/docs
- **Adobe Firefly**: https://www.adobe.com/developer/firefly.html
- **Photoroom**: https://www.photoroom.com/contact

## Cost Management

### Monitor Usage
- Set up usage alerts in your API provider dashboards
- Implement logging to track API calls
- Consider implementing usage limits in your app

### Optimize Costs
- Cache frequently used masks and edits
- Implement batch processing where possible
- Use lower-resolution previews during development
- Clean up temporary files and storage regularly

## Security Best Practices

1. **Never commit API keys to version control**
2. **Use environment variables in production**
3. **Implement proper error handling without exposing keys**
4. **Regularly rotate API keys**
5. **Monitor for unauthorized usage**

---

**Note**: Some APIs (especially Adobe Firefly and Photoroom) may require business verification or have limited availability. Consider the alternatives mentioned above if you encounter access issues.