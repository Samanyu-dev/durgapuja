import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/generated_image.dart';
import '../../services/concepts_store_service.dart';
import '../../services/language_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/language_toggle_action.dart';

class MyConceptsScreen extends StatefulWidget {
  const MyConceptsScreen({Key? key}) : super(key: key);

  @override
  State<MyConceptsScreen> createState() => _MyConceptsScreenState();
}

class _MyConceptsScreenState extends State<MyConceptsScreen> {
  String _selectedTheme = 'All';
  String _selectedDate = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ConceptsStoreService _conceptsStore = ConceptsStoreService();
  List<Map<String, String>> _concepts = [];
  bool _loading = true;

  static const List<Map<String, String>> _demoConcepts = [
    {'title': 'Divine Durga', 'date': 'Created on 2024-07-20', 'image': 'assets/images/durga_1.jpg', 'id': 'demo_1'},
    {'title': 'Traditional Durga', 'date': 'Created on 2024-07-15', 'image': 'assets/images/durga_2.jpg', 'id': 'demo_2'},
    {'title': 'Modern Durga', 'date': 'Created on 2024-07-10', 'image': 'assets/images/durga_3.jpg', 'id': 'demo_3'},
    {'title': 'Eco-Friendly Durga', 'date': 'Created on 2024-07-05', 'image': 'assets/images/durga_4.jpg', 'id': 'demo_4'},
    {'title': 'Minimalist Durga', 'date': 'Created on 2024-06-30', 'image': 'assets/images/durga_5.jpg', 'id': 'demo_5'},
    {'title': 'Gold Durga', 'date': 'Created on 2024-06-25', 'image': 'assets/images/durga_6.jpg', 'id': 'demo_6'},
  ];

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
    _loadConcepts();
  }

  Future<void> _loadConcepts() async {
    final saved = await _conceptsStore.getConcepts();
    if (mounted) {
      setState(() {
        _concepts = [
          ...saved.map((m) => {
            'id': m['id'] ?? m['title'] ?? '',
            'title': m['title'] ?? 'Untitled',
            'date': m['date'] ?? 'Created on ${DateTime.now().toString().substring(0, 10)}',
            'image': m['image'] ?? '',
          }),
          ..._demoConcepts,
        ];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(lang.getText('my_concepts')),
        automaticallyImplyLeading: false,
        actions: [
          const LanguageToggleAction(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/design/create'),
            tooltip: lang.getText('create_new_concept'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: lang.getText('search_concepts'),
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
            Text(
              lang.getText('filters'),
              style: const TextStyle(
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
                    lang.getText('theme'),
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
                    lang.getText('date'),
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
            const SizedBox(height: AppConstants.mediumPadding),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }

  Future<void> _removeConcept(Map<String, String> concept) async {
    final id = concept['id'] ?? concept['title'];
    if (id == null) return;
    if (id.startsWith('demo_')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo concepts cannot be removed')),
        );
      }
      return;
    }
    await _conceptsStore.removeConcept(id);
    await _loadConcepts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${concept['title']}')),
      );
    }
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

  void _openConceptForEdit(Map<String, String> concept) {
    final imageUrl = concept['image'] ?? '';
    final title = concept['title'] ?? 'Untitled';
    final id = concept['id'] ?? title;
    final generatedImage = GeneratedImage(
      id: id,
      url: imageUrl,
      prompt: title,
      createdAt: DateTime.now(),
    );
    context.go(
      '/design/edit/image/${Uri.encodeComponent(id)}',
      extra: generatedImage,
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
                  _openConceptForEdit(concept);
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
            fit: StackFit.expand,
            children: [
              _buildConceptThumbnail(concept),
              Container(
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
                onTap: () => _removeConcept(concept),
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

  Widget _buildConceptThumbnail(Map<String, String> concept) {
    final imageUrl = concept['image'] ?? '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.darkBrown,
          child: const Icon(Icons.image_not_supported, color: Colors.white38, size: 48),
        ),
      );
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.darkBrown,
          child: const Icon(Icons.image_outlined, color: Colors.white38, size: 48),
        ),
      );
    }
    return Container(
      color: AppColors.darkBrown,
      child: const Icon(Icons.image_outlined, color: Colors.white38, size: 48),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
