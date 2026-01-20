import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../services/database_service.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final String workerName;
  final String category;
  final String budget;
  final String paid;

  const WorkerDetailsScreen({
    super.key,
    required this.workerName,
    required this.category,
    required this.budget,
    required this.paid,
  });

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  final TextEditingController _amountPaidController = TextEditingController();

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  Future<void> _confirmDetails() async {
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
    if (amountPaid <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Parse category to extract idol_type and worker_type
    final parts = widget.category.split(' / ');
    final idolType = parts.isNotEmpty ? parts[0] : 'Unknown';
    final workerType = parts.length > 1 ? parts[1] : 'Unknown';

    // Insert worker fund with transaction log
    await DatabaseService.insertWorkerFundManual(
      idolType: idolType,
      workerType: workerType,
      amountPaid: amountPaid,
      amountTotal: double.tryParse(widget.budget.replaceAll(",", "")) ?? 0.0,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker payment added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double pending =
        double.tryParse(widget.budget.replaceAll(",", ""))! -
        double.tryParse(widget.paid.replaceAll(",", ""))!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E6),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            // Stay on Finance tab, just pop back
            Navigator.pop(context);
            return;
          }

          // Pop back to MainNavigationScreen, then switch tabs
          // Pop multiple times if needed to get back to MainNavigationScreen
          int popCount = 0;
          while (Navigator.canPop(context) && popCount < 5) {
            Navigator.pop(context);
            popCount++;
            // Stop if we've popped enough to get back to MainNavigationScreen
          }

          // Switch to the selected tab after popping
          Future.microtask(() {
            // Navigation handled by popping
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF9A5222),
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    widget.workerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                "Category: ${widget.category}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              // Budget + Paid Row
              Row(
                children: [
                  // Budget Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9A5222),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Budget",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "₹ ${widget.budget}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Paid Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Paid",
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "₹ ${widget.paid}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Pending Amount
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEDFD0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pending amount"),
                    const SizedBox(height: 6),
                    Text(
                      "₹ ${pending.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Amount Paid Input
              const Text("Amount paid", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEDFD0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text("₹ ", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _amountPaidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "0.00",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5222),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Confirm Details",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
