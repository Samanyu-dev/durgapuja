import 'package:flutter/material.dart';
import 'samiti_funds_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'add_new_rate_screen.dart';

import 'add_new_rate_screen.dart';
import 'worker_funds_screen.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

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
              // -------- TOP: TITLE + BACK BUTTON -------
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
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

              // -------- NEW TABS (Material Tracker | Samiti Funds | Worker Funds) --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Material Tracker (SELECTED)
                  Column(
                    children: [
                      const Text(
                        "Material Tracker",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        height: 3,
                        width: 110,
                        color: Colors.brown,
                      ),
                    ],
                  ),

                  // Samiti Funds
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

                  // Worker Funds — not implemented yet
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
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- SEARCH BAR ----------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Search",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                    const Icon(Icons.mic, color: Colors.black54),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------------- RECENT MATERIALS ----------------
              const Text(
                "Recent Materials",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 15),

              _materialTile(
                icon: Icons.category,
                name: "Clay",
                place: "Shop 1 - Town 1",
                rate: "₹150 /Kg",
                trendUp: true,
              ),

              const SizedBox(height: 12),

              _materialTile(
                icon: Icons.brush,
                name: "Paint",
                place: "Town 2",
                rate: "₹150 /Kg",
                trendUp: true,
              ),

              const SizedBox(height: 12),

              _materialTile(
                icon: Icons.grass,
                name: "Bamboo",
                place: "Town 2",
                rate: "₹150 /Kg",
                trendUp: false,
              ),

              const SizedBox(height: 25),

              // Add new rate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddNewRateScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5222),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Add new rate",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Latest Trend",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 15),

              _trendTable(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- MATERIAL TILE WIDGET ----------------
  Widget _materialTile({
    required IconData icon,
    required String name,
    required String place,
    required String rate,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEDFD0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 30, color: Colors.brown),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  place,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: trendUp ? Colors.green : Colors.red,
                size: 20,
              ),
              Text(
                rate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TREND TABLE ----------------
  Widget _trendTable() {
    final rows = [
      ["Clay", "Maniktala", "12 Oct", "3%", "₹150/kg"],
      ["Paint", "Shobhabazar", "12 Oct", "3%", "₹200/liter"],
      ["Bamboo", "Bagbazar", "12 Oct", "3%", "₹50/piece"],
      ["Straw", "Cossipore", "12 Oct", "3%", "₹30/bundle"],
      ["Fiber", "Shobhabazar", "12 Oct", "3%", "₹80/meter"],
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row[0]),
                Text(row[1]),
                Text(row[2]),
                Text(row[3], style: const TextStyle(color: Colors.green)),
                Text(
                  row[4],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
