import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/krea_ai_service.dart';
import '../../services/speech_service.dart';
import '../../services/image_save_service.dart';
import '../../models/generated_image.dart';
import '../../widgets/voice_input_button.dart';
import 'image_viewer_screen.dart';

class CreateDesignScreen extends StatefulWidget {
  const CreateDesignScreen({Key? key}) : super(key: key);

  @override
  State<CreateDesignScreen> createState() => _CreateDesignScreenState();
}

class _CreateDesignScreenState extends State<CreateDesignScreen> {
  final TextEditingController _promptController = TextEditingController();
  final KreaAIService _kreaService = KreaAIService();
  final SpeechService _speechService = SpeechService();

  final List<GeneratedImage> _generatedImages = [];
  bool _isGenerating = false;
  bool _isListening = false;
  bool _hasGenerated = false;
  File? _selectedImage;
  String _imagePrompt = '';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateDesign() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt or use voice input')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasGenerated = false;
    });

    try {
      final images = await _kreaService.generateImages(prompt, count: 1);
      
      setState(() {
        _generatedImages.addAll(images);
        _isGenerating = false;
        _hasGenerated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design generated successfully!')),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate design: $e')),
      );
    }
  }

  Future<void> _startVoiceInput() async {
    if (_isListening) {
      await _stopVoiceInput();
      return;
    }

    setState(() {
      _isListening = true;
    });

    try {
      final recognizedText = await _speechService.listenBangla();
      
      if (recognizedText.isNotEmpty) {
        setState(() {
          _promptController.text = recognizedText;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice input failed: $e')),
      );
    } finally {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopVoiceInput() async {
    try {
      final text = await _speechService.stopListening();
      if (text.isNotEmpty) {
        setState(() {
          _promptController.text = text;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop voice input: $e')),
      );
    } finally {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _saveImage(GeneratedImage image) async {
    final ImageSaveService saveService = ImageSaveService();
    
    try {
      final success = await saveService.saveToGallery(image.url, 'durga_design');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  Future<void> _editImage(GeneratedImage image) async {
    // Navigate to edit screen
    context.push('/design/edit/image/${image.id}', extra: image);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Create Durga Design'),
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Vision',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe your Durga idol design or speak your vision',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Input Field with Voice Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(
                        color: AppColors.primaryBrown.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promptController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'e.g., "Traditional Durga with golden ornaments and serene expression"',
                              hintStyle: TextStyle(color: AppColors.textLight),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        VoiceInputButton(
                          onPressed: _startVoiceInput,
                          isListening: _isListening,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Image Upload Section
                  if (_selectedImage == null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Or upload reference image',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentOrange,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _takePhoto,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrown,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Selected Image Preview
                  if (_selectedImage != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Image',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cardCream,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) => _imagePrompt = value,
                                decoration: InputDecoration(
                                  hintText: 'Describe what you want to modify or enhance in this image',
                                  hintStyle: TextStyle(color: AppColors.textLight),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                    borderSide: BorderSide(color: AppColors.primaryBrown.withOpacity(0.2)),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Handle image-based generation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image-based generation feature coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Generate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBrown,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _imagePrompt = '';
                                  });
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primaryBrown),
                                  foregroundColor: AppColors.primaryBrown,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Change'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  
                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generateDesign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                      child: _isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Generating Design...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome),
                                SizedBox(width: 8),
                                Text('Generate Design'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Status Section
            if (_isGenerating)
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Creating your design...',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI is generating your Durga idol design with intricate details',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmall,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_hasGenerated && _generatedImages.isNotEmpty)
              const SizedBox(height: AppConstants.largePadding),

            // Generated Images Section
            if (_generatedImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Generated Designs',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _generatedImages.length,
                    itemBuilder: (context, index) {
                      final image = _generatedImages[index];
                      return _buildGeneratedImageCard(image);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedImageCard(GeneratedImage image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.largeRadius)),
            child: Image.network(
              image.url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: AppColors.cardCream,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBrown,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColors.cardCream,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveImage(image),
                    icon: const Icon(Icons.download),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryBrown),
                      foregroundColor: AppColors.primaryBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editImage(image),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}