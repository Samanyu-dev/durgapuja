import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_bottom_nav.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({super.key});

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _generatedPrompts = [];
  bool _isLoading = false;

  void _generatePrompts() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _generatedPrompts.addAll([
          {
            'title': 'PROMPT FOR IMAGE GENERATION',
            'content':
                'A hyper-realistic digital painting of a Durga idol\'s sari in the traditional Bengal style, featuring intricate Jamdani motifs in red and gold on a white silk base. Focus on the fabric\'s texture and the precise geometric patterns of the weave, ensuring iconographic accuracy for the goddess\'s attire.'
          },
          {
            'title': 'PROMPT FOR DESIGN CONCEPT',
            'content':
                'Detailed ornamentation design for a Durga idol\'s mukut (crown) in the Bengal Dokra style. The prompt should specify traditional motifs like peacock, lotus flowers, and solar symbols. Emphasize a rustic, non-polished brass finish and asymmetrical handcrafted details.'
          },
          {
            'title': 'PROMPT FOR COLOR PALETTE',
            'content':
                'Generate a traditional Bengali color palette for a Chalchitra backdrop. Primary colors: vermillion red, ochre yellow, and deep indigo. Secondary colors: leaf green and pristine white for accents. The style should be reminiscent of Patachitra scroll painting.'
          },
        ]);
        _isLoading = false;
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
        title: const Text('Create Prompt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are you designing?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'e.g., Idol Design for durga pooja',
              controller: _promptController,
              hasVoiceInput: true,
              maxLines: 3,
              onVoicePressed: () {
              },
            ),
            const SizedBox(height: 32),
            if (_generatedPrompts.isNotEmpty) ...[
              const Text(
                'Generated Prompts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ..._generatedPrompts.map((prompt) => _buildPromptCard(prompt)),
            ],
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generatePrompts,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 8),
                      Text('Generate Prompts'),
                    ],
                  ),
                ),
              ),
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

  Widget _buildPromptCard(Map<String, String> prompt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt['title']!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accentOrange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prompt['content']!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit & Refine'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
