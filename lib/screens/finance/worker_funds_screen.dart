import 'package:flutter/material.dart';
import 'material_screen.dart';
import 'samiti_funds_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

import 'worker_details_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

class WorkerFundsScreen extends StatelessWidget {
  const WorkerFundsScreen({super.key});

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SamitiFundsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Samiti Funds",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),

                  Column(
                    children: [
                      const Text(
                        "Worker Funds",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: 90,
                        margin: const EdgeInsets.only(top: 4),
                        color: Colors.brown,
                      ),
                    ],
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
                paid: "₹ 16,000",
                total: "25,000",
                workerName: "Ramesh Pal",
                workerPaid: "₹ 3,000",
                workerPending: "₹ 5,000",
              ),

              const SizedBox(height: 20),

              // SECTION 2: Painting
              _categoryCard(
                context,
                title: "Painting",
                workers: "3 workers",
                paid: "₹ 16,000",
                total: "25,000",
                workerName: "Ramesh Pal",
                workerPaid: "₹ 3,000",
                workerPending: "₹ 5,000",
              ),

              const SizedBox(height: 25),

              // ADD NEW WORKER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
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
