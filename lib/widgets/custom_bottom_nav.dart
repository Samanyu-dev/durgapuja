import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/speech_service.dart';
import '../services/translation_service.dart';
import '../services/gpt_service.dart';
import '../services/finance_processor.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            Expanded(
              child: _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
            ),
            // Orders
            Expanded(
              child: _buildNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Orders',
                index: 1,
              ),
            ),
            // Central Microphone Button
            GestureDetector(
              onTap: () async {
                if (!_isListening) {
                  final started = await _speechService.startListening();
                  if (!started) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Unable to start listening",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _isListening = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Listening..."),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                final banglaText = await _speechService.stopListening();
                setState(() {
                  _isListening = false;
                });
                debugPrint("Bangla Text: $banglaText");

                if (banglaText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Recording unsuccessful, please try again",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Recorded successfully",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );

                String englishText = await _translationService
                    .translateToEnglish(banglaText);
                debugPrint("English Text: $englishText");

                final gptJson = await GPTService.sendToGPT(englishText);
                debugPrint("GPT JSON:");
                debugPrint(gptJson.toString());

                final confirmed = await _showGptConfirmationDialog(
                  context,
                  banglaText: banglaText,
                  englishText: englishText,
                  gptJson: gptJson,
                );

                if (confirmed) {
                  await FinanceProcessor.processGptResult(
                    gptJson: gptJson,
                    englishText: englishText,
                  );
                }
              },
              child: Container(
                width: _isListening ? 64 : 56,
                height: _isListening ? 64 : 56,
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.accentOrange
                      : AppColors.primaryBrown,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            // Finance
            Expanded(
              child: _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: 'Finance',
                index: 2,
              ),
            ),
            // Reports
            Expanded(
              child: _buildNavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Reports',
                index: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCircular = false,
  }) {
    final isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCircular)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.primaryBrown.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.primaryBrown : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primaryBrown : AppColors.textLight,
                size: 18,
              ),
            )
          else
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryBrown : AppColors.textLight,
              size: 24,
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primaryBrown : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isActive && !isCircular)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 30,
              color: AppColors.primaryBrown,
            ),
        ],
      ),
    );
  }
}

Future<bool> _showGptConfirmationDialog(
  BuildContext context, {
  required String banglaText,
  required String englishText,
  required Map<String, dynamic> gptJson,
}) async {
  String asString(dynamic value) => value == null ? 'null' : value.toString();

  final workerType = gptJson['worker_type'];
  final idolType = gptJson['idol_type'];
  final confidence = gptJson['confidence'];
  final intent = gptJson['intent'];
  final amount = gptJson['amount'];
  final category = gptJson['category'];
  final name = gptJson['name'] ?? gptJson['worker_name'];

  Widget buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  final otherFields = <Widget>[];
  gptJson.forEach((key, value) {
    if (key == 'intent' ||
        key == 'amount' ||
        key == 'category' ||
        key == 'name' ||
        key == 'worker_name' ||
        key == 'worker_type' ||
        key == 'idol_type' ||
        key == 'confidence') {
      return;
    }
    otherFields.add(buildField(key.toString(), asString(value)));
  });

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm transaction'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bengali text block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🗣 Bengali Text",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(banglaText),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // English text block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🌍 English Text",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(englishText),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Classified result block with pill header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0C2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Classified Result",
                        style: TextStyle(
                          color: Color(0xFF8B4513),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (intent != null) buildField("Intent", asString(intent)),
                    if (name != null) buildField("Name", asString(name)),
                    if (amount != null) buildField("Amount", asString(amount)),
                    if (category != null)
                      buildField("Category", asString(category)),
                    if (workerType != null)
                      buildField("Worker Type", asString(workerType)),
                    if (idolType != null)
                      buildField("Idol Type", asString(idolType)),
                    if (confidence != null)
                      buildField("Confidence", asString(confidence)),
                    if (otherFields.isNotEmpty) const SizedBox(height: 8),
                    ...otherFields,
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("❌ NO, DISCARD"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("✅ YES, THIS IS CORRECT"),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
