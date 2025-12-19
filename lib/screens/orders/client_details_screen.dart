import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String clientId;

  const ClientDetailsScreen({Key? key, required this.clientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Client Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Info Fields
            _buildFormField('Client Name', 'Rohan Sharma'),
            const SizedBox(height: 16),
            _buildFormField('Contact Number', '+91 9876543210'),
            const SizedBox(height: 16),
            _buildFormField('Idol Name', 'Durga Idol'),
            const SizedBox(height: 16),
            _buildFormField('Materials/Special Requirements', 'Clay, Paint, Gold leaf'),
            const SizedBox(height: 24),

            // Delivery Dates Section
            const Text(
              'Delivery Dates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildDeliveryDateItem('Durga Idol', 'Dec 25, 2025'),
            _buildDeliveryDateItem('Lakshmi Idol', 'Jan 15, 2026'),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBrown,
                      side: const BorderSide(color: AppColors.primaryBrown),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Add another idol'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: 'Update details',
                    onPressed: () {},
                    backgroundColor: AppColors.primaryBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warningRed,
                side: const BorderSide(color: AppColors.warningRed),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Delete Client'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textLight.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.edit,
                color: AppColors.primaryBrown,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDateItem(String idolName, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idolName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit,
            color: AppColors.primaryBrown,
          ),
        ],
      ),
    );
  }
}
