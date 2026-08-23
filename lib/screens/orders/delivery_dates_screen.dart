import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/database_service.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';

class DeliveryDatesScreen extends StatefulWidget {
  final String clientId;

  const DeliveryDatesScreen({super.key, required this.clientId});

  @override
  State<DeliveryDatesScreen> createState() => _DeliveryDatesScreenState();
}

class _DeliveryDatesScreenState extends State<DeliveryDatesScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;
  bool _isLoading = true;
  int? _activeOrderId;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await DatabaseService.getOrdersByCustomerName(widget.clientId);
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
          SnackBar(content: Text('Failed to load orders: $e')),
        );
      }
    }
  }

  void _openCalendarFor(int orderId) {
    setState(() {
      _activeOrderId = orderId;
      _showCalendar = true;
      _selectedDay = null;
    });
  }

  Future<void> _confirmDeliveryDate() async {
    if (_selectedDay == null || _activeOrderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    try {
      await DatabaseService.updateOrder(
        id: _activeOrderId!,
        deliveryDate: _selectedDay!.toIso8601String(),
      );
      if (!mounted) return;
      setState(() => _showCalendar = false);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delivery Date Updated'),
          content: Text(
            'Delivery scheduled for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update delivery date: $e')),
        );
      }
    }
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

  Future<void> _recordWithVoice() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listening...')),
    );
    try {
      final banglaText = await SpeechService().listenBangla();
      if (!mounted) return;
      if (banglaText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No speech detected')),
        );
        return;
      }
      final englishText = await TranslationService().translateToEnglish(banglaText);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recognized: $englishText')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition failed: $e')),
        );
      }
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'No date set';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'No date set';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.clientId),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Dates',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeHeading,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  if (_showCalendar) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.mediumPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 730)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primaryBrown,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: TextStyle(color: AppColors.warningRed),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),
                    CustomButton(
                      label: 'Confirm date',
                      icon: Icons.check,
                      onPressed: _confirmDeliveryDate,
                      backgroundColor: AppColors.primaryBrown,
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                  ],

                  const Text(
                    'Scheduled Deliveries',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  if (_orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No orders found for this client.',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    )
                  else
                    ..._orders.map((order) => _buildDeliveryOrderCard(order)),
                  const SizedBox(height: AppConstants.largePadding),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.mediumPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrown,
                      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                    ),
                    child: TextButton.icon(
                      onPressed: _recordWithVoice,
                      icon: const Icon(Icons.mic, color: Colors.white),
                      label: const Text(
                        'Record with voice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeBody,
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

  Widget _buildDeliveryOrderCard(Map<String, dynamic> order) {
    final delivered = (order['delivered'] as int? ?? 0) == 1;
    final id = order['id'] as int;
    final idolName = (order['idol_name'] as String?)?.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idolName != null && idolName.isNotEmpty ? idolName : 'Idol order',
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  delivered ? 'Delivered' : _formatDate(order['delivery_date']),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: delivered ? AppColors.successGreen : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (!delivered) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openCalendarFor(id),
              color: AppColors.primaryBrown,
              tooltip: 'Change delivery date',
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => _markDelivered(id),
              color: AppColors.successGreen,
              tooltip: 'Mark as delivered',
            ),
          ],
        ],
      ),
    );
  }
}
