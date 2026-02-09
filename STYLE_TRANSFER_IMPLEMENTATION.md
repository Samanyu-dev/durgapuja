# Style Transfer Feature Implementation

## Overview

This document describes the implementation of the style transfer feature using Krea AI to apply reference images as context for image design in the Durga Puja app.

## Feature Description

The style transfer feature allows users to:
1. Upload an original image that needs to be transformed
2. Select a reference image that provides the style context
3. Optionally provide a text prompt to guide the transformation
4. Generate a new image that combines the composition of the original with the style of the reference

## Implementation Details

### Files Modified

1. **lib/screens/design/enhanced_image_editor_screen.dart**
   - Updated `_applyEdit()` method to use `applyStyleTransferWithContext`
   - Added support for style transfer with reference images as context

2. **lib/services/image_to_image_service.dart**
   - Added new `applyStyleTransferWithContext()` method
   - Enhanced prompt generation for better context understanding
   - Improved error handling and logging

3. **lib/screens/design/image_to_image_screen.dart**
   - Fixed constructor parameter issues
   - Ensured compatibility with EnhancedImageEditorScreen

### Key Components

#### 1. EnhancedImageEditorScreen
- **Reference Image Selection**: Users can upload reference images via gallery
- **Prompt Input**: Text field for additional style guidance
- **Style Transfer Button**: Triggers the Krea AI style transfer process
- **Processing Animation**: Visual feedback during image generation

#### 2. ImageToImageService
- **applyStyleTransferWithContext()**: Main method for style transfer
- **Enhanced Prompt Generation**: Creates detailed prompts combining user input with style transfer requirements
- **Error Handling**: Sanitizes error messages for user display
- **Logging**: Detailed console logging for debugging

#### 3. KreaAIService Integration
- **generateImageWithReferences()**: Uses Krea AI's reference-based generation
- **Dual Image Upload**: Both original and reference images are uploaded to Krea
- **Context Preservation**: Maintains original composition while applying reference style

## Technical Implementation

### Method Signature
```dart
Future<String> applyStyleTransferWithContext({
  required String originalImagePath,
  required String referenceImagePath,
  String prompt = '',
  String styleStrength = 'medium',
  String styleType = 'artistic',
})
```

### Enhanced Prompt Generation
The system generates intelligent prompts based on user input:

**With User Prompt:**
```
"Apply the style and mood from the reference image to the original image. 
Incorporate the following user requirements: '[user prompt]'. 
Preserve the composition and main subject of the original image while matching 
the artistic style, color palette, and mood of the reference image."
```

**Without User Prompt:**
```
"Transform the original image to match the style, mood and color palette 
of the reference image. Preserve the composition and main subject of the original image. 
Apply the artistic style of the reference image with [strength] strength and [type] style type."
```

### Workflow

1. **User Input**: Select original image, reference image, and optional prompt
2. **File Validation**: Check if both images exist and are valid
3. **Prompt Enhancement**: Generate detailed prompt combining user input with style transfer requirements
4. **Krea API Call**: Upload both images and send enhanced prompt to Krea AI
5. **Job Processing**: Poll Krea API for job completion
6. **Result Display**: Navigate to EnhancedImageEditorScreen with generated image

### Error Handling

- **File Validation**: Ensures both original and reference images exist
- **API Token Check**: Validates Krea API token availability
- **Network Errors**: Handles HTTP errors and timeouts
- **User-Friendly Messages**: Sanitizes technical errors for user display

## Usage Examples

### Basic Style Transfer
1. Upload original image (e.g., a Durga idol sketch)
2. Upload reference image (e.g., a Van Gogh painting)
3. Leave prompt empty for automatic style transfer
4. Result: Durga idol in Van Gogh's artistic style

### Guided Style Transfer
1. Upload original image
2. Upload reference image
3. Add prompt: "Make it look more vibrant with golden accents"
4. Result: Style transfer with additional user-specified enhancements

### Creative Transformation
1. Upload original image
2. Skip reference image
3. Add creative prompt: "Transform into digital art with neon colors"
4. Result: Creative transformation without style reference

## Benefits

1. **Enhanced Creativity**: Users can easily apply artistic styles to their designs
2. **Preserved Composition**: Original image structure is maintained
3. **Flexible Input**: Supports both guided and automatic style transfer
4. **Professional Results**: Leverages Krea AI's advanced image generation capabilities
5. **User-Friendly**: Simple interface with clear feedback

## Testing

The implementation includes comprehensive tests in `test_style_transfer.dart`:
- Method availability verification
- Basic functionality testing
- Prompt enhancement logic validation
- Error handling verification

## Future Enhancements

1. **Style Strength Control**: Allow users to adjust style transfer intensity
2. **Multiple Reference Images**: Support for multiple style references
3. **Style Presets**: Pre-defined style templates for common use cases
4. **Real-time Preview**: Live preview of style transfer effects
5. **Batch Processing**: Apply style transfer to multiple images at once

## Dependencies

- **Krea AI API**: For image generation and style transfer
- **Image Picker**: For image selection from device
- **HTTP Client**: For API communication
- **File System**: For temporary image storage

## Performance Considerations

- **Image Upload**: Large images may take time to upload to Krea
- **API Processing**: Style transfer jobs may take 1-2 minutes
- **Memory Usage**: Temporary file storage for uploaded images
- **Network Requirements**: Stable internet connection required for API calls

## Security

- **API Token Security**: Tokens stored securely in configuration
- **File Access**: Limited to user-selected images
- **Data Privacy**: Images processed through Krea AI's secure API