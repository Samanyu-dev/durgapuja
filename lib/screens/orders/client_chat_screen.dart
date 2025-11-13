import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'send_update_screen.dart';
import 'record_payment_screen.dart';
import 'delivery_dates_screen.dart';

class ClientChatScreen extends StatelessWidget {
  final String clientName;

  const ClientChatScreen({Key? key, required this.clientName}) : super(key: key);

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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMessageBubble(
                  'Rohan Sharma',
                  'Namaste! I\'m excited to see the progress on the Ganesha idol. Any updates?',
                  false,
                  null,
                ),
                const SizedBox(height: 16),
                _buildMessageBubble(
                  'You',
                  'Namaste, Rahul! The idol is coming along beautifully. I\'ll send you a photo update shortly.',
                  true,
                  null,
                ),
                const SizedBox(height: 16),
                _buildMessageBubble(
                  'Rohan Sharma',
                  'That\'s wonderful to hear! Looking forward to it.',
                  false,
                  null,
                ),
                const SizedBox(height: 16),
                _buildMessageBubble(
                  'You',
                  'Here\'s a sneak peek! The details are really starting to take shape.',
                  true,
                  'assets/images/idol_progress.jpg',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SendUpdateScreen(clientName: clientName),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBrown,
                        ),
                        child: const Text('Send Update'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecordPaymentScreen(clientName: clientName),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                        ),
                        child: const Text('Add Payment'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DeliveryDatesScreen(clientName: clientName),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBrown,
                    side: const BorderSide(color: AppColors.primaryBrown),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('View Delivery Date'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      String sender, String message, bool isMe, String? imagePath) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBrown,
            child: Text(
              sender,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    sender,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primaryBrown : AppColors.cardCream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                    if (imagePath != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isMe) const SizedBox(width: 8),
      ],
    );
  }
}
