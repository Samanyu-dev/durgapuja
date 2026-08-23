import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/database_service.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';

class SendUpdateScreen extends StatefulWidget {
  final String clientId;

  const SendUpdateScreen({super.key, required this.clientId});

  @override
  State<SendUpdateScreen> createState() => _SendUpdateScreenState();
}

class _SendUpdateScreenState extends State<SendUpdateScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  final TranslationService _translationService = TranslationService();
  bool _isRecording = false;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    try {
      final orders = await DatabaseService.getOrdersByCustomerName(widget.clientId);
      if (orders.isNotEmpty && mounted) {
        setState(() {
          _phoneNumber = orders.first['phone_number'] as String?;
        });
      }
    } catch (_) {
      // Ignore — WhatsApp send will fall back to a manual-share message.
    }
  }

  Future<void> _recordVoiceMessage() async {
    setState(() => _isRecording = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎙️ Recording message...'), duration: Duration(seconds: 2)),
    );
    try {
      final banglaText = await _speechService.listenBangla();
      if (banglaText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No speech detected')),
          );
        }
        return;
      }
      final englishText = await _translationService.translateToEnglish(banglaText);
      if (mounted) {
        setState(() {
          _messageController.text = _messageController.text.isEmpty
              ? englishText
              : '${_messageController.text} $englishText';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice recording failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    final digitsOnlyPhone = _phoneNumber?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnlyPhone == null || digitsOnlyPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this client')),
      );
      return;
    }

    final whatsappUri = Uri.parse(
      'https://wa.me/$digitsOnlyPhone?text=${Uri.encodeComponent(_messageController.text)}',
    );

    try {
      final launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      if (!launched) throw Exception('Could not open WhatsApp');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Message Sent'),
          content: Text('Your update has been sent to ${widget.clientId} via WhatsApp'),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open WhatsApp: $e')),
        );
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send update',
              style: TextStyle(
                fontSize: AppConstants.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            const Text(
              'YOUR MESSAGE',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrown,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            TextField(
              controller: _messageController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Write a message',
                hintStyle: const TextStyle(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.cardCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(
                  AppConstants.mediumPadding,
                ),
              ),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeBody,
                color: AppColors.textDark,
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
                borderRadius: BorderRadius.circular(AppConstants.largeRadius),
              ),
              child: TextButton.icon(
                onPressed: _isRecording ? null : _recordVoiceMessage,
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
              label: 'Send message',
              icon: Icons.send_outlined,
              onPressed: _sendMessage,
              backgroundColor: AppColors.primaryBrown,
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
