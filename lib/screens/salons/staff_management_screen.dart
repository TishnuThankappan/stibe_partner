import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class StaffManagementScreen extends StatefulWidget {
  final int salonId;
  
  const StaffManagementScreen({super.key, required this.salonId});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _staff = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    // Simulate loading staff data
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Replace with actual API call to fetch salon staff
    setState(() {
      _staff = []; // Empty list - no sample data
      _isLoading = false;
    });
  }

  Future<void> _refreshStaff() async {
    setState(() {
      _isLoading = true;
    });
    await _loadStaff();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_staff.length} Staff Members',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddStaffDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add Staff'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Staff List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshStaff,
            child: _staff.isEmpty
                ? _buildEmptyState()
                : _buildStaffList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Staff Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first staff member to get started',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _staff.length,
      itemBuilder: (context, index) {
        final staffMember = _staff[index];
        return _buildStaffCard(staffMember);
      },
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staffMember) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(
          color: staffMember['isActive'] ? Colors.transparent : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStaffDetailsDialog(staffMember),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        staffMember['name'].split(' ').map((name) => name[0]).join().toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Staff Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  staffMember['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: staffMember['isActive'] 
                                      ? Colors.green.withOpacity(0.1) 
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  staffMember['isActive'] ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: staffMember['isActive'] 
                                        ? Colors.green.shade700 
                                        : Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            staffMember['role'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${staffMember['rating']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${staffMember['completedBookings']} bookings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // More Menu
                    IconButton(
                      onPressed: () => _showStaffOptionsMenu(staffMember),
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Contact Info
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      staffMember['email'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      staffMember['phone'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Specialties
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (staffMember['specialties'] as List<String>)
                      .map((specialty) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              specialty,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Staff Member'),
        content: const Text('Staff member creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement staff creation
            },
            child: const Text('Add Staff'),
          ),
        ],
      ),
    );
  }

  void _showStaffDetailsDialog(Map<String, dynamic> staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staffMember['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${staffMember['role']}'),
            Text('Email: ${staffMember['email']}'),
            Text('Phone: ${staffMember['phone']}'),
            Text('Rating: ${staffMember['rating']}'),
            Text('Completed Bookings: ${staffMember['completedBookings']}'),
            Text('Join Date: ${staffMember['joinDate']}'),
            Text('Status: ${staffMember['isActive'] ? 'Active' : 'Inactive'}'),
            const SizedBox(height: 8),
            const Text('Specialties:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...((staffMember['specialties'] as List<String>).map((specialty) => Text('• $specialty'))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement edit staff
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showStaffOptionsMenu(Map<String, dynamic> staffMember) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Staff Member'),
            onTap: () {
              Navigator.pop(context);
              // Implement edit staff
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Manage Schedule'),
            onTap: () {
              Navigator.pop(context);
              // Implement schedule management
            },
          ),
          ListTile(
            leading: Icon(
              staffMember['isActive'] ? Icons.pause_circle : Icons.play_circle,
            ),
            title: Text(staffMember['isActive'] ? 'Deactivate' : 'Activate'),
            onTap: () {
              Navigator.pop(context);
              // Implement toggle staff status
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('View Performance'),
            onTap: () {
              Navigator.pop(context);
              // Implement performance analytics
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove, color: Colors.red),
            title: const Text('Remove Staff', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Implement remove staff
            },
          ),
        ],
      ),
    );
  }
}
