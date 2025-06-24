import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/screens/analytics/analytics_screen.dart';
import 'package:stibe_partner/screens/appointments/appointments_screen.dart';
import 'package:stibe_partner/screens/customers/customers_screen.dart';
import 'package:stibe_partner/screens/dashboard/dashboard_screen.dart';
import 'package:stibe_partner/screens/finance/finance_screen.dart';
import 'package:stibe_partner/screens/inventory/inventory_screen.dart';
import 'package:stibe_partner/screens/marketing/marketing_screen.dart';
import 'package:stibe_partner/screens/services/services_screen.dart';
import 'package:stibe_partner/screens/settings/settings_screen.dart';

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
    const ServicesScreen(),
    const CustomersScreen(),
    const FinanceScreen(),
    const MarketingScreen(),
    const InventoryScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];
  
  final List<String> _titles = [
    'Dashboard',
    'Appointments',
    'Services',
    'Customers',
    'Finance',
    'Marketing',
    'Inventory',
    'Analytics',
    'Settings',
  ];
  
  final List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.calendar_today_outlined,
    Icons.spa_outlined,
    Icons.people_outline,
    Icons.account_balance_wallet_outlined,
    Icons.campaign_outlined,
    Icons.inventory_outlined,
    Icons.analytics_outlined,
    Icons.settings_outlined,
  ];
  
  final List<IconData> _activeIcons = [
    Icons.dashboard,
    Icons.calendar_today,
    Icons.spa,
    Icons.people,
    Icons.account_balance_wallet,
    Icons.campaign,
    Icons.inventory,
    Icons.analytics,
    Icons.settings,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex < 5 ? _currentIndex : 4, // Keep the more tab selected for other screens
        onTap: (index) {
          if (index == 4 && _currentIndex >= 4) {
            // If more tab is tapped while already on a "more" screen, show the more menu
            _showMoreMenu();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
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
            icon: const Icon(Icons.more_horiz),
            activeIcon: const Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
      floatingActionButton: _shouldShowFAB()
          ? FloatingActionButton(
              onPressed: () {
                // Show add dialog based on current tab
                if (_currentIndex == 1) {
                  // Add new appointment
                } else if (_currentIndex == 2) {
                  // Add new service
                } else if (_currentIndex == 3) {
                  // Add new customer
                } else if (_currentIndex == 6) {
                  // Add new inventory item
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  bool _shouldShowFAB() {
    return _currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3 || _currentIndex == 6;
  }
  
  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Menu options
              for (int i = 4; i < _titles.length; i++)
                ListTile(
                  leading: Icon(
                    _icons[i],
                    color: _currentIndex == i ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    _titles[i],
                    style: TextStyle(
                      color: _currentIndex == i ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: _currentIndex == i ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _currentIndex = i;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
