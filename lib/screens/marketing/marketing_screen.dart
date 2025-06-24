import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/custom_button.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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
      appBar: CustomAppBar(
        title: 'Marketing',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to marketing history
            },
            tooltip: 'Campaign History',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.background,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Campaigns'),
                Tab(text: 'Promotions'),
                Tab(text: 'Loyalty'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCampaignsTab(),
                _buildPromotionsTab(),
                _buildLoyaltyTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open create campaign/promotion modal based on current tab
          _showCreateModal(context, _tabController.index);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCampaignsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader('Active Campaigns'),
        ..._buildMockCampaigns(active: true),
        const SizedBox(height: 24),
        _buildSectionHeader('Scheduled Campaigns'),
        ..._buildMockCampaigns(active: false),
      ],
    );
  }

  Widget _buildPromotionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader('Active Promotions'),
        ..._buildMockPromotions(active: true),
        const SizedBox(height: 24),
        _buildSectionHeader('Past Promotions'),
        ..._buildMockPromotions(active: false),
      ],
    );
  }

  Widget _buildLoyaltyTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoyaltyProgramCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Top Loyal Customers'),
          Expanded(
            child: ListView(
              children: _buildMockLoyalCustomers(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  List<Widget> _buildMockCampaigns({required bool active}) {
    final campaigns = [
      {
        'title': 'Summer Special',
        'type': 'Email',
        'target': '240 customers',
        'date': active ? 'Running until Jul 30' : 'Scheduled for Aug 15',
        'stats': active ? '24% open rate' : null,
      },
      {
        'title': 'New Service Announcement',
        'type': 'SMS',
        'target': '180 customers',
        'date': active ? 'Running until Aug 5' : 'Scheduled for Aug 20',
        'stats': active ? '36 bookings' : null,
      },
    ];

    return campaigns.map((campaign) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    campaign['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? AppColors.success.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      active ? 'Active' : 'Scheduled',
                      style: TextStyle(
                        color: active ? AppColors.success : AppColors.info,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(campaign['type']!, Icons.campaign),
                  const SizedBox(width: 8),
                  _buildInfoChip(campaign['target']!, Icons.people),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                campaign['date']!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              if (campaign['stats'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  campaign['stats']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      active ? 'End Campaign' : 'Edit',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildMockPromotions({required bool active}) {
    final promotions = [
      {
        'title': '20% Off Spa Treatments',
        'code': 'SPA20',
        'validity': active ? 'Valid until Aug 10' : 'Expired on Jul 15',
        'redemptions': active ? '12 times used' : '28 times used',
      },
      {
        'title': 'Free Hair Treatment',
        'code': 'FREEHAIR',
        'validity': active ? 'Valid until Aug 25' : 'Expired on Jul 20',
        'redemptions': active ? '8 times used' : '15 times used',
      },
    ];

    return promotions.map((promo) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      promo['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      active ? 'Active' : 'Expired',
                      style: TextStyle(
                        color: active ? AppColors.success : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  'Code: ${promo['code']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                promo['validity']!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                promo['redemptions']!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (active)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'End Promotion',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      active ? 'Edit' : 'Reactivate',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLoyaltyProgramCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loyalty Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: const Text('Active'),
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Points System',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Customers earn 1 point for every \$10 spent',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              '• 100 points = \$10 discount on any service',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 120 customers enrolled',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              '• 45 rewards redeemed this month',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: 'Manage Program',
                  onPressed: () {},
                  backgroundColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMockLoyalCustomers() {
    final customers = [
      {
        'name': 'Emma Thompson',
        'points': '580',
        'spent': '\$1,245',
        'visits': '12',
      },
      {
        'name': 'Michael Chen',
        'points': '450',
        'spent': '\$980',
        'visits': '9',
      },
      {
        'name': 'Sarah Johnson',
        'points': '320',
        'spent': '\$760',
        'visits': '8',
      },
      {
        'name': 'David Williams',
        'points': '290',
        'spent': '\$650',
        'visits': '6',
      },
    ];

    return customers.map((customer) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    customer['name']!.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${customer['points']} points • ${customer['visits']} visits',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    customer['spent']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Spent',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateModal(BuildContext context, int tabIndex) {
    String title;
    Widget content;

    switch (tabIndex) {
      case 0:
        title = 'Create Campaign';
        content = _buildCreateCampaignForm();
        break;
      case 1:
        title = 'Create Promotion';
        content = _buildCreatePromotionForm();
        break;
      case 2:
        title = 'Loyalty Program Action';
        content = _buildLoyaltyActionForm();
        break;
      default:
        title = 'Create';
        content = const SizedBox();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateCampaignForm() {
    return Builder(
      builder: (BuildContext formContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Campaign Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Campaign Type',
                border: OutlineInputBorder(),
              ),
              items: ['Email', 'SMS', 'Push Notification']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
                hintText: 'All customers, loyal customers, etc.',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () {
                      // Show date picker
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () {
                      // Show date picker
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Message Content',
                border: OutlineInputBorder(),
                hintText: 'Enter campaign message',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(formContext),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Create Campaign',
                  onPressed: () {
                    // Create campaign logic
                    Navigator.pop(formContext);
                  },
                  backgroundColor: AppColors.primary,
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _buildCreatePromotionForm() {
    return Builder(
      builder: (BuildContext formContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Promotion Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Discount Type',
                border: OutlineInputBorder(),
              ),
              items: ['Percentage Off', 'Fixed Amount Off', 'Free Service/Product']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Discount Value',
                border: OutlineInputBorder(),
                hintText: 'e.g., 20 for 20% off or \$15 for fixed amount',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Promo Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Valid From',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () {
                      // Show date picker
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Valid Until',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () {
                      // Show date picker
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(formContext),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Create Promotion',
                  onPressed: () {
                    // Create promotion logic
                    Navigator.pop(formContext);
                  },
                  backgroundColor: AppColors.primary,
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _buildLoyaltyActionForm() {
    return Builder(
      builder: (BuildContext formContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Action Type',
                border: OutlineInputBorder(),
              ),
              items: ['Adjust Points', 'Create Special Reward', 'Update Program Rules']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Customer (optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter customer name or leave blank for all',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Points to Add/Subtract',
                border: OutlineInputBorder(),
                hintText: 'Enter positive or negative number',
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(formContext),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Apply Action',
                  onPressed: () {
                    // Apply loyalty action logic
                    Navigator.pop(formContext);
                  },
                  backgroundColor: AppColors.primary,
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
