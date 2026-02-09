import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../l10n/app_localizations.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/language_toggle_action.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final pad = size.width * 0.04;
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(l10n.helloArtisan),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const LanguageToggleAction(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: AppColors.primaryBrown),
            onPressed: () => context.go('/'),
            tooltip: l10n.backToModuleSelection,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad.clamp(12.0, 20.0)),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Record Voice Note Card — first tap START, second tap STOP
            GestureDetector(
              onTap: () async {
                if (!_speechService.isListening) {
                  final started = await _speechService.startListening();
                  if (mounted) setState(() {});
                  if (!started) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not start listening')),
                      );
                    }
                  }
                  return;
                }
                final banglaText = await _speechService.stopListening();
                if (mounted) setState(() {});
                if (banglaText.isNotEmpty) {
                  final englishText =
                      await _translationService.translateToEnglish(banglaText);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Voice Note: $englishText')),
                    );
                  }
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No speech detected')),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all((size.width * 0.06).clamp(16.0, 28.0)),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(size.width * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _speechService.isListening
                            ? Colors.orange.shade100
                            : AppColors.primaryBrown,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _speechService.isListening ? Icons.graphic_eq : Icons.mic,
                        color: _speechService.isListening ? Colors.orange : Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _speechService.isListening ? 'Listening... tap again to stop' : l10n.recordVoiceNote,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.voiceNoteDescription,
                      style: const TextStyle(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    l10n.todaysExpenses,
                    '₹2,450',
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    l10n.materialsBought,
                    '₹8,200',
                    Icons.inventory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              l10n.pendingPayments,
              '₹15,000',
              Icons.pending,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // View Report Button
            CustomButton(
              label: l10n.viewReport,
              onPressed: () => context.go('/finance/reports'),
              backgroundColor: AppColors.primaryBrown,
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: AppColors.primaryBrown, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
