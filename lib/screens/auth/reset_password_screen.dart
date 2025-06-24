import 'package:flutter/material.dart' hide OutlinedButton;
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/screens/auth/login_screen.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  
  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordChanged = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.resetPassword(
        token: widget.token,
        newPassword: _passwordController.text,
      );
      
      if (success && mounted) {
        setState(() {
          _passwordChanged = true;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onNavigateToRegister: () {
            // Navigate to register
          },
          onLoginSuccess: () {
            // Navigate to main screen
          },
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Reset Password',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _passwordChanged ? _buildSuccessView() : _buildFormView(authProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Password',
            style: AppTextStyles.heading2,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your new password must be different from previously used passwords.',
            style: AppTextStyles.caption,
          ),
          
          const SizedBox(height: 32),
          
          // Error message
          if (authProvider.error != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Password field
          CustomTextField(
            label: 'New Password',
            hintText: 'Enter your new password',
            controller: _passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your new password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            prefix: const Icon(Icons.lock_outline),
            required: true,
          ),
          
          const SizedBox(height: 20),
          
          // Confirm password field
          CustomTextField(
            label: 'Confirm New Password',
            hintText: 'Confirm your new password',
            controller: _confirmPasswordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            prefix: const Icon(Icons.lock_outline),
            required: true,
          ),
          
          const SizedBox(height: 32),
          
          // Reset button
          PrimaryButton(
            text: 'Reset Password',
            onPressed: _resetPassword,
            isLoading: authProvider.isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 80,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Password Reset Successful',
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Your password has been reset successfully. You can now login with your new password.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        PrimaryButton(
          text: 'Login',
          onPressed: _navigateToLogin,
          width: double.infinity,
        ),
      ],
    );
  }
}
