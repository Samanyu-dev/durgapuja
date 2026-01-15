import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final phoneNumber = '+91${_phoneController.text.trim()}'; // Assuming Indian numbers

      await authService.sendWhatsAppOTP(phoneNumber);

      if (mounted) {
        // Navigate to OTP verification screen
        context.push('/otp-verification', extra: {
          'phoneNumber': phoneNumber,
          'verificationId': authService.verificationId,
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    if (!RegExp(r'^[6-9]').hasMatch(value)) {
      return 'Please enter a valid Indian mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppConstants.largePadding * 2),

                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrown.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 60,
                    color: AppColors.primaryBrown,
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Title
                Text(
                  'Welcome to Durga Idol Maker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Subtitle
                Text(
                  'Enter your phone number to continue',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Phone Input
                Container(
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
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter 10-digit mobile number',
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    validator: _validatePhone,
                  ),
                ),

                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppConstants.mediumPadding),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontSize: AppConstants.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.largePadding),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: _isLoading ? 'Sending...' : 'Send OTP via WhatsApp',
                    onPressed: _isLoading ? null : () => _sendOTP(),
                    backgroundColor: AppColors.primaryBrown,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Info Text
                Text(
                  'We will send an OTP to your WhatsApp number for verification',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Terms and Privacy
                Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppColors.textLight,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
