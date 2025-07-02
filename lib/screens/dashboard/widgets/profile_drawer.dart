import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/screens/dashboard/dashboard_screen.dart';
import 'package:stibe_partner/screens/profile/edit_profile_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userName = user?.firstName != null && user?.lastName != null 
        ? '${user!.firstName} ${user.lastName}'
        : 'Partner';
    final email = user?.email ?? 'No email';
    
    // Get screen size for full-screen drawer
    final size = MediaQuery.of(context).size;
    
    return Material(
      child: Container(
        width: size.width * 0.85, // Adjust width to 85% of screen width
        height: size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, userName, email),
              Expanded(
                child: _buildDrawerBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDrawerBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        _buildSectionHeader('Salon Management'),
        _buildDrawerItem(
          icon: Icons.store_outlined,
          title: 'My Salons',
          subtitle: 'Manage your salon locations',
          iconColor: Colors.blue.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/salons');
          },
        ),
        _buildDrawerItem(
          icon: Icons.calendar_month_outlined,
          title: 'Appointments',
          subtitle: 'View and manage bookings',
          iconColor: Colors.orange.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/appointments');
          },
        ),
        
        _buildSectionHeader('Business Insights'),
        _buildDrawerItem(
          icon: Icons.insert_chart_outlined,
          title: 'Dashboard',
          subtitle: 'Business performance overview',
          iconColor: Colors.indigo.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/dashboard');
          },
        ),
        _buildDrawerItem(
          icon: Icons.payments_outlined,
          title: 'Finance',
          subtitle: 'Revenue and payments',
          iconColor: Colors.green.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/finance');
          },
        ),
        
        _buildSectionHeader('Account'),
        _buildDrawerItem(
          icon: Icons.person_outline,
          title: 'My Profile',
          subtitle: 'Edit your personal information',
          iconColor: Colors.blue.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        ),
        _buildDrawerItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'App preferences and notifications',
          iconColor: Colors.grey.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        _buildDrawerItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get assistance and resources',
          iconColor: Colors.amber.shade700,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/help');
          },
        ),
        
        // Development mode options
        if (AppConfig.isDevelopment) ...[
          _buildSectionHeader('Development'),
          _buildDrawerItem(
            icon: Icons.developer_mode,
            title: DevSettings.bypassAuth ? 'Auth Bypass: ON' : 'Auth Bypass: OFF',
            subtitle: 'Toggle authentication bypass mode',
            iconColor: DevSettings.bypassAuth ? Colors.green : Colors.deepPurple,
            onTap: () {
              Navigator.pop(context);
              _toggleDevMode(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.image,
            title: 'Image URL Debug',
            subtitle: 'Test image URL processing',
            iconColor: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/debug/image-url');
            },
          ),
          _buildDrawerItem(
            icon: Icons.store_mall_directory,
            title: 'Salon Service Test',
            subtitle: 'Test salon service functions',
            iconColor: Colors.purple,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/debug/salon-service-test');
            },
          ),
        ],
        
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: () {
           
              _showLogoutConfirmation(context);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Colors.red.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 28, top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 16,
                width: 3,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String email) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final profileImageUrl = user?.formattedProfileImage;
    
    // Debug output
    print('🖼️ Drawer profile picture URL: $profileImageUrl');
    print('🖼️ Original profile picture URL: ${user?.profileImage}');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A237E), // Deep indigo
            Color(0xFF3949AB), // Indigo
            Color(0xFF1E88E5), // Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                height: 38,
                width: 38,
                child: IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Business Hub',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          profileImageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('🖼️ Error loading profile image in drawer: $error');
                            print('🖼️ Failed URL: $profileImageUrl');
                            print('🖼️ StackTrace: $stackTrace');
                            return CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.shade100,
                              child: Text(
                                userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'P',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey.shade100,
                        child: Text(
                          userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'P',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/profile');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    if (AppConfig.isDevelopment) ...[
                      const SizedBox(height: 6),
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.developer_mode,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Development Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Function onTap,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(12),
          splashColor: (iconColor ?? Colors.black87).withOpacity(0.1),
          highlightColor: (iconColor ?? Colors.black87).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.black87).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (iconColor ?? Colors.black87).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: (textColor ?? Colors.grey).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDevMode(BuildContext context) {
    DevSettings.toggleAuthBypass();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Authentication Bypass: ${DevSettings.bypassAuth ? 'ENABLED' : 'DISABLED'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: DevSettings.bypassAuth ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // If we're in development mode and auth bypass is enabled, show different dialog
    if (AppConfig.isDevelopment && DevSettings.bypassAuth) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.developer_mode,
                  color: Colors.green.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Dev Mode Active',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Development mode is active with authentication bypass enabled.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'In this mode, logout will simulate a logout without actually calling the auth provider.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Simulated logout for development
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('DEV MODE: Simulated logout successful'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
                shadowColor: Colors.green.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Simulate Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
      return;
    }
    
    // Regular logout dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.logout,
                color: Colors.red.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from the Stibe Partner app?',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Check if Remember Me is active
              final credentials = await authProvider.getStoredCredentials();
              final hasRememberMe = credentials != null;
              
              if (hasRememberMe) {
                print('🔍 DEBUG Logout with active Remember Me: ${credentials['email']}');
                
                // Show a secondary confirmation for Remember Me
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Your "Remember Me" setting is active for ${credentials['email']}. Would you like to keep this device remembered for your next login?',
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Log out and DON'T preserve Remember Me
                            authProvider.logoutAndNavigate(context, preserveRememberMe: false);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text(
                            'Forget Me',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Log out but preserve Remember Me
                            authProvider.logoutAndNavigate(context, preserveRememberMe: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Keep Remembered',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                // No Remember Me active, just logout normally
                authProvider.logoutAndNavigate(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 2,
              shadowColor: Colors.red.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
