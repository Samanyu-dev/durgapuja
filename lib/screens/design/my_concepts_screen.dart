import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../models/concept.dart';
import '../../models/generated_image.dart';
import '../../services/database_service.dart';

class MyConceptsScreen extends StatefulWidget {
  const MyConceptsScreen({Key? key}) : super(key: key);

  @override
  State<MyConceptsScreen> createState() => _MyConceptsScreenState();
}

class _MyConceptsScreenState extends State<MyConceptsScreen> {
  String _selectedTheme = 'All';
  String _selectedDate = 'All';
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Concept> _concepts = [];

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadConcepts();
  }

  Future<void> _loadConcepts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rows = await DatabaseService.getConcepts();
      setState(() {
        _concepts = rows.map((row) => Concept.fromMap(row)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load concepts: $e')),
        );
      }
    }
  }

  List<Concept> get _filteredConcepts {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();
    return _concepts.where((concept) {
      if (_selectedTheme != 'All' && concept.theme != _selectedTheme) {
        return false;
      }
      if (query.isNotEmpty && !concept.title.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedDate != 'All') {
        final created = DateTime.tryParse(concept.dateCreated);
        if (created == null) return false;
        final diff = now.difference(created).inDays;
        switch (_selectedDate) {
          case 'This Month':
            if (diff > 30) return false;
            break;
          case 'Last Month':
            if (diff <= 30 || diff > 60) return false;
            break;
          case 'Last 3 Months':
            if (diff > 90) return false;
            break;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _deleteConcept(Concept concept) async {
    try {
      await DatabaseService.deleteConcept(concept.id);
      setState(() {
        _concepts.removeWhere((c) => c.id == concept.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed ${concept.title}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove concept: $e')),
        );
      }
    }
  }

  void _editConcept(Concept concept) {
    final image = GeneratedImage(
      id: concept.id,
      url: concept.imageUrl,
      prompt: concept.prompt?.isNotEmpty == true ? concept.prompt! : concept.title,
      createdAt: DateTime.tryParse(concept.dateCreated) ?? DateTime.now(),
    );
    context.push('/design/edit/image/${concept.id}', extra: image);
  }

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
            onPressed: () => context.go('/design/create'),
            tooltip: 'Create new concept',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConcepts,
        child: Column(
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
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBrown),
                    )
                  : _concepts.isEmpty
                      ? _buildEmptyState()
                      : _buildConceptsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 64, color: AppColors.textLight),
                    const SizedBox(height: 16),
                    Text(
                      'No concepts saved yet',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate a design and save it to see it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/design/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Design'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConceptsGrid() {
    final filtered = _filteredConcepts;
    if (filtered.isEmpty) {
      return const Center(child: Text('No concepts match your filters'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.mediumPadding,
        mainAxisSpacing: AppConstants.mediumPadding,
        childAspectRatio: 0.75,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildConceptCard(filtered[index]);
      },
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

  Widget _buildConceptImage(Concept concept) {
    final isNetwork = concept.imageUrl.startsWith('http://') || concept.imageUrl.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        concept.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.darkBrown,
          child: const Icon(Icons.broken_image, color: Colors.white30, size: 48),
        ),
      );
    }
    final file = File(concept.imageUrl);
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.darkBrown,
        child: const Icon(Icons.broken_image, color: Colors.white30, size: 48),
      ),
    );
  }

  Widget _buildConceptCard(Concept concept) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(concept.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Created on ${concept.dateCreated.split('T').first}'),
                const SizedBox(height: AppConstants.largePadding),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _buildConceptImage(concept),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _editConcept(concept);
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Stack(
            children: [
              Positioned.fill(child: _buildConceptImage(concept)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
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
                        concept.title,
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
                        concept.dateCreated.split('T').first,
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
                  onTap: () => _deleteConcept(concept),
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
