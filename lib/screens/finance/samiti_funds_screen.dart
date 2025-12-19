import 'package:flutter/material.dart';
import 'material_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

import 'worker_funds_screen.dart';

class SamitiFundsScreen extends StatelessWidget {
  const SamitiFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E6),
      bottomNavigationBar: CustomBottomNav(currentIndex: 3, onTap: (index) {}),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title + Back Icon Row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Finance",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 15),

              // TAB BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Material Tracker Tab
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MaterialsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Material Tracker",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),

                  // Samiti Funds Tab (Selected)
                  Column(
                    children: [
                      const Text(
                        "Samiti Funds",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        height: 3,
                        width: 80,
                        color: Colors.brown,
                      ),
                    ],
                  ),

                  // Worker Funds Tab
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerFundsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Worker Funds",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Fund Sources Header
              const Text(
                "Fund sources",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 15),

              // Cards
              _fundCard(
                name: "Artisan Support Grant",
                amount: "₹10,500",
                date: "10 Oct",
                status: "Repayment Due",
                statusColor: Colors.red,
                statusDate: "15 Oct",
                showButton: true,
              ),

              const SizedBox(height: 12),

              _fundCard(
                name: "Artisan Support Grant",
                amount: "₹10,500",
                date: "10 Oct",
                status: "Paid",
                statusColor: Colors.green,
                showButton: false,
              ),

              const SizedBox(height: 12),

              _fundCard(
                name: "Artisan Support Grant",
                amount: "₹10,500",
                date: "10 Oct",
                status: "Repayment Due",
                statusColor: Colors.red,
                statusDate: "15 Oct",
                showButton: true,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- FUND CARD WIDGET ----------------
  Widget _fundCard({
    required String name,
    required String amount,
    required String date,
    required String status,
    required Color statusColor,
    String? statusDate,
    required bool showButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Amount: $amount",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    "Date: $date",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),

              // Right status text
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (statusDate != null)
                    Text(
                      statusDate,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),

          if (showButton) ...[
            const SizedBox(height: 12),

            // Mark As Completed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9D7C0),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "✓   Mark as completed",
                  style: TextStyle(
                    color: Color(0xFF9A5222),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
