import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/screens/services/add_service_screen.dart';
import 'package:stibe_partner/screens/services/edit_service_screen.dart';
import 'package:stibe_partner/screens/services/service_detail_screen.dart';
import 'package:stibe_partner/screens/services/service_categories_screen.dart';
import 'package:stibe_partner/screens/services/service_packages_screen.dart';
import 'package:stibe_partner/screens/services/service_analytics_screen.dart';
import 'package:stibe_partner/screens/services/service_bulk_operations_screen.dart';
import 'package:stibe_partner/screens/services/service_templates_screen.dart';

class EnhancedServicesScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const EnhancedServicesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<EnhancedServicesScreen> createState() => _EnhancedServicesScreenState();
}

class _EnhancedServicesScreenState extends State<EnhancedServicesScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  List<ServiceDto> _services = [];
  List<ServiceCategoryDto> _categories = [];
  List<ServicePackageDto> _packages = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter and search
  String _searchQuery = '';
  int? _selectedCategoryId;
  String _sortBy = 'name';
  bool _showActiveOnly = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        _serviceService.getSalonServices(
          widget.salonId,
          isActive: _showActiveOnly ? true : null,
          categoryId: _selectedCategoryId,
          searchTerm: _searchQuery.isEmpty ? null : _searchQuery,
          sortBy: _sortBy,
        ),
        _serviceService.getSalonCategories(widget.salonId),
        _serviceService.getServicePackages(widget.salonId),
      ]);

      setState(() {
        _services = futures[0] as List<ServiceDto>;
        _categories = futures[1] as List<ServiceCategoryDto>;
        _packages = futures[2] as List<ServicePackageDto>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.salonName} Services',
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => _navigateToCategories(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'templates',
                child: ListTile(
                  leading: Icon(Icons.library_add),
                  title: Text('Service Templates'),
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
                value: 'analytics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Analytics'),
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
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildServicesTab(),
                          _buildPackagesTab(),
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
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.spa, size: 16),
                const SizedBox(width: 4),
                Text('Services (${_services.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory, size: 16),
                const SizedBox(width: 4),
                Text('Packages (${_packages.length})'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadData();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (_) => _loadData(),
          ),
          const SizedBox(height: 12),
          
          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category filter
                _buildFilterChip(
                  label: _selectedCategoryId == null 
                      ? 'All Categories' 
                      : _categories.firstWhere((c) => c.id == _selectedCategoryId).name,
                  onTap: () => _showCategoryFilter(),
                  isSelected: _selectedCategoryId != null,
                ),
                const SizedBox(width: 8),
                
                // Active filter
                _buildFilterChip(
                  label: _showActiveOnly ? 'Active Only' : 'All Status',
                  onTap: () {
                    setState(() {
                      _showActiveOnly = !_showActiveOnly;
                    });
                    _loadData();
                  },
                  isSelected: _showActiveOnly,
                ),
                const SizedBox(width: 8),
                
                // Sort filter
                _buildFilterChip(
                  label: 'Sort: ${_getSortLabel()}',
                  onTap: () => _showSortOptions(),
                  isSelected: _sortBy != 'name',
                ),
              ],
            ),
          ),
        ],
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
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceDto service) {
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
                Row(
                  children: [
                    // Service image or icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: service.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                service.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.spa, color: AppColors.primary),
                              ),
                            )
                          : Icon(Icons.spa, color: AppColors.primary),
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
                              if (service.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.orange.shade600,
                                      ),
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
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: service.isActive 
                                      ? Colors.green.shade100 
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
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
                          const SizedBox(height: 4),
                          if (service.categoryName != null)
                            Text(
                              service.categoryName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 4),
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
                const SizedBox(height: 12),
                
                // Service details row
                Row(
                  children: [
                    _buildServiceInfo(
                      icon: Icons.access_time,
                      label: service.formattedDuration,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 16),
                    _buildServiceInfo(
                      icon: Icons.attach_money,
                      label: service.discountPercentage != null 
                          ? service.priceWithDiscount
                          : service.formattedPrice,
                      color: Colors.green.shade600,
                    ),
                    if (service.averageRating > 0) ...[
                      const SizedBox(width: 16),
                      _buildServiceInfo(
                        icon: Icons.star,
                        label: service.averageRating.toStringAsFixed(1),
                        color: Colors.amber.shade600,
                      ),
                    ],
                    if (service.bookingCount > 0) ...[
                      const SizedBox(width: 16),
                      _buildServiceInfo(
                        icon: Icons.event,
                        label: '${service.bookingCount}',
                        color: Colors.purple.shade600,
                      ),
                    ],
                  ],
                ),
                
                // Tags
                if (service.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: service.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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

  Widget _buildServiceInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesTab() {
    if (_packages.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_outlined,
        title: 'No Service Packages',
        message: 'Create packages to offer bundled services at discounted rates',
        actionLabel: 'Create Package',
        onAction: () => _navigateToCreatePackage(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final package = _packages[index];
          return _buildPackageCard(package);
        },
      ),
    );
  }

  Widget _buildPackageCard(ServicePackageDto package) {
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPackageDetail(package),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (package.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Popular',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  package.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Package details
                Row(
                  children: [
                    Text(
                      package.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (package.savings > 0) ...[
                      Text(
                        'Save ${package.savingsFormatted}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      package.formattedDuration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Services included
                Text(
                  'Includes ${package.services.length} services',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics, color: AppColors.primary),
              title: const Text('Detailed Analytics'),
              subtitle: const Text('View comprehensive service analytics and performance metrics'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ServiceAnalyticsScreen(
                      salonId: widget.salonId,
                      salonName: widget.salonName,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_services.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            'Total Services',
                            _services.length.toString(),
                            Icons.spa,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickStat(
                            'Active Services',
                            _services.where((s) => s.isActive).length.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            'Avg. Price',
                            '\$${(_services.fold<double>(0, (sum, s) => sum + s.price) / _services.length).toStringAsFixed(2)}',
                            Icons.attach_money,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickStat(
                            'Popular Services',
                            _services.where((s) => s.isPopular).length.toString(),
                            Icons.star,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Add some services to see analytics',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Services',
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
              onPressed: _loadData,
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

  // Navigation methods
  void _navigateToAddService() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddServiceScreen(
          salonId: widget.salonId,
          categories: _categories,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToServiceDetail(ServiceDto service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
          service: service,
          salonId: widget.salonId,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToEditService(ServiceDto service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          service: service,
          salonId: widget.salonId,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceCategoriesScreen(
          salonId: widget.salonId,
          salonName: widget.salonName,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToCreatePackage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServicePackagesScreen(
          salonId: widget.salonId,
          salonName: widget.salonName,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToPackageDetail(ServicePackageDto package) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServicePackagesScreen(
          salonId: widget.salonId,
          salonName: widget.salonName,
        ),
      ),
    ).then((_) => _refreshData());
  }

  // Helper methods
  String _getSortLabel() {
    switch (_sortBy) {
      case 'price':
        return 'Price';
      case 'duration':
        return 'Duration';
      case 'popularity':
        return 'Popularity';
      case 'rating':
        return 'Rating';
      default:
        return 'Name';
    }
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Categories'),
              leading: const Icon(Icons.all_inclusive),
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                });
                Navigator.pop(context);
                _loadData();
              },
              selected: _selectedCategoryId == null,
            ),
            ..._categories.map((category) => ListTile(
              title: Text(category.name),
              leading: const Icon(Icons.category),
              onTap: () {
                setState(() {
                  _selectedCategoryId = category.id;
                });
                Navigator.pop(context);
                _loadData();
              },
              selected: _selectedCategoryId == category.id,
            )),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              ('name', 'Name', Icons.sort_by_alpha),
              ('price', 'Price', Icons.attach_money),
              ('duration', 'Duration', Icons.access_time),
              ('popularity', 'Popularity', Icons.trending_up),
              ('rating', 'Rating', Icons.star),
            ].map((option) => ListTile(
              title: Text(option.$2),
              leading: Icon(option.$3),
              onTap: () {
                setState(() {
                  _sortBy = option.$1;
                });
                Navigator.pop(context);
                _loadData();
              },
              selected: _sortBy == option.$1,
            )),
          ],
        ),
      ),
    );
  }

  void _showServiceContextMenu(BuildContext context, ServiceDto service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: service.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              service.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.spa, color: AppColors.primary),
                            ),
                          )
                        : Icon(Icons.spa, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          service.formattedPrice,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Actions
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _navigateToServiceDetail(service);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Edit Service'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditService(service);
              },
            ),
            ListTile(
              leading: Icon(
                service.isActive ? Icons.pause_circle : Icons.play_circle,
                color: service.isActive ? Colors.orange : Colors.green,
              ),
              title: Text(service.isActive ? 'Deactivate' : 'Activate'),
              onTap: () {
                Navigator.pop(context);
                _toggleServiceStatus(service);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.purple),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                _duplicateService(service);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Service',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteService(service);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'templates':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceTemplatesScreen(
              salonId: widget.salonId,
              salonName: widget.salonName,
            ),
          ),
        ).then((_) => _refreshData());
        break;
      case 'bulk_operations':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceBulkOperationsScreen(
              salonId: widget.salonId,
              salonName: widget.salonName,
            ),
          ),
        ).then((_) => _refreshData());
        break;
      case 'analytics':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceAnalyticsScreen(
              salonId: widget.salonId,
              salonName: widget.salonName,
            ),
          ),
        );
        break;
      case 'export':
        _exportServicesData();
        break;
    }
  }

  Future<void> _exportServicesData() async {
    try {
      // Show export options dialog
      final exportType = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Services Data'),
          content: const Text('Choose export format:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('csv'),
              child: const Text('CSV'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('json'),
              child: const Text('JSON'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (exportType != null) {
        // TODO: Implement actual export functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export to $exportType format coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Service action methods
  Future<void> _toggleServiceStatus(ServiceDto service) async {
    try {
      await _serviceService.toggleServiceStatus(
        widget.salonId,
        service.id,
        !service.isActive,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Service ${!service.isActive ? "activated" : "deactivated"} successfully!',
            ),
            backgroundColor: !service.isActive ? Colors.green : Colors.orange,
          ),
        );
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _duplicateService(ServiceDto service) async {
    final newName = '${service.name} (Copy)';
    
    try {
      await _serviceService.duplicateService(
        widget.salonId,
        service.id,
        newName,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service duplicated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating service: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteService(ServiceDto service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${service.name}"?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _serviceService.deleteService(widget.salonId, service.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting service: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
