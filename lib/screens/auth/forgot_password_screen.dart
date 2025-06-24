import 'package:flutter/material.dart' hide OutlinedButton;
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;
  
  const ForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.forgotPassword(
        email: _emailController.text.trim(),
      );
      
      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Forgot Password',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _emailSent ? _buildSuccessView() : _buildFormView(authProvider),
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
            'Reset Your Password',
            style: AppTextStyles.heading2,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
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
          
          // Email field
          CustomTextField(
            label: 'Email',
            hintText: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            prefix: const Icon(Icons.email_outlined),
            required: true,
          ),
          
          const SizedBox(height: 32),
          
          // Submit button
          PrimaryButton(
            text: 'Reset Password',
            onPressed: _resetPassword,
            isLoading: authProvider.isLoading,
            width: double.infinity,
          ),
          
          const SizedBox(height: 24),
          
          // Back to login link
          Center(
            child: TextButton(
              onPressed: widget.onBackToLogin,
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
          'Email Sent',
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text}',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
          const SizedBox(height: 8),
        
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        OutlinedButton(
          text: 'Back to Login',
          onPressed: widget.onBackToLogin,
          width: double.infinity,
        ),
      ],
    );
  }
}
