import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';

class SculptingAssistantScreen extends StatefulWidget {
  const SculptingAssistantScreen({Key? key}) : super(key: key);

  @override
  State<SculptingAssistantScreen> createState() =>
      _SculptingAssistantScreenState();
}

class _SculptingAssistantScreenState extends State<SculptingAssistantScreen> {
  File? _uploadedImage;
  File? _enhancedImage;
  bool _isAnalyzing = false;
  bool _showBeforeAfter = false;
  final ImagePicker _picker = ImagePicker();
  String _selectedMode = 'Upload Photo';

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _showBeforeAfter = false;
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _showBeforeAfter = false;
      });
    }
  }

  void _analyzeIdol() {
    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _enhancedImage = _uploadedImage;
        _isAnalyzing = false;
        _showBeforeAfter = true;
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
        title: const Text('Sculpting Assistant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMode = 'Upload Photo';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.mediumPadding,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedMode == 'Upload Photo'
                              ? AppColors.primaryBrown
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: Center(
                          child: Text(
                            'Upload Photo',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeBody,
                              fontWeight: FontWeight.w600,
                              color: _selectedMode == 'Upload Photo'
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMode = 'Scan Live';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.mediumPadding,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedMode == 'Scan Live'
                              ? AppColors.primaryBrown
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: Center(
                          child: Text(
                            'Scan Live',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeBody,
                              fontWeight: FontWeight.w600,
                              color: _selectedMode == 'Scan Live'
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            GestureDetector(
              onTap: _pickImage,
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
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library,
                                    size: 18),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primaryBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _captureImage,
                                icon: const Icon(Icons.camera_alt,
                                    size: 18),
                                label: const Text('Camera'),
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
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        child: Image.file(
                          _uploadedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            if (_uploadedImage != null && !_showBeforeAfter)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeIdol,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.mediumPadding,
                    ),
                  ),
                  child: _isAnalyzing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome),
                            SizedBox(width: 8),
                            Text('Analyze Idol'),
                          ],
                        ),
                ),
              ),

            if (_isAnalyzing) ...[
              const SizedBox(height: AppConstants.largePadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppConstants.mediumPadding),
                    Text(
                      'Analyzing your idol...',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_showBeforeAfter) ...[
              const SizedBox(height: AppConstants.largePadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Before',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        color: AppColors.textLight,
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.primaryBrown,
                    ),
                    const Text(
                      'After',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Before',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeBody,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                            image: DecorationImage(
                              image: FileImage(_uploadedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'After',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeBody,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                            image: DecorationImage(
                              image: FileImage(_enhancedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.largePadding),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save Progress',
                      icon: Icons.save_alt,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Progress saved'),
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
                          _enhancedImage = null;
                          _showBeforeAfter = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBrown,
                        side: const BorderSide(
                          color: AppColors.primaryBrown,
                        ),
                      ),
                      child: const Text('Reset View'),
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
}
