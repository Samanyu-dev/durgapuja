import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../design/create_prompt_screen.dart';
import '../design/ai_design_assistant_screen.dart';
import '../design/idol_visualization_screen.dart';
import '../design/fine_detailing_screen.dart';
import '../design/sculpting_assistant_screen.dart';
import '../design/create_preview_screen.dart';
import '../design/create_backdrop_screen.dart';
import '../design/suggest_lighting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Welcome, artisan'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppConstants.mediumPadding,
              crossAxisSpacing: AppConstants.mediumPadding,
              children: [
                _buildFeatureCard(
                  icon: Icons.lightbulb_outline,
                  title: 'Idea Generation',
                  subtitle: 'Generate unique idol designs with AI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIDesignAssistantScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.build_circle_outlined,
                  title: 'Idol Build',
                  subtitle: 'Step-by-step guide to building your idol',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const IdolVisualizationScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.palette_outlined,
                  title: 'Decoration & Detailing',
                  subtitle: 'Add details and decorations to your idol',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FineDetailingScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.preview_outlined,
                  title: 'Idol Previews',
                  subtitle: 'Showcase your creations',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePreviewScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.image_outlined,
                  title: 'Generate Backdrop',
                  subtitle: 'Add details and decorations to your idol',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateBackdropScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.lightbulb_circle_outlined,
                  title: 'Try Lights',
                  subtitle: 'Showcase your creations',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SuggestLightingScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppColors.primaryBrown,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
