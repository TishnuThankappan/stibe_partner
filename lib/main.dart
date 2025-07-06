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
import 'package:stibe_partner/screens/debug/salon_service_test_screen.dart';
import 'package:stibe_partner/screens/salons/salons_screen.dart';
import 'package:stibe_partner/screens/salons/add_salon_screen.dart';
import 'package:stibe_partner/screens/services/services_screen.dart';
import 'package:stibe_partner/screens/services/service_detail_screen.dart';
import 'package:stibe_partner/screens/services/add_service_screen.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';

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
          '/debug/salon-service-test': (context) => const SalonServiceTestScreen(),
          '/salons': (context) => const SalonsScreen(),
          '/add-salon': (context) => const AddSalonScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/services':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => ServicesScreen(
                  salonId: args?['salonId'] ?? 0,
                  salonName: args?['salonName'] ?? 'Salon',
                ),
              );
            case '/service-detail':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => ServiceDetailScreen(
                  service: args?['service'],
                  salonId: args?['salonId'] ?? 0,
                  salonName: args?['salonName'] ?? 'Salon',
                ),
              );
            case '/add-service':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => AddServiceScreen(
                  salonId: args?['salonId'] ?? 0,
                  salonName: args?['salonName'] ?? 'Salon',
                  service: args?['service'],
                ),
              );
            default:
              return null;
          }
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
        // Start a stopwatch to measure initialization time
        final Stopwatch authWrapperStopwatch = Stopwatch()..start();
        
        // Show loading indicator while initializing auth state
        if (authProvider.isLoading) {
          print('⏱️ AuthWrapper showing loading at ${authWrapperStopwatch.elapsedMilliseconds}ms');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(
                    type: LoadingIndicatorType.google,
                    size: 56.0,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your account...',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Check if user is authenticated
        final bool isAuthenticated = authProvider.isAuthenticated;
        
        print('⏱️ AuthWrapper authentication check completed in ${authWrapperStopwatch.elapsedMilliseconds}ms: $isAuthenticated');
        
        if (isAuthenticated) {
          // User is authenticated, go directly to main dashboard
          print('🧭 User is authenticated - Showing MainNavigationScreen');
          return const MainNavigationScreen();
        } else {
          // User is not authenticated, show auth wrapper
          print('🧭 User is NOT authenticated - Showing AuthWrapperScreen (login)');
          return AuthWrapperScreen(
            onAuthSuccess: () {
              // Start a timer to measure navigation time
              final navigationStopwatch = Stopwatch()..start();
              print('⏱️ Starting navigation to dashboard');
              
              // Navigate directly to dashboard after successful login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
              
              print('⏱️ Navigation to dashboard completed in ${navigationStopwatch.elapsedMilliseconds}ms');
            },
          );
        }
      },
    );
  }
}
