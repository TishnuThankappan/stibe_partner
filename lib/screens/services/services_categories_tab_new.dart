import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/screens/services/manage_categories_screen.dart';

class ServicesCategoriesTab extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServicesCategoriesTab({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServicesCategoriesTab> createState() => _ServicesCategoriesTabState();
}

class _ServicesCategoriesTabState extends State<ServicesCategoriesTab>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<ServiceDto> _services = [];
  List<ServiceDto> _allServices = [];
  String? _errorMessage;
  bool _showInactiveServices = true;
  
  // Category filter
  List<ServiceCategoryDto> _categories = [];
  bool _loadingCategories = true;
  
  // Expanded categories tracking
  Set<int> _expandedCategoryIds = {};
  
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadCategories();
    _loadServices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
    });

    try {
      final serviceService = ServiceManagementService();
      final categories = await serviceService.getServiceCategories(widget.salonId);
      
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceService = ServiceManagementService();
      final services = await serviceService.getSalonServices(widget.salonId);
      
      setState(() {
        _allServices = services;
        _filterServices();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading services: $_errorMessage'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _filterServices() {
    if (_showInactiveServices) {
      _services = _allServices;
    } else {
      _services = _allServices.where((service) => service.isActive).toList();
    }
    setState(() {});
  }

  Future<void> _refreshServices() async {
    setState(() {
      _isLoading = true;
    });
    await _loadServices();
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading && _loadingCategories
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshServices,
              color: AppColors.primary,
              strokeWidth: 3,
              child: CustomScrollView(
                slivers: [
                  _buildModernAppBar(),
                  _buildQuickStats(),
                  if (!_loadingCategories && _categories.isNotEmpty) 
                    _buildCategoriesOverview(),
                  _buildServicesContent(),
                ],
              ),
            ),
      floatingActionButton: AnimatedScale(
        scale: _categories.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: _addService,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Service',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Your Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Setting up your salon workspace...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withBlue(AppColors.primary.blue + 40)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              'Manage your salon offerings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              Expanded(child: _buildToggleSwitch()),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.category_rounded,
                color: Colors.orange,
                onPressed: _managCategories,
                tooltip: 'Manage Categories',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.add_rounded,
                color: AppColors.primary,
                onPressed: _addService,
                tooltip: 'Add Service',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showInactiveServices ? Icons.visibility : Icons.visibility_off,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Show Inactive',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _showInactiveServices,
              onChanged: (value) {
                setState(() {
                  _showInactiveServices = value;
                  _filterServices();
                });
              },
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildStatsCards(),
              const SizedBox(height: 16),
              _buildUserHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final activeServices = _services.where((s) => s.isActive).length;
    final inactiveServices = _services.length - activeServices;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Services',
            count: activeServices,
            icon: Icons.trending_up_rounded,
            color: Colors.green,
            gradient: [Colors.green.shade400, Colors.green.shade600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Categories',
            count: _categories.length,
            icon: Icons.category_rounded,
            color: Colors.orange,
            gradient: [Colors.orange.shade400, Colors.orange.shade600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Inactive Services',
            count: inactiveServices,
            icon: Icons.pause_circle_outline_rounded,
            color: Colors.grey,
            gradient: [Colors.grey.shade400, Colors.grey.shade600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 20,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Organize services with categories first, then expand each category to view and manage services.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesOverview() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${_categories.length} categories created',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _managCategories,
                    icon: const Icon(Icons.settings_rounded, size: 16),
                    label: const Text('Manage'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final colors = _getCategoryGradient(category.name);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors.map((c) => c.withOpacity(0.1)).toList()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.first.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category.name),
                          size: 16,
                          color: colors.first,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.first,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesContent() {
    return SliverFillRemaining(
      child: _loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? _buildEmptyState()
              : _buildServicesList(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.spa_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Service Categories Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Start by creating categories to organize your services, then add amazing services for your customers.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            _buildEmptyStateButton(
              onPressed: _managCategories,
              icon: Icons.category_rounded,
              label: 'Create Categories First',
              color: Colors.orange,
              isPrimary: true,
            ),
            const SizedBox(height: 12),
            _buildEmptyStateButton(
              onPressed: _addService,
              icon: Icons.add_rounded,
              label: 'Add Service Directly',
              color: AppColors.primary,
              isPrimary: false,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _refreshServices,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : color.withOpacity(0.9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: isPrimary ? 4 : 2,
        shadowColor: color.withOpacity(0.4),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    final Map<int?, List<ServiceDto>> servicesByCategory = {};
    final List<ServiceDto> uncategorizedServices = [];
    
    for (final service in _services) {
      if (service.categoryId == null) {
        uncategorizedServices.add(service);
      } else {
        servicesByCategory.putIfAbsent(service.categoryId, () => []).add(service);
      }
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._categories.map((category) {
          final categoryServices = servicesByCategory[category.id] ?? [];
          return _buildCategorySection(category, categoryServices);
        }),
        if (uncategorizedServices.isNotEmpty)
          _buildUncategorizedSection(uncategorizedServices),
      ],
    );
  }

  Widget _buildCategorySection(ServiceCategoryDto category, List<ServiceDto> services) {
    final isExpanded = _expandedCategoryIds.contains(category.id);
    final colors = _getCategoryGradient(category.name);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCategoryHeader(category, services.length, isExpanded, colors),
          if (isExpanded) _buildCategoryServices(services, colors),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(ServiceCategoryDto category, int serviceCount, bool isExpanded, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedCategoryIds.remove(category.id);
            } else {
              _expandedCategoryIds.add(category.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isExpanded ? LinearGradient(
              colors: colors.map((c) => c.withOpacity(0.05)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$serviceCount ${serviceCount == 1 ? 'service' : 'services'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isExpanded ? colors.first.withOpacity(0.1) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? colors.first : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryServices(List<ServiceDto> services, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors.map((c) => c.withOpacity(0.2)).toList()),
            ),
          ),
          ...services.map((service) => _buildServiceCard(service, colors)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceDto service, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isActive ? colors.first.withOpacity(0.2) : Colors.orange.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _viewServiceDetail(service),
          onLongPress: () => _showServiceMenu(service),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.spa_outlined,
                    size: 16,
                    color: colors.first,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(service),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriceDisplay(service, colors.first),
                          const Spacer(),
                          _buildDurationChip(service),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showServiceMenu(service),
                  icon: const Icon(Icons.more_vert_rounded),
                  iconSize: 18,
                  color: colors.first,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ServiceDto service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: service.isActive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: service.isActive ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Text(
        service.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: service.isActive ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(ServiceDto service, Color color) {
    if (service.offerPrice != null && service.offerPrice! < service.price) {
      return Row(
        children: [
          Text(
            '₹${service.offerPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '₹${service.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      );
    }
    
    return Text(
      '₹${service.price.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildDurationChip(ServiceDto service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 12,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '${service.durationInMinutes}m',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUncategorizedSection(List<ServiceDto> services) {
    final isExpanded = _expandedCategoryIds.contains(-999);
    final colors = [Colors.grey.shade400, Colors.grey.shade600];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildUncategorizedHeader(services.length, isExpanded, colors),
          if (isExpanded) _buildCategoryServices(services, colors),
        ],
      ),
    );
  }

  Widget _buildUncategorizedHeader(int serviceCount, bool isExpanded, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedCategoryIds.remove(-999);
            } else {
              _expandedCategoryIds.add(-999);
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uncategorized Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$serviceCount ${serviceCount == 1 ? 'service' : 'services'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isExpanded ? colors.first.withOpacity(0.1) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? colors.first : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryGradient(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'hair care':
        return [Colors.purple.shade400, Colors.purple.shade700];
      case 'skin care':
        return [Colors.blue.shade400, Colors.blue.shade700];
      case 'nail care':
        return [Colors.pink.shade300, Colors.pink.shade600];
      case 'massage':
        return [Colors.teal.shade400, Colors.teal.shade700];
      case 'makeup':
        return [Colors.red.shade400, Colors.red.shade700];
      case 'hair removal':
        return [Colors.amber.shade400, Colors.amber.shade700];
      case 'men\'s grooming':
        return [Colors.indigo.shade400, Colors.indigo.shade700];
      case 'spa packages':
        return [Colors.green.shade400, Colors.green.shade700];
      case 'bridal services':
        return [Colors.pink.shade400, Colors.pink.shade700];
      case 'children\'s services':
        return [Colors.orange.shade400, Colors.orange.shade700];
      default:
        return [AppColors.primary, AppColors.primary.withOpacity(0.8)];
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'hair care':
        return Icons.content_cut_rounded;
      case 'skin care':
        return Icons.face_rounded;
      case 'nail care':
        return Icons.back_hand_rounded;
      case 'massage':
        return Icons.spa_rounded;
      case 'makeup':
        return Icons.brush_rounded;
      case 'hair removal':
        return Icons.waves_rounded;
      case 'men\'s grooming':
        return Icons.person_rounded;
      case 'spa packages':
        return Icons.spa_outlined;
      case 'bridal services':
        return Icons.favorite_rounded;
      case 'children\'s services':
        return Icons.child_care_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _managCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageCategoriesScreen(
          salonId: widget.salonId,
          salonName: widget.salonName,
        ),
      ),
    ).then((_) {
      _loadCategories();
    });
  }

  void _addService() {
    Navigator.pushNamed(
      context,
      '/add-service',
      arguments: {
        'salonId': widget.salonId,
        'salonName': widget.salonName,
      },
    ).then((_) => _refreshServices());
  }

  void _viewServiceDetail(ServiceDto service) {
    Navigator.pushNamed(
      context,
      '/service-detail',
      arguments: {
        'service': service,
        'salonId': widget.salonId,
        'salonName': widget.salonName,
      },
    ).then((_) => _refreshServices());
  }

  void _showServiceMenu(ServiceDto service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildServiceBottomSheet(service),
    );
  }

  Widget _buildServiceBottomSheet(ServiceDto service) {
    final colors = _getCategoryGradient(
      _categories
          .where((c) => c.id == service.categoryId)
          .map((c) => c.name)
          .firstOrNull ?? 'default'
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildServiceHeader(service, colors),
          const SizedBox(height: 24),
          const Divider(),
          ..._buildServiceActions(service),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildServiceHeader(ServiceDto service, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.spa_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '₹${service.price.toStringAsFixed(0)} · ${service.durationInMinutes} min',
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

  List<Widget> _buildServiceActions(ServiceDto service) {
    return [
      _buildActionTile(
        icon: Icons.visibility_outlined,
        title: 'View Details',
        color: Colors.blue.shade700,
        onTap: () {
          Navigator.pop(context);
          _viewServiceDetail(service);
        },
      ),
      _buildActionTile(
        icon: Icons.edit_outlined,
        title: 'Edit Service',
        color: Colors.green.shade700,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/add-service',
            arguments: {
              'salonId': widget.salonId,
              'salonName': widget.salonName,
              'service': service,
            },
          ).then((_) => _refreshServices());
        },
      ),
      _buildActionTile(
        icon: service.isActive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
        title: service.isActive ? 'Deactivate Service' : 'Activate Service',
        color: service.isActive ? Colors.orange.shade700 : Colors.green.shade700,
        onTap: () {
          Navigator.pop(context);
          _toggleServiceStatus(service);
        },
      ),
      _buildActionTile(
        icon: Icons.delete_outline,
        title: 'Delete Service',
        color: Colors.red.shade700,
        onTap: () {
          Navigator.pop(context);
          _deleteService(service);
        },
      ),
    ];
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleServiceStatus(ServiceDto service) async {
    try {
      final serviceService = ServiceManagementService();
      await serviceService.updateService(
        widget.salonId,
        UpdateServiceRequest(id: service.id, isActive: !service.isActive),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Service ${service.isActive ? 'deactivated' : 'activated'} successfully',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      
      _refreshServices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _deleteService(ServiceDto service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final serviceService = ServiceManagementService();
      await serviceService.deleteService(widget.salonId, service.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      _refreshServices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting service: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
