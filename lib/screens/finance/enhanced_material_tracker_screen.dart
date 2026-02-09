import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/material_tracker_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/language_service.dart';
import '../../widgets/language_toggle_action.dart';

class EnhancedMaterialTrackerScreen extends StatefulWidget {
  const EnhancedMaterialTrackerScreen({super.key});

  @override
  State<EnhancedMaterialTrackerScreen> createState() => _EnhancedMaterialTrackerScreenState();
}

class _EnhancedMaterialTrackerScreenState extends State<EnhancedMaterialTrackerScreen> {
  late Future<List<Map<String, dynamic>>> _materialsFuture;
  late Future<Map<String, dynamic>> _analyticsFuture;
  late Future<List<Map<String, dynamic>>> _trendingFuture;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  String _selectedCategory = MaterialCategory.CLAY;
  String _selectedUnit = MaterialUnit.KG;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    _materialsFuture = MaterialTrackerService.getMaterials();
    _analyticsFuture = MaterialTrackerService.getMaterialAnalytics();
    _trendingFuture = MaterialTrackerService.getTrendingMaterials();
  }

  Future<void> _addMaterial() async {
    if (_nameController.text.isEmpty || _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await MaterialTrackerService.addMaterial(
        name: _nameController.text,
        category: _selectedCategory,
        unit: _selectedUnit,
        currentRate: double.parse(_rateController.text),
        supplier: _supplierController.text,
      );

      _nameController.clear();
      _rateController.clear();
      _supplierController.clear();
      _quantityController.clear();

      setState(() => _isLoading = false);
      _refreshData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material added successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding material: $e')),
      );
    }
  }

  Future<void> _recordUsage(int materialId, String materialName) async {
    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Usage for $materialName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quantity: ${_quantityController.text} $_selectedUnit'),
            const SizedBox(height: 10),
            const Text('This will be recorded at current rate'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              try {
                await MaterialTrackerService.recordMaterialUsage(
                  materialId: materialId,
                  quantity: double.parse(_quantityController.text),
                  unit: _selectedUnit,
                  description: 'Manual usage entry',
                );
                
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usage recorded successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error recording usage: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMaterial(int materialId, String materialName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete $materialName? This will also delete all associated data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              try {
                await MaterialTrackerService.deleteMaterial(materialId);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Material deleted successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting material: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(lang.getText('material_tracker')),
        actions: [
          const LanguageToggleAction(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _refreshData()),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              setState(() {});
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analytics Cards
                  _buildAnalyticsCards(),
                  const SizedBox(height: 20),

                  // Add Material Form
                  _buildAddMaterialForm(),
                  const SizedBox(height: 20),

                  // Trending Materials
                  _buildTrendingMaterials(),
                  const SizedBox(height: 20),

                  // Materials List
                  _buildMaterialsList(),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accentOrange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final data = snapshot.data!;
        final totalMaterials = data['totalMaterials'] as int;
        final totalUsageCost = data['totalUsageCost'] as double;
        final expensiveMaterial = data['expensiveMaterial'] as String;

        return Column(
          children: [
            Text(
              'Material Analytics',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    icon: Icons.category,
                    title: 'Total Materials',
                    value: totalMaterials.toString(),
                    color: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    icon: Icons.monetization_on,
                    title: 'Total Usage Cost',
                    value: '₹${totalUsageCost.toStringAsFixed(0)}',
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAnalyticsCard(
              icon: Icons.trending_up,
              title: 'Most Expensive',
              value: expensiveMaterial,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

  Widget _buildAddMaterialForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Material',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _nameController,
                    hintText: 'Material name (e.g., Clay)',
                    labelText: 'Material Name',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _rateController,
                    hintText: 'Rate per unit',
                    labelText: 'Current Rate',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _supplierController,
                    hintText: 'Supplier name (optional)',
                    labelText: 'Supplier',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Category',
                    value: _selectedCategory,
                    items: [
                      DropdownMenuItem(value: 'Clay', child: Text('Clay')),
                      DropdownMenuItem(value: 'Paint', child: Text('Paint')),
                      DropdownMenuItem(value: 'Bamboo', child: Text('Bamboo')),
                      DropdownMenuItem(value: 'Straw', child: Text('Straw')),
                      DropdownMenuItem(value: 'Fiber', child: Text('Fiber')),
                      DropdownMenuItem(value: 'Decoration', child: Text('Decoration')),
                      DropdownMenuItem(value: 'Tools', child: Text('Tools')),
                      DropdownMenuItem(value: 'Others', child: Text('Others')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value as String);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _quantityController,
                    hintText: 'Quantity to record',
                    labelText: 'Usage Quantity',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Unit',
                    value: _selectedUnit,
                    items: [
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'liter', child: Text('liter')),
                      DropdownMenuItem(value: 'piece', child: Text('piece')),
                      DropdownMenuItem(value: 'bundle', child: Text('bundle')),
                      DropdownMenuItem(value: 'meter', child: Text('meter')),
                      DropdownMenuItem(value: 'box', child: Text('box')),
                      DropdownMenuItem(value: 'packet', child: Text('packet')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedUnit = value as String);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _addMaterial,
                    label: 'Add Material',
                    backgroundColor: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
                        // Find material by name
                        _materialsFuture.then((materials) {
                          final material = materials.firstWhere(
                            (m) => m['name'] == _nameController.text,
                            orElse: () => {},
                          );
                          if (material.isNotEmpty) {
                            _recordUsage(material['id'] as int, material['name'] as String);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Material not found. Please add it first.')),
                            );
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter material name and quantity')),
                        );
                      }
                    },
                    label: 'Record Usage',
                    backgroundColor: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textLight),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: Container(),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingMaterials() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final materials = snapshot.data!;
        if (materials.isEmpty) {
          return Container();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Trends (Last 30 Days)',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];
                    final changePercent = material['change_percent'] as double?;
                    final isPositive = (changePercent ?? 0) > 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              material['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            material['category'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${material['current_rate'] as double}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 12,
                                  color: isPositive ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${(changePercent ?? 0).abs().toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isPositive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _materialsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final materials = snapshot.data!;
        if (materials.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No materials found. Add your first material above!',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: AppConstants.fontSizeBody,
                  ),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materials List',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];
                    return _buildMaterialItem(material);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialItem(Map<String, dynamic> material) {
    final name = material['name'] as String;
    final category = material['category'] as String;
    final currentRate = material['current_rate'] as double;
    final supplier = material['supplier'] as String?;
    final lastUpdated = material['last_updated'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Text(
                  '₹$currentRate',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (supplier != null)
                  Text(
                    supplier,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                const Spacer(),
                Text(
                  'Updated: ${_formatDate(lastUpdated)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => _recordUsage(material['id'] as int, name),
                    label: 'Record Usage',
                    backgroundColor: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      _nameController.text = name;
                      _rateController.text = currentRate.toString();
                      _supplierController.text = supplier ?? '';
                      _selectedCategory = category;
                    },
                    label: 'Edit',
                    backgroundColor: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    onPressed: () => _deleteMaterial(material['id'] as int, name),
                    label: 'Delete',
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Error loading data: $error',
            style: TextStyle(color: Colors.red, fontSize: AppConstants.fontSizeBody),
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoString;
    }
  }
}