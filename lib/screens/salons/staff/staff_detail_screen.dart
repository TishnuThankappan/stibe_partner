import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/api/comprehensive_staff_service.dart';
import 'package:stibe_partner/screens/salons/staff/edit_staff_screen.dart';
import 'package:stibe_partner/screens/salons/staff/staff_dashboard_screen.dart';
import 'package:stibe_partner/screens/salons/staff/staff_schedule_management_screen.dart';

class StaffDetailScreen extends StatefulWidget {
  final StaffDto staff;

  const StaffDetailScreen({
    super.key,
    required this.staff,
  });

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ComprehensiveStaffService _staffService = ComprehensiveStaffService();
  
  bool _isLoading = false;
  Map<String, dynamic> _performanceData = {};
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _specializations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdditionalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdditionalData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load performance data, bookings, and specializations in parallel
      final results = await Future.wait([
        _staffService.getStaffPerformance(widget.staff.id),
        _staffService.getStaffBookings(widget.staff.id),
        _staffService.getStaffSpecializations(widget.staff.id),
      ]);

      setState(() {
        _performanceData = results[0] as Map<String, dynamic>;
        _recentBookings = results[1] as List<Map<String, dynamic>>;
        _specializations = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Use dummy data if API fails
      _setDummyData();
    }
  }

