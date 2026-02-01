import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'client_options_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 for Pending Payments, 1 for Upcoming Deliveries

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Container(
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
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),

              // Upcoming Deliveries Summary Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upcoming Deliveries",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            "5",
                            "Due Today",
                            isHighlighted: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryCard("12", "Due Tomorrow")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryCard("24", "Due Oct 13")),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            "Pending Payments",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 0
                                  ? AppColors.primaryBrown
                                  : AppColors.textLight,
                            ),
                          ),
                          if (_selectedTab == 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: 130,
                              color: AppColors.primaryBrown,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            "Upcoming Deliveries",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1
                                  ? AppColors.primaryBrown
                                  : AppColors.textLight,
                            ),
                          ),
                          if (_selectedTab == 1)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: 150,
                              color: AppColors.primaryBrown,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Client List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (_selectedTab == 0) ..._buildPendingPaymentsList(),
                      if (_selectedTab == 1) ..._buildUpcomingDeliveriesList(),
                      const SizedBox(height: 20),
                      // Add new client button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Add new client",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String number,
    String label, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? AppColors.accentOrange
                  : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPendingPaymentsList() {
    return List.generate(3, (index) {
      return _buildPendingPaymentCard(
        name: "Rohan Sharma",
        delay: "2 day delay",
        isFirst: index == 0,
      );
    });
  }

  List<Widget> _buildUpcomingDeliveriesList() {
    return List.generate(3, (index) {
      return _buildUpcomingDeliveryCard(
        name: "Rohan Sharma",
        daysLeft: "in 2 days",
      );
    });
  }

  Widget _buildPendingPaymentCard({
    required String name,
    required String delay,
    required bool isFirst,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientOptionsScreen(clientName: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cardCream,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primaryBrown,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Text(
                        delay,
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardCream,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isFirst) ...[
                      const Icon(Icons.check, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isFirst
                          ? "Record Payment if complete"
                          : "Mark as completed",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeliveryCard({
    required String name,
    required String daysLeft,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientOptionsScreen(clientName: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cardCream,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primaryBrown,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Text(
                        daysLeft,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Delivery Done",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}