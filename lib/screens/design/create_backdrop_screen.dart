import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';

class CreateBackdropScreen extends StatefulWidget {
  const CreateBackdropScreen({super.key});

  @override
  State<CreateBackdropScreen> createState() => _CreateBackdropScreenState();
}

class _CreateBackdropScreenState extends State<CreateBackdropScreen> {
  File? _uploadedImage;
  File? _generatedBackdrop;
  bool _isGenerating = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _generatedBackdrop = null;
      });
    }
  }

  void _generateBackdrop() {
    setState(() {
      _isGenerating = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _generatedBackdrop = _uploadedImage;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Backdrop generated successfully'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Backdrop'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload your Idol\'s structure',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.lightCream,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppColors.primaryBrown,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _uploadedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: AppColors.primaryBrown,
                          ),
                          const SizedBox(
                              height: AppConstants.mediumPadding),
                          const Text(
                            'Tap to Upload or Use Camera',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeBody,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppConstants.mediumPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library,
                                    size: 18),
                                label: const Text('From Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primaryBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt,
                                    size: 18),
                                label: const Text('Use Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.darkBrown,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        child: Image.file(
                          _uploadedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            if (_uploadedImage != null)
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppConstants.mediumPadding),
                        const Text(
                          'Analyzing your idol...',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeBody,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: AppColors.cardCream,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),
                    const Text(
                      'Detecting Deity, Mood, and Ornamentation...',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppConstants.largePadding),

            if (_uploadedImage != null && _generatedBackdrop == null)
              CustomButton(
                label: 'Click here to generate Backdrop',
                icon: Icons.auto_awesome,
                onPressed: _isGenerating ? () {} : _generateBackdrop,
                isLoading: _isGenerating,
                backgroundColor: AppColors.accentOrange,
              ),

            if (_generatedBackdrop != null) ...[
              const Text(
                'Generated Backdrop',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.darkBrown,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  image: DecorationImage(
                    image: FileImage(_generatedBackdrop!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              const Text(
                'Background Details',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Deity Pattern', 'Durga Chaturdashi'),
                    const SizedBox(height: AppConstants.mediumPadding),
                    _buildDetailRow('Mood Analysis', 'Powerful, Divine'),
                    const SizedBox(height: AppConstants.mediumPadding),
                    _buildDetailRow(
                        'Ornamentation', 'Golden, Traditional'),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save to Gallery',
                      icon: Icons.save_alt,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Backdrop saved'),
                          ),
                        );
                      },
                      backgroundColor: AppColors.primaryBrown,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _uploadedImage = null;
                          _generatedBackdrop = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBrown,
                        side: const BorderSide(
                          color: AppColors.primaryBrown,
                        ),
                      ),
                      child: const Text('Start over'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: AppColors.textLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
