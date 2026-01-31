import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/image_to_image_service.dart';
import '../../models/generated_image.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'enhanced_image_editor_screen.dart';

class ImageToImageScreen extends StatefulWidget {
  const ImageToImageScreen({super.key});

  @override
  State<ImageToImageScreen> createState() => _ImageToImageScreenState();
}

class _ImageToImageScreenState extends State<ImageToImageScreen> with SingleTickerProviderStateMixin {
  final ImageToImageService _imageToImageService = ImageToImageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  final TextEditingController _promptController = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  
  XFile? _originalImage;
  XFile? _referenceImage;
  bool _isListening = false;
  bool _isProcessing = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  String _enhancementMode = 'enhance';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _promptController.text = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _pickOriginalImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _originalImage = image;
      });
    }
  }

  Future<void> _pickReferenceImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _referenceImage = image;
      });
    }
  }

  Future<void> _processImageToImage() async {
    if (_originalImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an original image')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      GeneratedImage resultImage;

      if (_enhancementMode == 'enhance') {
        // Basic enhancement
        final resultUrl = await _imageToImageService.enhanceExistingImage(
          imagePath: _originalImage!.path,
          prompt: _promptController.text.trim(),
          enhancementType: 'auto',
        );
        resultImage = GeneratedImage(
          id: 'enhance_${DateTime.now().millisecondsSinceEpoch}',
          url: resultUrl,
          prompt: _promptController.text.trim(),
          createdAt: DateTime.now(),
        );
      } else if (_enhancementMode == 'style_transfer') {
        // Style transfer
        if (_referenceImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a reference image for style transfer')),
          );
          return;
        }
        
        final resultUrl = await _imageToImageService.applyStyleTransfer(
          originalImagePath: _originalImage!.path,
          referenceImagePath: _referenceImage!.path,
          styleStrength: 'medium',
          styleType: 'artistic',
        );
        resultImage = GeneratedImage(
          id: 'style_${DateTime.now().millisecondsSinceEpoch}',
          url: resultUrl,
          prompt: _promptController.text.trim(),
          createdAt: DateTime.now(),
        );
      } else {
        // Creative transformation
        final resultUrl = await _imageToImageService.applyCreativeTransformation(
          imagePath: _originalImage!.path,
          prompt: _promptController.text.trim(),
          transformationType: 'creative',
        );
        resultImage = GeneratedImage(
          id: 'creative_${DateTime.now().millisecondsSinceEpoch}',
          url: resultUrl,
          prompt: _promptController.text.trim(),
          createdAt: DateTime.now(),
        );
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedImageEditorScreen(
              generatedImage: resultImage,
              originalPrompt: _promptController.text,
              originalImagePath: _originalImage!.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _applyQuickEnhancement(String enhancementType) async {
    if (_originalImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an original image')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final resultUrl = await _imageToImageService.applyPresetEnhancement(
        imagePath: _originalImage!.path,
        presetType: enhancementType,
      );
      final resultImage = GeneratedImage(
        id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
        url: resultUrl,
        prompt: enhancementType,
        createdAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedImageEditorScreen(
              generatedImage: resultImage,
              originalPrompt: enhancementType,
              originalImagePath: _originalImage!.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enhancement failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Image-to-Image Generation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _originalImage = null;
                _referenceImage = null;
                _promptController.clear();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSelectionSection(),
              const SizedBox(height: AppConstants.mediumPadding),
              _buildEnhancementModeSection(),
              const SizedBox(height: AppConstants.mediumPadding),
              _buildPromptSection(),
              const SizedBox(height: AppConstants.mediumPadding),
              _buildQuickEnhancementsSection(),
              const SizedBox(height: AppConstants.mediumPadding),
              _buildProcessButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Selection',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Original Image
            _buildImageCard(
              title: 'Original Image',
              subtitle: 'Select the image you want to transform',
              image: _originalImage,
              onTap: _pickOriginalImage,
              icon: Icons.image,
              color: AppColors.primaryBrown,
            ),
            
            const SizedBox(height: AppConstants.mediumPadding),
            
            // Reference Image (for style transfer)
            if (_enhancementMode == 'style_transfer')
              _buildImageCard(
                title: 'Reference Image',
                subtitle: 'Select style reference image',
                image: _referenceImage,
                onTap: _pickReferenceImage,
                icon: Icons.collections,
                color: AppColors.accentOrange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required XFile? image,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: image != null ? AppColors.cardCream : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: image != null ? color.withOpacity(0.3) : AppColors.textLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: AppConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (image != null)
                    Text(
                      'Selected: ${image.name}',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              image != null ? Icons.check_circle : Icons.add,
              color: image != null ? color : AppColors.textLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancementModeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enhancement Mode',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Choose how you want to transform your image',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildModeChip(
                  label: 'Enhance',
                  icon: Icons.auto_fix_high,
                  isSelected: _enhancementMode == 'enhance',
                  color: AppColors.primaryBrown,
                  onTap: () => setState(() => _enhancementMode = 'enhance'),
                ),
                _buildModeChip(
                  label: 'Style Transfer',
                  icon: Icons.palette,
                  isSelected: _enhancementMode == 'style_transfer',
                  color: AppColors.accentOrange,
                  onTap: () => setState(() => _enhancementMode = 'style_transfer'),
                ),
                _buildModeChip(
                  label: 'Creative Transform',
                  icon: Icons.transform,
                  isSelected: _enhancementMode == 'creative',
                  color: Colors.purple,
                  onTap: () => setState(() => _enhancementMode = 'creative'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onPressed: onTap,
      backgroundColor: isSelected ? color : AppColors.cardCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildPromptSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: AppColors.primaryBrown),
                const SizedBox(width: 8),
                Text(
                  'Describe Your Transformation',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Describe what you want to change or enhance in your image',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            TextField(
              controller: _promptController,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: _enhancementMode == 'enhance'
                    ? 'e.g., Enhance colors and details'
                    : _enhancementMode == 'style_transfer'
                        ? 'e.g., Apply Van Gogh style'
                        : 'e.g., Transform into digital art',
                suffixIcon: _isListening
                    ? ScaleTransition(
                        scale: _pulseAnimation,
                        child: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.red),
                          onPressed: _stopListening,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.mic_none, color: AppColors.primaryBrown),
                        onPressed: _startListening,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide(color: AppColors.textLight),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            if (_isListening)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Listening... tap the mic to stop',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEnhancementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Enhancements',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Try these preset enhancements',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickEnhancementChip(
                  label: 'Enhance Details',
                  icon: Icons.zoom_in,
                  color: AppColors.primaryBrown,
                  onTap: () => _applyQuickEnhancement('enhance_details'),
                ),
                _buildQuickEnhancementChip(
                  label: 'Color Boost',
                  icon: Icons.color_lens,
                  color: AppColors.accentOrange,
                  onTap: () => _applyQuickEnhancement('color_boost'),
                ),
                _buildQuickEnhancementChip(
                  label: 'Artistic Style',
                  icon: Icons.brush,
                  color: Colors.purple,
                  onTap: () => _applyQuickEnhancement('artistic_style'),
                ),
                _buildQuickEnhancementChip(
                  label: 'Vintage Look',
                  icon: Icons.history,
                  color: Colors.brown,
                  onTap: () => _applyQuickEnhancement('vintage'),
                ),
                _buildQuickEnhancementChip(
                  label: 'High Contrast',
                  icon: Icons.contrast,
                  color: Colors.black87,
                  onTap: () => _applyQuickEnhancement('high_contrast'),
                ),
                _buildQuickEnhancementChip(
                  label: 'Soft Focus',
                  icon: Icons.blur_circular,
                  color: Colors.blue,
                  onTap: () => _applyQuickEnhancement('soft_focus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEnhancementChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onPressed: onTap,
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildProcessButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transform Your Image',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'This will apply AI transformations to your selected image',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _originalImage != null ? _processImageToImage : null,
                    label: _isProcessing ? 'Processing...' : 'Transform Image',
                    icon: Icons.auto_awesome,
                    backgroundColor: AppColors.accentOrange,
                    isLoading: _isProcessing,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      // Navigate back to design dashboard
                      Navigator.pop(context);
                    },
                    label: 'Cancel',
                    backgroundColor: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

