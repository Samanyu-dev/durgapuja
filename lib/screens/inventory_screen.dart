import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/loading_skeleton.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isLoading = true;

  final List<Map<String, dynamic>> _materials = [
    {
      'id': '1',
      'name': 'Clay (Fine)',
      'category': 'Raw Material',
      'currentStock': 45.5,
      'unit': 'kg',
      'minThreshold': 20.0,
      'supplier': 'ABC Pottery',
      'lastUpdated': '2025-12-19',
      'status': 'normal',
    },
    {
      'id': '2',
      'name': 'Clay (Coarse)',
      'category': 'Raw Material',
      'currentStock': 12.0,
      'unit': 'kg',
      'minThreshold': 15.0,
      'supplier': 'ABC Pottery',
      'lastUpdated': '2025-12-18',
      'status': 'low',
    },
    {
      'id': '3',
      'name': 'Acrylic Paint (Red)',
      'category': 'Paint',
      'currentStock': 8.5,
      'unit': 'liters',
      'minThreshold': 5.0,
      'supplier': 'Color Masters',
      'lastUpdated': '2025-12-17',
      'status': 'normal',
    },
    {
      'id': '4',
      'name': 'Gold Leaf (24K)',
      'category': 'Decorative',
      'currentStock': 2.1,
      'unit': 'sheets',
      'minThreshold': 10.0,
      'supplier': 'Luxury Crafts',
      'lastUpdated': '2025-12-16',
      'status': 'critical',
    },
    {
      'id': '5',
      'name': 'Fabric (Silk)',
      'category': 'Textile',
      'currentStock': 25.0,
      'unit': 'meters',
      'minThreshold': 10.0,
      'supplier': 'Silk Traders',
      'lastUpdated': '2025-12-15',
      'status': 'normal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
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
        title: Text('Material Inventory'),
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMaterialDialog,
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildInventoryView(),
    );
  }

  Widget _buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppConstants.mediumPadding),
        child: LoadingCard(),
      ),
    );
  }

  Widget _buildInventoryView() {
    // Group materials by status
    final criticalMaterials = _materials.where((m) => m['status'] == 'critical').toList();
    final lowMaterials = _materials.where((m) => m['status'] == 'low').toList();
    final normalMaterials = _materials.where((m) => m['status'] == 'normal').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert Section
          if (criticalMaterials.isNotEmpty || lowMaterials.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              decoration: BoxDecoration(
                color: criticalMaterials.isNotEmpty ? AppColors.errorRed.withOpacity(0.1) : AppColors.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: criticalMaterials.isNotEmpty ? AppColors.errorRed : AppColors.warningOrange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    criticalMaterials.isNotEmpty ? Icons.warning : Icons.info,
                    color: criticalMaterials.isNotEmpty ? AppColors.errorRed : AppColors.warningOrange,
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: Text(
                      criticalMaterials.isNotEmpty
                          ? '${criticalMaterials.length} materials critically low!'
                          : '${lowMaterials.length} materials running low.',
                      style: TextStyle(
                        color: criticalMaterials.isNotEmpty ? AppColors.errorRed : AppColors.warningOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Critical Materials
          if (criticalMaterials.isNotEmpty) ...[
            _buildSectionHeader('Critical Stock', AppColors.errorRed),
            ...criticalMaterials.map((material) => _buildMaterialCard(material)),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Low Stock Materials
          if (lowMaterials.isNotEmpty) ...[
            _buildSectionHeader('Low Stock', AppColors.warningOrange),
            ...lowMaterials.map((material) => _buildMaterialCard(material)),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Normal Stock Materials
          _buildSectionHeader('In Stock', AppColors.successGreen),
          ...normalMaterials.map((material) => _buildMaterialCard(material)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            title,
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

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final status = material['status'] as String;
    final currentStock = material['currentStock'] as double;
    final minThreshold = material['minThreshold'] as double;
    final percentage = (currentStock / (minThreshold * 2)).clamp(0.0, 1.0);

    Color statusColor;
    switch (status) {
      case 'critical':
        statusColor = AppColors.errorRed;
        break;
      case 'low':
        statusColor = AppColors.warningOrange;
        break;
      default:
        statusColor = AppColors.successGreen;
    }

    return GestureDetector(
      onTap: () => _showMaterialDetails(material),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: status == 'normal' ? Colors.transparent : statusColor.withOpacity(0.3),
            width: 1,
          ),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material['name'],
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material['category'],
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Stock',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currentStock ${material['unit']}',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeBody,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Min Threshold',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$minThreshold ${material['unit']}',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeBody,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Stock Level Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock Level',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppColors.cardCream,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialDetails(Map<String, dynamic> material) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              material['name'],
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            _buildDetailRow('Category', material['category']),
            _buildDetailRow('Current Stock', '${material['currentStock']} ${material['unit']}'),
            _buildDetailRow('Min Threshold', '${material['minThreshold']} ${material['unit']}'),
            _buildDetailRow('Supplier', material['supplier']),
            _buildDetailRow('Last Updated', material['lastUpdated']),

            const SizedBox(height: AppConstants.largePadding),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Stock adjustment feature coming soon
                      Navigator.pop(context);
                    },
                    child: const Text('Adjust Stock'),
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Reorder alerts coming soon
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                    ),
                    child: const Text('Reorder'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Material'),
        content: const Text('Material management feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
