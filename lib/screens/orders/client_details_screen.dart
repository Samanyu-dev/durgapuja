import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          // Navigation handled by MainNavigationScreen
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String banglaText = await _speechService.listenBangla();
          debugPrint("Bangla Text: $banglaText");
          String englishText = await _translationService.translateToEnglish(
            banglaText,
          );
          debugPrint("English Text: $englishText");
        },
        backgroundColor: AppColors.primaryBrown,
        child: const Icon(Icons.mic, color: Colors.white),
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
                  onPressed: () {},
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
                  onPressed: () {},
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
                  onPressed: () {},
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
