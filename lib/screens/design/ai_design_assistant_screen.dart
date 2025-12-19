import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../services/krea_ai_service.dart';
import '../../models/generated_image.dart';

class AIDesignAssistantScreen extends StatefulWidget {
  const AIDesignAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AIDesignAssistantScreen> createState() =>
      _AIDesignAssistantScreenState();
}

class _AIDesignAssistantScreenState extends State<AIDesignAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _themeController = TextEditingController();
  late TabController _tabController;
  final List<GeneratedImage> _generatedImages = [];
  bool _isGenerating = false;
  final KreaAIService _kreaService = KreaAIService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _generateIdeas() async {
    if (_themeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a theme first')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final prompt = _buildPromptFromTheme(_themeController.text.trim());
      final images = await _kreaService.generateImages(prompt, count: 4);

      setState(() {
        _generatedImages.addAll(images);
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate images: $e')),
      );
    }
  }

  String _buildPromptFromTheme(String theme) {
    final inspiration = _tabController.index == 0
        ? 'Scripture'
        : _tabController.index == 1
            ? 'Festival'
            : 'Modern Theme';

    return 'Create a beautiful Durga Puja idol design with theme: $theme, inspiration from: $inspiration. Traditional Bengali style, intricate details, golden ornaments, serene expression.';
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
        title: const Text('AI Design Assistant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your theme or speak it aloud',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'e.g., "Victory of good over evil"',
              controller: _themeController,
              hasVoiceInput: true,
              onVoicePressed: () {
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Click here to generate prompt',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Choose your inspiration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
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
                  Tab(text: 'Scripture'),
                  Tab(text: 'Festival'),
                  Tab(text: 'Modern Theme'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateIdeas,
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 8),
                          Text('Generate Ideas'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
            if (_generatedImages.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _generatedImages.length,
                itemBuilder: (context, index) {
                  final image = _generatedImages[index];
                  return GestureDetector(
                    onTap: () {
                      // TODO: Navigate to detail view or save image
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkBrown,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(image.url),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Fallback to placeholder if image fails to load
                          },
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Generated Idol Design',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

  @override
  void dispose() {
    _themeController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
