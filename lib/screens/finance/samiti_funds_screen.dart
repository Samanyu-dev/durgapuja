import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class SamitiMaterialView extends StatefulWidget {
  const SamitiMaterialView({Key? key}) : super(key: key);

  @override
  State<SamitiMaterialView> createState() => _SamitiMaterialViewState();
}

class _SamitiMaterialViewState extends State<SamitiMaterialView> {
  final List<Map<String, dynamic>> _fundSources = [
    {
      'title': 'Artisan Support Grant',
      'amount': '₹10,500',
      'date': '10 Oct',
      'status': 'Repayment Due 15 Oct',
      'statusColor': AppColors.warningRed,
    },
    {
      'title': 'Artisan Support Grant',
      'amount': '₹10,500',
      'date': '10 Oct',
      'status': 'Paid',
      'statusColor': AppColors.successGreen,
    },
    {
      'title': 'Artisan Support Grant',
      'amount': '₹10,500',
      'date': '10 Oct',
      'status': 'Repayment Due 15 Oct',
      'statusColor': AppColors.warningRed,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fund summary',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppConstants.largePadding),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCream,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_outlined,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        const Text(
                          'Fund Chart (Oct 10 - Oct 15)',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: AppConstants.fontSizeBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.largePadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildFundIndicator(
                        'Received',
                        '₹10,500',
                        AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumPadding),
                    Expanded(
                      child: _buildFundIndicator(
                        'Used',
                        '₹10,500',
                        AppColors.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),

          const Text(
            'Fund sources',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          ..._fundSources.map((fund) => _buildFundSourceCard(fund)),
          const SizedBox(height: AppConstants.largePadding),

          CustomButton(
            label: 'Request Fund',
            icon: Icons.mic_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎙️ Recording fund request...'),
                ),
              );
            },
            backgroundColor: AppColors.primaryBrown,
          ),
        ],
      ),
    );
  }

  Widget _buildFundIndicator(
      String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            amount,
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundSourceCard(Map<String, dynamic> fund) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund['title'],
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeBody,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ${fund['amount']}',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${fund['date']}',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mediumPadding,
                  vertical: AppConstants.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: fund['statusColor'].withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Text(
                  fund['status'],
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: fund['statusColor'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
