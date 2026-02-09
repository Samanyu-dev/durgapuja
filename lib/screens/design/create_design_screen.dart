import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/openai_image_service.dart';
import '../../services/krea_ai_service.dart';
import '../../services/language_service.dart';
import '../../models/generated_image.dart';
import '../../widgets/language_toggle_action.dart';
import 'enhanced_image_editor_screen.dart';

class CreateDesignScreen extends StatefulWidget {
  const CreateDesignScreen({super.key});

  @override
  State<CreateDesignScreen> createState() => _CreateDesignScreenState();
}

class _CreateDesignScreenState extends State<CreateDesignScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final OpenAIImageService _openAIImageService = OpenAIImageService();
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
        SnackBar(content: Text(Provider.of<LanguageService>(context, listen: false).getText('max_3_images'))),
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
        SnackBar(content: Text(Provider.of<LanguageService>(context, listen: false).getText('max_3_images'))),
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
    if (s.contains('OpenAI API key missing') || s.contains('api_keys.dart')) {
      return 'API key missing. Set ApiKeys.openAIKey in lib/config/api_keys.dart (for reference-image generation).';
    }
    if (s.contains('<html') || s.contains('<!doctype') || s.contains('401') || s.contains('403')) {
      return 'Server error. Check your API key and try again.';
    }
    if (s.length > 120) return '${s.substring(0, 117)}...';
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Provider.of<LanguageService>(context, listen: false).getText('please_enter_prompt'))),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      GeneratedImage generatedImage;
      
      if (_referenceImages.isNotEmpty) {
        // Only this flow uses OpenAI (reference image + prompt).
        generatedImage = await _openAIImageService.generateImageWithReference(
          referenceImage: _referenceImages.first,
          prompt: _promptController.text.trim(),
        );
      } else {
        generatedImage = await _kreaService.generateImage(_promptController.text.trim());
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
    final lang = context.watch<LanguageService>();
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            lang.getText('durga_idol_designer'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: const [
            LanguageToggleAction(),
          ],
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), // Increased bottom padding to prevent navbar overlap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(lang),
              const SizedBox(height: 24),
              _buildPromptSection(lang),
              const SizedBox(height: 24),
              _buildReferenceImagesSection(lang),
              const SizedBox(height: 32),
              _buildGenerateButton(lang),
              const SizedBox(height: 16),
              _buildQuickPrompts(lang),
              // Additional content to ensure the page is scrollable and button is accessible
              const SizedBox(height: 40),
              _buildAccessibilityInfo(lang),
              const SizedBox(height: 60),
              _buildAdditionalContent(lang),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeaderSection(LanguageService lang) {
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
            Text(
              lang.getText('create_your_durga_idol'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang.getText('use_text_voice_or_reference'),
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

  Widget _buildPromptSection(LanguageService lang) {
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
                Text(
                  lang.getText('describe_your_design'),
                  style: const TextStyle(
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
                hintText: lang.getText('prompt_hint_durga'),
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
                  '${lang.getText('confidence_label')}: $_confidence%',
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

  Widget _buildReferenceImagesSection(LanguageService lang) {
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
                Text(
                  lang.getText('reference_images'),
                  style: const TextStyle(
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
              lang.getText('reference_images_help'),
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
                    label: lang.getText('gallery'),
                    onTap: _pickImageFromGallery,
                  ),
                  const SizedBox(width: 12),
                  _buildAddImageButton(
                    icon: Icons.camera_alt,
                    label: lang.getText('camera'),
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

  Widget _buildGenerateButton(LanguageService lang) {
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                Text(
                  lang.getText('generate_design'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickPrompts(LanguageService lang) {
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
          lang.getText('quick_prompts'),
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

  Widget _buildAccessibilityInfo(LanguageService lang) {
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
                Text(
                  lang.getText('accessibility_tips'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lang.getText('accessibility_button_help'),
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
                  lang.getText('scroll_for_button'),
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
                  lang.getText('page_scrollable'),
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

  Widget _buildAdditionalContent(LanguageService lang) {
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
                Text(
                  lang.getText('design_tips'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lang.getText('best_results_include'),
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
                  lang.getText('specific_materials'),
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
                  lang.getText('color_schemes'),
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
                  lang.getText('traditional_vs_modern'),
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
                  lang.getText('cultural_elements'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              lang.getText('tip_specific'),
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
