import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';
import 'samiti_funds_screen.dart';

class MaterialTrackerScreen extends StatefulWidget {
  const MaterialTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MaterialTrackerScreen> createState() => _MaterialTrackerScreenState();
}

class _MaterialTrackerScreenState extends State<MaterialTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _recentMaterials = [
    {
      'name': 'Clay',
      'shop': 'Shop 1 - Town 1',
      'price': '₹150/Kg',
      'trend': '+3%',
      'trendColor': AppColors.successGreen,
    },
    {
      'name': 'Paint',
      'shop': 'Town 2',
      'price': '₹150/Kg',
      'trend': '+3%',
      'trendColor': AppColors.successGreen,
    },
    {
      'name': 'Bamboo',
      'shop': 'Town 2',
      'price': '₹150/Kg',
      'trend': '-3%',
      'trendColor': AppColors.warningRed,
    },
  ];

  final List<Map<String, dynamic>> _latestTrends = [
    {
      'material': 'Clay',
      'town': 'Manikitala',
      'date': '12 Oct',
      'trend': '+3%',
      'trendColor': AppColors.successGreen,
      'price': '₹150/kg',
    },
    {
      'material': 'Paint',
      'town': 'Shobhabazar',
      'date': '12 Oct',
      'trend': '-3%',
      'trendColor': AppColors.warningRed,
      'price': '₹200/liter',
    },
    {
      'material': 'Bamboo',
      'town': 'Bagbazar',
      'date': '12 Oct',
      'trend': '+3%',
      'trendColor': AppColors.successGreen,
      'price': '₹50/piece',
    },
    {
      'material': 'Straw',
      'town': 'Cossipore',
      'date': '12 Oct',
      'trend': '+3%',
      'trendColor': AppColors.successGreen,
      'price': '₹30/bundle',
    },
    {
      'material': 'Fiber',
      'town': 'Shobhabazar',
      'date': '12 Oct',
      'trend': '-3%',
      'trendColor': AppColors.warningRed,
      'price': '₹80/meter',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Finance'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryBrown,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textDark,
              tabs: const [
                Tab(text: 'Material Tracker'),
                Tab(text: 'Samiti Funds'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialTrackerTab(),
                const SamitiMaterialView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) {
        },
      ),
    );
  }

  Widget _buildMaterialTrackerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎙️ Voice search')),
                  );
                },
              ),
              filled: true,
              fillColor: AppColors.cardCream,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),

          const Text(
            'Recent Materials',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          ..._recentMaterials.map((material) => _buildMaterialCard(material)),
          const SizedBox(height: AppConstants.largePadding),

          CustomButton(
            label: 'Add new rate',
            icon: Icons.mic_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎙️ Recording material rate...'),
                ),
              );
            },
            backgroundColor: AppColors.primaryBrown,
          ),
          const SizedBox(height: AppConstants.largePadding),

          const Text(
            'Latest Trend',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildTrendTable(),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryBrown,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(
              Icons.category_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.mediumPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['name'],
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  material['shop'],
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                material['price'],
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: material['trendColor'].withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Text(
                  material['trend'],
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: material['trendColor'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTable() {
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
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTableHeader('Material'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildTableHeader('Town'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildTableHeader('Date'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildTableHeader('Trend'),
                ),
              ],
            ),
          ),
          ..._latestTrends.map((trend) => _buildTrendRow(trend)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppConstants.fontSizeSmall,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTrendRow(Map<String, dynamic> trend) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.cardCream,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              trend['material'],
              style: const TextStyle(
                fontSize: AppConstants.fontSizeBody,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              trend['town'],
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              trend['date'],
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: trend['trendColor'].withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                trend['trend'],
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: trend['trendColor'],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
