import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';

class StaffDashboardScreen extends StatefulWidget {
  final int staffId;
  final String staffName;

  const StaffDashboardScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // final ComprehensiveStaffService _staffService = ComprehensiveStaffService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // This would call the staff dashboard API endpoint
      // final dashboard = await _staffService.getStaffDashboard(widget.staffId);
      
      // For now, let's simulate dashboard data
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _dashboardData = _getMockDashboardData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Map<String, dynamic> _getMockDashboardData() {
    return {
      'profile': {
        'firstName': widget.staffName.split(' ').first,
        'lastName': widget.staffName.split(' ').length > 1 ? widget.staffName.split(' ').last : '',
        'role': 'Senior Stylist',
        'photoUrl': null,
        'experienceYears': 5,
        'averageRating': 4.8,
        'totalReviews': 127,
        'salonName': 'Stibe Studio',
        'isOnShift': true,
        'shiftStart': '09:00',
        'shiftEnd': '17:00',
        'currentStatus': 'Available',
      },
      'todayWork': {
        'workDate': DateTime.now(),
        'clockInTime': '09:15',
        'clockOutTime': null,
        'isClockedIn': true,
        'scheduledMinutes': 480,
        'workedMinutes': 180,
        'servicesCompleted': 3,
        'servicesRemaining': 4,
        'todayEarnings': 1200.0,
        'todayCommission': 480.0,
        'utilizationPercentage': 75.0,
        'nextBreakTime': '13:00',
        'currentStatus': 'Available',
        'statusMessage': 'Ready for next appointment',
      },
      'todayBookings': [
        {
          'bookingId': 1,
          'customerName': 'Sarah Johnson',
          'customerPhone': '+91-9876543210',
          'serviceName': 'Hair Coloring & Styling',
          'scheduledTime': '10:00',
          'estimatedStartTime': '10:00',
          'estimatedEndTime': '11:30',
          'durationMinutes': 90,
          'servicePrice': 2500.0,
          'expectedCommission': 1000.0,
          'status': 'Confirmed',
          'serviceStatus': 'Completed',
          'notes': 'Customer prefers cooler tones',
          'isRunningLate': false,
          'delayMinutes': 0,
          'isNextBooking': false,
        },
        {
          'bookingId': 2,
          'customerName': 'Priya Sharma',
          'customerPhone': '+91-9876543211',
          'serviceName': 'Hair Cut & Blow Dry',
          'scheduledTime': '14:00',
          'estimatedStartTime': '14:00',
          'estimatedEndTime': '15:00',
          'durationMinutes': 60,
          'servicePrice': 800.0,
          'expectedCommission': 320.0,
          'status': 'Confirmed',
          'serviceStatus': 'Scheduled',
          'notes': '',
          'isRunningLate': false,
          'delayMinutes': 0,
          'isNextBooking': true,
        },
      ],
      'performance': {
        'todayServices': 3,
        'todayEarnings': 1200.0,
        'weekServices': 18,
        'weekEarnings': 7200.0,
        'monthServices': 65,
        'monthEarnings': 26000.0,
        'averageRating': 4.8,
        'totalReviews': 127,
        'utilizationPercentage': 85,
        'topServices': ['Hair Coloring', 'Hair Cut', 'Highlights'],
        'achievements': ['⭐ Customer Favorite', '🎯 Top Performer', '💎 Quality Expert'],
      },
      'notifications': [
        {
          'id': 1,
          'type': 'Reminder',
          'title': 'Lunch Break Soon',
          'message': 'Your lunch break starts in 30 minutes',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 10)),
          'isRead': false,
          'priority': 'Low',
        },
        {
          'id': 2,
          'type': 'Booking',
          'title': 'New Booking Added',
          'message': 'Priya Sharma booked Hair Cut for 2:00 PM',
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': false,
          'priority': 'Medium',
        },
      ],
      'monthlyTarget': {
        'month': DateTime.now().month,
        'year': DateTime.now().year,
        'monthName': _getMonthName(DateTime.now().month),
        'targetRevenue': 25000.0,
        'actualRevenue': 18000.0,
        'revenueProgress': 72.0,
        'targetServices': 80,
        'actualServices': 58,
        'serviceProgress': 72.5,
        'targetRating': 4.5,
        'actualRating': 4.8,
        'potentialBonus': 2500.0,
        'bonusEligible': false,
        'bonusStatus': 'In Progress',
        'achievements': ['⭐ Excellence in Service Quality'],
        'recommendations': ['Focus on booking more appointments to reach service target'],
      },
    };
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.staffName} Dashboard',
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildDashboardContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        // Quick Stats Header
        _buildQuickStatsHeader(),
        
        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Today', icon: Icon(Icons.today, size: 20)),
              Tab(text: 'Performance', icon: Icon(Icons.analytics, size: 20)),
              Tab(text: 'Schedule', icon: Icon(Icons.schedule, size: 20)),
              Tab(text: 'Notifications', icon: Icon(Icons.notifications, size: 20)),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(),
              _buildPerformanceTab(),
              _buildScheduleTab(),
              _buildNotificationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsHeader() {
    final todayWork = _dashboardData!['todayWork'];
    final performance = _dashboardData!['performance'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Staff Status
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  widget.staffName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.staffName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_dashboardData!['profile']['role']} • ${todayWork['currentStatus']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: todayWork['isClockedIn'] ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      todayWork['isClockedIn'] ? Icons.access_time : Icons.schedule,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todayWork['isClockedIn'] ? 'On Shift' : 'Off Shift',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Today',
                  '${todayWork['servicesCompleted']}/${todayWork['servicesCompleted'] + todayWork['servicesRemaining']}',
                  'Services',
                  Icons.spa,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Earnings',
                  '₹${todayWork['todayEarnings'].toStringAsFixed(0)}',
                  'Today',
                  Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Rating',
                  '${performance['averageRating']}',
                  '(${performance['totalReviews']} reviews)',
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
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
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    final todayWork = _dashboardData!['todayWork'];
    final todayBookings = _dashboardData!['todayBookings'] as List;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Work Summary Card
          _buildWorkSummaryCard(todayWork),
          const SizedBox(height: 16),
          
          // Today's Bookings
          Text(
            'Today\'s Appointments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (todayBookings.isEmpty)
            _buildEmptyBookingsCard()
          else
            ...todayBookings.map((booking) => _buildBookingCard(booking)).toList(),
        ],
      ),
    );
  }

  Widget _buildWorkSummaryCard(Map<String, dynamic> todayWork) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Work Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Work Time Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: todayWork['workedMinutes'] / todayWork['scheduledMinutes'],
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(todayWork['workedMinutes'] / 60).toStringAsFixed(1)}h / ${(todayWork['scheduledMinutes'] / 60).toStringAsFixed(1)}h',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${todayWork['utilizationPercentage'].toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick Stats Row
          Row(
            children: [
              Expanded(
                child: _buildWorkStatItem(
                  'Clock In',
                  todayWork['clockInTime'] ?? 'Not clocked in',
                  Icons.login,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildWorkStatItem(
                  'Services',
                  '${todayWork['servicesCompleted']}/${todayWork['servicesCompleted'] + todayWork['servicesRemaining']}',
                  Icons.spa,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildWorkStatItem(
                  'Earnings',
                  '₹${todayWork['todayEarnings'].toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBookingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Appointments Today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your free day or check if there are any walk-ins!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isCompleted = booking['serviceStatus'] == 'Completed';
    final isNext = booking['isNextBooking'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isNext 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : 
                         isNext ? AppColors.primary : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              
              // Time
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isNext ? AppColors.primary : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['scheduledTime'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isNext ? AppColors.primary : Colors.grey.shade700,
                  ),
                ),
              ),
              
              if (isNext) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Service status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['serviceStatus'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Customer info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  booking['customerName'][0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['customerName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      booking['serviceName'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${booking['servicePrice'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${booking['expectedCommission'].toStringAsFixed(0)} commission',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (booking['notes']?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking['notes'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final performance = _dashboardData!['performance'];
    final monthlyTarget = _dashboardData!['monthlyTarget'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Overview
          _buildPerformanceOverview(performance),
          const SizedBox(height: 16),
          
          // Monthly Target Progress
          _buildMonthlyTargetCard(monthlyTarget),
          const SizedBox(height: 16),
          
          // Achievements & Top Services
          Row(
            children: [
              Expanded(child: _buildAchievementsCard(performance['achievements'])),
              const SizedBox(width: 12),
              Expanded(child: _buildTopServicesCard(performance['topServices'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(Map<String, dynamic> performance) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Performance metrics
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  'This Month',
                  '${performance['monthServices']} services',
                  '₹${performance['monthEarnings'].toStringAsFixed(0)}',
                  Icons.calendar_month,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                  'This Week',
                  '${performance['weekServices']} services',
                  '₹${performance['weekEarnings'].toStringAsFixed(0)}',
                  Icons.date_range,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                  'Today',
                  '${performance['todayServices']} services',
                  '₹${performance['todayEarnings'].toStringAsFixed(0)}',
                  Icons.today,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Utilization & Rating
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utilization Rate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: performance['utilizationPercentage'] / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${performance['utilizationPercentage']}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${performance['averageRating']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${performance['totalReviews']} reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

  Widget _buildPerformanceMetric(String period, String services, String earnings, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          period,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          services,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          earnings,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTargetCard(Map<String, dynamic> monthlyTarget) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                '${monthlyTarget['monthName']} ${monthlyTarget['year']} Target',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Revenue Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Revenue Target',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${monthlyTarget['actualRevenue'].toStringAsFixed(0)} / ₹${monthlyTarget['targetRevenue'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: monthlyTarget['revenueProgress'] / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 4),
              Text(
                '${monthlyTarget['revenueProgress'].toStringAsFixed(1)}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Services Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services Target',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${monthlyTarget['actualServices']} / ${monthlyTarget['targetServices']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: monthlyTarget['serviceProgress'] / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 4),
              Text(
                '${monthlyTarget['serviceProgress'].toStringAsFixed(1)}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          if (monthlyTarget['potentialBonus'] > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonus Potential',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        Text(
                          '₹${monthlyTarget['potentialBonus'].toStringAsFixed(0)} - ${monthlyTarget['bonusStatus']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(List achievements) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...achievements.map((achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    achievement.toString().replaceAll(RegExp(r'^[^\s]*\s'), ''),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTopServicesCard(List topServices) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...topServices.asMap().entries.map((entry) {
            int index = entry.key;
            String service = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Schedule Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Advanced schedule management features coming soon! This will include shift planning, availability management, and schedule optimization.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Schedule management feature coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.schedule),
              label: const Text('View Schedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    final notifications = _dashboardData!['notifications'] as List;
    
    return notifications.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up! New notifications will appear here.',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] == true;
    final priority = notification['priority'];
    
    Color priorityColor = Colors.grey;
    if (priority == 'High') priorityColor = Colors.red;
    else if (priority == 'Medium') priorityColor = Colors.orange;
    else if (priority == 'Low') priorityColor = Colors.blue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isRead ? null : Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification['message']),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(DateTime.parse(notification['createdAt'].toString())),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: isRead ? null : const Icon(
          Icons.circle,
          color: Colors.blue,
          size: 8,
        ),
        onTap: () {
          // Mark as read functionality would go here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification: ${notification['title']}'),
              backgroundColor: priorityColor,
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
