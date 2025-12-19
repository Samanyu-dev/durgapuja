import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';

class CreatePreviewScreen extends StatefulWidget {
  const CreatePreviewScreen({Key? key}) : super(key: key);

  @override
  State<CreatePreviewScreen> createState() => _CreatePreviewScreenState();
}

class _CreatePreviewScreenState extends State<CreatePreviewScreen> {
  // ignore: prefer_final_fields
  List<File> _uploadedImages = [];
  File? _generated360View;
  bool _isGenerating = false;
  bool _cleanSmooth = true;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _uploadedImages.add(File(image.path));
      });
    }
  }

  void _generate360View() {
    setState(() {
      _isGenerating = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        if (_uploadedImages.isNotEmpty) {
          _generated360View = _uploadedImages.first;
        }
        _isGenerating = false;
      });
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
        title: const Text('Create Idol Preview'),
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
              onTap: _pickImage,
              child: Container(
                height: 150,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: AppColors.primaryBrown,
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),
                    const Text(
                      'Tap to Upload',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Upload 3 to 8 photos',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            if (_uploadedImages.isNotEmpty) ...[
              const Text(
                'Uploaded Images',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._uploadedImages.asMap().entries.map((entry) {
                      int idx = entry.key;
                      File image = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(
                              right: AppConstants.mediumPadding,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                              image: DecorationImage(
                                image: FileImage(image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: AppConstants.mediumPadding,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _uploadedImages.removeAt(idx);
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.warningRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    // ignore: unnecessary_to_list_in_spreads
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(
                        AppConstants.smallPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      child: const Text(
                        'Front View',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(
                        AppConstants.smallPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      child: const Text(
                        'Side View',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.largePadding),
              CustomButton(
                label: 'Generate 360° View',
                icon: Icons.threed_rotation_outlined,
                onPressed:
                    (_uploadedImages.length >= 3 && !_isGenerating)
                        ? _generate360View
                        : () {},
                backgroundColor: AppColors.primaryBrown,
              ),
            ],
            const SizedBox(height: AppConstants.largePadding),

            if (_generated360View != null) ...[
              const Text(
                'Generated 360° View',
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
                    image: FileImage(_generated360View!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              const Text(
                'Texture Enhancement',
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _cleanSmooth = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cleanSmooth
                            ? AppColors.primaryBrown
                            : Colors.white,
                        foregroundColor: _cleanSmooth
                            ? Colors.white
                            : AppColors.primaryBrown,
                        side: BorderSide(
                          color: AppColors.primaryBrown,
                        ),
                      ),
                      child: const Text('Clean & Smooth'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _cleanSmooth = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_cleanSmooth
                            ? AppColors.primaryBrown
                            : Colors.white,
                        foregroundColor: !_cleanSmooth
                            ? Colors.white
                            : AppColors.primaryBrown,
                        side: BorderSide(
                          color: AppColors.primaryBrown,
                        ),
                      ),
                      child: const Text('Keep Raw Texture'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              CustomButton(
                label: 'Click here to generate Backdrop',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎨 Generating backdrop...'),
                    ),
                  );
                },
                backgroundColor: AppColors.accentOrange,
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
                            content: Text('✓ Saved to gallery'),
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
                          _uploadedImages.clear();
                          _generated360View = null;
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

            if (_isGenerating) ...[
              const SizedBox(height: AppConstants.largePadding),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppConstants.mediumPadding),
                    const Text(
                      'Generating 360° view...',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
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
}
