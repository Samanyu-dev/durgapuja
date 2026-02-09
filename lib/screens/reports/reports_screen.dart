import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../services/database_service.dart';
import '../../services/language_service.dart';
import '../../widgets/language_toggle_action.dart';

class ReportsScreen extends StatefulWidget {
  final bool showBottomNav;

  const ReportsScreen({super.key, this.showBottomNav = true});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedTimeframe =
      "Last 6 months"; // Last 6 months, Last year, All years
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double get _totalProfit => _totalIncome - _totalExpenses;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
    _loadRecentTransactions();
  }

  Future<void> _loadFinanceData() async {
    final data = await DatabaseService.getFinanceData();
    if (mounted) {
      setState(() {
        _totalIncome = data['total_income'] ?? 0.0;
        _totalExpenses = data['total_expenses'] ?? 0.0;
      });
    }
  }

  Future<void> _loadRecentTransactions() async {
    final list = await DatabaseService.getRecentTransactions(limit: 3);
    if (mounted) {
      setState(() => _recentTransactions = list);
    }
  }

  Future<void> _undoTransaction(int id) async {
    try {
      await DatabaseService.undoTransaction(id);
      await _loadFinanceData();
      await _loadRecentTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction undone'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Undo failed: $e'),
            backgroundColor: Colors.red,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) context.go('/finance/dashboard');
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/finance/dashboard'),
          ),
          title: Text(lang.getText('profits')),
          actions: const [
            LanguageToggleAction(),
          ],
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Section
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.getText('total_income'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${_formatCurrency(_totalIncome)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          Text(
                            lang.getText('total_expenses'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${_formatCurrency(_totalExpenses)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Total Profit Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('total_profit'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${_formatCurrency(_totalProfit)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Recent Transactions Section (latest 3 from DB)
              Text(
                lang.getText('recent_transactions'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              if (_recentTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    lang.getText('no_transactions'),
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                )
              else
                ..._recentTransactions.map((t) {
                  final id = t['id'] as int?;
                  if (id == null) return const SizedBox.shrink();
                  final type = t['type'] as String? ?? 'other';
                  final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                  final desc = t['source_text'] as String? ?? '';
                  final createdAt = t['created_at'] as String? ?? '';
                  final amountColor = (type == 'income') ? Colors.green : Colors.red;
                  final displayIntent = type.replaceAll('_', ' ');
                  final dateStr = createdAt.length >= 10
                      ? createdAt.substring(0, 10)
                      : createdAt;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRecentTransactionItem(
                      id: id,
                      intent: displayIntent,
                      amount: amount,
                      description: desc,
                      dateStr: dateStr,
                      amountColor: amountColor,
                      onUndo: _undoTransaction,
                    ),
                  );
                }),

              const SizedBox(height: 30),

              // Project Profits Section
              Text(
                lang.getText('project_profits'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 15),

              // Time Filter Buttons
              Row(
                children: [
                  Expanded(child: _buildTimeFilterButton(lang.getText('last_6_months'))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeFilterButton(lang.getText('last_year'))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeFilterButton(lang.getText('all_years'))),
                ],
              ),

              const SizedBox(height: 25),

              // Bar Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: _getProjectProfitsData().map((project) {
                    return Column(
                      children: [
                        _buildBarChartItem(
                          project['name'],
                          project['value'],
                          project['color'],
                          isSelected: project['selected'] ?? false,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Material Expenses Section
              Text(
                lang.getText('material_expenses'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 15),

              // Material Expenses Bar Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildBarChartItem(
                      "Clay",
                      125000,
                      AppColors.primaryBrown,
                      barWidth: 1.0,
                    ),
                    const SizedBox(height: 20),
                    _buildBarChartItem(
                      "Ornaments",
                      25000,
                      AppColors.accentOrange,
                      barWidth: 0.25,
                    ),
                    const SizedBox(height: 20),
                    _buildBarChartItem(
                      "Paint",
                      40000,
                      AppColors.primaryBrown,
                      barWidth: 0.40,
                    ),
                    const SizedBox(height: 20),
                    _buildBarChartItem(
                      "Clothes",
                      45000,
                      AppColors.primaryBrown,
                      barWidth: 0.45,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Transactions Section
              Text(
                lang.getText('transactions'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 15),

              // Transaction Items
              _buildTransactionItem(
                '${lang.getText('payment_from_samiti')} 1',
                "Oct 15",
                "+ ₹16,000",
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildTransactionItem(
                lang.getText('purchase_of_clay'),
                "Oct 15",
                "- ₹16,000",
                Colors.red,
              ),

              const SizedBox(height: 30),

              // Detailed Reports Section
              Text(
                lang.getText('detailed_reports'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 15),

              // Report List Items
              _buildReportItem(lang.getText('durga_puja_idols'), "+₹16,000", Colors.green),
              const SizedBox(height: 12),
              _buildReportItem(lang.getText('durga_puja_idols'), "+₹16,000", Colors.green),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildRecentTransactionItem({
    required int id,
    required String intent,
    required double amount,
    required String description,
    required String dateStr,
    required Color amountColor,
    required Future<void> Function(int id) onUndo,
  }) {
    final amountStr = amountColor == Colors.green
        ? '+ ₹${_formatCurrency(amount)}'
        : '- ₹${_formatCurrency(amount)}';
    final shortDesc =
        description.isEmpty ? intent : (description.length > 40 ? '${description.substring(0, 40)}...' : description);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intent,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortDesc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amountStr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => onUndo(id),
                icon: const Icon(Icons.undo, size: 18),
                label: Text(context.read<LanguageService>().getText('undo')),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterButton(String label) {
    final isSelected = _selectedTimeframe == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrown : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryBrown : AppColors.cardCream,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartItem(
    String label,
    int value,
    Color color, {
    bool isSelected = false,
    double? barWidth,
  }) {
    // Use provided barWidth or calculate from value based on timeframe
    final maxValue = _getMaxValueForTimeframe();
    final widthFactor = barWidth ?? (value / maxValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              _formatCurrencyWithSymbol(value),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
            ),
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 8,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  int _getMaxValueForTimeframe() {
    switch (_selectedTimeframe) {
      case "Last 6 months":
        return 125000;
      case "Last year":
        return 300000;
      case "All years":
        return 500000;
      default:
        return 125000;
    }
  }

  List<Map<String, dynamic>> _getProjectProfitsData() {
    switch (_selectedTimeframe) {
      case "Last 6 months":
        return [
          {'name': 'Saraswati P.', 'value': 125000, 'color': AppColors.primaryBrown, 'selected': false},
          {'name': 'Durga P.', 'value': 25000, 'color': AppColors.accentOrange, 'selected': false},
          {'name': 'Ganesha P.', 'value': 40000, 'color': AppColors.primaryBrown, 'selected': true},
          {'name': 'Diwali', 'value': 45000, 'color': AppColors.primaryBrown, 'selected': false},
        ];
      case "Last year":
        return [
          {'name': 'Saraswati P.', 'value': 280000, 'color': AppColors.primaryBrown, 'selected': false},
          {'name': 'Durga P.', 'value': 120000, 'color': AppColors.accentOrange, 'selected': false},
          {'name': 'Ganesha P.', 'value': 95000, 'color': AppColors.primaryBrown, 'selected': true},
          {'name': 'Diwali', 'value': 110000, 'color': AppColors.primaryBrown, 'selected': false},
        ];
      case "All years":
        return [
          {'name': 'Saraswati P.', 'value': 450000, 'color': AppColors.primaryBrown, 'selected': false},
          {'name': 'Durga P.', 'value': 320000, 'color': AppColors.accentOrange, 'selected': false},
          {'name': 'Ganesha P.', 'value': 280000, 'color': AppColors.primaryBrown, 'selected': true},
          {'name': 'Diwali', 'value': 350000, 'color': AppColors.primaryBrown, 'selected': false},
        ];
      default:
        return [
          {'name': 'Saraswati P.', 'value': 125000, 'color': AppColors.primaryBrown, 'selected': false},
          {'name': 'Durga P.', 'value': 25000, 'color': AppColors.accentOrange, 'selected': false},
          {'name': 'Ganesha P.', 'value': 40000, 'color': AppColors.primaryBrown, 'selected': true},
          {'name': 'Diwali', 'value': 45000, 'color': AppColors.primaryBrown, 'selected': false},
        ];
    }
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    Color amountColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Implement undo functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction undone')),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Undo'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  // Parse the amount string to determine if income or expense
                  final amountStr = amount.replaceAll('₹', '').replaceAll(',', '');
                  final isIncome = amountColor == Colors.green;
                  final transactionAmount = double.tryParse(amountStr.replaceAll('+ ', '').replaceAll('- ', '')) ?? 0.0;

                  try {
                    if (isIncome) {
                      await DatabaseService.updateIncome(transactionAmount);
                    } else {
                      await DatabaseService.updateExpenses(transactionAmount);
                    }

                    // Refresh the finance data
                    await _loadFinanceData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction confirmed successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error confirming transaction: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrencyWithSymbol(int value) {
    // Format as Indian numbering system: 1,25,000 (last 3 digits, then groups of 2)
    final String valueStr = value.toString();
    if (valueStr.length <= 3) {
      return "₹$valueStr";
    }

    List<String> parts = [];
    // Take last 3 digits
    if (valueStr.length > 3) {
      parts.add(valueStr.substring(valueStr.length - 3));
      // Take remaining digits in groups of 2 from right
      int remaining = valueStr.length - 3;
      for (int i = remaining - 2; i >= 0; i -= 2) {
        int start = i < 0 ? 0 : i;
        int end = i + 2 > remaining ? remaining : i + 2;
        parts.insert(0, valueStr.substring(start, end));
      }
    } else {
      parts.add(valueStr);
    }

    return "₹${parts.join(',')}";
  }
}
