import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';
import '../../services/database_service.dart';

class ClientDetailsScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();

  final TextEditingController _clientNameController = TextEditingController(
    text: "Rohan Sharma",
  );
  final TextEditingController _contactController = TextEditingController(
    text: "9967352832",
  );
  final TextEditingController _idolNameController = TextEditingController(
    text: "Ganesha Idol",
  );
  final TextEditingController _materialsController = TextEditingController(
    text: "Make with clay and terracotta.",
  );

  @override
  void dispose() {
    _clientNameController.dispose();
    _contactController.dispose();
    _idolNameController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  void _updateClientDetails(BuildContext context) async {
    try {
      await DatabaseService.updateClientDetails(
        oldCustomerName: widget.clientId,
        newCustomerName: _clientNameController.text,
        phoneNumber: _contactController.text,
      );
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

        return AlertDialog(
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
                      selectedDate = picked;
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
                    setState(() {});
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
        );
      },
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
          if (banglaText.isNotEmpty) {
            final englishText =
                await _translationService.translateToEnglish(banglaText);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recognized: $englishText')),
              );
            }
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No speech detected')),
            );
          }
        },
        backgroundColor: _speechService.isListening ? Colors.orange : AppColors.primaryBrown,
        child: Icon(
          _speechService.isListening ? Icons.graphic_eq : Icons.mic,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Details Section
              const Text(
                "Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 20),

              // Client name
              _buildLabel("Client name"),
              const SizedBox(height: 8),
              _buildTextField(_clientNameController, "Rohan Sharma"),

              const SizedBox(height: 20),

              // Contact number
              _buildLabel("Contact number"),
              const SizedBox(height: 8),
              _buildTextField(_contactController, "9967352832"),

              const SizedBox(height: 20),

              // Idol Name
              _buildLabel("Idol Name"),
              const SizedBox(height: 8),
              _buildTextField(_idolNameController, "Ganesha Idol"),

              const SizedBox(height: 20),

              // Materials and Special Requirements
              _buildLabel("Materials and Special Requirements"),
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
                    hintText: "Make with clay and terracotta.",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Delivery Date
              _buildLabel("Delivery Date"),
              const SizedBox(height: 12),

              // Ganesh Idol
              _buildDeliveryDateCard("Ganesh Idol", "Oct 26, 2024"),

              const SizedBox(height: 12),

              // Durga Idol
              _buildDeliveryDateCard("Durga Idol", "Oct 26, 2024"),

              const SizedBox(height: 30),

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
                    "Add another idol",
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
                    "Delete Client",
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
                    "Update details",
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
            onPressed: () {},
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }
}
