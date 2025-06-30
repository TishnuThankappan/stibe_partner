import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/screens/analytics/analytics_screen.dart';
import 'package:stibe_partner/screens/appointments/appointments_screen.dart';
import 'package:stibe_partner/screens/customers/customers_screen.dart';
import 'package:stibe_partner/screens/dashboard/dashboard_screen.dart';
import 'package:stibe_partner/screens/salons/salons_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const AppointmentsScreen(),
    const CustomersScreen(),
    const SalonsScreen(),
    const AnalyticsScreen(),
  ];
  
  final List<String> _titles = [
    'Dashboard',
    'Bookings',
    'Customers',
    'Salons',
    'Analytics',
  ];
  
  final List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.calendar_today_outlined,
    Icons.people_outline,
    Icons.store_outlined,
    Icons.analytics_outlined,
  ];
  
  final List<IconData> _activeIcons = [
    Icons.dashboard,
    Icons.calendar_today,
    Icons.people,
    Icons.store,
    Icons.analytics,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_icons[0]),
            activeIcon: Icon(_activeIcons[0]),
            label: _titles[0],
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[1]),
            activeIcon: Icon(_activeIcons[1]),
            label: _titles[1],
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[2]),
            activeIcon: Icon(_activeIcons[2]),
            label: _titles[2],
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[3]),
            activeIcon: Icon(_activeIcons[3]),
            label: _titles[3],
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[4]),
            activeIcon: Icon(_activeIcons[4]),
            label: _titles[4],
          ),
        ],
      ),
      floatingActionButton: _shouldShowFAB()
          ? FloatingActionButton(
              onPressed: () {
                _showQuickActionDialog();
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  bool _shouldShowFAB() {
    // Show FAB on bookings, customers, and salons screens
    return _currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3;
  }

  void _showQuickActionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.event_note,
                    label: 'New Booking',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                  ),
                ),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Customer',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                  ),
                ),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.store,
                    label: 'Add Salon',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
