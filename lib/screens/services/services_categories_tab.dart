import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/screens/services/manage_categories_screen.dart';
import 'package:stibe_partner/widgets/offer_management_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading && _loadingCategories
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshServices,
              color: AppColors.primary,
              strokeWidth: 2,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildCompactHeader(),
                  _buildMinimalInsights(),
                  _buildCategoryChips(),
                  _buildServicesContent(),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FB), Colors.white],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Loading Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Setting up your workspace...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Manage offerings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildCompactToggle(),
            const SizedBox(width: 8),
            _buildCompactMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactToggle() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              _showInactiveServices = !_showInactiveServices;
              _filterServices();
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            _showInactiveServices ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMenuButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: _managCategories,
          borderRadius: BorderRadius.circular(8),
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }





  Widget _buildMinimalInsights() {
    final activeServices = _services.where((s) => s.isActive).length;
    final totalRevenue = _services.fold<double>(0, (sum, service) => sum + service.price);
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildMiniInsightCard(
                icon: Icons.trending_up_rounded,
                value: activeServices.toString(),
                label: 'Active',
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniInsightCard(
                icon: Icons.category_rounded,
                value: _categories.length.toString(),
                label: 'Categories',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniInsightCard(
                icon: Icons.analytics_rounded,
                value: '₹${(totalRevenue / 1000).toStringAsFixed(1)}K',
                label: 'Revenue',
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInsightCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildCategoryChips() {
    if (_categories.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final colors = _getCategoryGradient(category.name);
            return _buildCompactCategoryChip(category, colors);
          },
        ),
      ),
    );
  }

  Widget _buildCompactCategoryChip(ServiceCategoryDto category, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.first.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.first.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category.name),
            size: 12,
            color: colors.first,
          ),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.first,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildModernFAB() {
    return FloatingActionButton(
      onPressed: _addService,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_rounded, size: 24),
    );
  }



  Widget _buildServicesContent() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _loadingCategories
                ? _buildCompactLoadingSkeleton()
                : _categories.isEmpty
                    ? _buildCompactEmptyState()
                    : _buildCompactServicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLoadingSkeleton() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildCompactServicesList() {
    final Map<int?, List<ServiceDto>> servicesByCategory = {};
    final List<ServiceDto> uncategorizedServices = [];
    
    for (final service in _services) {
      if (service.categoryId == null) {
        uncategorizedServices.add(service);
      } else {
        servicesByCategory.putIfAbsent(service.categoryId, () => []).add(service);
      }
    }
    
    return Column(
      children: [
        ..._categories.map((category) {
          final categoryServices = servicesByCategory[category.id] ?? [];
          if (categoryServices.isEmpty) return const SizedBox.shrink();
          return _buildCompactCategorySection(category, categoryServices);
        }),
        if (uncategorizedServices.isNotEmpty)
          _buildCompactUncategorizedSection(uncategorizedServices),
      ],
    );
  }

  Widget _buildCompactCategorySection(ServiceCategoryDto category, List<ServiceDto> services) {
    final isExpanded = _expandedCategoryIds.contains(category.id);
    final colors = _getCategoryGradient(category.name);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          _buildCompactCategoryHeader(category, services.length, isExpanded, colors),
          if (isExpanded) _buildCompactCategoryServices(services, colors),
        ],
      ),
    );
  }

  Widget _buildCompactCategoryHeader(ServiceCategoryDto category, int serviceCount, bool isExpanded, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      '$serviceCount services',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCategoryServices(List<ServiceDto> services, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: services.map((service) => _buildCompactServiceCard(service, colors)).toList(),
      ),
    );
  }

  Widget _buildCompactServiceCard(ServiceDto service, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: service.isActive ? colors.first.withOpacity(0.2) : Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewServiceDetail(service),
          onLongPress: () => _showOfferManagement(service),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 10,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.durationInMinutes}m',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.currency_rupee_rounded,
                          size: 10,
                          color: colors.first,
                        ),
                        Text(
                          service.price.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.first,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildCompactStatusBadge(service),
              const SizedBox(width: 8),
              _buildCompactServiceMenuButton(service),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatusBadge(ServiceDto service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: service.isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service.isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCompactServiceMenuButton(ServiceDto service) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => _showServiceBottomSheet(service),
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Icon(
              Icons.more_vert_rounded,
              size: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactUncategorizedSection(List<ServiceDto> services) {
    final isExpanded = _expandedCategoryIds.contains(-999);
    final colors = [Colors.grey.shade400, Colors.grey.shade600];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          _buildCompactUncategorizedHeader(services.length, isExpanded, colors),
          if (isExpanded) _buildCompactCategoryServices(services, colors),
        ],
      ),
    );
  }

  Widget _buildCompactUncategorizedHeader(int serviceCount, bool isExpanded, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uncategorized',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      '$serviceCount services',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create categories and add services for your customers.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCompactActionButton(
                  onPressed: _managCategories,
                  icon: Icons.category_rounded,
                  label: 'Categories',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactActionButton(
                  onPressed: _addService,
                  icon: Icons.add_business_rounded,
                  label: 'Add Service',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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

  void _showServiceBottomSheet(ServiceDto service) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.visibility_outlined,
            title: 'View Details',
            onTap: () {
              Navigator.pop(context);
              _viewServiceDetail(service);
            },
          ),
          _buildActionTile(
            icon: Icons.edit_outlined,
            title: 'Edit Service',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/add-service',
                arguments: {
                  'service': service,
                  'salonId': widget.salonId,
                  'salonName': widget.salonName,
                },
              ).then((_) => _refreshServices());
            },
          ),
          _buildActionTile(
            icon: service.isActive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
            title: service.isActive ? 'Deactivate' : 'Activate',
            onTap: () {
              Navigator.pop(context);
              _toggleServiceStatus(service);
            },
          ),
          _buildActionTile(
            icon: Icons.delete_outline,
            title: 'Delete Service',
            onTap: () {
              Navigator.pop(context);
              _deleteService(service);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
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

  void _showOfferManagement(ServiceDto service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OfferManagementDialog(
        service: service,
        onOfferUpdated: (updatedService) {
          // Update the service in our local lists
          final serviceIndex = _allServices.indexWhere((s) => s.id == updatedService.id);
          if (serviceIndex != -1) {
            setState(() {
              _allServices[serviceIndex] = updatedService;
              _filterServices();
            });
          }
        },
      ),
    );
  }
}
