import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/krea_ai_service.dart';
import '../../models/generated_image.dart';
import 'enhanced_image_editor_screen.dart';

class CreateDesignScreen extends StatefulWidget {
  const CreateDesignScreen({super.key});

  @override
  State<CreateDesignScreen> createState() => _CreateDesignScreenState();
}

class _CreateDesignScreenState extends State<CreateDesignScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final KreaAIService _kreaService = KreaAIService();
  final List<File> _referenceImages = [];
  
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isGenerating = false;
  String _confidence = '';
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
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
              _confidence = result.hasConfidenceRating
                  ? (result.confidence * 100).toStringAsFixed(1)
                  : '';
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

  Future<void> _pickImageFromGallery() async {
    if (_referenceImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 reference images allowed')),
      );
      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _referenceImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (_referenceImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 reference images allowed')),
      );
      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _referenceImages.add(File(image.path));
      });
    }
  }

  void _removeReferenceImage(int index) {
    setState(() {
      _referenceImages.removeAt(index);
    });
  }

  String _sanitizeError(Object e) {
    final s = e.toString();
    if (s.contains('Krea API token not found') || s.contains('KREA_API')) {
      return 'API key missing. Add KREA_API_TOKEN in .env or at krea.ai/settings/api-tokens.';
    }
    if (s.contains('<html') || s.contains('<!doctype') || s.contains('401') || s.contains('403')) {
      return 'Server error. Check your Krea API key and try again.';
    }
    if (s.length > 120) return '${s.substring(0, 117)}...';
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      GeneratedImage generatedImage;
      
      if (_referenceImages.isNotEmpty) {
        generatedImage = await _kreaService.generateImageWithReferences(
          _promptController.text,
          _referenceImages,
        );
      } else {
        generatedImage = await _kreaService.generateImage(_promptController.text);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedImageEditorScreen(
              generatedImage: generatedImage,
              originalPrompt: _promptController.text,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = _sanitizeError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation failed: $msg'),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Durga Idol Designer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), // Increased bottom padding to prevent navbar overlap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildPromptSection(),
              const SizedBox(height: 24),
              _buildReferenceImagesSection(),
              const SizedBox(height: 32),
              _buildGenerateButton(),
              const SizedBox(height: 16),
              _buildQuickPrompts(),
              // Additional content to ensure the page is scrollable and button is accessible
              const SizedBox(height: 40),
              _buildAccessibilityInfo(),
              const SizedBox(height: 60),
              _buildAdditionalContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      color: const Color(0xFFFF6B35),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            const Text(
              'Create Your Durga Idol',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use text, voice, or reference images',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                const Text(
                  'Describe Your Design',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'E.g., Traditional Bengali Durga idol with golden jewelry and red saree...',
                suffixIcon: _isListening
                    ? ScaleTransition(
                        scale: _pulseAnimation,
                        child: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.red),
                          onPressed: _stopListening,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.mic_none, color: Color(0xFFFF6B35)),
                        onPressed: _startListening,
                      ),
              ),
            ),
            if (_isListening && _confidence.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Confidence: $_confidence%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceImagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                const Text(
                  'Reference Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_referenceImages.length}/3',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Add up to 3 reference images to guide the AI',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAddImageButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _pickImageFromGallery,
                  ),
                  const SizedBox(width: 12),
                  _buildAddImageButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: _pickImageFromCamera,
                  ),
                  const SizedBox(width: 12),
                  ..._referenceImages.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildReferenceImageCard(entry.value, entry.key),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _referenceImages.length < 3 ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: _referenceImages.length < 3
              ? const Color(0xFFFF6B35).withOpacity(0.1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _referenceImages.length < 3
                ? const Color(0xFFFF6B35)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: _referenceImages.length < 3
                  ? const Color(0xFFFF6B35)
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _referenceImages.length < 3
                    ? const Color(0xFFFF6B35)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceImageCard(File image, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeReferenceImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _isGenerating ? null : _generateImage,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isGenerating
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome),
                SizedBox(width: 8),
                Text(
                  'Generate Design',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      'Traditional Bengali Durga',
      'Modern fusion design',
      'Golden jewelry details',
      'Royal red saree',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Prompts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prompts.map((prompt) {
            return ActionChip(
              label: Text(prompt),
              onPressed: () {
                setState(() {
                  _promptController.text = prompt;
                });
              },
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccessibilityInfo() {
    return Card(
      color: const Color(0xFFFF6B35).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.accessibility, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                const Text(
                  'Accessibility Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'If you\'re having trouble accessing the Generate Design button, try scrolling down the page. The button is positioned at the bottom of the content area to ensure it\'s accessible even when navigation bars are present.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.touch_app, size: 16, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                Text(
                  'Scroll down to access the Generate Design button',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.arrow_downward, size: 16, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                Text(
                  'The page is designed to be scrollable for better accessibility',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalContent() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                const Text(
                  'Design Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'For best results, use detailed descriptions that include:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFFFF6B35)),
                const SizedBox(width: 12),
                Text(
                  'Specific materials (gold, silver, wood)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFFFF6B35)),
                const SizedBox(width: 12),
                Text(
                  'Color schemes and patterns',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFFFF6B35)),
                const SizedBox(width: 12),
                Text(
                  'Traditional vs modern styles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFFFF6B35)),
                const SizedBox(width: 12),
                Text(
                  'Specific cultural elements',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: The more specific your description, the better the AI can create your vision!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
