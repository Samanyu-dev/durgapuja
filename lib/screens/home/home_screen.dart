import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/test_firebase.dart';
import '../design/create_prompt_screen.dart';
import '../design/create_preview_screen.dart';
import '../design/create_backdrop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _testFirebaseConnection() async {
    try {
      final testService = FirebaseTestService();
      final result = await testService.testFirebaseConnection();

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Test Successful! ${result['data']['total_test_records']} dynamic records created and verified. Sample: ${result['data']['sample_client']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Test Failed: ${result['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

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
                        builder: (context) => const CreatePromptScreen(),
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
              ],
            ),
            const SizedBox(height: AppConstants.largePadding),
            // Firebase Test Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: ElevatedButton.icon(
                onPressed: _testFirebaseConnection,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Test Firebase Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ),
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
