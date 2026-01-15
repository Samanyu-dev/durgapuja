import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../l10n/app_localizations.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Get user statistics
      final usersQuery = await FirebaseFirestore.instance.collection('users').get();
      final totalUsers = usersQuery.docs.length;
      final adminUsers = usersQuery.docs.where((doc) => doc.data()['role'] == 'admin').length;
      final idolMakerUsers = usersQuery.docs.where((doc) => doc.data()['role'] == 'idol_maker').length;
      final regularUsers = usersQuery.docs.where((doc) => doc.data()['role'] == 'user').length;

      // Get orders statistics
      final ordersQuery = await FirebaseFirestore.instance.collectionGroup('orders').get();
      final totalOrders = ordersQuery.docs.length;
      final pendingOrders = ordersQuery.docs.where((doc) => doc.data()['status'] == 'pending').length;
      final completedOrders = ordersQuery.docs.where((doc) => doc.data()['status'] == 'completed').length;

      setState(() {
        _stats = {
          'totalUsers': totalUsers,
          'adminUsers': adminUsers,
          'idolMakerUsers': idolMakerUsers,
          'regularUsers': regularUsers,
          'totalOrders': totalOrders,
          'pendingOrders': pendingOrders,
          'completedOrders': completedOrders,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stats: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (!authProvider.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: const Center(
          child: Text('Access denied. Admin privileges required.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryBrown, AppColors.secondaryBrown],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: AppConstants.mediumPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppConstants.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage users, roles, and system settings',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: AppConstants.fontSizeBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Statistics Cards
                  Text(
                    'System Statistics',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),

                  // User Statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Users',
                          _stats['totalUsers']?.toString() ?? '0',
                          Icons.people,
                          AppColors.primaryBrown,
                        ),
                      ),
                      const SizedBox(width: AppConstants.mediumPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Admins',
                          _stats['adminUsers']?.toString() ?? '0',
                          Icons.admin_panel_settings,
                          AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.mediumPadding),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Idol Makers',
                          _stats['idolMakerUsers']?.toString() ?? '0',
                          Icons.palette,
                          AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(width: AppConstants.mediumPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Regular Users',
                          _stats['regularUsers']?.toString() ?? '0',
                          Icons.person,
                          AppColors.secondaryBrown,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Order Statistics
                  Text(
                    'Order Statistics',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Orders',
                          _stats['totalOrders']?.toString() ?? '0',
                          Icons.shopping_cart,
                          AppColors.primaryBrown,
                        ),
                      ),
                      const SizedBox(width: AppConstants.mediumPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          _stats['pendingOrders']?.toString() ?? '0',
                          Icons.pending,
                          AppColors.warningOrange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.mediumPadding),

                  _buildStatCard(
                    'Completed Orders',
                    _stats['completedOrders']?.toString() ?? '0',
                    Icons.check_circle,
                    AppColors.successGreen,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Management Actions
                  Text(
                    'Management Actions',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),

                  _buildActionCard(
                    'User Management',
                    'View and manage all users',
                    Icons.manage_accounts,
                    () => context.go('/admin/users'),
                  ),

                  const SizedBox(height: AppConstants.mediumPadding),

                  _buildActionCard(
                    'Role Management',
                    'Assign and change user roles',
                    Icons.assignment_ind,
                    () => context.go('/admin/roles'),
                  ),

                  const SizedBox(height: AppConstants.mediumPadding),

                  _buildActionCard(
                    'System Settings',
                    'Configure app settings',
                    Icons.settings,
                    () => context.go('/admin/settings'),
                  ),

                  const SizedBox(height: AppConstants.mediumPadding),

                  _buildActionCard(
                    'Analytics',
                    'View detailed analytics',
                    Icons.analytics,
                    () => context.go('/analytics'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
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
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBrown,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryBrown,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
