import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/generated_image.dart';
import '../../services/image_to_image_service.dart';
import '../../services/concepts_store_service.dart';

class EnhancedImageEditorScreen extends StatefulWidget {
  final GeneratedImage generatedImage;
  final String originalPrompt;

  const EnhancedImageEditorScreen({
    super.key,
    required this.generatedImage,
    required this.originalPrompt,
  });

  @override
  State<EnhancedImageEditorScreen> createState() =>
      _EnhancedImageEditorScreenState();
}

class _EnhancedImageEditorScreenState extends State<EnhancedImageEditorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _editPromptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageToImageService _imageService = ImageToImageService();
  final ConceptsStoreService _conceptsStore = ConceptsStoreService();

  File? _editReferenceImage;
  File? _tempDownloadedImage;
  bool _isProcessing = false;
  double _imageWidth = 0;
  double _imageHeight = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _downloadToTemp();
    _loadImageDimensions();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _editPromptController.dispose();
    _tempDownloadedImage?.deleteSync();
    super.dispose();
  }

  Future<void> _loadImageDimensions() async {
    final response = await http.get(Uri.parse(widget.generatedImage.url));
    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _imageWidth = frame.image.width.toDouble();
      _imageHeight = frame.image.height.toDouble();
    });
  }

  Future<void> _downloadToTemp() async {
    try {
      final response = await http.get(Uri.parse(widget.generatedImage.url));
      final bytes = response.bodyBytes;
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/temp_${widget.generatedImage.id}.jpg',
      );
      await file.writeAsBytes(bytes);
      _tempDownloadedImage = file;
    } catch (e) {
      debugPrint('Failed to download temp image: $e');
    }
  }

  Future<void> _pickReferenceImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _editReferenceImage = File(image.path);
      });
    }
  }

  void _removeReferenceImage() {
    setState(() {
      _editReferenceImage = null;
    });
  }

  String _sanitizeError(Object e) {
    final s = e.toString();
    if (s.contains('not found') || s.contains('API')) {
      return 'API configuration error. Check your settings.';
    }
    if (s.length > 120) return '${s.substring(0, 117)}...';
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _applyEdit() async {
    if (_editPromptController.text.trim().isEmpty && _editReferenceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a prompt or add a reference image')),
      );
      return;
    }

    if (_tempDownloadedImage == null || !_tempDownloadedImage!.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image not ready. Please wait...')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      String editedImageUrl;

      if (_editReferenceImage != null) {
        // Style transfer with reference image
        editedImageUrl = await _imageService.applyStyleTransfer(
          originalImagePath: _tempDownloadedImage!.path,
          referenceImagePath: _editReferenceImage!.path,
        );
      } else {
        // Creative transformation with prompt
        editedImageUrl = await _imageService.applyCreativeTransformation(
          imagePath: _tempDownloadedImage!.path,
          prompt: _editPromptController.text.trim(),
        );
      }

      final editedImage = GeneratedImage(
        id: '${widget.generatedImage.id}_edited_${DateTime.now().millisecondsSinceEpoch}',
        url: editedImageUrl,
        prompt: _editPromptController.text.isNotEmpty
            ? _editPromptController.text
            : widget.originalPrompt,
        createdAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedImageEditorScreen(
              generatedImage: editedImage,
              originalPrompt: _editPromptController.text.isNotEmpty
                  ? _editPromptController.text
                  : widget.originalPrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_sanitizeError(e)),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _downloadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.generatedImage.url));
      final bytes = response.bodyBytes;
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/durga_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${file.path}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${_sanitizeError(e)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveToMyConcepts() async {
    try {
      await _conceptsStore.saveConcept(
        id: widget.generatedImage.id,
        title: widget.generatedImage.prompt.isNotEmpty
            ? widget.generatedImage.prompt.length > 40
                ? '${widget.generatedImage.prompt.substring(0, 40)}...'
                : widget.generatedImage.prompt
            : 'Durga Design ${DateTime.now().day}/${DateTime.now().month}',
        imageUrl: widget.generatedImage.url,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to My Concepts'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: ${_sanitizeError(e)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createNewDesign() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/design/welcome'),
          tooltip: 'Back to Design',
        ),
        title: const Text('Your Design'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: _saveToMyConcepts,
            tooltip: 'Save to My Concepts',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadImage,
            tooltip: 'Download',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isProcessing ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Image.network(
                  widget.generatedImage.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF6B35)),
                    SizedBox(height: 16),
                    Text(
                      'Creating your design...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildEditPanel(),
        ],
      ),
    );
  }

  Widget _buildEditPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Your Design',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Prompt Input
              TextField(
                controller: _editPromptController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe how you want to edit...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),

              // Reference Image Section
              Row(
                children: [
                  const Text(
                    'Reference Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_editReferenceImage != null)
                    TextButton.icon(
                      onPressed: _removeReferenceImage,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Remove'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (_editReferenceImage != null)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_editReferenceImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickReferenceImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Reference Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              const SizedBox(height: 20),

              // Apply Edit Button
              ElevatedButton(
                onPressed: _applyEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Generate Edit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Create New Button
              OutlinedButton(
                onPressed: _createNewDesign,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create New Design'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
