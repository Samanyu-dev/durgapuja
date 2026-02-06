import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/generated_image.dart';
import '../../services/tap_to_edit_service.dart';
import '../../services/concepts_store_service.dart';
import '../../models/editable_element.dart';

class EnhancedImageEditorScreen extends StatefulWidget {
  final GeneratedImage generatedImage;
  final String originalPrompt;
  final String? originalImagePath;

  const EnhancedImageEditorScreen({
    super.key,
    required this.generatedImage,
    required this.originalPrompt,
    this.originalImagePath,
  });

  @override
  State<EnhancedImageEditorScreen> createState() =>
      _EnhancedImageEditorScreenState();
}

class _EnhancedImageEditorScreenState extends State<EnhancedImageEditorScreen>
    with TickerProviderStateMixin {
  final GlobalKey _imageKey = GlobalKey();
  final TextEditingController _editPromptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final TapToEditService _editService = TapToEditService();
  final ConceptsStoreService _conceptsStore = ConceptsStoreService();
  final ScrollController _scrollController = ScrollController();

  List<Offset> _tracePoints = [];
  bool _isTracing = false;
  bool _isProcessing = false;
  File? _editReferenceImage;
  double _imageWidth = 0;
  double _imageHeight = 0;
  ElementType _selectedElementType = ElementType.face;

  late AnimationController _tracePulseController;
  late Animation<double> _tracePulseAnimation;

  /// Durga-relevant element types shown in the edit sheet
  static const List<ElementType> _durgaElementTypes = [
    ElementType.face,
    ElementType.weapon,
    ElementType.ornaments,
    ElementType.lion,
    ElementType.clothing,
    ElementType.jewelry,
    ElementType.background,
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
    _tracePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _tracePulseAnimation = Tween<double>(begin: 6.0, end: 14.0).animate(
      CurvedAnimation(parent: _tracePulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tracePulseController.dispose();
    _editPromptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final response = await http.get(Uri.parse(widget.generatedImage.url));
    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _imageWidth = frame.image.width.toDouble();
      _imageHeight = frame.image.height.toDouble();
    });
  }

  void _startTracing(Offset position) {
    setState(() {
      _isTracing = true;
      _tracePoints = [position];
    });
  }

  void _updateTrace(Offset position) {
    if (_isTracing) {
      setState(() {
        _tracePoints.add(position);
      });
    }
  }

  void _endTracing() {
    setState(() {
      _isTracing = false;
    });
    if (_tracePoints.length >= 3) {
      _showEditDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please trace a larger area')),
      );
      setState(() {
        _tracePoints.clear();
      });
    }
  }

  void _clearTrace() {
    setState(() {
      _tracePoints.clear();
      _isTracing = false;
    });
  }

  Future<void> _pickEditReference() async {
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

  void _showEditDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Get screen dimensions and safe areas
          final mediaQuery = MediaQuery.of(context);
          final screenHeight = mediaQuery.size.height;
          final bottomPadding = mediaQuery.padding.bottom;
          final viewInsets = mediaQuery.viewInsets.bottom;

          // Calculate modal height - make it taller to ensure button is accessible
          final modalHeight = screenHeight * 0.85;

          return Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: Container(
              height: modalHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Edit Selection',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF6B35,
                                    ).withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: Color(0xFFFF6B35),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Region selected · ${_selectedElementType.displayName}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                            _clearTrace();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'What are you editing?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _durgaElementTypes.map((type) {
                              final isSelected = _selectedElementType == type;
                              return FilterChip(
                                label: Text(type.displayName),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedElementType = type);
                                  setModalState(() {});
                                },
                                selectedColor: const Color(
                                  0xFFFF6B35,
                                ).withOpacity(0.3),
                                checkmarkColor: const Color(0xFFFF6B35),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Describe your edit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _editPromptController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  EditableElement.fromType(
                                    _selectedElementType,
                                  )?.examplePrompts.first ??
                                  'E.g., Make it more detailed...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Reference Image (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_editReferenceImage != null)
                            Stack(
                              children: [
                                Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(_editReferenceImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        _editReferenceImage = null;
                                      });
                                      setState(() {
                                        _editReferenceImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _pickEditReference();
                                setModalState(() {});
                                setState(() {});
                              },
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Add Reference Image'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Apply Edit button (duplicate for easy access)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _applyEdit();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Apply Edit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Quick Edits',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (EditableElement.fromType(
                                          _selectedElementType,
                                        )?.examplePrompts ??
                                        [
                                          'More detailed',
                                          'Change color',
                                          'Enhance',
                                        ])
                                    .map((text) {
                                      return ActionChip(
                                        label: Text(text),
                                        onPressed: () {
                                          _editPromptController.text = text;
                                          setModalState(() {});
                                        },
                                      );
                                    })
                                    .toList(),
                          ),
                          const SizedBox(height: 24),

                          // Additional helpful content to ensure scrollability
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pro Tips',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• Be specific in your edit description\n'
                                  '• Reference images improve accuracy\n'
                                  '• Larger traced areas work better',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Additional content for better scrolling experience
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF6B35).withOpacity(0.05),
                                  const Color(0xFFFFB74D).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFF6B35,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb_outline,
                                        size: 18,
                                        color: Color(0xFFFF6B35),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Edit Suggestions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'For faces: Try "make more divine", "add intricate tilaka", or "enhance facial features"\n\n'
                                  'For weapons: Try "add more detail to trident", "make weapon more ornate", or "enhance metallic shine"\n\n'
                                  'For ornaments: Try "add traditional jewelry", "make more elaborate", or "enhance golden details"\n\n'
                                  'For lion: Try "make more majestic", "add detailed mane", or "enhance fierce expression"\n\n'
                                  'For clothing: Try "add intricate patterns", "enhance silk texture", or "make more vibrant"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Additional helpful information
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFFF6B35,
                                ).withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      size: 18,
                                      color: Color(0xFFFF6B35),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Best Practices',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '✓ Trace completely around the element\n'
                                  '✓ Keep the traced area clear and focused\n'
                                  '✓ Use descriptive, specific language\n'
                                  '✓ Select the correct element type\n'
                                  '✓ Upload reference images when available\n'
                                  '✓ Allow processing time for best results',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Add significant extra space at bottom to ensure button is always visible
                          // This must be larger than the button container to allow proper scrolling
                          const SizedBox(height: 250),
                        ],
                      ),
                    ),
                  ),

                  // Fixed Apply Edit button at bottom
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _applyEdit();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Apply Edit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _applyEdit() async {
    if (_editPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your edit')),
      );
      return;
    }

    if (_tracePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please trace the area to edit')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final RenderBox? renderBox =
          _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;

      // Convert trace points to image coordinates (multiple points help SAM detect region)
      final traceImagePoints = <List<double>>[];
      for (var p in _tracePoints) {
        final imageX = (p.dx / size.width) * _imageWidth;
        final imageY = (p.dy / size.height) * _imageHeight;
        traceImagePoints.add([imageX, imageY]);
      }

      final centerX =
          _tracePoints.map((p) => p.dx).reduce((a, b) => a + b) /
          _tracePoints.length;
      final centerY =
          _tracePoints.map((p) => p.dy).reduce((a, b) => a + b) /
          _tracePoints.length;

      final imageX = (centerX / size.width) * _imageWidth;
      final imageY = (centerY / size.height) * _imageHeight;

      final userText = _editPromptController.text.trim();
      final elementName = _selectedElementType.displayName.toLowerCase();
      final editPrompt = 'Edit the $elementName of this Durga idol: $userText';

      final editedImage = await _editService.completeTapToEditWorkflow(
        originalImage: widget.generatedImage,
        tapX: imageX,
        tapY: imageY,
        imageWidth: _imageWidth,
        imageHeight: _imageHeight,
        editPrompt: editPrompt,
        elementType: _selectedElementType,
        traceImagePoints: traceImagePoints.length >= 2
            ? traceImagePoints
            : null,
        referenceImage: _editReferenceImage,
        applyRelighting: true,
        preserveColors: true,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedImageEditorScreen(
              generatedImage: editedImage,
              originalPrompt: widget.originalPrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = _sanitizeEditError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Show a short, user-friendly message for tap-to-edit errors.
  String _sanitizeEditError(Object e) {
    final s = e.toString();
    if (s.contains('version does not exist') ||
        s.contains("don't have permission")) {
      return 'Edit service unavailable. Check your Replicate API key at replicate.com/account/api-tokens.';
    }
    if (s.contains('Mask generation failed')) {
      return 'Selection not detected. Trace clearly around one part (face, weapon, ornaments, lion) or try a larger area.';
    }
    if (s.contains('Tap-to-Edit workflow failed')) {
      return 'Edit could not be applied. Please try again or use a different area.';
    }
    if (s.length > 120) return '${s.substring(0, 117)}...';
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
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
        title: const Text('Edit Your Design'),
        actions: [
          if (_tracePoints.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearTrace,
              tooltip: 'Clear trace',
            ),
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
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onPanStart: (details) {
                final RenderBox? renderBox =
                    _imageKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPosition = renderBox.globalToLocal(
                    details.globalPosition,
                  );
                  _startTracing(localPosition);
                }
              },
              onPanUpdate: (details) {
                final RenderBox? renderBox =
                    _imageKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPosition = renderBox.globalToLocal(
                    details.globalPosition,
                  );
                  _updateTrace(localPosition);
                }
              },
              onPanEnd: (_) => _endTracing(),
              child: RepaintBoundary(
                key: _imageKey,
                child: Stack(
                  children: [
                    Image.network(
                      widget.generatedImage.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
                    if (_tracePoints.isNotEmpty)
                      AnimatedBuilder(
                        animation: _tracePulseAnimation,
                        builder: (context, _) => CustomPaint(
                          painter: TracePainter(
                            points: _tracePoints,
                            isActive: _isTracing,
                            pulseValue: _tracePulseAnimation.value,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    if (_tracePoints.length >= 3 && !_isTracing)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _RegionSelectedBadge(
                            elementType: _selectedElementType,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF6B35)),
                    SizedBox(height: 16),
                    Text(
                      'Processing your edit...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isTracing && _tracePoints.isEmpty && !_isProcessing)
            Positioned(
              bottom: 32,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app,
                      size: 32,
                      color: Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Trace around the part you want to edit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Face, weapons, ornaments, lion, sari — draw around one element',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tip: Choose "What are you editing?" in the panel (Face, Weapon, Lion, etc.) then describe the change.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Trace clearly around a single element for best results.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
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
            content: Text('Download failed: ${_sanitizeEditError(e)}'),
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
            content: Text('Save failed: ${_sanitizeEditError(e)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class TracePainter extends CustomPainter {
  final List<Offset> points;
  final bool isActive;
  final double pulseValue;

  TracePainter({
    required this.points,
    required this.isActive,
    this.pulseValue = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final bounds = _computeBounds();
    if (bounds == null) return;

    // When trace is complete: fill with subtle tint (region selected)
    if (!isActive && points.length >= 3) {
      final fillPath = Path.from(path)..lineTo(points[0].dx, points[0].dy);
      final fillPaint = Paint()
        ..color = const Color(0xFFFF6B35).withOpacity(0.12)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Outer glow
    final outerGlow = Paint()
      ..color = const Color(0xFFFFB74D).withOpacity(0.25)
      ..strokeWidth = 18.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, outerGlow);

    // Inner glow
    final innerGlow = Paint()
      ..color = const Color(0xFFFF6B35).withOpacity(0.5)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, innerGlow);

    // Gradient stroke (orange → gold)
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFFFF6B35), Color(0xFFFF8F50), Color(0xFFFFB74D)],
    );
    final strokeRect = Rect.fromLTWH(
      bounds.left - 20,
      bounds.top - 20,
      bounds.width + 40,
      bounds.height + 40,
    );
    final strokePaint = Paint()
      ..shader = gradient.createShader(strokeRect)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Bright inner edge
    final innerStroke = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, innerStroke);

    // Pulsing dot at current point when drawing
    if (isActive && points.isNotEmpty) {
      final last = points.last;
      final r = 4.0 + pulseValue;
      final pulseFill = Paint()
        ..color = const Color(0xFFFF6B35).withOpacity(0.9 - pulseValue * 0.04)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(last, r, pulseFill);

      final pulseRing = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(last, r, pulseRing);
    }
  }

  Rect? _computeBounds() {
    if (points.isEmpty) return null;
    double minX = points[0].dx, maxX = points[0].dx;
    double minY = points[0].dy, maxY = points[0].dy;
    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool shouldRepaint(TracePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.isActive != isActive ||
        oldDelegate.pulseValue != pulseValue;
  }
}

class _RegionSelectedBadge extends StatelessWidget {
  final ElementType elementType;

  const _RegionSelectedBadge({required this.elementType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Region selected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '· ${elementType.displayName}',
            style: const TextStyle(
              color: Color(0xFFFFB74D),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
