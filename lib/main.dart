import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/providers/appointment_provider.dart';
import 'package:stibe_partner/screens/auth/auth_wrapper_screen.dart';
import 'package:stibe_partner/screens/main_navigation_screen.dart';
import 'package:stibe_partner/screens/profile/edit_profile_screen.dart';
import 'package:stibe_partner/screens/debug/image_url_debug_screen.dart';
import 'package:stibe_partner/screens/salons/salons_screen.dart';
import 'package:stibe_partner/screens/salons/add_salon_screen.dart';

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
        routes: {
          '/profile': (context) => const EditProfileScreen(),
          '/debug/image-url': (context) => const ImageUrlDebugScreen(),
          '/salons': (context) => const SalonsScreen(),
          '/add-salon': (context) => const AddSalonScreen(),
        },
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
          // User is authenticated, go directly to main dashboard
          return const MainNavigationScreen();
        } else {
          // User is not authenticated, show auth wrapper
          return AuthWrapperScreen(
            onAuthSuccess: () {
              // Navigate directly to dashboard after successful login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
            },
          );
        }
      },
    );
  }
}
