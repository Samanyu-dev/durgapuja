import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'samiti_funds_screen.dart';
import 'worker_details_screen.dart';
import 'material_screen.dart';
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
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text('Worker Funds'),
        backgroundColor: const Color(0xFF9A5222),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to finance dashboard instead of popping
            context.go('/finance/dashboard');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                progress: _clayTotalAssigned <= 0
                    ? 0.0
                    : (_clayPaid / _clayTotalAssigned).clamp(0.0, 1.0),
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
                progress: _paintingTotalAssigned <= 0
                    ? 0.0
                    : (_paintingPaid / _paintingTotalAssigned).clamp(0.0, 1.0),
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
  required double progress,
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
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  height: 6,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 15),

        // Mark as completed button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title marked as completed')),
              );
            },
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
