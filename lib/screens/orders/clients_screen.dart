import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../services/database_service.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';
import 'client_options_screen.dart';
import 'client_chat_screen.dart';
import 'record_payment_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 for Pending Payments, 1 for Upcoming Deliveries
  bool _isLoading = true;
  bool _isListening = false;
  List<Map<String, dynamic>> _orders = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await DatabaseService.getOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load clients: $e')),
        );
      }
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool _matchesSearch(Map<String, dynamic> order) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    final name = (order['customer_name'] as String? ?? '').toLowerCase();
    final idol = (order['idol_name'] as String? ?? '').toLowerCase();
    return name.contains(query) || idol.contains(query);
  }

  List<Map<String, dynamic>> get _pendingPayments {
    return _orders.where((o) {
      final amount = (o['amount_received'] as num?) ?? 0;
      return amount <= 0 && _matchesSearch(o);
    }).toList();
  }

  List<Map<String, dynamic>> get _upcomingDeliveries {
    final list = _orders.where((o) {
      final delivered = (o['delivered'] as int? ?? 0) == 1;
      final date = _parseDate(o['delivery_date']);
      return !delivered && date != null && _matchesSearch(o);
    }).toList();
    list.sort((a, b) {
      final da = _parseDate(a['delivery_date'])!;
      final db = _parseDate(b['delivery_date'])!;
      return da.compareTo(db);
    });
    return list;
  }

  int _countDueWithin(int daysFromNow) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + daysFromNow);
    return _orders.where((o) {
      final delivered = (o['delivered'] as int? ?? 0) == 1;
      final date = _parseDate(o['delivery_date']);
      if (delivered || date == null) return false;
      final d = DateTime(date.year, date.month, date.day);
      return d == target;
    }).length;
  }

  int get _totalUpcoming {
    return _orders.where((o) {
      final delivered = (o['delivered'] as int? ?? 0) == 1;
      return !delivered && _parseDate(o['delivery_date']) != null;
    }).length;
  }

  Future<void> _startVoiceSearch() async {
    setState(() => _isListening = true);
    try {
      final banglaText = await SpeechService().listenBangla();
      if (banglaText.isNotEmpty) {
        final englishText = await TranslationService().translateToEnglish(banglaText);
        setState(() {
          _searchController.text = englishText;
          _searchQuery = englishText;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice search failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isListening = false);
    }
  }

  Future<void> _openClientOptions(String clientName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientOptionsScreen(clientName: clientName),
      ),
    );
    _loadOrders();
  }

  Future<void> _openChat(String clientId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientChatScreen(clientId: clientId),
      ),
    );
  }

  Future<void> _recordPayment(String clientId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordPaymentScreen(clientId: clientId),
      ),
    );
    _loadOrders();
  }

  Future<void> _markDelivered(int orderId) async {
    try {
      await DatabaseService.markOrderDelivered(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as delivered')),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update delivery status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOrders,
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Search clients or idols",
                            hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? AppColors.primaryBrown : Colors.black54,
                        ),
                        onPressed: _isListening ? null : _startVoiceSearch,
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
                            "${_countDueWithin(0)}",
                            "Due Today",
                            isHighlighted: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard("${_countDueWithin(1)}", "Due Tomorrow"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard("$_totalUpcoming", "Total Upcoming"),
                        ),
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
                      onTap: () => setState(() => _selectedTab = 0),
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
                      onTap: () => setState(() => _selectedTab = 1),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                onPressed: () async {
                                  await context.push('/finance/orders/add-client');
                                  _loadOrders();
                                },
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
    final pending = _pendingPayments;
    if (pending.isEmpty) {
      return [_buildEmptyState('No pending payments')];
    }
    return pending.map((order) {
      final name = order['customer_name'] as String? ?? 'Unknown';
      final idolName = order['idol_name'] as String?;
      return _buildPendingPaymentCard(
        name: name,
        subtitle: idolName != null && idolName.isNotEmpty ? idolName : 'No payment recorded',
      );
    }).toList();
  }

  List<Widget> _buildUpcomingDeliveriesList() {
    final deliveries = _upcomingDeliveries;
    if (deliveries.isEmpty) {
      return [_buildEmptyState('No upcoming deliveries')];
    }
    return deliveries.map((order) {
      final name = order['customer_name'] as String? ?? 'Unknown';
      final date = _parseDate(order['delivery_date'])!;
      final daysLeft = date.difference(DateTime.now()).inDays;
      final id = order['id'] as int;
      String label;
      if (daysLeft <= 0) {
        label = 'Due today';
      } else if (daysLeft == 1) {
        label = 'in 1 day';
      } else {
        label = 'in $daysLeft days';
      }
      return _buildUpcomingDeliveryCard(name: name, daysLeft: label, orderId: id);
    }).toList();
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        message,
        style: const TextStyle(fontSize: 15, color: AppColors.textLight),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPendingPaymentCard({
    required String name,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () => _openClientOptions(name),
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
                        subtitle,
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                  onPressed: () => _openChat(name),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _recordPayment(name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardCream,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Record Payment",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
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
    required int orderId,
  }) {
    return GestureDetector(
      onTap: () => _openClientOptions(name),
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
                  onPressed: () => _openChat(name),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markDelivered(orderId),
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
}
