import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/speech_service.dart';
import '../../utils/colors.dart';
import '../../services/translation_service.dart';
import '../../services/gpt_service.dart';
import '../../services/database_service.dart';
import '../../services/finance_processor.dart';
import '../../utils/dummy_data.dart';
import '../../services/language_service.dart';
import '../../widgets/language_toggle_action.dart';

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

  Future<void> _handleCapturedSpeech(String banglaText) async {
    debugPrint("Bangla: $banglaText");
    final englishText =
        await _translationService.translateToEnglish(banglaText);
    debugPrint("English: $englishText");
    final gptJson = await GPTService.sendToGPT(englishText);
    debugPrint("GPT JSON: $gptJson");
    if (!mounted) return;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction recorded."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
    final lang = context.watch<LanguageService>();
    final size = MediaQuery.of(context).size;
    final horizontalPad = size.width * 0.05;
    final verticalPad = size.height * 0.012;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) context.go('/main');
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad.clamp(16.0, 24.0),
            vertical: verticalPad.clamp(8.0, 16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go('/main'),
                          tooltip: 'Back to Modules',
                        ),
                        SizedBox(width: size.width * 0.02),
                        Flexible(
                          child: Text(
                            lang.getText('finance'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LanguageToggleAction(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings, size: size.width * 0.065),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.01),
              Text(
                lang.getText('hello_artisan'),
                style: TextStyle(
                  fontSize: (size.width * 0.065).clamp(20.0, 28.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.028),
              if (!_showManagementView) _buildQuickNavigationChips(),
              SizedBox(height: size.height * 0.028),

              // 🎤 MIC CONTAINER — first tap START, second tap STOP → capture → translate → GPT → confirm
              GestureDetector(
                onTap: () async {
                  if (!_speechService.isListening) {
                    final started = await _speechService.startListening();
                    if (mounted) setState(() {});
                    if (!started) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not start listening."),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return;
                    }
                    return;
                  }
                  final banglaText = await _speechService.stopListening();
                  if (mounted) setState(() {});

                  if (banglaText.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No speech detected. Try again."),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    return;
                  }
                  await _handleCapturedSpeech(banglaText);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = MediaQuery.of(context).size;
                    final pad = size.width * 0.06;
                    final radius = size.width * 0.06;
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(pad.clamp(16.0, 28.0)),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang.getText('record_voice_note'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.008),
                          Text(
                            _speechService.isListening
                                ? lang.getText('tap_again_to_stop')
                                : lang.getText('tap_to_record'),
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.02),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _speechService.isListening
                                  ? Colors.orange.shade100
                                  : AppColors.primaryBrown,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _speechService.isListening
                                  ? Icons.graphic_eq
                                  : Icons.mic,
                              color: _speechService.isListening
                                  ? Colors.orange
                                  : Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            lang.getText('example_inputs'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            "Sold 2 idols to Behala Samity for ₹10,000",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Paid ₹500 for paints at Shyambazar shop",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // Total Income Card
              _buildFinancialCard(
                icon: Icons.account_balance_wallet,
                title: lang.getText('total_income'),
                amount: "₹ ${_formatCurrency(_totalIncome)}",
                changePercent: "3%",
                isPositive: true,
                iconBackground: AppColors.cardCream,
              ),

              const SizedBox(height: 15),

              // Total Expenses Card
              _buildFinancialCard(
                icon: Icons.shopping_basket,
                title: lang.getText('total_expenses'),
                amount: "₹ ${_formatCurrency(_totalExpenses)}",
                changePercent: "3%",
                isPositive: false,
                iconBackground: AppColors.cardCream,
              ),

              const SizedBox(height: 15),

              // Current Balance Card
              _buildFinancialCard(
                icon: Icons.account_balance,
                title: lang.getText('current_balance'),
                amount: "₹ ${_formatCurrency(_currentBalance)}",
                changePercent: null,
                isPositive: true,
                iconBackground: AppColors.cardCream,
              ),

              const SizedBox(height: 30),

              // Finance Navigation Grid
              Text(
                lang.getText('finance_management'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFinanceCard(
                    icon: Icons.category,
                    title: lang.getText('material_tracker'),
                    subtitle: lang.getText('material_tracker_subtitle'),
                    onTap: () => context.go('/finance/materials'),
                  ),
                  _buildFinanceCard(
                    icon: Icons.account_balance_wallet,
                    title: lang.getText('samiti_funds'),
                    subtitle: lang.getText('samiti_funds_subtitle'),
                    onTap: () => context.go('/finance/samiti-funds'),
                  ),
                  _buildFinanceCard(
                    icon: Icons.people,
                    title: lang.getText('worker_funds'),
                    subtitle: lang.getText('worker_funds_subtitle'),
                    onTap: () => context.go('/finance/worker-funds'),
                  ),
                  _buildFinanceCard(
                    icon: Icons.person,
                    title: lang.getText('worker_details'),
                    subtitle: lang.getText('worker_details_subtitle'),
                    onTap: () => context.go('/finance/worker-details', extra: {
                      'name': 'Ramesh',
                      'category': 'Durga Idol / Claymaking',
                      'budget': '25000',
                      'paid': '12000'
                    }),
                  ),
                  _buildFinanceCard(
                    icon: Icons.bar_chart,
                    title: lang.getText('financial_reports'),
                    subtitle: lang.getText('financial_reports_subtitle'),
                    onTap: () => context.go('/finance/reports'),
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
                          lang.getText('pending_payments'),
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
                          lang.getText('upcoming_deliveries'),
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
    final size = MediaQuery.of(context).size;
    final iconSize = (size.width * 0.12).clamp(44.0, 56.0);
    final pad = (size.width * 0.04).clamp(12.0, 20.0);
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(size.width * 0.03),
            ),
            child: Icon(icon, color: AppColors.primaryBrown, size: iconSize * 0.55),
          ),
          SizedBox(width: pad),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            context.read<LanguageService>().getText('no_pending_payments'),
            style: const TextStyle(fontSize: 16, color: AppColors.textLight),
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Mark as completed",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            context.read<LanguageService>().getText('no_upcoming_deliveries'),
            style: const TextStyle(fontSize: 16, color: AppColors.textLight),
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
            label: context.read<LanguageService>().getText('dashboard_tab'),
            isSelected: !_showManagementView,
            onTap: () {
              setState(() {
                _showManagementView = false;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: context.read<LanguageService>().getText('all_sections_tab'),
            isSelected: _showManagementView,
            onTap: () {
              setState(() {
                _showManagementView = true;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            label: context.read<LanguageService>().getText('materials_tab'),
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

  // Compact Financial Summary Cards for Management View (used when showing management view)
  // ignore: unused_element
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

  // Finance Navigation Card Widget — no fixed height; Expanded + maxLines to avoid overflow
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: AppColors.primaryBrown),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
