import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_bottom_nav.dart';

class FineDetailingScreen extends StatefulWidget {
  const FineDetailingScreen({Key? key}) : super(key: key);

  @override
  State<FineDetailingScreen> createState() => _FineDetailingScreenState();
}

class _FineDetailingScreenState extends State<FineDetailingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedExpression = 'Calm';
  double _joyValue = 50;
  double _serenityValue = 25;
  double _powerValue = 5;
  double _compassionValue = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Fine Detailing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/idol_face.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: Colors.white30,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryBrown,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textDark,
              tabs: const [
                Tab(text: 'Face Expressions'),
                Tab(text: 'Ornaments'),
                Tab(text: 'Full Dress'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFaceExpressionsTab(),
                _buildOrnamentsTab(),
                _buildFullDressTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                    ),
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBrown,
                      side: const BorderSide(color: AppColors.primaryBrown),
                    ),
                    child: const Text('Preview'),
                  ),
                ),
              ],
            ),
          ),
          CustomBottomNav(
            currentIndex: 1,
            onTap: (index) {},
          ),
        ],
      ),
    );
  }

  Widget _buildFaceExpressionsTab() {
    final expressions = ['Calm', 'Fierce', 'Kind', 'Motherly', 'Love'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: expressions.map((expression) {
              final isSelected = _selectedExpression == expression;
              return ChoiceChip(
                label: Text(expression),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedExpression = expression;
                  });
                },
                selectedColor: AppColors.primaryBrown,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            'Emotions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildEmotionSlider('Joy', _joyValue, (value) {
            setState(() => _joyValue = value);
          }),
          _buildEmotionSlider('Serenity', _serenityValue, (value) {
            setState(() => _serenityValue = value);
          }),
          _buildEmotionSlider('Power', _powerValue, (value) {
            setState(() => _powerValue = value);
          }),
          _buildEmotionSlider('Compassion', _compassionValue, (value) {
            setState(() => _compassionValue = value);
          }),
        ],
      ),
    );
  }

  Widget _buildEmotionSlider(
      String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accentOrange,
              inactiveTrackColor: AppColors.lightCream,
              thumbColor: AppColors.primaryBrown,
              overlayColor: AppColors.primaryBrown.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
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
      ),
    );
  }

  Widget _buildOrnamentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBrown,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryBrown, width: 2),
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Customization',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomizationOption('Material', 'Gold'),
          _buildCustomizationOption('Color', 'Golden Yellow'),
          _buildCustomizationOption('Size', 'Medium'),
        ],
      ),
    );
  }

  Widget _buildFullDressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBrown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.checkroom_outlined,
                    color: Colors.white30,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Customization',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomizationOption('Material', 'Silk'),
          _buildCustomizationOption('Color', 'Red'),
          _buildCustomizationOption('Drape Style', 'Bengal'),
        ],
      ),
    );
  }

  Widget _buildCustomizationOption(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightCream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primaryBrown,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
