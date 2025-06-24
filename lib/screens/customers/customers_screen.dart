import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/models/customer_model.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _customers = _getMockCustomers();
      _filteredCustomers = _customers;
      _isLoading = false;
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _activeFilter == 'All'
            ? _customers
            : _customers.where((customer) => _getCustomerCategory(customer) == _activeFilter).toList();
      } else {
        _filteredCustomers = _customers
            .where((customer) => 
                customer.fullName.toLowerCase().contains(query) ||
                (customer.email?.toLowerCase().contains(query) ?? false) ||
                customer.phoneNumber.contains(query))
            .where((customer) => _activeFilter == 'All' || _getCustomerCategory(customer) == _activeFilter)
            .toList();
      }
    });
  }

  String _getCustomerCategory(Customer customer) {
    if (customer.totalVisits == 0) {
      return 'New';
    } else if (customer.totalVisits > 5) {
      return 'Regular';
    } else {
      return 'Occasional';
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _filterCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Customers',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : _buildCustomersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search customers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'New', 'Regular', 'Occasional'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: filters.map((filter) {
          final isActive = _activeFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (selected) {
                if (selected) _setFilter(filter);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final categoryText = _getCustomerCategory(customer);
    Color categoryColor;
    
    switch (categoryText) {
      case 'New':
        categoryColor = AppColors.info;
        break;
      case 'Regular':
        categoryColor = AppColors.success;
        break;
      default:
        categoryColor = AppColors.secondary;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to customer details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: customer.profileImage != null
                        ? NetworkImage(customer.profileImage!)
                        : null,
                    child: customer.profileImage == null
                        ? Text(
                            customer.fullName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                categoryText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.phoneNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (customer.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.email!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCustomerStat(
                    icon: Icons.calendar_today,
                    value: '${customer.totalVisits}',
                    label: 'Visits',
                  ),
                  _buildCustomerStat(
                    icon: Icons.attach_money,
                    value: '\$${customer.totalSpent.toStringAsFixed(0)}',
                    label: 'Spent',
                  ),
                  _buildCustomerStat(
                    icon: Icons.access_time,
                    value: customer.lastVisit != null
                        ? _formatLastVisitDate(customer.lastVisit!)
                        : 'Never',
                    label: 'Last Visit',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement quick appointment booking
                      },
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: const Text('Book'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement call feature
                      },
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement messaging feature
                      },
                      icon: const Icon(Icons.message_outlined, size: 18),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
                        side: const BorderSide(color: AppColors.info),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Customers Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'Add your first customer to get started',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement add new customer
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastVisitDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  
  // Mock data generator
  List<Customer> _getMockCustomers() {
    return [
      Customer(
        id: '1',
        fullName: 'Emma Thompson',
        email: 'emma.thompson@example.com',
        phoneNumber: '(555) 123-4567',
        profileImage: null,
        totalVisits: 8,
        totalSpent: 650.0,
        lastVisit: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Customer(
        id: '2',
        fullName: 'James Wilson',
        email: 'james.wilson@example.com',
        phoneNumber: '(555) 234-5678',
        profileImage: null,
        totalVisits: 3,
        totalSpent: 210.0,
        lastVisit: DateTime.now().subtract(const Duration(days: 14)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Customer(
        id: '3',
        fullName: 'Sophia Garcia',
        email: 'sophia.garcia@example.com',
        phoneNumber: '(555) 345-6789',
        profileImage: null,
        totalVisits: 12,
        totalSpent: 980.0,
        lastVisit: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Customer(
        id: '4',
        fullName: 'Michael Brown',
        email: 'michael.brown@example.com',
        phoneNumber: '(555) 456-7890',
        profileImage: null,
        notes: [
          CustomerNote(
            id: 'note1',
            content: 'Prefers tea over coffee while waiting.',
            authorId: 'staff1',
            authorName: 'John Stylist',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
        totalVisits: 0,
        totalSpent: 0.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Customer(
        id: '5',
        fullName: 'Olivia Miller',
        email: 'olivia.miller@example.com',
        phoneNumber: '(555) 567-8901',
        profileImage: null,
        totalVisits: 5,
        totalSpent: 420.0,
        lastVisit: DateTime.now().subtract(const Duration(days: 21)),
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      Customer(
        id: '6',
        fullName: 'Daniel Martinez',
        email: 'daniel.martinez@example.com',
        phoneNumber: '(555) 678-9012',
        profileImage: null,
        totalVisits: 7,
        totalSpent: 540.0,
        lastVisit: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
    ];
  }
}
