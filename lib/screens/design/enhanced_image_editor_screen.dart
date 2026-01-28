import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/editable_element.dart';
import '../../models/generated_image.dart';
import '../../services/element_edit_service.dart';
import '../../services/krea_ai_service.dart';
import '../../services/speech_service.dart';
import '../../services/tap_to_edit_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/voice_input_button.dart';

class EnhancedImageEditorScreen extends StatefulWidget {
  final GeneratedImage image;

  const EnhancedImageEditorScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<EnhancedImageEditorScreen> createState() => _EnhancedImageEditorScreenState();
}

class _EnhancedImageEditorScreenState extends State<EnhancedImageEditorScreen> {
  final ElementEditService _editService = ElementEditService();
  final KreaAIService _kreaService = KreaAIService();
  final TapToEditService _tapToEditService = TapToEditService();
  final TextEditingController _promptController = TextEditingController();
  
  List<ElementType> _selectedElements = [];
  ElementType? _currentElementType;
  bool _isGenerating = false;
  bool _isListening = false;
  bool _showSelectionTools = false;
  bool _showEditPanel = false;

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

  void _selectElement(ElementType elementType) {
    setState(() {
      _currentElementType = elementType;
      _showSelectionTools = false;
      _showEditPanel = true;
      _promptController.text = '';
    });
  }

  void _removeElement(ElementType elementType) {
    setState(() {
      _selectedElements.remove(elementType);
    });
  }

  Future<void> _regenerateElement() async {
    if (_currentElementType == null || _promptController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final editDescription = _promptController.text.trim();
      final editPrompt = _editService.createElementEditPrompt(
        _currentElementType!,
        editDescription,
        widget.image.prompt,
      );
      
      final images = await _kreaService.generateImages(editPrompt, count: 1);
      
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Element updated successfully!')),
      );
      
      // Navigate to image viewer with the new image
      context.push('/design/image-viewer', extra: images.first);
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to regenerate element: $e')),
      );
    }
  }

  Future<void> _saveDesign() async {
    try {
      // For now, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design saved successfully!')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Enhanced Image Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDesign,
            tooltip: 'Save Design',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Viewer with Zoom
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  widget.image.url,
                  fit: BoxFit.contain,
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
              ),
            ),
          ),

          // Selection Tools
          if (_showSelectionTools)
            _buildSelectionTools(),

          // Edit Panel
          if (_showEditPanel && _currentElementType != null)
            _buildEditPanel(),

          // Bottom Controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildSelectionTools() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        border: Border(top: BorderSide(color: AppColors.primaryBrown.withOpacity(0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Element to Edit',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showSelectionTools = false;
                    _currentElementType = null;
                  });
                },
                tooltip: 'Cancel',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ElementType.values.map((elementType) {
              return FilterChip(
                label: Row(
                  children: [
                    Icon(_getIconForType(elementType), size: 16),
                    const SizedBox(width: 4),
                    Text(elementType.displayName),
                  ],
                ),
                selected: _currentElementType == elementType,
                onSelected: (selected) {
                  if (selected) {
                    _selectElement(elementType);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPanel() {
    final element = EditableElement.fromType(_currentElementType!);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        border: Border(top: BorderSide(color: AppColors.primaryBrown.withOpacity(0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit ${element?.type.displayName ?? 'Element'}',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _regenerateElement,
                    tooltip: 'Regenerate',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showEditPanel = false;
                        _currentElementType = null;
                      });
                    },
                    tooltip: 'Close',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Guidance Text
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
            ),
            child: Text(
              _editService.getElementGuidance(_currentElementType!),
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
          ),

          const SizedBox(height: 8),
          
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
                    maxLines: 2,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Describe changes for ${element?.type.displayName.toLowerCase() ?? 'element'}...',
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
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Example Prompts
          if (_editService.getExamplePrompts(_currentElementType!).isNotEmpty)
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
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _editService.getExamplePrompts(_currentElementType!).map((prompt) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _promptController.text = prompt;
                        });
                      },
                      child: Chip(
                        label: Text(prompt, style: TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.cardCream,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        border: Border(top: BorderSide(color: AppColors.primaryBrown.withOpacity(0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                onPressed: () {
                  setState(() {
                    _showSelectionTools = !_showSelectionTools;
                    if (!_showSelectionTools) _currentElementType = null;
                  });
                },
                label: _showSelectionTools ? 'Hide Tools' : 'Select Element',
                icon: _showSelectionTools ? Icons.close : Icons.touch_app,
                backgroundColor: _showSelectionTools ? AppColors.textLight : AppColors.primaryBrown,
              ),
              
              CustomButton(
                onPressed: _isGenerating ? null : _regenerateElement,
                label: 'Regenerate',
                icon: Icons.refresh,
                backgroundColor: AppColors.accentOrange,
                isLoading: _isGenerating,
              ),

              CustomButton(
                onPressed: () {
                  // Navigate to fine detailing
                  context.push('/design/fine-detailing', extra: widget.image);
                },
                label: 'Fine Detail',
                icon: Icons.edit,
              ),
              
              CustomButton(
                onPressed: () {
                  // Navigate to Tap-to-Edit
                  context.push('/design/tap-to-edit', extra: widget.image);
                },
                label: 'Tap-to-Edit',
                icon: Icons.touch_app,
                backgroundColor: AppColors.accentOrange,
              ),
            ],
          ),

          // Selected Elements List
          if (_selectedElements.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Selected Elements (${_selectedElements.length})',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedElements.map((elementType) {
                    final element = EditableElement.fromType(elementType);
                    return Chip(
                      label: Row(
                        children: [
                          Icon(_getIconForType(elementType), size: 16),
                          const SizedBox(width: 4),
                          Text(element?.type.displayName ?? elementType.name),
                        ],
                      ),
                      onDeleted: () => _removeElement(elementType),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
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