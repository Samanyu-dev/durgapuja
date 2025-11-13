import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_bottom_nav.dart';

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
  final List<String> _generatedImages = [];
  bool _isGenerating = false;
  String _selectedInspiration = 'Scripture';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _generateIdeas() {
    setState(() {
      _isGenerating = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _generatedImages.addAll(['1', '2', '3', '4', '5', '6']);
        _isGenerating = false;
      });
    });
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
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkBrown,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/images/durga_${index + 1}.jpg'),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
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
                            Colors.black.withOpacity(0.5),
                          ],
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
