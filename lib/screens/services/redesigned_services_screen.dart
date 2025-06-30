import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/salon_service_management_api.dart';
import 'package:stibe_partner/api/service_management_dtos.dart';

class RedesignedServicesScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const RedesignedServicesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<RedesignedServicesScreen> createState() => _RedesignedServicesScreenState();
}

class _RedesignedServicesScreenState extends State<RedesignedServicesScreen> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final SalonServiceManagementApi _serviceApi = SalonServiceManagementApi();
  
  // Data
  List<EnhancedServiceDto> _services = [];
  List<ServiceCategoryDto> _categories = [];
  List<ServicePackageDto> _packages = [];
  List<StaffServiceAssignmentDto> _staffAssignments = [];
  
  // State
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filters
  String _searchQuery = '';
  int? _selectedCategoryId;
  String _sortBy = 'name';
  bool _showActiveOnly = true;
  bool _showFeaturedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all data in parallel for better performance
      await Future.wait([
        _loadServices(),
        _loadCategories(),
        _loadPackages(),
        _loadStaffAssignments(),
        _loadAnalytics(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<EnhancedServiceDto>> _loadServices() async {
    try {
      final services = await _serviceApi.getServices(
        widget.salonId,
        isActive: _showActiveOnly ? true : null,
        categoryId: _selectedCategoryId,
        searchTerm: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        includeAnalytics: true,
        includeAvailability: true,
        includeStaffAssignments: true,
        includePromotions: true,
      );
      
      setState(() {
        _services = _showFeaturedOnly 
            ? services.where((s) => s.isFeatured).toList()
            : services;
      });
      
      return _services;
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }

  Future<List<ServiceCategoryDto>> _loadCategories() async {
    try {
      final categories = await _serviceApi.getServiceCategories(
        widget.salonId,
        includeInactive: !_showActiveOnly,
        includeServiceCount: true,
      );
      
      setState(() {
        _categories = categories;
      });
      
      return categories;
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<ServicePackageDto>> _loadPackages() async {
    try {
      final packages = await _serviceApi.getServicePackages(
        widget.salonId,
        isActive: _showActiveOnly ? true : null,
        searchTerm: _searchQuery.isNotEmpty ? _searchQuery : null,
        includeServices: true,
      );
      
      setState(() {
        _packages = packages;
      });
      
      return packages;
    } catch (e) {
      throw Exception('Failed to load packages: $e');
    }
  }

  Future<List<StaffServiceAssignmentDto>> _loadStaffAssignments() async {
    try {
      final assignments = await _serviceApi.getStaffServiceAssignments(
        widget.salonId,
        includeAvailability: true,
      );
      
      setState(() {
        _staffAssignments = assignments;
      });
      
      return assignments;
    } catch (e) {
      throw Exception('Failed to load staff assignments: $e');
    }
  }

  Future<ServiceAnalyticsDto?> _loadAnalytics() async {
    try {
      final analytics = await _serviceApi.getServiceAnalytics(
        widget.salonId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      // Analytics loaded successfully but not stored in state for now
      return analytics;
    } catch (e) {
      // Analytics failure shouldn't break the entire screen
      print('Warning: Failed to load analytics: $e');
      return null;
    }
  }

  Future<void> _refreshData() async {
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.salonName} - Service Management',
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Manage Categories'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'staff_assignments',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Staff Assignments'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'promotions',
                child: ListTile(
                  leading: Icon(Icons.local_offer),
                  title: Text('Promotions'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'templates',
                child: ListTile(
                  leading: Icon(Icons.library_add),
                  title: Text('Templates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_operations',
                child: ListTile(
                  leading: Icon(Icons.checklist),
                  title: Text('Bulk Operations'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildQuickFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildServicesTab(),
                          _buildCategoriesTab(),
                          _buildPackagesTab(),
                          _buildStaffAssignmentsTab(),
                          _buildAnalyticsTab(),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        isScrollable: true,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.spa, size: 16),
                const SizedBox(width: 4),
                Text('Services (${_services.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 4),
                Text('Categories (${_categories.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory, size: 16),
                const SizedBox(width: 4),
                Text('Packages (${_packages.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text('Staff (${_staffAssignments.length})'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.analytics, size: 16),
                SizedBox(width: 4),
                Text('Analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: _selectedCategoryId == null 
                  ? 'All Categories' 
                  : _categories.firstWhere((c) => c.id == _selectedCategoryId, 
                      orElse: () => ServiceCategoryDto(
                        id: 0, name: 'Unknown', description: '', salonId: widget.salonId,
                        isActive: true, serviceCount: 0, totalRevenue: 0, totalBookings: 0,
                        createdAt: DateTime.now(), updatedAt: DateTime.now()
                      )).name,
              onTap: () => _showCategoryFilter(),
              isSelected: _selectedCategoryId != null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _showActiveOnly ? 'Active Only' : 'All Status',
              onTap: () {
                setState(() {
                  _showActiveOnly = !_showActiveOnly;
                });
                _loadServices();
              },
              isSelected: _showActiveOnly,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _showFeaturedOnly ? 'Featured Only' : 'All Services',
              onTap: () {
                setState(() {
                  _showFeaturedOnly = !_showFeaturedOnly;
                });
                _loadServices();
              },
              isSelected: _showFeaturedOnly,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Sort: ${_getSortLabel()}',
              onTap: () => _showSortOptions(),
              isSelected: _sortBy != 'name',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    if (_services.isEmpty) {
      return _buildEmptyState(
        icon: Icons.spa_outlined,
        title: 'No Services Found',
        message: _searchQuery.isNotEmpty 
            ? 'No services match your search criteria'
            : 'Add your first service to get started',
        actionLabel: 'Add Service',
        onAction: () => _navigateToAddService(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return _buildEnhancedServiceCard(service);
        },
      ),
    );
  }

  Widget _buildEnhancedServiceCard(EnhancedServiceDto service) {
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
        border: service.isFeatured 
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToServiceDetail(service),
          onLongPress: () => _showServiceContextMenu(context, service),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service header with image and basic info
                Row(
                  children: [
                    // Service image or icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: service.isFeatured 
                            ? Border.all(color: Colors.amber, width: 2)
                            : null,
                      ),
                      child: service.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                service.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.spa, color: AppColors.primary, size: 30),
                              ),
                            )
                          : Icon(Icons.spa, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 12),
                    
                    // Service info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Status badges
                              if (service.isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Featured',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (service.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_up, size: 12, color: Colors.orange.shade600),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Popular',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Category and status
                          Row(
                            children: [
                              if (service.categoryName != null)
                                Expanded(
                                  child: Text(
                                    service.categoryName!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: service.isActive 
                                      ? Colors.green.shade100 
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  service.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: service.isActive 
                                        ? Colors.green.shade600 
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Description
                          Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Service metrics
                Row(
                  children: [
                    _buildServiceMetric(
                      icon: Icons.access_time,
                      label: service.formattedDuration,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 16),
                    _buildServiceMetric(
                      icon: Icons.attach_money,
                      label: service.hasActivePromotions 
                          ? service.priceWithDiscount
                          : service.formattedPrice,
                      color: service.hasActivePromotions 
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      strikethrough: service.hasActivePromotions ? service.formattedPrice : null,
                    ),
                    if (service.averageRating > 0) ...[
                      const SizedBox(width: 16),
                      _buildServiceMetric(
                        icon: Icons.star,
                        label: '${service.averageRating.toStringAsFixed(1)} (${service.reviewCount})',
                        color: Colors.amber.shade600,
                      ),
                    ],
                    if (service.bookingCount > 0) ...[
                      const SizedBox(width: 16),
                      _buildServiceMetric(
                        icon: Icons.event,
                        label: '${service.bookingCount}',
                        color: Colors.purple.shade600,
                      ),
                    ],
                  ],
                ),
                
                // Staff assignments preview
                if (service.staffAssignments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Staff: ${service.staffAssignments.length} assigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (service.staffAssignments.any((s) => s.isPrimary))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Primary Staff',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                
                // Active promotions
                if (service.hasActivePromotions) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer, size: 12, color: Colors.red.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${service.currentDiscountPercentage.toInt()}% OFF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Tags
                if (service.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: service.tags.take(4).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceMetric({
    required IconData icon,
    required String label,
    required Color color,
    String? strikethrough,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (strikethrough != null)
              Text(
                strikethrough,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Placeholder methods for other tabs
  Widget _buildCategoriesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Categories Management',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Organize your services into categories',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to category management
            },
            child: const Text('Manage Categories'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Service Packages',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create bundled service packages',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to package management
            },
            child: const Text('Create Package'),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAssignmentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Staff Assignments',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Assign staff members to services',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to staff assignment management
            },
            child: const Text('Manage Assignments'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Service Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'View detailed performance metrics',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to analytics dashboard
            },
            child: const Text('View Analytics'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddService(),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Service'),
    );
  }

  // Helper methods
  String _getSortLabel() {
    switch (_sortBy) {
      case 'price': return 'Price';
      case 'duration': return 'Duration';
      case 'popularity': return 'Popularity';
      case 'rating': return 'Rating';
      case 'revenue': return 'Revenue';
      case 'bookings': return 'Bookings';
      default: return 'Name';
    }
  }

  // Navigation and dialog methods
  void _navigateToAddService() {
    // TODO: Implement add service navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add service feature coming soon!')),
    );
  }

  void _navigateToServiceDetail(EnhancedServiceDto service) {
    // TODO: Implement service detail navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for ${service.name}')),
    );
  }

  void _showSearchDialog() {
    // TODO: Implement search dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search feature coming soon!')),
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced filters coming soon!')),
    );
  }

  void _showCategoryFilter() {
    // TODO: Implement category filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category filter coming soon!')),
    );
  }

  void _showSortOptions() {
    // TODO: Implement sort options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sort options coming soon!')),
    );
  }

  void _showServiceContextMenu(BuildContext context, EnhancedServiceDto service) {
    // TODO: Implement service context menu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Service menu for ${service.name}')),
    );
  }

  void _handleMenuAction(String action) {
    // TODO: Implement menu actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action feature coming soon!')),
    );
  }
}
