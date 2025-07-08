import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onNavigateToLogin;
  final Function(String?) onRegisterSuccess;
  
  const RegisterScreen({
    super.key,
    required this.onNavigateToLogin,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }  
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and conditions'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Split full name into first and last name
      final fullName = _fullNameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      final emailForVerification = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _phoneController.text.trim(),
      );
      
      if (mounted) {
        widget.onRegisterSuccess(emailForVerification);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onNavigateToLogin,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Create Account',
                    style: AppTextStyles.heading1,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Register as a salon owner and start managing your business',
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
                  
                  // Full name field
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    prefix: const Icon(Icons.person_outline),
                    required: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                  
                  const SizedBox(height: 20),
                  
                  // Phone field
                  CustomTextField(
                    label: 'Phone Number',
                    hintText: 'Enter your phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    prefix: const Icon(Icons.phone_outlined),
                    required: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
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
                    label: 'Confirm Password',
                    hintText: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    prefix: const Icon(Icons.lock_outline),
                    required: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms and conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(
                                text: 'I agree to the ',
                              ),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: null, // Add GestureRecognizer here
                              ),
                              const TextSpan(
                                text: ' and ',
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: null, // Add GestureRecognizer here
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register button
                  PrimaryButton(
                    text: 'Register',
                    onPressed: _register,
                    isLoading: authProvider.isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToLogin,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
