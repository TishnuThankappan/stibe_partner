import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';

class StaffScheduleManagementScreen extends StatefulWidget {
  final int staffId;
  final String staffName;

  const StaffScheduleManagementScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffScheduleManagementScreen> createState() => _StaffScheduleManagementScreenState();
}

class _StaffScheduleManagementScreenState extends State<StaffScheduleManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _weekSchedule = [];
  List<Map<String, dynamic>> _todayBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadScheduleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadScheduleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _weekSchedule = _generateWeekSchedule();
        _todayBookings = _generateTodayBookings();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateWeekSchedule() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final isToday = date.day == now.day && date.month == now.month;
      final isWeekend = date.weekday > 5;
      
      return {
        'date': date,
        'dayName': _getDayName(date.weekday),
        'dayNumber': date.day,
        'isToday': isToday,
        'isWorkDay': !isWeekend,
        'startTime': isWeekend ? null : '09:00',
        'endTime': isWeekend ? null : '17:00',
        'breakStart': isWeekend ? null : '13:00',
        'breakEnd': isWeekend ? null : '14:00',
        'bookingsCount': isWeekend ? 0 : (3 + (index % 4)),
        'revenue': isWeekend ? 0.0 : (1200.0 + (index * 200)),
        'utilization': isWeekend ? 0 : (70 + (index * 5)),
        'status': isWeekend ? 'Off' : (isToday ? 'Active' : 'Scheduled'),
      };
    });
  }

  List<Map<String, dynamic>> _generateTodayBookings() {
    return [
      {
        'id': 1,
        'time': '10:00 AM',
        'customerName': 'Sarah Johnson',
        'serviceName': 'Hair Coloring',
        'duration': 90,
        'status': 'Confirmed',
        'amount': 2500.0,
        'commission': 1000.0,
      },
      {
        'id': 2,
        'time': '11:45 AM',
        'customerName': 'Priya Sharma',
        'serviceName': 'Hair Cut & Style',
        'duration': 60,
        'status': 'Confirmed',
        'amount': 1200.0,
        'commission': 480.0,
      },
      {
        'id': 3,
        'time': '2:30 PM',
        'customerName': 'Anjali Reddy',
        'serviceName': 'Hair Treatment',
        'duration': 45,
        'status': 'Confirmed',
        'amount': 1800.0,
        'commission': 720.0,
      },
      {
        'id': 4,
        'time': '4:00 PM',
        'customerName': 'Meera Patel',
        'serviceName': 'Hair Cut',
        'duration': 30,
        'status': 'Pending',
        'amount': 800.0,
        'commission': 320.0,
      },
    ];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.staffName} Schedule',
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              _showDatePicker();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScheduleData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date Selector Header
                _buildDateSelectorHeader(),
                
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Week View', icon: Icon(Icons.view_week, size: 18)),
                      Tab(text: 'Today', icon: Icon(Icons.today, size: 18)),
                      Tab(text: 'Time Off', icon: Icon(Icons.event_busy, size: 18)),
                    ],
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWeekViewTab(),
                      _buildTodayTab(),
                      _buildTimeOffTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showScheduleOptionsDialog();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Manage'),
      ),
    );
  }

  Widget _buildDateSelectorHeader() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFormattedDate(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.staffName}\'s Schedule',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                      });
                      _loadScheduleData();
                    },
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 7));
                      });
                      _loadScheduleData();
                    },
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'This Week',
                  '${_weekSchedule.where((day) => day['isWorkDay']).fold<int>(0, (sum, day) => sum + (day['bookingsCount'] as int))}',
                  'Bookings',
                  Icons.event,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Revenue',
                  '₹${_weekSchedule.fold(0.0, (sum, day) => sum + day['revenue']).toStringAsFixed(0)}',
                  'This Week',
                  Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Utilization',
                  '${(_weekSchedule.where((day) => day['isWorkDay']).fold<int>(0, (sum, day) => sum + (day['utilization'] as int)) / _weekSchedule.where((day) => day['isWorkDay']).length).toStringAsFixed(0)}%',
                  'Average',
                  Icons.trending_up,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekViewTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _weekSchedule.length,
      itemBuilder: (context, index) {
        final day = _weekSchedule[index];
        return _buildDayCard(day);
      },
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final isToday = day['isToday'] == true;
    final isWorkDay = day['isWorkDay'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isToday 
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Day info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          day['dayName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isToday ? AppColors.primary : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${day['dayNumber']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'TODAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWorkDay 
                          ? '${day['startTime']} - ${day['endTime']}'
                          : 'Day Off',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(day['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(day['status']),
                    ),
                  ),
                ),
              ],
            ),
            
            if (isWorkDay) ...[
              const SizedBox(height: 12),
              
              // Schedule stats
              Row(
                children: [
                  Expanded(
                    child: _buildScheduleStatItem(
                      'Bookings',
                      '${day['bookingsCount']}',
                      Icons.event,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildScheduleStatItem(
                      'Revenue',
                      '₹${day['revenue'].toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildScheduleStatItem(
                      'Utilization',
                      '${day['utilization']}%',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Lunch break info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Lunch: ${day['breakStart']} - ${day['breakEnd']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
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
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today's summary
        Container(
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
                  Icon(Icons.today, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getFormattedDate(DateTime.now()),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTodayStatCard(
                      'Total Bookings',
                      '${_todayBookings.length}',
                      Icons.event,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTodayStatCard(
                      'Expected Revenue',
                      '₹${_todayBookings.fold(0.0, (sum, booking) => sum + booking['amount']).toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Today's appointments
        Text(
          'Today\'s Appointments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        if (_todayBookings.isEmpty)
          _buildEmptyBookingsCard()
        else
          ..._todayBookings.map((booking) => _buildBookingCard(booking)).toList(),
      ],
    );
  }

  Widget _buildTodayStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            'Enjoy your free day or check for walk-ins!',
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
    final status = booking['status'];
    final isConfirmed = status == 'Confirmed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isConfirmed 
            ? Border.all(color: Colors.green.withOpacity(0.3))
            : Border.all(color: Colors.orange.withOpacity(0.3)),
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
              // Time
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isConfirmed ? Colors.green : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isConfirmed ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Customer and service info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  booking['customerName'][0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
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
                    Text(
                      '${booking['duration']} minutes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${booking['amount'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${booking['commission'].toStringAsFixed(0)} commission',
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
        ],
      ),
    );
  }

  Widget _buildTimeOffTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Time Off Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage vacation days, sick leave, and other time-off requests. This feature will be available soon.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Time off management coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.event_busy),
              label: const Text('Request Time Off'),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'scheduled': return Colors.blue;
      case 'off': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _loadScheduleData();
    }
  }

  void _showScheduleOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Schedule Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.edit_calendar, color: Colors.blue),
              title: const Text('Modify Work Hours'),
              subtitle: const Text('Change daily work schedule'),
              onTap: () {
                Navigator.pop(context);
                _showModifyHoursDialog();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.event_busy, color: Colors.orange),
              title: const Text('Request Time Off'),
              subtitle: const Text('Submit vacation or sick leave request'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Time off request feature coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.green),
              title: const Text('Shift Exchange'),
              subtitle: const Text('Request to exchange shifts with another staff'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shift exchange feature coming soon!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.purple),
              title: const Text('Schedule Notifications'),
              subtitle: const Text('Manage schedule-related notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings coming soon!'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showModifyHoursDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modify work hours feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
