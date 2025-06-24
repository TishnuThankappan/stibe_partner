import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final dateFormatter = DateFormat('MMM dd, yyyy');
  String _selectedTimeRange = 'This Month';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Finances',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Revenue summary card
          _buildRevenueSummaryCard(),
          
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Transactions'),
                Tab(text: 'Reports'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTransactionsTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRevenueSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A90E2),
            Color(0xFF50E3C2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Revenue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: _selectedTimeRange,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  underline: const SizedBox(),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTimeRange = newValue!;
                    });
                  },
                  items: <String>['Today', 'This Week', 'This Month', 'This Year']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: _selectedTimeRange == value
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormatter.format(8945.75),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '12.5%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'vs previous period',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
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
          _buildSectionTitle('Revenue Breakdown'),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Top Services by Revenue'),
          const SizedBox(height: 16),
          _buildTopServicesCard(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Recent Transactions'),
          const SizedBox(height: 16),
          _buildRecentTransactionsList(),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filter options
                  },
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Transactions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: 20,
            itemBuilder: (context, index) {
              // Generate mock transaction data
              final bool isIncome = index % 3 != 0;
              final double amount = (index + 1) * 25.0 + (index * 3.5);
              final DateTime date = DateTime.now().subtract(Duration(days: index));
              
              return _buildTransactionItem(
                isIncome: isIncome,
                amount: amount,
                date: date,
                title: isIncome ? 'Service Payment' : 'Inventory Purchase',
                subtitle: isIncome ? 'Hair Cut & Styling' : 'Shampoo Products',
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildReportsTab() {
    final reportItems = [
      {
        'title': 'Monthly Revenue Report',
        'description': 'Detailed breakdown of all revenue sources',
        'icon': Icons.bar_chart,
      },
      {
        'title': 'Service Performance',
        'description': 'Analysis of most profitable services',
        'icon': Icons.spa,
      },
      {
        'title': 'Staff Commission Report',
        'description': 'Commission breakdown by staff member',
        'icon': Icons.people,
      },
      {
        'title': 'Expense Summary',
        'description': 'Summary of all business expenses',
        'icon': Icons.money_off,
      },
      {
        'title': 'Tax Report',
        'description': 'Tax liabilities and payment history',
        'icon': Icons.receipt_long,
      },
      {
        'title': 'Customer Spending Report',
        'description': 'Top customers by spending amount',
        'icon': Icons.person,
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reportItems.length,
      itemBuilder: (context, index) {
        final report = reportItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                report['icon'] as IconData,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              report['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(report['description'] as String),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to report details
            },
          ),
        );
      },
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
  
  Widget _buildRevenueChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.divider,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0:
                      text = const Text('Jan', style: style);
                      break;
                    case 1:
                      text = const Text('Feb', style: style);
                      break;
                    case 2:
                      text = const Text('Mar', style: style);
                      break;
                    case 3:
                      text = const Text('Apr', style: style);
                      break;
                    case 4:
                      text = const Text('May', style: style);
                      break;
                    case 5:
                      text = const Text('Jun', style: style);
                      break;
                    case 6:
                      text = const Text('Jul', style: style);
                      break;
                    case 7:
                      text = const Text('Aug', style: style);
                      break;
                    case 8:
                      text = const Text('Sep', style: style);
                      break;
                    case 9:
                      text = const Text('Oct', style: style);
                      break;
                    case 10:
                      text = const Text('Nov', style: style);
                      break;
                    case 11:
                      text = const Text('Dec', style: style);
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: text,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: 2000,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 500),
                FlSpot(1, 650),
                FlSpot(2, 1000),
                FlSpot(3, 800),
                FlSpot(4, 1200),
                FlSpot(5, 1100),
                FlSpot(6, 900),
                FlSpot(7, 1500),
                FlSpot(8, 1300),
                FlSpot(9, 1700),
                FlSpot(10, 1600),
                FlSpot(11, 1800),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopServicesCard() {
    final topServices = [
      {'name': 'Haircut', 'revenue': 2350.0, 'percentage': 28},
      {'name': 'Hair Coloring', 'revenue': 1850.0, 'percentage': 22},
      {'name': 'Styling', 'revenue': 1520.0, 'percentage': 18},
      {'name': 'Facial', 'revenue': 1200.0, 'percentage': 14},
      {'name': 'Manicure', 'revenue': 850.0, 'percentage': 10},
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: topServices.map((service) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    service['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (service['percentage'] as int) / 100,
                      backgroundColor: AppColors.divider,
                      color: AppColors.primary,
                      minHeight: 8,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    currencyFormatter.format(service['revenue']),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildRecentTransactionsList() {
    final transactions = [
      {
        'isIncome': true,
        'amount': 120.0,
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'title': 'Service Payment',
        'subtitle': 'Hair Cut & Color',
      },
      {
        'isIncome': false,
        'amount': 45.0,
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'title': 'Inventory Purchase',
        'subtitle': 'Hair Products',
      },
      {
        'isIncome': true,
        'amount': 85.0,
        'date': DateTime.now().subtract(const Duration(hours: 8)),
        'title': 'Service Payment',
        'subtitle': 'Manicure & Pedicure',
      },
    ];
    
    return Column(
      children: transactions.map((transaction) => _buildTransactionItem(
        isIncome: transaction['isIncome'] as bool,
        amount: transaction['amount'] as double,
        date: transaction['date'] as DateTime,
        title: transaction['title'] as String,
        subtitle: transaction['subtitle'] as String,
      )).toList(),
    );
  }
  
  Widget _buildTransactionItem({
    required bool isIncome,
    required double amount,
    required DateTime date,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isIncome ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              dateFormatter.format(date),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${currencyFormatter.format(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isIncome ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    );
  }
}
