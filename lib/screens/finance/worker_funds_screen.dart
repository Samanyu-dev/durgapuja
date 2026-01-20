import 'package:flutter/material.dart';
import 'samiti_funds_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'worker_details_screen.dart';
import '../../services/database_service.dart';

class WorkerFundsScreen extends StatefulWidget {
  const WorkerFundsScreen({super.key});

  @override
  State<WorkerFundsScreen> createState() => _WorkerFundsScreenState();
}

class _WorkerFundsScreenState extends State<WorkerFundsScreen> {
  double _clayPaid = 0.0;
  double _paintingPaid = 0.0;

  static const double _clayTotalAssigned = 25000;
  static const double _paintingTotalAssigned = 25000;

  @override
  void initState() {
    super.initState();
    _loadWorkerPayments();
  }

  Future<void> _loadWorkerPayments() async {
    final clay = await DatabaseService.getWorkerPaymentsTotalByType('clay');
    final painting = await DatabaseService.getWorkerPaymentsTotalByType(
      'painting',
    );
    if (!mounted) return;
    setState(() {
      _clayPaid = clay;
      _paintingPaid = painting;
    });
  }

  String _formatCurrency(double amount) {
    final amountStr = amount.toStringAsFixed(0);
    if (amountStr.length <= 3) {
      return amountStr;
    }
    String result = '';
    for (int i = amountStr.length - 1; i >= 0; i--) {
      int position = amountStr.length - 1 - i;
      if (position == 3 || (position > 3 && (position - 3) % 2 == 0)) {
        result = ',$result';
      }
      result = '${amountStr[i]}$result';
    }
    return result;
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
            // Navigation handled by popping
          });
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
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

              // TABS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          // Replace current screen with SamitiFundsScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SamitiFundsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Samiti Funds",
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

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Worker Funds",
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
                ],
              ),

              const SizedBox(height: 20),

              // DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Durga Idol", style: TextStyle(fontSize: 16)),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // SECTION 1: Clay Modeling
              _categoryCard(
                context,
                title: "Clay Modeling",
                workers: "3 workers",
                paid: "₹ ${_formatCurrency(_clayPaid)}",
                total: _formatCurrency(_clayTotalAssigned),
                workerName: "Ramesh",
                workerPaid:
                    "₹ ${_formatCurrency(_clayPaid)}", // display same as paid summary
                workerPending:
                    "₹ ${_formatCurrency(_clayTotalAssigned - _clayPaid)}",
              ),

              const SizedBox(height: 20),

              // SECTION 2: Painting
              _categoryCard(
                context,
                title: "Painting",
                workers: "3 workers",
                paid: "₹ ${_formatCurrency(_paintingPaid)}",
                total: _formatCurrency(_paintingTotalAssigned),
                workerName: "Ramesh",
                workerPaid:
                    "₹ ${_formatCurrency(_paintingPaid)}", // display same as paid summary
                workerPending:
                    "₹ ${_formatCurrency(_paintingTotalAssigned - _paintingPaid)}",
              ),

              const SizedBox(height: 25),

              // ADD NEW WORKER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerDetailsScreen(
                          workerName: "New Worker",
                          category: "Durga Idol / Claymaking",
                          budget: "0",
                          paid: "0",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5222),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Add new worker",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

// ***** CATEGORY CARD WIDGET *****
Widget _categoryCard(
  BuildContext context, {
  required String title,
  required String workers,
  required String paid,
  required String total,
  required String workerName,
  required String workerPaid,
  required String workerPending,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),

        Text(workers, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          "Paid: $paid of $total",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),

        const SizedBox(height: 20),

        // Worker Item (Clickable)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerDetailsScreen(
                  workerName: workerName,
                  category: title,
                  budget: total,
                  paid: workerPaid,
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                workerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),

        const SizedBox(height: 4),
        Text(
          "Paid: $workerPaid  /  Pending: $workerPending",
          style: const TextStyle(fontSize: 14, color: Colors.green),
        ),

        const SizedBox(height: 10),

        // Green progress bar
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        const SizedBox(height: 15),

        // Mark as completed button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9D7C0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
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
    ),
  );
}
