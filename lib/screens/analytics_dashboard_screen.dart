import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/loading_skeleton.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _isLoading = true;

  // Mock analytics data
  final Map<String, dynamic> _analyticsData = {
    'totalRevenue': 245000.0,
    'totalOrders': 156,
    'totalClients': 89,
    'monthlyGrowth': 12.5,
    'popularDesigns': [
      {'name': 'Traditional Durga', 'orders': 45, 'revenue': 135000},
      {'name': 'Modern Abstract', 'orders': 32, 'revenue': 96000},
      {'name': 'Decorative Series', 'orders': 28, 'revenue': 84000},
      {'name': 'Miniature Idol', 'orders': 22, 'revenue': 66000},
      {'name': 'Custom Design', 'orders': 29, 'revenue': 87000},
    ],
    'materialUsage': [
      {'name': 'Clay', 'usage': 85, 'color': Colors.brown},
      {'name': 'Paint', 'usage': 65, 'color': Colors.blue},
      {'name': 'Gold Leaf', 'usage': 45, 'color': Colors.yellow},
      {'name': 'Fabric', 'usage': 35, 'color': Colors.purple},
      {'name': 'Wood', 'usage': 25, 'color': Colors.green},
    ],
    'revenueByMonth': [12000, 15000, 18000, 22000, 25000, 28000],
    'clientSatisfaction': 4.7,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
      ),
      body: _isLoading ? _buildLoadingView() : _buildAnalyticsView(),
    );
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards Loading
          Row(
            children: [
              Expanded(child: LoadingCard()),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(child: LoadingCard()),
            ],
          ),
          const SizedBox(height: AppConstants.largePadding),

          // Charts Loading
          LoadingSkeleton(width: double.infinity, height: 200),
          const SizedBox(height: AppConstants.largePadding),

          // Popular Designs Loading
          LoadingSkeleton(width: double.infinity, height: 150),
          const SizedBox(height: AppConstants.largePadding),

          // Material Usage Loading
          LoadingSkeleton(width: double.infinity, height: 150),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'Total Revenue',
                      '₹${_analyticsData['totalRevenue'].toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  AppColors.successGreen,
                ),
              ),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(
                child: _buildKPICard(
                  'Total Orders',
                  _analyticsData['totalOrders'].toString(),
                  Icons.shopping_cart,
                  AppColors.primaryBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'Total Clients',
                  _analyticsData['totalClients'].toString(),
                  Icons.people,
                  AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(
                child: _buildKPICard(
                  'Monthly Growth',
                  '${_analyticsData['monthlyGrowth']}%',
                  Icons.trending_up,
                  AppColors.successGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Revenue Chart (Simplified bar chart)
          _buildRevenueChart(),

          const SizedBox(height: AppConstants.largePadding),

          // Popular Designs
          _buildPopularDesigns(),

          const SizedBox(height: AppConstants.largePadding),

          // Material Usage
          _buildMaterialUsage(),

          const SizedBox(height: AppConstants.largePadding),

          // Client Satisfaction
          _buildClientSatisfaction(),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Revenue',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                final revenue = _analyticsData['revenueByMonth'][index] as int;
                final maxRevenue = (_analyticsData['revenueByMonth'] as List<int>).reduce((a, b) => a > b ? a : b);
                final height = (revenue / maxRevenue) * 120;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '₹${(revenue / 1000).toStringAsFixed(0)}k',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'M${index + 1}',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDesigns() {
    final popularDesigns = _analyticsData['popularDesigns'] as List<Map<String, dynamic>>;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Designs',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Column(
            children: popularDesigns.map((design) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        design['name'],
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeBody,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${design['orders']} orders',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialUsage() {
    final materials = _analyticsData['materialUsage'] as List<Map<String, dynamic>>;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material Usage',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Column(
            children: materials.map((material) {
              final usage = material['usage'] as int;
              final maxUsage = materials.map((m) => m['usage'] as int).reduce((a, b) => a > b ? a : b);
              final percentage = usage / maxUsage;

              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        material['name'],
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.cardCream,
                        valueColor: AlwaysStoppedAnimation<Color>(material['color']),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Text(
                      '${usage}%',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSatisfaction() {
    final rating = _analyticsData['clientSatisfaction'] as double;

    return Container(
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
          Icon(Icons.star, color: AppColors.accentOrange, size: 32),
          const SizedBox(width: AppConstants.mediumPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Satisfaction',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rating}/5.0 average rating',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            rating.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.accentOrange,
            ),
          ),
        ],
      ),
    );
  }
}
