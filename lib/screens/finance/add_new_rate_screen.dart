import 'package:flutter/material.dart';
import '../../services/material_tracker_service.dart';

class AddNewRateScreen extends StatefulWidget {
  const AddNewRateScreen({super.key});

  @override
  State<AddNewRateScreen> createState() => _AddNewRateScreenState();
}

class _AddNewRateScreenState extends State<AddNewRateScreen> {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveRate() async {
    if (materialController.text.trim().isEmpty ||
        rateController.text.trim().isEmpty ||
        unitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in material, rate and unit')),
      );
      return;
    }

    final rate = double.tryParse(rateController.text.trim());
    if (rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid rate')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await MaterialTrackerService.addMaterial(
        name: materialController.text.trim(),
        category: MaterialCategory.OTHERS,
        unit: unitController.text.trim(),
        currentRate: rate,
        supplier: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving rate: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Add New Rate",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 20),

              // Material Name
              _inputField(
                label: "Material Name",
                hint: "e.g., Clay / Bamboo / Paint",
                controller: materialController,
              ),

              const SizedBox(height: 15),

              // Location
              _inputField(
                label: "Location",
                hint: "e.g., Shobhabazar / Maniktala",
                controller: locationController,
              ),

              const SizedBox(height: 15),

              // Rate + Unit Row
              Row(
                children: [
                  Expanded(
                    child: _inputField(
                      label: "Rate",
                      hint: "e.g., 150",
                      controller: rateController,
                      keyboard: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _inputField(
                      label: "Unit",
                      hint: "Kg / Liter / Piece",
                      controller: unitController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Optional Voice Input
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Color(0xFF9A5222),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 32),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Tap to add details using your voice",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 35),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5222),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Rate",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- INPUT FIELD WIDGET ----------------
  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }
}