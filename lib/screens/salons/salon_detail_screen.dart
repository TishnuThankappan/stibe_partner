import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/screens/services/redesigned_services_screen.dart';
import 'package:stibe_partner/screens/salons/staff_management_screen.dart';
import 'package:stibe_partner/screens/salons/edit_salon_screen.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/salon_service.dart';

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

  Future<void> _navigateToEditSalon() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch the salon details by ID to get the proper SalonDto structure
      final salonDto = await _salonService.getSalonById(widget.salon['id']);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to edit screen
      if (mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditSalonScreen(salon: salonDto),
          ),
        );

        // If salon was updated, you might want to refresh the current screen
        if (result == true && mounted) {
          // Optionally refresh the salon data here
          setState(() {}); // This will trigger a rebuild
        }
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (mounted) Navigator.of(context).pop();
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load salon details: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _toggleSalonStatus() async {
    final bool currentStatus = _currentSalon['isActive'] ?? true;
    final bool newStatus = !currentStatus;
    
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Activate Salon' : 'Deactivate Salon'),
        content: Text(
          newStatus 
            ? 'Are you sure you want to activate this salon? It will become visible to customers again.'
            : 'Are you sure you want to deactivate this salon? It will be hidden from customers but you can reactivate it anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSalon = await _salonService.toggleSalonStatus(
        _currentSalon['id'],
        newStatus,
      );

      setState(() {
        _currentSalon = updatedSalon.toJson();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Salon ${newStatus ? "activated" : "deactivated"} successfully!',
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );
        
        // Return updated salon data to parent screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSalon() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Salon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this salon?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. All salon data, including:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text('• Salon information', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('• Images and profile picture', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('• Services and staff', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('• Booking history', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            const Text(
              'will be permanently removed.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show second confirmation for extra safety
    final bool? doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Text(
          'Type "${_currentSalon['name']}" to confirm deletion:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (innerContext) {
                  final TextEditingController controller = TextEditingController();
                  return AlertDialog(
                    title: const Text('Confirm Salon Name'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Type "${_currentSalon['name']}" to confirm:'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter salon name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(innerContext);
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim() == _currentSalon['name']) {
                            Navigator.pop(innerContext);
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(innerContext).showSnackBar(
                              const SnackBar(
                                content: Text('Salon name does not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete Forever'),
                      ),
                    ],
                  );
                },
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (doubleConfirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _salonService.deleteSalon(_currentSalon['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salon deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to salons list
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting salon: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'settings':
        // TODO: Navigate to settings screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings feature coming soon!')),
        );
        break;
      case 'analytics':
        // TODO: Navigate to analytics screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics feature coming soon!')),
        );
        break;
      case 'deactivate':
      case 'activate':
        _toggleSalonStatus();
        break;
      case 'delete':
        _deleteSalon();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _currentSalon['name'] ?? widget.salon['name'],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : () => _navigateToEditSalon(),
          ),
          PopupMenuButton(
            onSelected: _isLoading ? null : _handlePopupMenuSelection,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('Analytics'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: _currentSalon['isActive'] ?? true ? 'deactivate' : 'activate',
                child: Row(
                  children: [
                    Icon(
                      _currentSalon['isActive'] ?? true ? Icons.pause_circle : Icons.play_circle,
                      size: 20,
                      color: _currentSalon['isActive'] ?? true ? Colors.orange : Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _currentSalon['isActive'] ?? true ? 'Deactivate' : 'Activate',
                      style: TextStyle(
                        color: _currentSalon['isActive'] ?? true ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      size: 20,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Delete Salon',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Services'),
            Tab(text: 'Staff'),
            Tab(text: 'Bookings'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              RedesignedServicesScreen(
                salonId: widget.salon['id'],
                salonName: widget.salon['name'] ?? 'Salon',
              ),
              StaffManagementScreen(salonId: widget.salon['id']),
              _buildBookingsTab(),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salon Header Card
          _buildSalonHeaderCard(),
          const SizedBox(height: 20),
          
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 20),
          
          // Recent Activity
          _buildRecentActivity(),
          const SizedBox(height: 20),
          
          // Performance Metrics
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildSalonHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              // Profile Picture Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: widget.salon['profilePictureUrl'] != null && 
                                widget.salon['profilePictureUrl'].toString().isNotEmpty
                    ? NetworkImage(widget.salon['profilePictureUrl'])
                    : null,
                child: widget.salon['profilePictureUrl'] == null || 
                       widget.salon['profilePictureUrl'].toString().isEmpty
                    ? Icon(
                        Icons.store,
                        color: AppColors.primary,
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.salon['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.salon['address'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.salon['isActive'] ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.salon['isActive'] ? 'Active' : 'Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rating and Contact Info
          Row(
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.salon['rating']} Rating',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Icon(Icons.phone_outlined, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.salon['phoneNumber'] ?? 'No phone',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.spa_outlined,
                title: 'Services',
                value: widget.salon['servicesCount'].toString(),
                color: Colors.purple.shade600,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.people_outline,
                title: 'Staff Members',
                value: widget.salon['staffCount'].toString(),
                color: Colors.teal.shade600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.calendar_month_outlined,
                title: 'Total Bookings',
                value: widget.salon['totalBookings'].toString(),
                color: Colors.orange.shade600,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.trending_up,
                title: 'This Month',
                value: '42',
                color: Colors.green.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.person_add,
            title: 'New staff member added',
            subtitle: 'Sarah Johnson joined as Hair Stylist',
            time: '2 hours ago',
            color: Colors.green,
          ),
          _buildActivityItem(
            icon: Icons.spa,
            title: 'Service updated',
            subtitle: 'Hair Cut & Style price updated',
            time: '5 hours ago',
            color: Colors.blue,
          ),
          _buildActivityItem(
            icon: Icons.calendar_month,
            title: 'Booking completed',
            subtitle: 'Client: Emma Wilson - Facial Treatment',
            time: '1 day ago',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Revenue Chart Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text(
                'Revenue Chart\n(Coming Soon)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return const Center(
      child: Text(
        'Bookings Management\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
