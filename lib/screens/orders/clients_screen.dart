import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _clients = [
    {
      'name': 'Rohan Sharma',
      'status': 'New',
      'statusColor': AppColors.successGreen,
      'due': 'Due: 25 Oct',
      'daysLeft': 'in 2 days',
    },
    {
      'name': 'Priya Verma',
      'status': 'In Progress',
      'statusColor': AppColors.accentOrange,
      'due': 'Due: 25 Oct',
      'daysLeft': 'in 2 days',
    },
    {
      'name': 'Arjun Kapoor',
      'status': 'Delivered',
      'statusColor': AppColors.successGreen,
      'due': 'Completed',
      'daysLeft': '',
    },
    {
      'name': 'Divya Patel',
      'status': 'New',
      'statusColor': AppColors.successGreen,
      'due': 'Due: 25 Oct',
      'daysLeft': 'in 2 days',
    },
    {
      'name': 'Vikram Singh',
      'status': 'In Progress',
      'statusColor': AppColors.accentOrange,
      'due': 'Due: 25 Oct',
      'daysLeft': 'in 2 days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Clients'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎙️ Voice search')),
                    );
                  },
                ),
                filled: true,
                fillColor: AppColors.cardCream,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
              ),
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return _buildClientCard(client);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final clientId = (_clients.indexOf(client) + 1).toString();
    return GestureDetector(
      onTap: () {
        context.go('/orders/client/$clientId');
      },
      child: Container(
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
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryBrown.withOpacity(0.2),
              child: Text(
                client['name'][0],
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client['name'],
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smallPadding,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: client['statusColor'].withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Text(
                      client['status'],
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: client['statusColor'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  client['due'],
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                if (client['daysLeft'].isNotEmpty)
                  Text(
                    client['daysLeft'],
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
