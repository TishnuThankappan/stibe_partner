import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/providers/appointment_provider.dart';
import 'package:stibe_partner/screens/auth/business_profile_setup_screen.dart';
import 'package:stibe_partner/screens/auth/login_screen.dart';
import 'package:stibe_partner/screens/auth/onboarding_screen.dart';
import 'package:stibe_partner/screens/auth/register_screen.dart';
import 'package:stibe_partner/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'Stibe Partner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while initializing auth state
        if (authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }
        
        // Check if user is authenticated
        final bool isAuthenticated = authProvider.isAuthenticated;
        
        if (isAuthenticated) {
          // Check if business profile is set up
          final hasBusiness = authProvider.user?.business != null;
          
          if (hasBusiness) {
            // User is authenticated and has business profile, show main app
            return const MainNavigationScreen();
          } else {
            // User is authenticated but needs to set up business profile
            return BusinessProfileSetupScreen(
              onSetupComplete: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                );
              },
            );
          }
        } else {
          // User is not authenticated, show login screen
          return LoginScreen(
            onNavigateToRegister: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(
                    onNavigateToLogin: () => Navigator.pop(context),
                    onRegisterSuccess: () {
                      // After registration, show onboarding
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            onLoginSuccess: () {
              // Check if user has business profile
              final hasBusiness = Provider.of<AuthProvider>(context, listen: false).user?.business != null;
              
              if (hasBusiness) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                );
              } else {
                // Show onboarding for new users
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
