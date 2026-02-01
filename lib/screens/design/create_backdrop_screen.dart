import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/krea_ai_service.dart';
import '../../models/generated_image.dart';
import 'image_viewer_screen.dart';

class CreateBackdropScreen extends StatefulWidget {
  const CreateBackdropScreen({Key? key}) : super(key: key);

  @override
  State<CreateBackdropScreen> createState() => _CreateBackdropScreenState();
}

class _CreateBackdropScreenState extends State<CreateBackdropScreen> {
  final TextEditingController _backdropController = TextEditingController();
  final List<GeneratedImage> _generatedImages = [];
  bool _isGenerating = false;
  final KreaAIService _kreaService = KreaAIService();

  final List<String> _backdropStyles = [
    'Traditional Bengali',
    'Modern Contemporary',
    'Floral Design',
    'Geometric Patterns',
    'Nature Inspired',
    'Cultural Symbols'
  ];

  String _selectedBackdropStyle = 'Traditional Bengali';

  Future<void> _generateBackdrop() async {
    if (_backdropController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter backdrop description first')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final prompt = 'Create beautiful Durga Puja backdrop in ${_selectedBackdropStyle.toLowerCase()} style: ${_backdropController.text.trim()}. Traditional Bengali pandal background, festive decorations, intricate details, cultural elements.';

      final images = await _kreaService.generateImages(prompt, count: 2);

      setState(() {
        _generatedImages.addAll(images);
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate backdrop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundCream,
      child: Column(
        children: [
          // Custom App Bar
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            color: AppColors.backgroundCream,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/design/welcome'),
                ),
                const Expanded(
                  child: Text(
                    'Backdrop Generator',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose backdrop style',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedBackdropStyle,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _backdropStyles.map((style) {
                        return DropdownMenuItem(
                          value: style,
                          child: Text(style),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBackdropStyle = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Describe your backdrop vision',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hintText: 'e.g., "colorful flowers, traditional motifs, golden accents"',
                    controller: _backdropController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'AI will create stunning pandal backdrops',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generateBackdrop,
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
                                Icon(Icons.image),
                                SizedBox(width: 8),
                                Text('Generate Backdrop'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_generatedImages.isNotEmpty) ...[
                    Text(
                      '${_selectedBackdropStyle} Backdrops (${_generatedImages.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: _generatedImages.length,
                      itemBuilder: (context, index) {
                        final image = _generatedImages[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerScreen(
                                  images: _generatedImages,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'backdrop_${image.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      image.url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: AppColors.cardCream,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primaryBrown,
                                              strokeWidth: 2,
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
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBrown.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.image,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _selectedBackdropStyle,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Pandal Backdrop',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tap to zoom and see backdrop details',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _backdropController.dispose();
    super.dispose();
  }
}
