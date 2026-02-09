import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/generated_image.dart';
import '../../services/language_service.dart';
import '../../utils/colors.dart';
import '../../widgets/language_toggle_action.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<GeneratedImage> images;
  final int initialIndex;

  const ImageViewerScreen({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          const LanguageToggleAction(),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareImage,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadImage,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _scale = 1.0; // Reset scale when changing pages
            _previousScale = 1.0;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return _buildImageViewer(context, image);
        },
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context, GeneratedImage image) {
    final lang = context.watch<LanguageService>();
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = _previousScale * details.scale;
          // Limit zoom to reasonable bounds
          _scale = _scale.clamp(0.5, 4.0);
        });
      },
      onScaleEnd: (details) {
        // Optional: Add momentum or snap back to bounds
      },
      onDoubleTap: _handleDoubleTap,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Transform.scale(
            scale: _scale,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                image.url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primaryBrown,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.cardCream,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            lang.getText('failed_to_load_image'),
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    setState(() {
      if (_scale > 1.0) {
        // Zoom out to fit
        _scale = 1.0;
      } else {
        // Zoom in
        _scale = 2.0;
      }
      _previousScale = _scale;
    });
  }

  void _shareImage() {
    final image = widget.images[_currentIndex];
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing image: ${image.prompt}')),
    );
  }

  void _downloadImage() {
    final image = widget.images[_currentIndex];
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading image: ${image.prompt}')),
    );
  }
}
