import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/screens/auth/forgot_password_screen.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onNavigateToRegister;
  final VoidCallback onLoginSuccess;
  
  const LoginScreen({
    super.key,
    required this.onNavigateToRegister,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkForStoredCredentials();
  }
  
  // Check if we have stored credentials and set Remember Me accordingly
  Future<void> _checkForStoredCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storedCredentials = await authProvider.getStoredCredentials();
    
    if (storedCredentials != null) {
      setState(() {
        _rememberMe = true;
        _emailController.text = storedCredentials['email'] ?? '';
      });
      print('🔍 DEBUG Found stored credentials, setting Remember Me to true');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Start a stopwatch to measure login performance
      final Stopwatch loginStopwatch = Stopwatch()..start();
      print('⏱️ Login button pressed at ${loginStopwatch.elapsedMilliseconds}ms');
      
      print('🔍 DEBUG LoginScreen._login - rememberMe: $_rememberMe');
      
      // Show a loading indicator immediately to improve perceived performance
      setState(() {
        // The loading state will be managed by the authProvider, 
        // but we can update the UI immediately
      });
      print('⏱️ Updated UI state at ${loginStopwatch.elapsedMilliseconds}ms');
      
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
      
      print('⏱️ Login process completed in ${loginStopwatch.elapsedMilliseconds}ms');
      
      if (success && mounted) {
        // Call the success callback which will navigate to the dashboard
        print('⏱️ Calling onLoginSuccess at ${loginStopwatch.elapsedMilliseconds}ms');
        widget.onLoginSuccess();
      }
    }
  }

  // Debug function to toggle remember me storage
  // This will be removed in production
  Future<void> _debugCheckRememberMe() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final credentials = await authProvider.getStoredCredentials();
    
    // Show current status
    if (credentials != null) {
      final snackBar = SnackBar(
        content: Text('Debug: Remember Me is ENABLED (${credentials['email']})'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'CLEAR',
          textColor: Colors.white,
          onPressed: () async {
            await authProvider.logoutAndNavigate(context, preserveRememberMe: false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debug: Remember Me credentials cleared'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debug: Remember Me is NOT enabled'),
          backgroundColor: Colors.grey,
        ),
      );
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
                  const SizedBox(height: 40),
                  
                  // Logo and welcome text
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.content_cut,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome Back!',
                          style: AppTextStyles.heading1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue to your salon dashboard',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
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
                      return null;
                    },
                    prefix: const Icon(Icons.lock_outline),
                    required: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Remember me and forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                              // Add debug print
                              print('🔍 DEBUG Remember Me checkbox toggled: $_rememberMe');
                            },
                            activeColor: AppColors.primary,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                              print('🔍 DEBUG Remember Me text tapped: $_rememberMe');
                            },
                            child: const Text(
                              'Remember me',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),                      TextButton(
                        onPressed: () {
                          // Navigate to forgot password screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(
                                onBackToLogin: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login button
                  PrimaryButton(
                    text: 'Login',
                    onPressed: _login,
                    isLoading: authProvider.isLoading,
                  ),
                  
                  // Debug button - will be removed in production
                  if (AppConfig.isDevelopment) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _debugCheckRememberMe,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEBUG: Check Remember Me Status',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToRegister,
                          child: const Text(
                            'Register',
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
