import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/generated_image.dart';
import '../../services/tap_to_edit_service.dart';
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
  State<EnhancedImageEditorScreen> createState() => _EnhancedImageEditorScreenState();
}

class _EnhancedImageEditorScreenState extends State<EnhancedImageEditorScreen> {
  final GlobalKey _imageKey = GlobalKey();
  final TextEditingController _editPromptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final TapToEditService _editService = TapToEditService();

  ui.Image? _image;
  List<Offset> _tracePoints = [];
  bool _isTracing = false;
  bool _isProcessing = false;
  File? _editReferenceImage;
  double _imageWidth = 0;
  double _imageHeight = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _editPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final response = await http.get(Uri.parse(widget.generatedImage.url));
    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    
    setState(() {
      _image = frame.image;
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Edit Selection',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                        decoration: const InputDecoration(
                          hintText: 'E.g., Change to a blue saree with golden borders...',
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
                          },
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Reference Image'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                        children: [
                          'More detailed',
                          'Change color',
                          'Add jewelry',
                          'Enhance lighting',
                        ].map((text) {
                          return ActionChip(
                            label: Text(text),
                            onPressed: () {
                              _editPromptController.text = text;
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () {
                    Navigator.pop(context);
                    _applyEdit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
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
            ],
          ),
        ),
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
      // Calculate center point of traced area
      double sumX = 0, sumY = 0;
      for (var point in _tracePoints) {
        sumX += point.dx;
        sumY += point.dy;
      }
      final centerX = sumX / _tracePoints.length;
      final centerY = sumY / _tracePoints.length;

      // Get render box for coordinate conversion
      final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;
      
      // Convert to image coordinates
      final imageX = (centerX / size.width) * _imageWidth;
      final imageY = (centerY / size.height) * _imageHeight;

      // Perform edit
      final editedImage = await _editService.completeTapToEditWorkflow(
        originalImage: widget.generatedImage,
        tapX: imageX,
        tapY: imageY,
        imageWidth: _imageWidth,
        imageHeight: _imageHeight,
        editPrompt: _editPromptController.text,
        elementType: ElementType.face,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _tracePoints.clear();
          _editPromptController.clear();
          _editReferenceImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Edit Your Design'),
        actions: [
          if (_tracePoints.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearTrace,
              tooltip: 'Clear trace',
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
                final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                  _startTracing(localPosition);
                }
              },
              onPanUpdate: (details) {
                final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPosition = renderBox.globalToLocal(details.globalPosition);
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
                      CustomPaint(
                        painter: TracePainter(
                          points: _tracePoints,
                          isActive: _isTracing,
                        ),
                        size: Size.infinite,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 32,
                      color: Color(0xFFFF6B35),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trace around the area you want to edit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Draw with your finger to select the object',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
      final file = File('${directory.path}/durga_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }
}

class TracePainter extends CustomPainter {
  final List<Offset> points;
  final bool isActive;

  TracePainter({required this.points, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = const Color(0xFFFF6B35).withOpacity(0.3)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final glowPath = Path();
    glowPath.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      glowPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(glowPath, glowPaint);

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 2, dotPaint);
    }

    if (isActive && points.isNotEmpty) {
      final lastPoint = points.last;
      final pulsePaint = Paint()
        ..color = const Color(0xFFFF6B35).withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 8, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(TracePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.isActive != isActive;
  }
}
