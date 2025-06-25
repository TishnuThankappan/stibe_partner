import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/screens/dashboard/widgets/business_setup_card.dart';
import 'package:stibe_partner/screens/dashboard/widgets/welcome_card.dart';
import 'package:stibe_partner/screens/dashboard/widgets/quick_action_section.dart';
import 'package:stibe_partner/screens/dashboard/widgets/summary_section.dart';
import 'package:stibe_partner/screens/dashboard/widgets/appointments_section.dart';
import 'package:stibe_partner/screens/dashboard/widgets/activity_section.dart';
import 'package:stibe_partner/screens/dashboard/widgets/profile_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    // Simulate data loading for demonstration
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConfig.isDevelopment ? 'Dashboard (Dev Mode)' : 'Dashboard',
        centerTitle: true,
        actions: [
          _buildProfileButton(context),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business setup prompt (if needed)
                    const BusinessSetupCard(
                      onSetupComplete: null,
                    ),
                    
                    // Welcome section
                    const WelcomeCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick actions
                    const QuickActionSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Summary cards
                    const SummarySection(),
                    
                    const SizedBox(height: 24),
                    
                    // Today's appointments
                    const AppointmentsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent activity
                    const ActivitySection(),
                  ],
                ),
              ),
            ),
          ),
    );
  }
  
  Widget _buildProfileButton(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context);
        final user = authProvider.user;
        final profileImageUrl = user?.formattedProfileImage;
        
        // Debug output
        print('🖼️ Dashboard profile picture URL: $profileImageUrl');
        print('🖼️ Original profile picture URL: ${user?.profileImage}');
        
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              // Show the full-screen menu using a route
              _showFullScreenMenu(context);
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            profileImageUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('🖼️ Error loading profile image: $error');
                              print('🖼️ Failed URL: $profileImageUrl');
                              print('🖼️ StackTrace: $stackTrace');
                              return CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                              );
                            },
                          ),
                        )
                      : CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu,
                        size: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showFullScreenMenu(BuildContext context) {
    // Refresh user profile to ensure we have the latest data
    Provider.of<AuthProvider>(context, listen: false).refreshProfile();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => const ProfileDrawer(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// Class to store development settings
class DevSettings {
  static bool bypassAuth = true; // Start with auth bypass enabled in dev mode
  
  static void toggleAuthBypass() {
    if (AppConfig.isDevelopment) {
      bypassAuth = !bypassAuth;
    }
  }
}
