import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/screens/salons/staff_management_screen.dart';
import 'package:stibe_partner/screens/salons/edit_salon_screen.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class SalonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> salon;
  final int? initialTab;
  
  const SalonDetailScreen({
    super.key, 
    required this.salon,
    this.initialTab,
  });

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SalonService _salonService = SalonService();
  final ServiceManagementService _enhancedServiceService = ServiceManagementService();
  bool _isLoading = false;
  Map<String, dynamic> _currentSalon = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4, 
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _currentSalon = Map<String, dynamic>.from(widget.salon);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToServicesScreen() {
    Navigator.pushNamed(
      context,
      '/services',
      arguments: {
        'salonId': _currentSalon['id'],
        'salonName': _currentSalon['name'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _currentSalon['name'] ?? 'Salon Detail',
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Salon header info here...
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Staff'),
                Tab(text: 'Settings'),
                Tab(text: 'Salon Works'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildStaffTab(),
                _buildSettingsTab(),
                _buildSalonWorksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return const Center(
      child: Text('Overview content...'),
    );
  }

  Widget _buildStaffTab() {
    return const Center(
      child: Text('Staff content...'),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Settings content...'),
    );
  }

  Widget _buildSalonWorksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services Section
          _buildSalonWorksSection(
            title: 'Services',
            icon: Icons.spa_outlined,
            color: Colors.purple.shade600,
            items: [],
            emptyMessage: 'No services added yet',
            onAddPressed: () {
              _navigateToServicesScreen();
            },
          ),
          const SizedBox(height: 20),
          
          // Packages Section
          _buildSalonWorksSection(
            title: 'Service Packages',
            icon: Icons.card_giftcard_outlined,
            color: Colors.orange.shade600,
            items: [],
            emptyMessage: 'No packages created yet',
            onAddPressed: () {
              _showAddPackageDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalonWorksSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required String emptyMessage,
    required VoidCallback onAddPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onAddPressed,
                  icon: Icon(Icons.add_circle_outline, color: color),
                  tooltip: 'Add ${title.toLowerCase()}',
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: items.isEmpty
                ? Column(
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: onAddPressed,
                        icon: const Icon(Icons.add),
                        label: Text('Add ${title.split(' ').first}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: items.map((item) => ListTile(
                      title: Text(item),
                      leading: Icon(icon, color: color),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddPackageDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Package creation feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
