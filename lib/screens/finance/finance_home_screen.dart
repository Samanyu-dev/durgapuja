import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/speech_service.dart';
import '../../utils/colors.dart';
import '../../services/translation_service.dart';
import '../../services/gpt_service.dart';
import '../../services/database_service.dart';
import '../../services/finance_processor.dart';
import '../../utils/dummy_data.dart';

class FinanceHomeScreen extends StatefulWidget {
  const FinanceHomeScreen({super.key});

  @override
  State<FinanceHomeScreen> createState() => _FinanceHomeScreenState();
}

class _FinanceHomeScreenState extends State<FinanceHomeScreen> {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();
  int _selectedTab = 0; // 0 for Pending Payments, 1 for Upcoming Deliveries
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double get _currentBalance => _totalIncome - _totalExpenses;
  bool _isListening = false;
  bool _showManagementView = false; // Toggle between Dashboard and All Sections

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    final data = await DatabaseService.getFinanceData();
    setState(() {
      _totalIncome = data['total_income'] ?? 0.0;
      _totalExpenses = data['total_expenses'] ?? 0.0;
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
      result = amountStr[i] + result;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
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

              // Quick Navigation Chips
              if (!_showManagementView)
                _buildQuickNavigationChips(),

              const SizedBox(height: 25),

              // 🎤 MIC CONTAINER
              GestureDetector(
                onTap: () async {
                  if (!_isListening) {
                    final started = await _speechService.startListening();
                    if (!started) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Unable to start listening",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _isListening = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Listening..."),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // Second tap: stop listening and process
                  final banglaText = await _speechService.stopListening();
                  setState(() {
                    _isListening = false;
                  });
                  debugPrint("Bangla Text: $banglaText");

                  if (banglaText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Recording unsuccessful, please try again",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Recorded successfully",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  final englishText = await _translationService
                      .translateToEnglish(banglaText);
                  debugPrint("English Text: $englishText");

                  final gptJson = await GPTService.sendToGPT(englishText);
                  debugPrint("GPT JSON:");
                  debugPrint(gptJson.toString());

                  final confirmed = await _showGptConfirmationDialog(
                    context,
                    banglaText: banglaText,
                    englishText: englishText,
                    gptJson: gptJson,
                  );

                  if (confirmed) {
                    await FinanceProcessor.processGptResult(
                      gptJson: gptJson,
                      englishText: englishText,
                    );
                    await _loadFinanceData();
                  }
                },

                child: Container(
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
                      const SizedBox(height: 4),
                      if (_isListening)
                        const Text(
                          "Listening... tap again to stop",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      const SizedBox(height: 18),
                      CircleAvatar(
                        radius: _isListening ? 40 : 35,
                        backgroundColor: _isListening
                            ? AppColors.accentOrange
                            : AppColors.primaryBrown,
                        child: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Example inputs:",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sold 2 idols to Behala Samity for ₹10,000",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const Text(
                        "Paid ₹500 for paints at Shyambazar shop",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Total Income Card
              _buildFinancialCard(
                icon: Icons.account_balance_wallet,
                title: "Total Income",
                amount: "₹ ${_formatCurrency(_totalIncome)}",
                changePercent: "3%",
                isPositive: true,
                iconBackground: AppColors.cardCream,
              ),

              const SizedBox(height: 15),

              // Total Expenses Card
              _buildFinancialCard(
                icon: Icons.shopping_basket,
                title: "Total Expenses",
                amount: "₹ ${_formatCurrency(_totalExpenses)}",
                changePercent: "3%",
                isPositive: false,
                iconBackground: AppColors.cardCream,
              ),

              const SizedBox(height: 15),

              // Current Balance Card
              _buildFinancialCard(
                icon: Icons.account_balance,
                title: "Current Balance",
                amount: "₹ ${_formatCurrency(_currentBalance)}",
                changePercent: null,
                isPositive: true,
                iconBackground: AppColors.cardCream,
              ),

              const SizedBox(height: 30),

              // Finance Navigation Grid
              const Text(
                "Finance Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Material Tracker
                  _buildFinanceCard(
                    icon: Icons.category,
                    title: "Material Tracker",
                    subtitle: "Track material costs and trends",
                    onTap: () {
                      context.go('/finance/materials');
                    },
                  ),
                  
                  // Samiti Funds
                  _buildFinanceCard(
                    icon: Icons.account_balance_wallet,
                    title: "Samiti Funds",
                    subtitle: "Manage community fund sources",
                    onTap: () {
                      context.go('/finance/samiti-funds');
                    },
                  ),

                  // Worker Funds
                  _buildFinanceCard(
                    icon: Icons.people,
                    title: "Worker Funds",
                    subtitle: "Track worker payments and budgets",
                    onTap: () {
                      context.go('/finance/worker-funds');
                    },
                  ),

                  // Worker Details
                  _buildFinanceCard(
                    icon: Icons.person,
                    title: "Worker Details",
                    subtitle: "View and manage worker information",
                    onTap: () {
                      context.go('/finance/worker-details', extra: {
                        'name': 'Ramesh',
                        'category': 'Durga Idol / Claymaking',
                        'budget': '25000',
                        'paid': '12000'
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Tabs for Pending Payments and Upcoming Deliveries
              Row(
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
                            width: 120,
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
                            width: 140,
                            color: AppColors.primaryBrown,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Pending Payments List
              if (_selectedTab == 0) _buildPendingPaymentList(),
              if (_selectedTab == 1) _buildUpcomingDeliveriesList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showGptConfirmationDialog(
    BuildContext context, {
    required String banglaText,
    required String englishText,
    required Map<String, dynamic> gptJson,
  }) async {
    String asString(dynamic value) => value == null ? 'null' : value.toString();

    Widget buildField(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
          ],
        ),
      );
    }

    final intent = gptJson['intent'];
    final amount = gptJson['amount'];
    final category = gptJson['category'];
    final name = gptJson['name'] ?? gptJson['worker_name'];
    final workerType = gptJson['worker_type'];
    final idolType = gptJson['idol_type'];
    final confidence = gptJson['confidence'];

    final otherFields = <Widget>[];
    gptJson.forEach((key, value) {
      if (key == 'intent' ||
          key == 'amount' ||
          key == 'category' ||
          key == 'name' ||
          key == 'worker_name' ||
          key == 'worker_type' ||
          key == 'idol_type' ||
          key == 'confidence') {
        return;
      }
      otherFields.add(buildField(key.toString(), asString(value)));
    });

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm transaction'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bengali text block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6D3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🗣 Bengali Text",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(banglaText),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // English text block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6D3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🌍 English Text",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(englishText),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Classified result block with pill header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0C2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Classified Result",
                          style: TextStyle(
                            color: Color(0xFF8B4513),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (intent != null)
                        buildField("Intent", asString(intent)),
                      if (name != null) buildField("Name", asString(name)),
                      if (amount != null)
                        buildField("Amount", asString(amount)),
                      if (category != null)
                        buildField("Category", asString(category)),
                      if (workerType != null)
                        buildField("Worker Type", asString(workerType)),
                      if (idolType != null)
                        buildField("Idol Type", asString(idolType)),
                      if (confidence != null)
                        buildField("Confidence", asString(confidence)),
                      if (otherFields.isNotEmpty) const SizedBox(height: 8),
                      ...otherFields,
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("❌ NO, DISCARD"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("✅ YES, THIS IS CORRECT"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget _buildFinancialCard({
    required IconData icon,
    required String title,
    required String amount,
    String? changePercent,
    required bool isPositive,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBrown, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (changePercent != null)
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        changePercent,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentList() {
    // Get clients with pending amounts
    final pendingClients = DummyData.clients.where((client) => client.pendingAmount > 0).toList();

    if (pendingClients.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            "No pending payments",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
        ),
      );
    }

    return Column(
      children: pendingClients.map((client) {
        return Column(
          children: [
            _buildPendingPaymentItem(
              name: client.name,
              amount: client.pendingAmount,
              delay: "Pending payment"
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPendingPaymentItem({
    required String name,
    required double amount,
    required String delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.cardCream,
            child: Icon(Icons.person, color: AppColors.primaryBrown),
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
                Text(
                  "₹${amount.toStringAsFixed(0)} - $delay",
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.check, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text(
                  "Mark as completed",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeliveriesList() {
    // Get all upcoming deliveries from clients
    final now = DateTime.now();
    final upcomingDeliveries = <Map<String, dynamic>>[];

    for (final client in DummyData.clients) {
      for (final idol in client.idols) {
        if (idol.deliveryDate.isAfter(now)) {
          upcomingDeliveries.add({
            'clientName': client.name,
            'idolName': idol.name,
            'deliveryDate': idol.deliveryDate,
            'status': idol.status,
          });
        }
      }
    }

    // Sort by delivery date
    upcomingDeliveries.sort((a, b) => a['deliveryDate'].compareTo(b['deliveryDate']));

    if (upcomingDeliveries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            "No upcoming deliveries",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
        ),
      );
    }

    return Column(
      children: upcomingDeliveries.map((delivery) {
        return Column(
          children: [
            _buildUpcomingDeliveryItem(
              clientName: delivery['clientName'],
              idolName: delivery['idolName'],
              deliveryDate: delivery['deliveryDate'],
              status: delivery['status'],
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingDeliveryItem({
    required String clientName,
    required String idolName,
    required DateTime deliveryDate,
    required String status,
  }) {
    final now = DateTime.now();
    final daysLeft = deliveryDate.difference(now).inDays;
    final dateStr = '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.cardCream,
            child: Icon(Icons.inventory, color: AppColors.primaryBrown),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$idolName - $clientName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$dateStr (${daysLeft > 0 ? '$daysLeft days left' : 'Overdue'})',
                  style: TextStyle(
                    fontSize: 14,
                    color: daysLeft > 0 ? AppColors.primaryBrown : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return AppColors.primaryBrown;
      case 'pending':
        return AppColors.accentOrange;
      case '2 day delay':
        return Colors.red;
      default:
        return AppColors.textLight;
    }
  }

  // Quick Navigation Chips
  Widget _buildQuickNavigationChips() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickChip(
            label: "Dashboard",
            isSelected: !_showManagementView,
            onTap: () {
              setState(() {
                _showManagementView = false;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: "All Sections",
            isSelected: _showManagementView,
            onTap: () {
              setState(() {
                _showManagementView = true;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: "Materials",
            isSelected: false,
            onTap: () {
              context.go('/finance/materials');
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: "Samiti Funds",
            isSelected: false,
            onTap: () {
              context.go('/finance/samiti-funds');
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: "Worker Funds",
            isSelected: false,
            onTap: () {
              context.go('/finance/worker-funds');
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: "Worker Details",
            isSelected: false,
            onTap: () {
              context.go('/finance/worker-details');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentOrange : AppColors.cardCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentOrange : AppColors.textLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Compact Financial Summary Cards for Management View
  Widget _buildCompactFinancialCards() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactFinancialCard(
            icon: Icons.account_balance_wallet,
            title: "Income",
            amount: "₹ ${_formatCurrency(_totalIncome)}",
            color: Colors.green.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactFinancialCard(
            icon: Icons.shopping_basket,
            title: "Expenses",
            amount: "₹ ${_formatCurrency(_totalExpenses)}",
            color: Colors.red.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFinancialCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryBrown),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Finance Navigation Card Widget
  Widget _buildFinanceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: AppColors.primaryBrown),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
