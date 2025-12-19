import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'material_screen.dart';

class FinanceHomeScreen extends StatelessWidget {
  const FinanceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      bottomNavigationBar: CustomBottomNav(currentIndex: 3, onTap: (index) {}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "App Name",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings, size: 26),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Text(
                "Hello, Artisan",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Record Voice Note",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Tap to record your transaction details",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBrown,
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildCard(
                icon: Icons.shopping_basket_outlined,
                title: "Today's Expenses",
                amount: "₹ 2,500",
                color: AppColors.warningRed,
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MaterialsScreen()),
                  );
                },
                child: _buildCard(
                  icon: Icons.category_outlined,
                  title: "Materials Bought",
                  amount: "₹ 15,000",
                  color: AppColors.accentOrange,
                ),
              ),

              const SizedBox(height: 15),

              _buildCard(
                icon: Icons.sticky_note_2_outlined,
                title: "Pending Payments",
                amount: "₹ 8,000",
                color: AppColors.primaryBrown,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
