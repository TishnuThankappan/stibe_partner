import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class ServiceAnalyticsScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServiceAnalyticsScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServiceAnalyticsScreen> createState() => _ServiceAnalyticsScreenState();
}

class _ServiceAnalyticsScreenState extends State<ServiceAnalyticsScreen> {
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  Map<String, dynamic> _analyticsData = {};
  List<ServiceDto> _topServices = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = '7days';

  final Map<String, String> _periodOptions = {
    '7days': 'Last 7 Days',
    '30days': 'Last 30 Days',
    '90days': 'Last 90 Days',
    '1year': 'Last Year',
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime? startDate;
      switch (_selectedPeriod) {
        case '7days':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '30days':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '90days':
          startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        case '1year':
          startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
      }

      final [analytics, topServices] = await Future.wait([
        _serviceService.getServiceAnalytics(
          widget.salonId,
          startDate: startDate,
          endDate: DateTime.now(),
        ),
        _serviceService.getTopPerformingServices(widget.salonId, limit: 10),
      ]);

      setState(() {
        _analyticsData = analytics as Map<String, dynamic>;
        _topServices = topServices as List<ServiceDto>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshAnalytics() async {
    await _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Service Analytics',
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadAnalytics();
            },
            itemBuilder: (context) => _periodOptions.entries
                .map((entry) => PopupMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          if (_selectedPeriod == entry.key)
                            const Icon(Icons.check, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalytics,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(),
          const SizedBox(height: 24),
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildTopServicesSection(),
          const SizedBox(height: 24),
          _buildRevenueBreakdown(),
          const SizedBox(height: 24),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Period',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _periodOptions[_selectedPeriod] ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.calendar_today, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalBookings = _analyticsData['totalBookings'] ?? 0;
    final totalRevenue = _analyticsData['totalRevenue'] ?? 0.0;
    final averageRating = _analyticsData['averageRating'] ?? 0.0;
    final totalServices = _analyticsData['totalServices'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildOverviewCard(
              title: 'Total Bookings',
              value: totalBookings.toString(),
              icon: Icons.calendar_month,
              color: Colors.blue,
            ),
            _buildOverviewCard(
              title: 'Total Revenue',
              value: '\$${totalRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _buildOverviewCard(
              title: 'Average Rating',
              value: averageRating.toStringAsFixed(1),
              icon: Icons.star,
              color: Colors.orange,
            ),
            _buildOverviewCard(
              title: 'Active Services',
              value: totalServices.toString(),
              icon: Icons.spa,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performing Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_topServices.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.trending_up, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No performance data available',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topServices.length,
            itemBuilder: (context, index) {
              final service = _topServices[index];
              return _buildTopServiceCard(service, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildTopServiceCard(ServiceDto service, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank).withOpacity(0.1),
          child: Text(
            '#$rank',
            style: TextStyle(
              color: _getRankColor(rank),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.formattedPrice),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  service.averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.event, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${service.bookingCount} bookings',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: service.isPopular
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildRevenueBreakdown() {
    final revenueByCategory = _analyticsData['revenueByCategory'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'By Service Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (revenueByCategory.isEmpty)
                const Text('No revenue data available')
              else
                ...revenueByCategory.entries.map((entry) {
                  final percentage = ((entry.value as double) / 
                      revenueByCategory.values.fold<double>(0, (sum, val) => sum + (val as double))) * 100;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(entry.key),
                        ),
                        Text(
                          '\$${(entry.value as double).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    final avgBookingDuration = _analyticsData['averageBookingDuration'] ?? 0;
    final repeatCustomerRate = _analyticsData['repeatCustomerRate'] ?? 0.0;
    final cancellationRate = _analyticsData['cancellationRate'] ?? 0.0;
    final peakHours = _analyticsData['peakHours'] as List<int>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMetricRow(
                'Average Booking Duration',
                '${avgBookingDuration} minutes',
                Icons.access_time,
              ),
              const Divider(),
              _buildMetricRow(
                'Repeat Customer Rate',
                '${(repeatCustomerRate * 100).toStringAsFixed(1)}%',
                Icons.repeat,
              ),
              const Divider(),
              _buildMetricRow(
                'Cancellation Rate',
                '${(cancellationRate * 100).toStringAsFixed(1)}%',
                Icons.cancel,
              ),
              const Divider(),
              _buildMetricRow(
                'Peak Hours',
                peakHours.isEmpty 
                    ? 'No data' 
                    : peakHours.map((h) => '${h}:00').join(', '),
                Icons.schedule,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
