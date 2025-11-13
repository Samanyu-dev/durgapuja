import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class MyConceptsScreen extends StatefulWidget {
  const MyConceptsScreen({Key? key}) : super(key: key);

  @override
  State<MyConceptsScreen> createState() => _MyConceptsScreenState();
}

class _MyConceptsScreenState extends State<MyConceptsScreen> {
  String _selectedTheme = 'All';
  String _selectedDate = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _themes = [
    'All',
    'Divine',
    'Traditional',
    'Modern',
    'Eco-Friendly'
  ];
  final List<String> _dates = [
    'All',
    'This Month',
    'Last Month',
    'Last 3 Months'
  ];

  final List<Map<String, String>> _concepts = [
    {
      'title': 'Divine Durga',
      'date': 'Created on 2024-07-20',
      'image': 'assets/images/durga_1.jpg',
    },
    {
      'title': 'Traditional Durga',
      'date': 'Created on 2024-07-15',
      'image': 'assets/images/durga_2.jpg',
    },
    {
      'title': 'Modern Durga',
      'date': 'Created on 2024-07-10',
      'image': 'assets/images/durga_3.jpg',
    },
    {
      'title': 'Eco-Friendly Durga',
      'date': 'Created on 2024-07-05',
      'image': 'assets/images/durga_4.jpg',
    },
    {
      'title': 'Minimalist Durga',
      'date': 'Created on 2024-06-30',
      'image': 'assets/images/durga_5.jpg',
    },
    {
      'title': 'Gold Durga',
      'date': 'Created on 2024-06-25',
      'image': 'assets/images/durga_6.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('My Concepts'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('+ Create new concept')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search concepts',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎙️ Voice search'),
                          ),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.cardCream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.largePadding),

                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppConstants.mediumPadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFilter(
                        'Theme',
                        _selectedTheme,
                        _themes,
                        (value) {
                          setState(() {
                            _selectedTheme = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumPadding),
                    Expanded(
                      child: _buildDropdownFilter(
                        'Date',
                        _selectedDate,
                        _dates,
                        (value) {
                          setState(() {
                            _selectedDate = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.mediumPadding,
                mainAxisSpacing: AppConstants.mediumPadding,
                childAspectRatio: 0.75,
              ),
              itemCount: _concepts.length,
              itemBuilder: (context, index) {
                final concept = _concepts[index];
                return _buildConceptCard(concept);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConceptCard(Map<String, String> concept) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(concept['title']!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(concept['date']!),
                const SizedBox(height: AppConstants.largePadding),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ ${concept['title']} edited'),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBrown,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                color: AppColors.darkBrown,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concept['title']!,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      concept['date']!.replaceAll('Created on ', ''),
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${concept['title']!}'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
