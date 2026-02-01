import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/generated_image.dart';
import '../../models/editable_element.dart';
import '../../services/tap_to_edit_service.dart';
import '../../services/speech_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/voice_input_button.dart';

class TapToEditScreen extends StatefulWidget {
  final GeneratedImage? image;

  const TapToEditScreen({Key? key, this.image}) : super(key: key);

  @override
  State<TapToEditScreen> createState() => _TapToEditScreenState();
}

class _TapToEditScreenState extends State<TapToEditScreen> {
  final TapToEditService _tapToEditService = TapToEditService();
  final SpeechService _speechService = SpeechService();
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  GeneratedImage? _currentImage;
  bool _isEditing = false;
  bool _showEditPanel = false;
  bool _showImageSourceOptions = false;
  bool _isTracing = false;
  bool _showConfirmSelection = false;
  
  // Freehand tracing state
  List<Offset> _tracePoints = [];
  List<List<Offset>> _completedTraces = [];
  Path? _currentTracePath;
  
  double _imageWidth = 0;
  double _imageHeight = 0;
  Offset _imageOffset = Offset.zero; // Image top-left in container space for coordinate conversion
  ElementType? _selectedElementType;
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _containerKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
    
    // Get image dimensions after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImageDimensions();
    });
  }

  void _getImageDimensions() {
    final imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final containerBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox != null && containerBox != null) {
      setState(() {
        _imageWidth = imageBox.size.width;
        _imageHeight = imageBox.size.height;
        final imageGlobal = imageBox.localToGlobal(Offset.zero);
        _imageOffset = containerBox.globalToLocal(imageGlobal);
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    if (!_speechService.isListening) {
      final started = await _speechService.startListening();
      if (mounted) setState(() {});
      if (!started) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice input failed to start')),
          );
        }
      }
      return;
    }
    final text = await _speechService.stopListening();
    if (mounted) {
      setState(() {
        if (text.isNotEmpty) _promptController.text = text;
      });
    }
  }

  Future<void> _selectImageSource() async {
    setState(() {
      _showImageSourceOptions = true;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _showImageSourceOptions = false;
    });

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _currentImage = GeneratedImage(
            id: 'gallery_${DateTime.now().millisecondsSinceEpoch}',
            url: pickedFile.path,
            prompt: 'User uploaded image',
            createdAt: DateTime.now(),
          );
          // Reset selection
          _resetSelection();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _resetSelection() {
    _tracePoints.clear();
    _completedTraces.clear();
    _currentTracePath = null;
    _isTracing = false;
    _showEditPanel = false;
    _selectedElementType = null;
    _promptController.clear();
  }

  void _handlePanStart(DragStartDetails details) {
    if (_currentImage == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    
    // Haptic feedback for tracing start
    HapticFeedback.selectionClick();
    
    setState(() {
      _tracePoints = [localOffset];
      _isTracing = true;
      _showEditPanel = false;
      _currentTracePath = Path()..moveTo(localOffset.dx, localOffset.dy);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isTracing) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    // Only add point if far enough from last (smoother trace, less jitter)
    const double minPointDistance = 3.0;
    if (_tracePoints.isEmpty ||
        (localOffset - _tracePoints.last).distance > minPointDistance) {
      setState(() {
        _tracePoints.add(localOffset);
        _currentTracePath?.lineTo(localOffset.dx, localOffset.dy);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isTracing) return;

    setState(() {
      _isTracing = false;
      if (_tracePoints.length >= 12) { // Minimum trace length for a meaningful selection
        final smoothed = _smoothTrace(_tracePoints);
        _completedTraces.add(smoothed);
        _showConfirmSelection = true;
      } else {
        _resetSelection();
      }
      _currentTracePath = null;
    });
  }

  void _handleTap(TapDownDetails details) {
    if (_currentImage == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    
    // For single tap, create a small circle trace (smooth octagon for better identification)
    const double r = 28.0;
    setState(() {
      _tracePoints = [
        localOffset + const Offset(r, 0),
        localOffset + Offset(r * 0.7, r * 0.7),
        localOffset + const Offset(0, r),
        localOffset + Offset(-r * 0.7, r * 0.7),
        localOffset + const Offset(-r, 0),
        localOffset + Offset(-r * 0.7, -r * 0.7),
        localOffset + const Offset(0, -r),
        localOffset + Offset(r * 0.7, -r * 0.7),
        localOffset + const Offset(r, 0),
      ];
      _completedTraces.add(_tracePoints.toList());
      _showConfirmSelection = true;
    });
  }

  /// Smooth trace with a simple 3-point moving average for cleaner identification.
  List<Offset> _smoothTrace(List<Offset> points) {
    if (points.length < 4) return List.from(points);
    final smoothed = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final prev = points[math.max(0, i - 1)];
      final curr = points[i];
      final next = points[math.min(points.length - 1, i + 1)];
      smoothed.add(Offset(
        (prev.dx + curr.dx + next.dx) / 3,
        (prev.dy + curr.dy + next.dy) / 3,
      ));
    }
    return smoothed;
  }

  void _confirmSelection() {
    setState(() {
      _showConfirmSelection = false;
      _showEditPanel = true;
    });
  }

  void _cancelSelection() {
    setState(() {
      _showConfirmSelection = false;
      _resetSelection();
    });
  }

  Future<void> _applyEdit() async {
    if (_currentImage == null || _completedTraces.isEmpty || _selectedElementType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please trace an area and select element type')),
      );
      return;
    }

    final editDescription = _promptController.text.trim();
    if (editDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the changes')),
      );
      return;
    }

    if (_isLocalFilePath(_currentImage!.url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AI edit works with images from the design flow. For gallery images, generate or open a design first, then use Tap-to-Edit.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isEditing = true;
    });

    try {
      // Bounding box of traced area (in container space)
      final allPoints = _completedTraces.expand((trace) => trace).toList();
      final minX = allPoints.map((p) => p.dx).reduce(math.min);
      final maxX = allPoints.map((p) => p.dx).reduce(math.max);
      final minY = allPoints.map((p) => p.dy).reduce(math.min);
      final maxY = allPoints.map((p) => p.dy).reduce(math.max);
      final centerX = (minX + maxX) / 2;
      final centerY = (minY + maxY) / 2;
      // Convert center to image space for SAM (0..imageWidth, 0..imageHeight)
      final tapX = (centerX - _imageOffset.dx).clamp(0.0, _imageWidth);
      final tapY = (centerY - _imageOffset.dy).clamp(0.0, _imageHeight);

      final editPrompt = _tapToEditService.generateElementEditPrompt(
        _selectedElementType!,
        editDescription,
        _currentImage!.prompt,
      );

      final editedImage = await _tapToEditService.completeTapToEditWorkflow(
        originalImage: _currentImage!,
        tapX: tapX,
        tapY: tapY,
        imageWidth: _imageWidth,
        imageHeight: _imageHeight,
        editPrompt: editPrompt,
        elementType: _selectedElementType!,
      );

      setState(() {
        _currentImage = editedImage;
        _resetSelection();
        _isEditing = false;
      });

      // Show success dialog with option to view the edited image
      await _showEditSuccessDialog(editedImage);
    } catch (e) {
      setState(() {
        _isEditing = false;
      });
      final msg = _sanitizeErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit failed: $msg'), duration: const Duration(seconds: 5)),
      );
    }
  }

  /// Never show raw HTML or huge error dumps to the user.
  String _sanitizeErrorMessage(Object e) {
    final s = e.toString();
    if (s.contains('<html') || s.contains('<!doctype') || s.contains('<title')) {
      return 'Server returned an error. Check API keys and try again.';
    }
    if (s.length > 200) return '${s.substring(0, 197)}...';
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // If we were opened with an image (e.g. from element edit), pop back; else go to design
            if (widget.image != null && context.canPop()) {
              context.pop();
            } else {
              context.go('/design/welcome');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('Tap-to-Edit'),
        actions: [
          if (_completedTraces.isNotEmpty || _currentTracePath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSelection,
              tooltip: 'Clear Selection',
            ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _selectImageSource,
            tooltip: 'Select Image',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image saved successfully!')),
              );
            },
            tooltip: 'Save',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Image Viewer (ignore pointer when overlay or edit panel is shown so buttons work)
            IgnorePointer(
              ignoring: _showConfirmSelection || _showEditPanel,
              child: _buildImageViewer(),
            ),

            // Image Source Options
            if (_showImageSourceOptions)
              _buildImageSourceOptions(),

            // Confirm Selection Overlay (positioned above navbar so it's visible and tappable)
            if (_showConfirmSelection)
              _buildConfirmSelectionOverlay(),

            // Edit Panel
            if (_showEditPanel)
              _buildEditPanel(),

            // Loading Overlay
            if (_isEditing)
              _buildLoadingOverlay(),

            // Instructions
            if (_currentImage != null && _completedTraces.isEmpty && _currentTracePath == null && !_showEditPanel)
              _buildInstructions(),
          ],
        ),
      ),
    );
  }

  /// Returns true if [url] is a local file path (e.g. from gallery picker).
  bool _isLocalFilePath(String url) {
    return url.startsWith('/') ||
        url.startsWith('file:') ||
        (!url.startsWith('http://') && !url.startsWith('https://'));
  }

  Widget _buildImageWidget() {
    final url = _currentImage!.url;
    if (_isLocalFilePath(url)) {
      final file = File(url);
      if (!file.existsSync()) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.white),
          ),
        );
      }
      return Image.file(
        file,
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _getImageDimensions();
            });
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.broken_image, size: 48, color: Colors.white),
            ),
          );
        },
      );
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _getImageDimensions();
          });
          return child;
        }
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrown),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTap,
      child: Container(
        key: _containerKey,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image (contain so coordinates match displayed rect)
            if (_currentImage != null)
              Center(
                child: FittedBox(
                  key: _imageKey,
                  fit: BoxFit.contain,
                  child: _buildImageWidget(),
                ),
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'No image selected\nTap the image icon to select one',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeLarge,
                    ),
                  ),
                ),
              ),

            // Freehand Tracing Overlay
            if (_completedTraces.isNotEmpty || _currentTracePath != null)
              CustomPaint(
                painter: TracingPainter(
                  completedTraces: _completedTraces,
                  currentTrace: _currentTracePath,
                  isTracing: _isTracing,
                ),
                child: Container(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmSelectionOverlay() {
    // Position above the bottom navbar (~100px) so overlay is visible and tappable
    const double navBarClearance = 100;
    return Positioned(
      bottom: navBarClearance,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          decoration: BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tracing Confirmed',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Element traced and ready for editing',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _cancelSelection,
                      label: 'Cancel',
                      backgroundColor: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: _confirmSelection,
                      label: 'Confirm Selection',
                      icon: Icons.check,
                      backgroundColor: AppColors.accentOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            Icon(Icons.touch_app, color: AppColors.accentOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Trace around the element you want to edit with your finger',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOptions() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    label: 'Gallery',
                    icon: Icons.photo_library,
                    backgroundColor: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    label: 'Camera',
                    icon: Icons.camera_alt,
                    backgroundColor: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomButton(
              onPressed: () {
                setState(() {
                  _showImageSourceOptions = false;
                });
              },
              label: 'Cancel',
              backgroundColor: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPanel() {
    EditableElement.fromType(_selectedElementType ?? ElementType.face);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.borderRadius),
            topRight: Radius.circular(AppConstants.borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // Added bottom padding to prevent navbar overlap
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Element Selection (only show if not auto-detected)
              if (_selectedElementType == null)
                Column(
                  children: [
                    Text(
                      'Select Element to Edit',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: ElementType.values.map((elementType) {
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getIconForType(elementType), size: 16),
                              const SizedBox(width: 4),
                              Text(elementType.displayName),
                            ],
                          ),
                          selected: _selectedElementType == elementType,
                          selectedColor: AppColors.accentOrange.withOpacity(0.3),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedElementType = elementType;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              else
                // Auto-detected element info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppColors.accentOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForType(_selectedElementType!),
                        size: 20,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected: ${_selectedElementType!.displayName}',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () {
                          setState(() {
                            _selectedElementType = null;
                          });
                        },
                        tooltip: 'Change selection',
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Guidance Text
              if (_selectedElementType != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppColors.accentOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tapToEditService.getElementGuidance(_selectedElementType!),
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Prompt Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppColors.primaryBrown.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        maxLines: 3,
                        minLines: 2,
                        style: TextStyle(fontSize: AppConstants.fontSizeMedium),
                        decoration: InputDecoration(
                          hintText: _selectedElementType != null
                              ? 'Describe changes for ${_selectedElementType!.displayName.toLowerCase()}...'
                              : 'Select an element type first',
                          hintStyle: TextStyle(color: AppColors.textLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: VoiceInputButton(
                        onPressed: _startVoiceInput,
                        isListening: _speechService.isListening,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Example Prompts
              if (_selectedElementType != null &&
                  _tapToEditService.getExamplePrompts(_selectedElementType!).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Prompts:',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tapToEditService
                          .getExamplePrompts(_selectedElementType!)
                          .map((prompt) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _promptController.text = prompt;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryBrown.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              prompt,
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSmall,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _resetSelection,
                      label: 'Cancel',
                      backgroundColor: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      onPressed: _applyEdit,
                      label: 'Apply Edit',
                      icon: Icons.auto_fix_high,
                      backgroundColor: AppColors.accentOrange,
                      isLoading: _isEditing,
                    ),
                  ),
                ],
              ),

              // Success Indicator
              if (_currentImage != null && _currentImage!.id != widget.image?.id)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(
                        color: AppColors.accentOrange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Image has been edited! View the result above.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmall,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Additional content to ensure the page is scrollable and buttons are accessible
              const SizedBox(height: 40),
              _buildAccessibilityInfo(),
              const SizedBox(height: 60),
              _buildAdditionalContent(),
              const SizedBox(height: 80), // Extra padding to ensure buttons are accessible
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.accentOrange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.accessibility, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Accessibility Tips',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If you\'re having trouble accessing the Apply Edit button, try scrolling down the edit panel. The buttons are positioned at the bottom to ensure they\'re accessible even when navigation bars are present.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.touch_app, size: 16, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Scroll down to access the Apply Edit button',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.arrow_downward, size: 16, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'The edit panel is designed to be scrollable for better accessibility',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.primaryBrown.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Edit Tips',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'For best editing results:',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle, size: 6, color: AppColors.accentOrange),
              const SizedBox(width: 12),
              Text(
                'Be specific about what you want to change',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, size: 6, color: AppColors.accentOrange),
              const SizedBox(width: 12),
              Text(
                'Use clear, descriptive language',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, size: 6, color: AppColors.accentOrange),
              const SizedBox(width: 12),
              Text(
                'Consider the element type you selected',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, size: 6, color: AppColors.accentOrange),
              const SizedBox(width: 12),
              Text(
                'Use example prompts as inspiration',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tip: The more precise your description, the better the AI can make your edits!',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppColors.textDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accentOrange),
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              'Processing your edit...',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'This may take a moment',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(ElementType elementType) {
    switch (elementType) {
      case ElementType.face:
        return Icons.face;
      case ElementType.jewelry:
        return Icons.diamond;
      case ElementType.clothing:
        return Icons.checkroom;
      case ElementType.weapon:
        return Icons.extension;
      case ElementType.ornaments:
      case ElementType.ornament:
        return Icons.diamond;
      case ElementType.pose:
        return Icons.accessibility;
      case ElementType.background:
        return Icons.photo;
      case ElementType.lighting:
        return Icons.lightbulb;
      case ElementType.lion:
        return Icons.pets;
    }
  }

  Future<void> _showEditSuccessDialog(GeneratedImage editedImage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your image has been successfully edited.'),
              const SizedBox(height: 16),
              const Text(
                'You can now view the edited image in the viewer above.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for drawing freehand tracing overlay with clear identification
class TracingPainter extends CustomPainter {
  final List<List<Offset>> completedTraces;
  final Path? currentTrace;
  final bool isTracing;

  TracingPainter({
    required this.completedTraces,
    required this.currentTrace,
    required this.isTracing,
  });

  static const double _strokeWidth = 4.0;
  static const double _glowWidth = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed traces
    for (final trace in completedTraces) {
      if (trace.length < 2) continue;
      
      final path = Path();
      path.moveTo(trace.first.dx, trace.first.dy);
      for (int i = 1; i < trace.length; i++) {
        path.lineTo(trace[i].dx, trace[i].dy);
      }
      path.close();

      // Dark overlay outside the traced area (dimmer for clearer focus on selection)
      final overlayPaint = Paint()
        ..color = Colors.black.withOpacity(0.55)
        ..style = PaintingStyle.fill;

      final combinedPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addPath(path, Offset.zero)
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(combinedPath, overlayPaint);

      // Fill the traced area first so border sits on top
      final fillPaint = Paint()
        ..color = AppColors.accentOrange.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Subtle glow behind border for better visibility
      final glowPaint = Paint()
        ..color = AppColors.accentOrange.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, glowPaint);

      // Trace border — rounded for smoother identification
      final borderPaint = Paint()
        ..color = AppColors.accentOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, borderPaint);
    }

    // Draw current trace being drawn
    if (currentTrace != null) {
      // Dashed border while drawing (rounded)
      final dashPath = _createDashedPath(currentTrace!, 12.0, 6.0);
      final borderPaint = Paint()
        ..color = AppColors.accentOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(dashPath, borderPaint);

      // Current position indicator (larger for visibility)
      final metrics = currentTrace!.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final lastMetric = metrics.last;
        final pos = lastMetric.getTangentForOffset(lastMetric.length)?.position;
        
        if (pos != null) {
          final centerPaint = Paint()
            ..color = AppColors.accentOrange
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 8, centerPaint);

          final centerBorderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5;
          canvas.drawCircle(pos, 8, centerBorderPaint);
        }
      }
    }
  }

  Path _createDashedPath(Path path, double dashLength, double dashSpace) {
    final metrics = path.computeMetrics();
    final newPath = Path();
    
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      
      while (distance < metric.length) {
        if (draw) {
          final startTangent = metric.getTangentForOffset(distance);
          final endTangent = metric.getTangentForOffset(distance + dashLength);
          
          if (startTangent != null && endTangent != null) {
            newPath.moveTo(startTangent.position.dx, startTangent.position.dy);
            newPath.lineTo(endTangent.position.dx, endTangent.position.dy);
          }
        }
        
        distance += dashLength + dashSpace;
        draw = !draw;
      }
    }
    
    return newPath;
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) {
    return oldDelegate.completedTraces != completedTraces ||
        oldDelegate.currentTrace != currentTrace ||
        oldDelegate.isTracing != isTracing;
  }
}

/// Custom painter for drawing the circle selection overlay (legacy)
class CircleSelectionPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final bool isDrawing;

  CircleSelectionPainter({
    required this.center,
    required this.radius,
    this.isDrawing = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dark overlay outside the circle
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final circlePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(circlePath, overlayPaint);

    // Circle border
    final borderPaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, borderPaint);

    // Animated dashed circle if drawing
    if (isDrawing) {
      final dashedPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      _drawDashedCircle(canvas, center, radius + 5, dashedPaint);
    }

    // Center point
    final centerPaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    // White inner border for center point
    final centerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 6, centerBorderPaint);

    // Selection handles (for resizing - optional)
    if (!isDrawing && radius > 30) {
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final handleBorderPaint = Paint()
        ..color = AppColors.accentOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw handles at cardinal points
      final handlePositions = [
        Offset(center.dx, center.dy - radius), // Top
        Offset(center.dx + radius, center.dy), // Right
        Offset(center.dx, center.dy + radius), // Bottom
        Offset(center.dx - radius, center.dy), // Left
      ];

      for (final pos in handlePositions) {
        canvas.drawCircle(pos, 8, handlePaint);
        canvas.drawCircle(pos, 8, handleBorderPaint);
      }
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashLength = 10.0;
    const dashSpace = 5.0;
    const totalDashes = 360 / (dashLength + dashSpace);

    for (int i = 0; i < totalDashes; i++) {
      final startAngle = (i * (dashLength + dashSpace)) * (3.14159 / 180);
      final sweepAngle = dashLength * (3.14159 / 180);

      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CircleSelectionPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.isDrawing != isDrawing;
  }
}
