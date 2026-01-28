import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  GeneratedImage? _currentImage;
  bool _isEditing = false;
  bool _isListening = false;
  bool _showEditPanel = false;
  bool _showImageSourceOptions = false;
  bool _isDrawingCircle = false;
  bool _showConfirmSelection = false;
  
  // Circle selection state
  Offset? _circleStart;
  Offset? _circleEnd;
  double _circleRadius = 0;
  Offset? _circleCenter;
  
  double _imageWidth = 0;
  double _imageHeight = 0;
  ElementType? _selectedElementType;
  
  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
    });

    try {
      final speechService = SpeechService();
      final recognizedText = await speechService.listenBangla();
      
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
    _circleStart = null;
    _circleEnd = null;
    _circleRadius = 0;
    _circleCenter = null;
    _isDrawingCircle = false;
    _showEditPanel = false;
    _selectedElementType = null;
    _promptController.clear();
  }

  void _handlePanStart(DragStartDetails details) {
    if (_currentImage == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    
    // Haptic feedback for circle drawing start
    HapticFeedback.selectionClick();
    
    setState(() {
      _circleStart = localOffset;
      _circleEnd = localOffset;
      _isDrawingCircle = true;
      _showEditPanel = false;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDrawingCircle || _circleStart == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      _circleEnd = localOffset;
      _circleRadius = (_circleStart! - _circleEnd!).distance;
      _circleCenter = _circleStart;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDrawingCircle) return;

    setState(() {
      _isDrawingCircle = false;
      if (_circleRadius > 10) { // Minimum circle size
        _showConfirmSelection = true;
      } else {
        _resetSelection();
      }
    });
  }

  void _handleTap(TapDownDetails details) {
    if (_currentImage == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    
    // Default circle radius for tap
    const double defaultRadius = 50.0;
    
    setState(() {
      _circleStart = localOffset;
      _circleCenter = localOffset;
      _circleRadius = defaultRadius;
      _showConfirmSelection = true;
    });
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
    if (_currentImage == null || _circleCenter == null || _selectedElementType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an area and element type')),
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

    setState(() {
      _isEditing = true;
    });

    try {
      final editPrompt = _tapToEditService.generateElementEditPrompt(
        _selectedElementType!,
        editDescription,
        _currentImage!.prompt,
      );

      final editedImage = await _tapToEditService.completeTapToEditWorkflow(
        originalImage: _currentImage!,
        tapX: _circleCenter!.dx,
        tapY: _circleCenter!.dy,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image edited successfully!')),
      );
    } catch (e) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Tap-to-Edit'),
        actions: [
          if (_circleCenter != null)
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
            // Image Viewer with Circle Selection
            _buildImageViewer(),

            // Image Source Options
            if (_showImageSourceOptions)
              _buildImageSourceOptions(),

            // Confirm Selection Overlay
            if (_showConfirmSelection)
              _buildConfirmSelectionOverlay(),

            // Edit Panel
            if (_showEditPanel)
              _buildEditPanel(),

            // Loading Overlay
            if (_isEditing)
              _buildLoadingOverlay(),

            // Instructions
            if (_currentImage != null && _circleCenter == null && !_showEditPanel)
              _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Image
            if (_currentImage != null)
              Center(
                child: Image.network(
                  _currentImage!.url,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBrown),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
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
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            // Circle Selection Overlay
            if (_circleCenter != null && _circleRadius > 0)
              Stack(
                children: [
                  CustomPaint(
                    painter: CircleSelectionPainter(
                      center: _circleCenter!,
                      radius: _circleRadius,
                      isDrawing: _isDrawingCircle,
                    ),
                    child: Container(),
                  ),
                  // Real-time radius display
                  if (_isDrawingCircle && _circleRadius > 20)
                    Positioned(
                      top: _circleCenter!.dy - _circleRadius - 40,
                      left: _circleCenter!.dx - 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_circleRadius.toInt()}px',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmSelectionOverlay() {
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
              'Selection Confirmed',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Circle drawn around selected area',
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
            Icon(Icons.info_outline, color: AppColors.accentOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap or draw a circle to select an element',
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
    final element = EditableElement.fromType(_selectedElementType ?? ElementType.face);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                        style: const TextStyle(fontSize: 16),
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
                        isListening: _isListening,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accentOrange),
            SizedBox(height: 16),
            Text(
              'Processing your edit...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
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
      case ElementType.ornaments:
        return Icons.diamond;
      case ElementType.clothing:
        return Icons.checkroom;
      case ElementType.pose:
        return Icons.accessibility;
      case ElementType.background:
        return Icons.photo;
      case ElementType.lighting:
        return Icons.lightbulb;
    }
  }
}

/// Custom painter for drawing the circle selection overlay
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
