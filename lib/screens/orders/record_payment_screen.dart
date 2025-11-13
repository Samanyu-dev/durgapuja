import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String clientName;

  const RecordPaymentScreen({Key? key, required this.clientName})
      : super(key: key);

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedPaymentMethod;
  bool _isRecording = false;
  DateTime? _selectedDate;

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'UPI',
    'Cheque',
    'Other'
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _confirmPayment() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select payment method')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Confirmed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${_amountController.text}'),
            Text('Date: ${_dateController.text}'),
            Text('Method: $_selectedPaymentMethod'),
            Text('Client: ${widget.clientName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
              'Record Payment',
              style: TextStyle(
                fontSize: AppConstants.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            const Text(
              'Amount received',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '₹ ',
                filled: true,
                fillColor: AppColors.cardCream,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.all(AppConstants.mediumPadding),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎙️ Recording amount...'),
                      ),
                    );
                  },
                ),
              ),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            const Text(
              'Date of payment',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                hintText: 'Select date',
                filled: true,
                fillColor: AppColors.cardCream,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.all(AppConstants.mediumPadding),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            const Text(
              'Payment method',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: DropdownButton<String>(
                value: _selectedPaymentMethod,
                hint: const Text('Select method'),
                isExpanded: true,
                underline: const SizedBox(),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            const Text(
              'Or use a quick option',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBody,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.mediumPadding,
              ),
              decoration: BoxDecoration(
                color: _isRecording
                    ? AppColors.warningRed
                    : AppColors.primaryBrown,
                borderRadius:
                    BorderRadius.circular(AppConstants.largeRadius),
              ),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isRecording = !_isRecording;
                  });
                  if (_isRecording) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎙️ Recording payment details...'),
                      ),
                    );
                  }
                },
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
                label: Text(
                  _isRecording ? 'Stop Recording' : 'Record with voice',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            CustomButton(
              label: 'Confirm Payment',
              onPressed: _confirmPayment,
              backgroundColor: AppColors.primaryBrown,
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

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
