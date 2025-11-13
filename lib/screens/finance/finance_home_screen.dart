// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'material_tracker_screen.dart';
import '../../widgets/custom_button.dart';

class FinanceHomeScreen extends StatefulWidget {
  const FinanceHomeScreen({super.key});

  @override
  State<FinanceHomeScreen> createState() => _FinanceHomeScreenState();
}

class _FinanceHomeScreenState extends State<FinanceHomeScreen> {
  bool _isRecording = false;
  final TextEditingController _voiceNoteController = TextEditingController();

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('🎙️ Recording started... Say your transaction details'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Recording saved'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Hello, Artisan'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Record Voice Note',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  const Text(
                    'Tap to record your transaction details',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppColors.warningRed
                            : AppColors.primaryBrown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording
                                    ? AppColors.warningRed
                                    : AppColors.primaryBrown)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  const Text(
                    'Example inputs:',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Container(
                    padding:
                        const EdgeInsets.all(AppConstants.mediumPadding),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCream,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Sold 2 idols to Behala Samity for ₹10,000"',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeBody,
                            color: AppColors.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Text(
                          '"Paid ₹500 for paints at Shyambazar shop"',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeBody,
                            color: AppColors.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            _buildFinancialCard(
              icon: Icons.shopping_cart_outlined,
              label: 'Today\'s Expenses',
              amount: '₹2,500',
              color: AppColors.warningRed,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            _buildFinancialCard(
              icon: Icons.local_shipping_outlined,
              label: 'Materials Bought',
              amount: '₹15,000',
              color: AppColors.accentOrange,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            _buildFinancialCard(
              icon: Icons.receipt_outlined,
              label: 'Pending Payments',
              amount: '₹8,000',
              color: AppColors.primaryBrown,
            ),
            const SizedBox(height: AppConstants.largePadding),

            CustomButton(
              label: 'View Report',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialTrackerScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primaryBrown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: AppConstants.mediumPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceNoteController.dispose();
    super.dispose();
  }
}
