import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';
import '../../services/database_service.dart';
import 'client_chat_screen.dart';
import 'delivery_dates_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();

  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _idolNameController = TextEditingController();
  final TextEditingController _materialsController = TextEditingController();

  bool _isLoading = true;
  int? _primaryOrderId;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _contactController.dispose();
    _idolNameController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    setState(() => _isLoading = true);
    try {
      final orders = await DatabaseService.getOrdersByCustomerName(widget.clientId);
      _clientNameController.text = widget.clientId;
      if (orders.isNotEmpty) {
        final primary = orders.first;
        _primaryOrderId = primary['id'] as int?;
        _contactController.text = (primary['phone_number'] as String?) ?? '';
        _idolNameController.text = (primary['idol_name'] as String?) ?? '';
        _materialsController.text = (primary['special_requirements'] as String?) ?? '';
      }
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
          SnackBar(content: Text('Failed to load client: $e')),
        );
      }
    }
  }

  void _updateClientDetails(BuildContext context) async {
    try {
      await DatabaseService.updateClientDetails(
        oldCustomerName: widget.clientId,
        newCustomerName: _clientNameController.text,
        phoneNumber: _contactController.text,
      );
      if (_primaryOrderId != null) {
        await DatabaseService.updateOrder(
          id: _primaryOrderId!,
          idolName: _idolNameController.text,
          specialRequirements: _materialsController.text,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client details updated successfully')),
      );
      // Navigate back or refresh
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating client details: $e')),
      );
    }
  }

  void _deleteClient(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Client'),
          content: const Text(
            'Are you sure you want to delete this client and all their orders? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteOrdersByCustomerName(widget.clientId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client deleted successfully')),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting client: $e')),
        );
      }
    }
  }

  void _addAnotherIdol(BuildContext context) async {
    // Show a dialog to input idol details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController idolNameController = TextEditingController();
        final TextEditingController requirementsController = TextEditingController();
        DateTime? selectedDate;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Another Idol'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idolNameController,
                  decoration: const InputDecoration(
                    labelText: 'Idol Name',
                    hintText: 'e.g., Durga Idol',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: requirementsController,
                  decoration: const InputDecoration(
                    labelText: 'Special Requirements',
                    hintText: 'Materials and requirements',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Delivery Date',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (idolNameController.text.isNotEmpty) {
                  try {
                    await DatabaseService.insertOrder(
                      customerName: widget.clientId,
                      idolName: idolNameController.text,
                      specialRequirements: requirementsController.text,
                      deliveryDate: selectedDate?.toIso8601String(),
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Idol added successfully')),
                    );
                    // Refresh the screen or update UI
                    _loadClient();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding idol: $e')),
                    );
                  }
                }
              },
              child: const Text('Add Idol'),
            ),
          ],
          ),
        );
      },
    );
  }

  Future<void> _openChat(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientChatScreen(clientId: widget.clientId),
      ),
    );
  }

  Future<void> _editDeliveryDate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryDatesScreen(clientId: widget.clientId),
      ),
    );
    _loadClient();
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'No date set';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'No date set';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            String banglaText = await _speechService.listenBangla();
            debugPrint('Bangla Text: $banglaText');
            if (banglaText.isNotEmpty) {
              String englishText = await _translationService.translateToEnglish(
                banglaText,
              );
              debugPrint('English Text: $englishText');
              // Show the recognized text to user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recognized: $englishText')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No speech detected')),
              );
            }
          } catch (e) {
            debugPrint('Speech recognition error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech recognition failed: $e')),
            );
          }
        },
        backgroundColor: AppColors.primaryBrown,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                    onPressed: () => _openChat(context),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Details Section
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 20),

              // Client name
              _buildLabel('Client name'),
              const SizedBox(height: 8),
              _buildTextField(_clientNameController, 'Client name'),

              const SizedBox(height: 20),

              // Contact number
              _buildLabel('Contact number'),
              const SizedBox(height: 8),
              _buildTextField(_contactController, 'Contact number'),

              const SizedBox(height: 20),

              // Idol Name
              _buildLabel('Idol Name'),
              const SizedBox(height: 8),
              _buildTextField(_idolNameController, 'Idol name'),

              const SizedBox(height: 20),

              // Materials and Special Requirements
              _buildLabel('Materials and Special Requirements'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEDFD0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _materialsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Materials and special requirements',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Delivery Date
              _buildLabel('Delivery Date'),
              const SizedBox(height: 12),

              if (_orders.isEmpty)
                const Text(
                  'No idol orders yet. Add one below.',
                  style: TextStyle(color: AppColors.textLight),
                )
              else
                for (final order in _orders) ...[
                  _buildDeliveryDateCard(
                    (order['idol_name'] as String?)?.trim().isNotEmpty == true
                        ? order['idol_name'] as String
                        : 'Idol order',
                    (order['delivered'] as int? ?? 0) == 1
                        ? 'Delivered'
                        : _formatDate(order['delivery_date']),
                  ),
                  const SizedBox(height: 12),
                ],

              const SizedBox(height: 18),

              // Action Buttons
              // Add another idol
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addAnotherIdol(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Add another idol',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Delete Client
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _deleteClient(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardCream,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Delete Client',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Update details
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateClientDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundCream,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    side: BorderSide(
                      color: AppColors.textLight.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Update details',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDFD0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => controller.clear(),
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDateCard(String idolName, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDFD0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idolName,
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
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _editDeliveryDate(context),
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }
}
