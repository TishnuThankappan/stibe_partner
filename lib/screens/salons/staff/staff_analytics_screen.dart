import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';

class StaffAnalyticsScreen extends StatefulWidget {
  final int staffId;
  final String staffName;

  const StaffAnalyticsScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffAnalyticsScreen> createState() => _StaffAnalyticsScreenState();
}

class _StaffAnalyticsScreenState extends State<StaffAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = false;
  String _selectedPeriod = 'month';
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _analyticsData = _generateAnalyticsData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _generateAnalyticsData() {
    return {
      'overview': {
        'totalRevenue': 125000.0,
        'totalServices': 420,
        'averageRating': 4.8,
        'totalReviews': 127,
        'utilizationRate': 85,
        'conversionRate': 92,
        'repeatCustomers': 78,
        'customerSatisfaction': 96,
      },
      'monthlyTrends': [
        {'month': 'Jan', 'revenue': 18000, 'services': 65, 'rating': 4.7},
        {'month': 'Feb', 'revenue': 19500, 'services': 68, 'rating': 4.8},
        {'month': 'Mar', 'revenue': 21000, 'services': 72, 'rating': 4.8},
        {'month': 'Apr', 'revenue': 20000, 'services': 70, 'rating': 4.9},
        {'month': 'May', 'revenue': 22500, 'services': 75, 'rating': 4.8},
        {'month': 'Jun', 'revenue': 24000, 'services': 80, 'rating': 4.8},
      ],
      'serviceBreakdown': [
        {'service': 'Hair Coloring', 'count': 85, 'revenue': 42500, 'avgRating': 4.9},
        {'service': 'Hair Cut & Style', 'count': 120, 'revenue': 36000, 'avgRating': 4.8},
        {'service': 'Hair Treatment', 'count': 95, 'revenue': 28500, 'avgRating': 4.7},
        {'service': 'Highlights', 'count': 75, 'revenue': 15000, 'avgRating': 4.8},
        {'service': 'Keratin Treatment', 'count': 45, 'revenue': 13500, 'avgRating': 4.9},
      ],
      'customerMetrics': {
        'newCustomers': 45,
        'returningCustomers': 78,
        'averageSpend': 1850.0,
        'topSpenders': [
          {'name': 'Sarah Johnson', 'visits': 12, 'totalSpent': 15600},
          {'name': 'Priya Sharma', 'visits': 8, 'totalSpent': 12400},
          {'name': 'Anjali Reddy', 'visits': 10, 'totalSpent': 11800},
        ],
        'customerFeedback': [
          {'rating': 5, 'count': 85, 'percentage': 67},
          {'rating': 4, 'count': 32, 'percentage': 25},
          {'rating': 3, 'count': 8, 'percentage': 6},
          {'rating': 2, 'count': 2, 'percentage': 2},
          {'rating': 1, 'count': 0, 'percentage': 0},
        ],
      },
      'timeAnalysis': {
        'peakHours': [
          {'hour': '10 AM', 'bookings': 15},
          {'hour': '11 AM', 'bookings': 18},
          {'hour': '2 PM', 'bookings': 20},
          {'hour': '3 PM', 'bookings': 17},
          {'hour': '4 PM', 'bookings': 12},
        ],
        'peakDays': [
          {'day': 'Monday', 'bookings': 22},
          {'day': 'Tuesday', 'bookings': 18},
          {'day': 'Wednesday', 'bookings': 20},
          {'day': 'Thursday', 'bookings': 25},
          {'day': 'Friday', 'bookings': 28},
          {'day': 'Saturday', 'bookings': 35},
          {'day': 'Sunday', 'bookings': 10},
        ],
        'averageServiceTime': {
          'Hair Coloring': 120,
          'Hair Cut & Style': 75,
          'Hair Treatment': 90,
          'Highlights': 150,
          'Keratin Treatment': 180,
        },
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.staffName} Analytics',
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadAnalyticsData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: 'quarter', child: Text('This Quarter')),
              const PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getPeriodLabel(_selectedPeriod),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Overview Header
                _buildOverviewHeader(),
                
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Performance', icon: Icon(Icons.trending_up, size: 18)),
                      Tab(text: 'Services', icon: Icon(Icons.spa, size: 18)),
                      Tab(text: 'Customers', icon: Icon(Icons.people, size: 18)),
                      Tab(text: 'Time', icon: Icon(Icons.schedule, size: 18)),
                    ],
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPerformanceTab(),
                      _buildServicesTab(),
                      _buildCustomersTab(),
                      _buildTimeAnalysisTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOverviewHeader() {
    final overview = _analyticsData['overview'] ?? {};
    
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
                      'Performance Analytics',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Key metrics
          Row(
            children: [
              Expanded(
                child: _buildOverviewMetric(
                  'Revenue',
                  '₹${(overview['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                  Icons.currency_rupee,
                ),
              ),
              Expanded(
                child: _buildOverviewMetric(
                  'Services',
                  '${overview['totalServices'] ?? 0}',
                  Icons.spa,
                ),
              ),
              Expanded(
                child: _buildOverviewMetric(
                  'Rating',
                  '${overview['averageRating'] ?? 0}',
                  Icons.star,
                ),
              ),
              Expanded(
                child: _buildOverviewMetric(
                  'Utilization',
                  '${overview['utilizationRate'] ?? 0}%',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetric(String label, String value, IconData icon) {
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
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final overview = _analyticsData['overview'] ?? {};
    final monthlyTrends = _analyticsData['monthlyTrends'] ?? [];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Key Performance Indicators
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Customer Satisfaction',
                '${overview['customerSatisfaction'] ?? 0}%',
                Icons.sentiment_very_satisfied,
                Colors.green,
                'Based on customer feedback',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Conversion Rate',
                '${overview['conversionRate'] ?? 0}%',
                Icons.trending_up,
                Colors.blue,
                'Service completion rate',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Repeat Customers',
                '${overview['repeatCustomers'] ?? 0}%',
                Icons.repeat,
                Colors.orange,
                'Customer retention rate',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Utilization Rate',
                '${overview['utilizationRate'] ?? 0}%',
                Icons.schedule,
                Colors.purple,
                'Time efficiency',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Monthly Performance Trend
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
              Text(
                'Monthly Performance Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Trend chart placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Performance Chart',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Interactive charts coming soon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Monthly data summary
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: monthlyTrends.map<Widget>((month) => 
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            month['month'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${month['revenue']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${month['services']} services',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${month['rating']} ★',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, String subtitle) {
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
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final serviceBreakdown = _analyticsData['serviceBreakdown'] ?? [];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Service Performance Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...serviceBreakdown.map<Widget>((service) => 
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    Expanded(
                      child: Text(
                        service['service'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${service['avgRating']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Services Provided',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${service['count']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revenue Generated',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '₹${service['revenue']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avg per Service',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '₹${(service['revenue'] / service['count']).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
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
        ).toList(),
      ],
    );
  }

  Widget _buildCustomersTab() {
    final customerMetrics = _analyticsData['customerMetrics'] ?? {};
    final topSpenders = customerMetrics['topSpenders'] ?? [];
    final feedback = customerMetrics['customerFeedback'] ?? [];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Customer Overview
        Row(
          children: [
            Expanded(
              child: _buildCustomerMetricCard(
                'New Customers',
                '${customerMetrics['newCustomers'] ?? 0}',
                Icons.person_add,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCustomerMetricCard(
                'Returning',
                '${customerMetrics['returningCustomers'] ?? 0}',
                Icons.repeat,
                Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        _buildCustomerMetricCard(
          'Average Spend',
          '₹${(customerMetrics['averageSpend'] ?? 0).toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.orange,
          isWide: true,
        ),
        
        const SizedBox(height: 24),
        
        // Top Customers
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
              Text(
                'Top Customers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              ...topSpenders.map<Widget>((customer) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          customer['name'][0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
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
                              customer['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${customer['visits']} visits',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${customer['totalSpent']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Customer Feedback
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
              Text(
                'Customer Feedback Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              ...feedback.map<Widget>((rating) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) => 
                          Icon(
                            index < rating['rating'] ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: rating['percentage'] / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            rating['rating'] >= 4 ? Colors.green : 
                            rating['rating'] >= 3 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${rating['count']} (${rating['percentage']}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerMetricCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
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
      child: isWide 
          ? Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
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
            ),
    );
  }

  Widget _buildTimeAnalysisTab() {
    final timeAnalysis = _analyticsData['timeAnalysis'] ?? {};
    final peakHours = timeAnalysis['peakHours'] ?? [];
    final peakDays = timeAnalysis['peakDays'] ?? [];
    final avgServiceTime = timeAnalysis['averageServiceTime'] ?? {};
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Peak Hours
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
              Text(
                'Peak Booking Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              ...peakHours.map<Widget>((hour) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          hour['hour'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: hour['bookings'] / 25,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${hour['bookings']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Peak Days
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
              Text(
                'Weekly Booking Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              ...peakDays.map<Widget>((day) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          day['day'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: day['bookings'] / 40,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${day['bookings']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Average Service Times
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
              Text(
                'Average Service Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              ...avgServiceTime.entries.map<Widget>((entry) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${entry.value} min',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      ],
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'week': return 'This Week';
      case 'month': return 'This Month';
      case 'quarter': return 'This Quarter';
      case 'year': return 'This Year';
      default: return 'This Month';
    }
  }
}
