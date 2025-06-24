import 'package:flutter/material.dart';
import 'package:stibe_partner/screens/auth/login_screen.dart';
import 'package:stibe_partner/screens/auth/register_screen.dart';
import 'package:stibe_partner/screens/auth/email_verification_screen.dart';

enum AuthState {
  login,
  register,
  emailVerification,
  verified,
}

class AuthWrapperScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthWrapperScreen({
    super.key,
    required this.onAuthSuccess,
  });

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  AuthState _currentState = AuthState.login;
  String? _emailForVerification;

  void _navigateToLogin() {
    setState(() {
      _currentState = AuthState.login;
      _emailForVerification = null;
    });
  }

  void _navigateToRegister() {
    setState(() {
      _currentState = AuthState.register;
    });
  }

  void _navigateToEmailVerification(String email) {
    setState(() {
      _currentState = AuthState.emailVerification;
      _emailForVerification = email;
    });
  }

  void _onVerificationComplete() {
    setState(() {
      _currentState = AuthState.verified;
    });
    widget.onAuthSuccess();
  }

  void _onLoginSuccess() {
    widget.onAuthSuccess();
  }

  void _onRegisterSuccess(String? emailForVerification) {
    if (emailForVerification != null) {
      // Email verification required
      _navigateToEmailVerification(emailForVerification);
    } else {
      // Email already verified, proceed to app
      widget.onAuthSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AuthState.login:
        return LoginScreen(
          onNavigateToRegister: _navigateToRegister,
          onLoginSuccess: _onLoginSuccess,
        );
      case AuthState.register:
        return RegisterScreen(
          onNavigateToLogin: _navigateToLogin,
          onRegisterSuccess: _onRegisterSuccess,
        );
      case AuthState.emailVerification:
        return EmailVerificationScreen(
          email: _emailForVerification!,
          onVerificationComplete: _onVerificationComplete,
          onBackToLogin: _navigateToLogin,
        );
      case AuthState.verified:
        // This should not be reached as onAuthSuccess should navigate away
        return const SizedBox.shrink();
    }
  }
}
