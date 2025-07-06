import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/constants/card_theme.dart';
import 'package:stibe_partner/api/comprehensive_staff_service.dart';
import 'package:stibe_partner/screens/salons/staff/add_staff_screen.dart';
import 'package:stibe_partner/screens/salons/staff/staff_detail_screen.dart';
import 'package:stibe_partner/screens/salons/staff/edit_staff_screen.dart';

class EnhancedStaffManagementScreen extends StatefulWidget {
  final int salonId;
  final String salonName;
  
  const EnhancedStaffManagementScreen({
    super.key, 
    required this.salonId,
    required this.salonName,
  });

  @override
  State<EnhancedStaffManagementScreen> createState() => _EnhancedStaffManagementScreenState();
}

class _EnhancedStaffManagementScreenState extends State<EnhancedStaffManagementScreen> {
  final ComprehensiveStaffService _staffService = ComprehensiveStaffService();
  
  bool _isLoading = true;
  List<StaffDto> _staff = [];
  List<StaffDto> _allStaff = [];
  String? _errorMessage;
  bool _showInactiveStaff = true; // Show all staff by default

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _staffService.getSalonStaff(
        widget.salonId,
        pageSize: 100, // Load all staff for now
        includeInactive: true,
      );
      
      setState(() {
        _allStaff = response.staff;
        _filterStaff();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterStaff() {
    // Only filter by active/inactive status
    if (_showInactiveStaff) {
      _staff = _allStaff;
    } else {
      _staff = _allStaff.where((staff) => staff.isActive).toList();
    }
    
    setState(() {});
  }

  Future<void> _refreshStaff() async {
    setState(() {
      _isLoading = true;
    });
    await _loadStaff();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refreshStaff,
            child: Column(
              children: [
                // Filter options
                SharedCardTheme.filterSection(
                  showInactive: _showInactiveStaff,
                  onToggle: (value) {
                    setState(() {
                      _showInactiveStaff = value;
                      _filterStaff();
                    });
                  },
                  description: 'Manage your salon staff members',
                ),
                
                // Staff list
                Expanded(
                  child: _staff.isEmpty
                      ? _buildEmptyState()
                      : _buildStaffList(),
                ),
              ],
            ),
          );
  }

  Widget _buildEmptyState() {
    return SharedCardTheme.emptyState(
      context: context,
      icon: Icons.people_outline,
      title: 'No Staff Members Yet',
      description: 'Start building your dream team by adding talented staff members to your salon.',
      buttonText: 'Add Your First Staff Member',
      onButtonPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddStaffScreen(
              salonId: widget.salonId,
              salonName: widget.salonName,
            ),
          ),
        ).then((_) => _refreshStaff());
      },
    );
  }

  Widget _buildStaffList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staff.length,
      itemBuilder: (context, index) {
        return _buildStaffCard(_staff[index]);
      },
    );
  }
  



  Widget _buildStaffCard(StaffDto staff) {
    final initials = ComprehensiveStaffService.getStaffInitials(staff.firstName, staff.lastName);

    return Opacity(
      opacity: staff.isActive ? 1.0 : 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: SharedCardTheme.cardDecoration(
          isActive: staff.isActive,
          borderColor: Colors.orange.shade300,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _viewStaffDetails(staff),
            onLongPress: () => _showStaffContextMenu(context, staff),
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Staff Photo/Avatar Section (similar to service image)
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Photo or placeholder
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: staff.photoUrl != null && staff.photoUrl!.isNotEmpty
                                ? Hero(
                                    tag: 'staff_photo_${staff.id}',
                                    child: Image.network(
                                      staff.photoUrl!,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildStaffPlaceholder(initials);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return _buildStaffPlaceholder(initials);
                                      },
                                    ),
                                  )
                                : _buildStaffPlaceholder(initials),
                          ),
                          
                          // Status indicator (top right)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: SharedCardTheme.statusChip(isActive: staff.isActive),
                          ),
                        ],
                      ),
                    ),
                    
                    // Staff Info (similar to service info)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Staff name and role
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  staff.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  staff.role,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Staff details
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  staff.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                staff.phoneNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Performance metrics and schedule row
                          Row(
                            children: [
                              // Performance metrics
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildMetricChip(
                                      Icons.star,
                                      '${staff.averageRating.toStringAsFixed(1)}',
                                      Colors.amber,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildMetricChip(
                                      Icons.work,
                                      '${staff.totalServices}',
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Schedule info
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${ComprehensiveStaffService.formatTime(staff.startTime)} - ${ComprehensiveStaffService.formatTime(staff.endTime)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Inactive staff banner (similar to services)
                if (!staff.isActive)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'INACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffPlaceholder(String initials) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.person,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showStaffContextMenu(BuildContext context, StaffDto staff) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: staff.photoUrl != null && staff.photoUrl!.isNotEmpty
                        ? NetworkImage(staff.photoUrl!)
                        : null,
                    child: staff.photoUrl == null || staff.photoUrl!.isEmpty
                        ? Text(ComprehensiveStaffService.getStaffInitials(staff.firstName, staff.lastName))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          staff.role,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Actions
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _viewStaffDetails(staff);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Edit Staff'),
              onTap: () {
                Navigator.pop(context);
                _editStaff(staff);
              },
            ),
            ListTile(
              leading: Icon(
                staff.isActive ? Icons.pause_circle : Icons.play_circle,
                color: staff.isActive ? Colors.orange : Colors.green,
              ),
              title: Text(staff.isActive ? 'Deactivate' : 'Activate'),
              onTap: () {
                Navigator.pop(context);
                _toggleStaffStatus(staff);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Remove Staff',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteStaff(staff);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewStaffDetails(StaffDto staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffDetailScreen(staff: staff),
      ),
    ).then((_) => _refreshStaff());
  }

  void _editStaff(StaffDto staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStaffScreen(staff: staff),
      ),
    ).then((_) => _refreshStaff());
  }

  Future<void> _toggleStaffStatus(StaffDto staff) async {
    try {
      await _staffService.toggleStaffStatus(staff.id, !staff.isActive);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Staff ${!staff.isActive ? "activated" : "deactivated"} successfully!',
            ),
            backgroundColor: !staff.isActive ? Colors.green : Colors.orange,
          ),
        );
        _refreshStaff();
      }
    } catch (e) {
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

  Future<void> _deleteStaff(StaffDto staff) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove "${staff.fullName}" from your staff?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. The staff member will lose access to their account.',
              style: TextStyle(color: Colors.red),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _staffService.deleteStaff(staff.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff member removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshStaff();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing staff: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
