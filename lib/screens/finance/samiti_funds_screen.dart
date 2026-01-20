import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'worker_funds_screen.dart';
import '../../services/database_service.dart';

class SamitiFundsScreen extends StatefulWidget {
  const SamitiFundsScreen({super.key});

  @override
  State<SamitiFundsScreen> createState() => _SamitiFundsScreenState();
}

class _SamitiFundsScreenState extends State<SamitiFundsScreen> {
  void _showAddSamitiFundDialog() {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    final dateController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Samiti Fund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Unknown',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final name = nameController.text.isEmpty
                  ? 'Unknown'
                  : nameController.text;
              final date = dateController.text.isEmpty
                  ? DateTime.now().toIso8601String().split('T').first
                  : dateController.text;

              if (amount > 0) {
                await DatabaseService.insertSamitiFundManual(
                  name: name,
                  amount: amount,
                  date: date,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Samiti fund added successfully'),
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E6),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            // Stay on Finance tab, just pop back to MaterialsScreen
            Navigator.pop(context);
            return;
          }

          // Pop back to MainNavigationScreen, then switch tabs
          Navigator.pop(context);

          // Switch to the selected tab after popping
          Future.microtask(() {
            // Navigation handled by popping back to main screen
          });
        },
      ),

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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Material Tracker Tab
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          // Pop back to MaterialsScreen (which is in MainNavigationScreen)
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Material Tracker",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF757575),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // Samiti Funds Tab (Selected)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Samiti Funds",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5C3D2E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 3,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C3D2E),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Worker Funds Tab
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          // Replace current screen with WorkerFundsScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkerFundsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Worker Funds",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF757575),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSamitiFundDialog,
        backgroundColor: const Color(0xFF9A5222),
        child: const Icon(Icons.add, color: Colors.white),
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
