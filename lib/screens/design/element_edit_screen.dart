import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../models/generated_image.dart';
import '../../models/editable_element.dart';
import '../../services/element_edit_service.dart';
import '../../services/speech_service.dart';
import '../../widgets/voice_input_button.dart';

class ElementEditScreen extends StatefulWidget {
  final GeneratedImage originalImage;

  const ElementEditScreen({
    Key? key,
    required this.originalImage,
  }) : super(key: key);

  @override
  State<ElementEditScreen> createState() => _ElementEditScreenState();
}

class _ElementEditScreenState extends State<ElementEditScreen> {
  final ElementEditService _editService = ElementEditService();
  final SpeechService _speechService = SpeechService();

  ElementType _selectedElement = ElementType.face;
  final TextEditingController _editDescriptionController = TextEditingController();
  bool _isEditing = false;
  bool _isListening = false;
  GeneratedImage? _editedImage;

  @override
  void dispose() {
    _editDescriptionController.dispose();
    super.dispose();
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
          _editDescriptionController.text = recognizedText;
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
          _editDescriptionController.text = text;
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

  Future<void> _applyElementEdit() async {
    final description = _editDescriptionController.text.trim();
    
    if (!_editService.validateEditDescription(description)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid edit description')),
      );
      return;
    }

    setState(() {
      _isEditing = true;
    });

    try {
      final editedImage = await _editService.editElement(
        widget.originalImage.url,
        _selectedElement,
        description,
        widget.originalImage.prompt,
      );

      setState(() {
        _editedImage = editedImage;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Element edited successfully!')),
      );
    } catch (e) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit element: $e')),
      );
    }
  }

  void _selectExamplePrompt(String prompt) {
    setState(() {
      _editDescriptionController.text = prompt;
    });
  }

  @override
  Widget build(BuildContext context) {
    final element = EditableElement.fromType(_selectedElement);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Edit Design Element'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Original Image
            Text(
              'Original Design',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                child: Image.network(
                  widget.originalImage.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
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
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Element Selection
            Text(
              'Select Element to Edit',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ElementType.values.map((element) {
                final isSelected = _selectedElement == element;
                return FilterChip(
                  label: Text(element.displayName),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedElement = element;
                      });
                    }
                  },
                  selectedColor: AppColors.primaryBrown,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBrown : AppColors.textLight,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Edit Description
            Text(
              'Edit Description',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _editService.getElementGuidance(_selectedElement),
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _editDescriptionController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Describe what you want to change...',
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

            const SizedBox(height: AppConstants.largePadding),

            // Example Prompts
            Text(
              'Example Prompts',
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
              children: _editService.getExamplePrompts(_selectedElement).map((prompt) {
                return ActionChip(
                  label: Text(
                    prompt,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _selectExamplePrompt(prompt),
                  backgroundColor: AppColors.cardCream,
                  labelStyle: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Edit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEditing ? null : _applyElementEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: _isEditing
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
                          Text('Editing Element...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Apply Element Edit'),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Tap-to-Edit Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/design/tap-to-edit/image/${widget.originalImage.id}', 
                    extra: widget.originalImage);
                },
                icon: const Icon(Icons.touch_app),
                label: const Text('Try Tap-to-Edit'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryBrown),
                  foregroundColor: AppColors.primaryBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ),

            // Status Section
            if (_isEditing)
              const SizedBox(height: AppConstants.largePadding),

            if (_isEditing)
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing ${element?.type.displayName ?? 'Element'}...',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI is modifying the selected element while preserving the rest of your design',
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

            // Edited Image
            if (_editedImage != null)
              const SizedBox(height: AppConstants.largePadding),

            if (_editedImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edited Design',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 250,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                      child: Image.network(
                        _editedImage!.url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
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
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Save edited image
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edited image saved')),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.accentOrange),
                            foregroundColor: AppColors.accentOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Continue editing
                            setState(() {
                              _editedImage = null;
                              _editDescriptionController.clear();
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit More'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    )
    );
  }
}
