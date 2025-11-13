import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';

class SuggestLightingScreen extends StatefulWidget {
  const SuggestLightingScreen({Key? key}) : super(key: key);

  @override
  State<SuggestLightingScreen> createState() => _SuggestLightingScreenState();
}

class _SuggestLightingScreenState extends State<SuggestLightingScreen> {
  double _intensityValue = 50;
  double _shadowValue = 50;
  String _selectedDirection = 'Front';
  String _selectedShadow = 'Medium';
  bool _expandLightingPanel = false;
  bool _expandSceneSimulation = false;
  bool _expandAIEnhancement = false;

  final List<String> _directions = ['Top', 'Bottom', 'Front', 'Left', 'Right', 'Backlight'];
  final List<String> _shadowOptions = ['Soft', 'Medium', 'Deep'];
  final List<String> _lightingPresets = [
    'Warm Golden Puja',
    'Temple Lighting',
    'Soft Shimmer'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Suggest Lighting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload your idol\'s structure',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📸 Upload photos for lighting analysis')),
                );
              },
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
                      'Upload 3 to 8 photos',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.darkBrown,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: Colors.white30,
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),
                    const Text(
                      'Analyzing your idol...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppConstants.fontSizeBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

            const Text(
              'Traditional Lighting Presets',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Wrap(
              spacing: AppConstants.mediumPadding,
              runSpacing: AppConstants.mediumPadding,
              children: _lightingPresets.map((preset) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Applied: $preset')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                  ),
                  child: Text(
                    preset,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.largePadding),

            _buildExpandablePanel(
              title: 'Lighting Control Panel',
              isExpanded: _expandLightingPanel,
              onTap: () {
                setState(() {
                  _expandLightingPanel = !_expandLightingPanel;
                });
              },
              child: Column(
                children: [
                  _buildSliderControl('Intensity', _intensityValue, (value) {
                    setState(() => _intensityValue = value);
                  }),
                  const SizedBox(height: AppConstants.largePadding),
                  const Text(
                    'Direction',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    runSpacing: AppConstants.smallPadding,
                    children: _directions.map((direction) {
                      return FilterChip(
                        label: Text(direction),
                        selected: _selectedDirection == direction,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDirection = selected ? direction : 'Front';
                          });
                        },
                        selectedColor: AppColors.primaryBrown,
                        labelStyle: TextStyle(
                          color: _selectedDirection == direction
                              ? Colors.white
                              : AppColors.textDark,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  const Text(
                    'Shadows',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    children: _shadowOptions.map((shadow) {
                      return FilterChip(
                        label: Text(shadow),
                        selected: _selectedShadow == shadow,
                        onSelected: (selected) {
                          setState(() {
                            _selectedShadow = selected ? shadow : 'Medium';
                          });
                        },
                        selectedColor: AppColors.primaryBrown,
                        labelStyle: TextStyle(
                          color: _selectedShadow == shadow
                              ? Colors.white
                              : AppColors.textDark,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            _buildExpandablePanel(
              title: 'Scene Simulation',
              isExpanded: _expandSceneSimulation,
              onTap: () {
                setState(() {
                  _expandSceneSimulation = !_expandSceneSimulation;
                });
              },
              child: const Text('Scene simulation options coming soon...'),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            _buildExpandablePanel(
              title: 'AI Enhancement',
              isExpanded: _expandAIEnhancement,
              onTap: () {
                setState(() {
                  _expandAIEnhancement = !_expandAIEnhancement;
                });
              },
              child: const Text('AI enhancement options coming soon...'),
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
                          content: Text('✓ Lighting saved to gallery'),
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
                        _intensityValue = 50;
                        _shadowValue = 50;
                        _selectedDirection = 'Front';
                        _selectedShadow = 'Medium';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBrown,
                      side: const BorderSide(color: AppColors.primaryBrown),
                    ),
                    child: const Text('Start over'),
                  ),
                ),
              ],
            ),
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

  Widget _buildSliderControl(
      String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.mediumPadding),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accentOrange,
            inactiveTrackColor: AppColors.lightCream,
            thumbColor: AppColors.primaryBrown,
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandablePanel({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
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
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppColors.primaryBrown,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: child,
            ),
          ],
        ],
      ),
    );
  }
}
