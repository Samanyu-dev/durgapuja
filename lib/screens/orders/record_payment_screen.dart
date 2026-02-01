import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String clientId;

  const RecordPaymentScreen({super.key, required this.clientId});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();
  final TextEditingController _amountController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _dateController = TextEditingController();
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;
  String? _signatureFileName;

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'UPI',
    'Cheque',
    'Other',
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _confirmPayment() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter amount')));
      return;
    }

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select date')));
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
            Text('Client: ${widget.clientId}'),
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

  void _showVoiceNoteRecheckDialog(String banglaText, String englishText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Note Recheck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recognized Bangla Text:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(banglaText),
            const SizedBox(height: 16),
            const Text(
              'Translated English Text:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(englishText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement re-record functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please record again')),
              );
            },
            child: const Text('Recheck'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Process the voice note (e.g., extract payment info)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice note confirmed')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_speechService.isListening) {
            final started = await _speechService.startListening();
            if (mounted) setState(() {});
            if (!started) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not start listening')),
                );
              }
            }
            return;
          }
          final banglaText = await _speechService.stopListening();
          if (mounted) setState(() {});
          if (banglaText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No speech detected. Try again.')),
            );
            return;
          }
          debugPrint("Bangla: $banglaText");
          final englishText =
              await _translationService.translateToEnglish(banglaText);
          debugPrint("English: $englishText");
          _showVoiceNoteRecheckDialog(banglaText, englishText);
        },
        backgroundColor: _speechService.isListening ? Colors.orange : AppColors.primaryBrown,
        child: Icon(
          _speechService.isListening ? Icons.graphic_eq : Icons.mic,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.018,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.clientId,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Record Payment',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 30),

              // Amount received
              const Text(
                'Amount received',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEDFD0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('₹ ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "0.00",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Date of payment
              const Text(
                'Date of payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEDFD0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dateController.text.isEmpty
                              ? "Select date"
                              : _dateController.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: _dateController.text.isEmpty
                                ? Colors.black54
                                : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Payment method
              const Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEDFD0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  hint: const Text("Select method"),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem(value: method, child: Text(method));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Signature Upload Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (_signatureFileName == null) ...[
                      const Icon(
                        Icons.upload_file,
                        size: 60,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _signatureFileName = "img.png";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEEDFD0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Upload signature image",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.image, color: AppColors.textLight),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _signatureFileName!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _signatureFileName = null;
                              });
                            },
                            child: const Text(
                              "Remove",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryBrown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Confirm Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Confirm Payment",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
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
