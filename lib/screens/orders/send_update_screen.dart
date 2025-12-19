import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/custom_button.dart';

class SendUpdateScreen extends StatefulWidget {
  final String clientId;

  const SendUpdateScreen({Key? key, required this.clientId})
      : super(key: key);

  @override
  State<SendUpdateScreen> createState() => _SendUpdateScreenState();
}

class _SendUpdateScreenState extends State<SendUpdateScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;

  String get clientName => DummyData.getClientNameById(widget.clientId);

  void _sendMessage() {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Sent'),
        content: Text(
          'Your update has been sent to $clientName',
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
        title: Text(clientName),
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
                hintStyle: const TextStyle(
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.cardCream,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.all(AppConstants.mediumPadding),
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
                        content: Text('🎙️ Recording message...'),
                        duration: Duration(seconds: 2),
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
