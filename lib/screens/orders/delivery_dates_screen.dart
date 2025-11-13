import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';

class DeliveryDatesScreen extends StatefulWidget {
  final String clientName;

  const DeliveryDatesScreen({Key? key, required this.clientName})
      : super(key: key);

  @override
  State<DeliveryDatesScreen> createState() => _DeliveryDatesScreenState();
}

class _DeliveryDatesScreenState extends State<DeliveryDatesScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;

  final List<Map<String, String>> _deliveryOrders = [
    {
      'name': 'Ganesh Idol',
      'date': 'Oct 26, 2024',
    },
    {
      'name': 'Durga Idol',
      'date': 'Oct 26, 2024',
    },
  ];

  void _addDeliveryDate() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery Date Added'),
        content: Text(
          'Delivery scheduled for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        title: Text(widget.clientName),
      ),
      body: SingleChildScrollView(
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

            if (_showCalendar)
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
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
                    weekendTextStyle: TextStyle(
                      color: AppColors.warningRed,
                    ),
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
            const SizedBox(height: AppConstants.largePadding),

            const Text(
              'Scheduled Deliveries',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            ..._deliveryOrders.map((order) => _buildDeliveryOrderCard(order)),
            const SizedBox(height: AppConstants.largePadding),

            CustomButton(
              label: 'Add delivery date',
              icon: Icons.calendar_today_outlined,
              onPressed: () {
                setState(() {
                  _showCalendar = !_showCalendar;
                });
                if (!_showCalendar) {
                  _addDeliveryDate();
                }
              },
              backgroundColor: AppColors.primaryBrown,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.mediumPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown,
                borderRadius:
                    BorderRadius.circular(AppConstants.largeRadius),
              ),
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎙️ Recording delivery details...'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
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
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
        },
      ),
    );
  }

  Widget _buildDeliveryOrderCard(Map<String, String> order) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order['name']!,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order['date']!,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
            color: AppColors.primaryBrown,
          ),
        ],
      ),
    );
  }
}
