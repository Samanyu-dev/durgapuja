import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignIn = true; // true for sign in, false for sign up
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final phoneNumber = '+91${_phoneController.text.trim()}';
      final password = _passwordController.text;

      bool success;
      if (_isSignIn) {
        success = await authProvider.signInWithPhoneAndPassword(phoneNumber, password);
      } else {
        success = await authProvider.signUpWithPhoneAndPassword(phoneNumber, password);
      }

      if (success && mounted) {
        // Navigation will be handled by router redirect
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('user-not-found')) {
      return 'No account found with this phone number';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorString.contains('email-already-in-use')) {
      return 'An account with this phone number already exists';
    } else if (errorString.contains('weak-password')) {
      return 'Password should be at least 6 characters';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid phone number format';
    } else {
      return 'Authentication failed. Please try again.';
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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
                    Icons.palette_outlined,
                    size: 60,
                    color: AppColors.primaryBrown,
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Title
                Text(
                  'Durga Idol Maker',
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
                  _isSignIn ? 'Sign in to your account' : 'Create your account',
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
                      prefixText: '+91',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterText: '',
                    ),
                    validator: _validatePhone,
                  ),
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Password Input
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
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: _validatePassword,
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

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: _isLoading
                        ? (_isSignIn ? 'Signing In...' : 'Creating Account...')
                        : (_isSignIn ? 'Sign In' : 'Sign Up'),
                    onPressed: _isLoading ? null : _submit,
                    backgroundColor: AppColors.primaryBrown,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Toggle between sign in and sign up
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignIn = !_isSignIn;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isSignIn
                        ? "Don't have an account? Sign Up"
                        : 'Already have an account? Sign In',
                    style: TextStyle(
                      color: AppColors.primaryBrown,
                      fontSize: AppConstants.fontSizeBody,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Terms and Privacy (only show for sign up)
                if (!_isSignIn) ...[
                  Text.rich(
                    TextSpan(
                      text: 'By signing up, you agree to our ',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