  void _setDummyData() {
    _performanceData = {
      'todayServices': 3,
      'todayEarnings': 2400.0,
      'weekServices': 18,
      'weekEarnings': 14400.0,
      'monthServices': 67,
      'monthEarnings': 54000.0,
      'utilizationPercentage': 85.0,
    };
    
    _recentBookings = [
      {
        'customerName': 'Sarah Johnson',
        'serviceName': 'Hair Cut & Style',
        'scheduledTime': '10:00 AM',
        'status': 'Completed',
        'amount': 800.0,
      },
      {
        'customerName': 'Mike Davis',
        'serviceName': 'Hair Coloring',
        'scheduledTime': '2:00 PM',
        'status': 'Scheduled',
        'amount': 1500.0,
      },
    ];
    
    _specializations = [
      {
        'serviceName': 'Hair Cutting',
        'proficiencyLevel': 'Expert',
        'isPreferred': true,
      },
      {
        'serviceName': 'Hair Coloring',
        'proficiencyLevel': 'Advanced',
        'isPreferred': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = ComprehensiveStaffService.getStaffAvatarColor(widget.staff.fullName);
    final initials = ComprehensiveStaffService.getStaffInitials(widget.staff.firstName, widget.staff.lastName);
    final staffCode = ComprehensiveStaffService.generateStaffCode(
      widget.staff.firstName, 
      widget.staff.lastName, 
      widget.staff.id
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff.fullName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStaffScreen(staff: widget.staff),
                ),
              ).then((_) {
                // Refresh data if needed
                _loadAdditionalData();
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'dashboard',
                child: ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.blue),
                  title: Text('View Dashboard'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: ListTile(
                  leading: Icon(
                    widget.staff.isActive ? Icons.pause_circle : Icons.play_circle,
                    color: widget.staff.isActive ? Colors.orange : Colors.green,
                  ),
                  title: Text(widget.staff.isActive ? 'Deactivate' : 'Activate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'schedule',
                child: ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text('Manage Schedule'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'earnings',
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('View Earnings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Remove Staff', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Profile', icon: Icon(Icons.person, size: 18)),
            Tab(text: 'Performance', icon: Icon(Icons.analytics, size: 18)),
            Tab(text: 'Bookings', icon: Icon(Icons.calendar_today, size: 18)),
            Tab(text: 'Skills', icon: Icon(Icons.star, size: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Staff Header Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar and basic info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(int.parse(avatarColor.substring(1), radix: 16) + 0xFF000000),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: widget.staff.photoUrl != null && widget.staff.photoUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  widget.staff.photoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.staff.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.staff.role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.staff.isActive 
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.staff.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                              child: Text(
                                widget.staff.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: widget.staff.isActive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Quick stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        '${widget.staff.averageRating.toStringAsFixed(1)}',
                        'Rating',
                        Icons.star,
                      ),
                      _buildQuickStat(
                        '${widget.staff.totalServices}',
                        'Services',
                        Icons.work,
                      ),
                      _buildQuickStat(
                        '${widget.staff.experienceYears}y',
                        'Experience',
                        Icons.timeline,
                      ),
                      _buildQuickStat(
                        staffCode,
                        'Staff ID',
                        Icons.badge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildPerformanceTab(),
                _buildBookingsTab(),
                _buildSkillsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Information
        _buildInfoSection(
          'Contact Information',
          Icons.contact_phone,
          [
            _buildInfoRow('Email', widget.staff.email, Icons.email),
            _buildInfoRow('Phone', widget.staff.phoneNumber, Icons.phone),
            if (widget.staff.instagramHandle.isNotEmpty)
              _buildInfoRow('Instagram', widget.staff.instagramHandle, Icons.camera_alt),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Work Schedule
        _buildInfoSection(
          'Work Schedule',
          Icons.schedule,
          [
            _buildInfoRow(
              'Working Hours',
              '${ComprehensiveStaffService.formatTime(widget.staff.startTime)} - ${ComprehensiveStaffService.formatTime(widget.staff.endTime)}',
              Icons.access_time,
            ),
            _buildInfoRow(
              'Lunch Break',
              '${ComprehensiveStaffService.formatTime(widget.staff.lunchBreakStart)} - ${ComprehensiveStaffService.formatTime(widget.staff.lunchBreakEnd)}',
              Icons.restaurant,
            ),
            _buildInfoRow('Employment Type', widget.staff.employmentType, Icons.work_outline),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Financial Information
        _buildInfoSection(
          'Financial Information',
          Icons.attach_money,
          [
            _buildInfoRow('Hourly Rate', '₹${widget.staff.hourlyRate.toStringAsFixed(0)}/hour', Icons.money),
            _buildInfoRow('Commission Rate', '${widget.staff.commissionRate.toStringAsFixed(0)}%', Icons.percent),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Bio
        if (widget.staff.bio.isNotEmpty)
          _buildInfoSection(
            'About',
            Icons.person,
            [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.staff.bio,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Languages & Certifications
        if (widget.staff.languagesAsList.isNotEmpty || widget.staff.certificationsAsList.isNotEmpty)
          _buildInfoSection(
            'Skills & Certifications',
            Icons.star,
            [
              if (widget.staff.languagesAsList.isNotEmpty) ...[
                _buildChipSection('Languages', widget.staff.languagesAsList, AppColors.primary),
                const SizedBox(height: 12),
              ],
              if (widget.staff.certificationsAsList.isNotEmpty)
                _buildChipSection('Certifications', widget.staff.certificationsAsList, Colors.green),
            ],
          ),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Performance Cards
        Row(
          children: [
            Expanded(
              child: _buildPerformanceCard(
                'Today',
                '${_performanceData['todayServices'] ?? 0}',
                'Services',
                '₹${(_performanceData['todayEarnings'] ?? 0).toStringAsFixed(0)}',
                'Earnings',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPerformanceCard(
                'This Week',
                '${_performanceData['weekServices'] ?? 0}',
                'Services',
                '₹${(_performanceData['weekEarnings'] ?? 0).toStringAsFixed(0)}',
                'Earnings',
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildPerformanceCard(
          'This Month',
          '${_performanceData['monthServices'] ?? 0}',
          'Services',
          '₹${(_performanceData['monthEarnings'] ?? 0).toStringAsFixed(0)}',
          'Earnings',
          Colors.purple,
          isWide: true,
        ),
        
        const SizedBox(height: 24),
        
        // Utilization Rate
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Utilization Rate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_performanceData['utilizationPercentage'] ?? 0) / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(_performanceData['utilizationPercentage'] ?? 0).toStringAsFixed(0)}% utilization',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Recent Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            Text(
              'Bookings will appear here when scheduled',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentBookings.length,
      itemBuilder: (context, index) {
        final booking = _recentBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildSkillsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Specializations
        if (_specializations.isNotEmpty) ...[
          _buildInfoSection(
            'Service Specializations',
            Icons.star,
            _specializations.map((spec) => _buildSpecializationItem(spec)).toList(),
          ),
          const SizedBox(height: 24),
        ],
        
        // Add new specialization button
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to add specialization screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add specialization coming soon!'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Specialization'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(
    String period,
    String servicesValue,
    String servicesLabel,
    String earningsValue,
    String earningsLabel,
    Color color, {
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (isWide)
            Row(
              children: [
                Expanded(child: _buildStatColumn(servicesValue, servicesLabel, color)),
                const SizedBox(width: 20),
                Expanded(child: _buildStatColumn(earningsValue, earningsLabel, color)),
              ],
            )
          else ...[
            _buildStatColumn(servicesValue, servicesLabel, color),
            const SizedBox(height: 12),
            _buildStatColumn(earningsValue, earningsLabel, color),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(booking['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(booking['status']),
              color: _getStatusColor(booking['status']),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['customerName'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  booking['serviceName'] ?? 'Unknown Service',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      booking['scheduledTime'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking['status'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(booking['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${(booking['amount'] ?? 0).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationItem(Map<String, dynamic> spec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: spec['isPreferred'] == true 
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      spec['serviceName'] ?? 'Unknown Service',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (spec['isPreferred'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Preferred',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  spec['proficiencyLevel'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getProficiencyColor(spec['proficiencyLevel']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildProficiencyStars(spec['proficiencyLevel']),
        ],
      ),
    );
  }

  Widget _buildProficiencyStars(String? level) {
    int stars = 0;
    switch (level) {
      case 'Beginner': stars = 1; break;
      case 'Intermediate': stars = 2; break;
      case 'Advanced': stars = 3; break;
      case 'Expert': stars = 4; break;
      default: stars = 0;
    }

    return Row(
      children: List.generate(4, (index) => Icon(
        index < stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 16,
      )),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'scheduled': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'in-progress': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed': return Icons.check_circle;
      case 'scheduled': return Icons.schedule;
      case 'cancelled': return Icons.cancel;
      case 'in-progress': return Icons.hourglass_empty;
      default: return Icons.help;
    }
  }

  Color _getProficiencyColor(String? level) {
    switch (level) {
      case 'Expert': return Colors.purple;
      case 'Advanced': return Colors.blue;
      case 'Intermediate': return Colors.orange;
      case 'Beginner': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'dashboard':
        // Navigate to staff dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDashboardScreen(
              staffId: widget.staff.id,
              staffName: widget.staff.fullName,
            ),
          ),
        );
        break;
      case 'toggle_status':
        // TODO: Implement toggle status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toggle status coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'schedule':
        // Navigate to schedule management
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffScheduleManagementScreen(
              staffId: widget.staff.id,
              staffName: widget.staff.fullName,
            ),
          ),
        );
        break;
      case 'earnings':
        // TODO: Navigate to earnings screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Earnings report coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'delete':
        // TODO: Implement delete confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remove staff coming soon!'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }
}
