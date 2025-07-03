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
      backgroundColor: const Color(0xFFF8F9FB),
      body: _isLoading && _loadingCategories
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshServices,
              color: AppColors.primary,
              strokeWidth: 2.5,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildModernHeader(),
                  _buildQuickInsights(),
                  _buildCategoryActions(),
                  _buildServicesContent(),
                  // Bottom padding for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(),
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

  Widget _buildModernHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primary.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Management',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your salon offerings with ease',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildHeaderActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        Expanded(
          child: _buildHeaderActionButton(
            icon: Icons.category_rounded,
            label: 'Categories',
            onTap: _managCategories,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHeaderActionButton(
            icon: Icons.add_business_rounded,
            label: 'Add Service',
            onTap: _addService,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _showInactiveServices = !_showInactiveServices;
            _filterServices();
          });
        },
        icon: Icon(
          _showInactiveServices ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
          size: 20,
        ),
        tooltip: _showInactiveServices ? 'Hide Inactive' : 'Show Inactive',
      ),
    );
  }

  Widget _buildQuickInsights() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Insights',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards() {
    final activeServices = _services.where((s) => s.isActive).length;
    final totalRevenue = _services.fold<double>(0, (sum, service) => sum + service.price);
    
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            title: 'Active',
            value: activeServices.toString(),
            subtitle: 'Services',
            icon: Icons.trending_up_rounded,
            gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            title: 'Categories',
            value: _categories.length.toString(),
            subtitle: 'Created',
            icon: Icons.category_rounded,
            gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            title: 'Revenue',
            value: '₹${(totalRevenue / 1000).toStringAsFixed(1)}K',
            subtitle: 'Potential',
            icon: Icons.analytics_rounded,
            gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryActions() {
    if (_categories.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: _managCategories,
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final colors = _getCategoryGradient(category.name);
                  return _buildCategoryChip(category, colors);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ServiceCategoryDto category, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          const SizedBox(width: 8),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.first,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _addService,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
      icon: const Icon(Icons.add_rounded, size: 24),
      label: const Text(
        'Add Service',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }



  Widget _buildServicesContent() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Services',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            _loadingCategories
                ? _buildServicesLoadingSkeleton()
                : _categories.isEmpty
                    ? _buildEmptyState()
                    : _buildModernServicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesLoadingSkeleton() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildModernServicesList() {
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
          return _buildModernCategorySection(category, categoryServices);
        }),
        if (uncategorizedServices.isNotEmpty)
          _buildModernUncategorizedSection(uncategorizedServices),
      ],
    );
  }

  Widget _buildModernCategorySection(ServiceCategoryDto category, List<ServiceDto> services) {
    final isExpanded = _expandedCategoryIds.contains(category.id);
    final colors = _getCategoryGradient(category.name);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernCategoryHeader(category, services.length, isExpanded, colors),
          if (isExpanded) _buildModernCategoryServices(services, colors),
        ],
      ),
    );
  }

  Widget _buildModernCategoryHeader(ServiceCategoryDto category, int serviceCount, bool isExpanded, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: isExpanded ? BoxDecoration(
            gradient: LinearGradient(
              colors: colors.map((c) => c.withOpacity(0.05)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ) : null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.first.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$serviceCount ${serviceCount == 1 ? 'service' : 'services'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.first,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (serviceCount > 0)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpanded ? colors.first.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: isExpanded ? colors.first : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCategoryServices(List<ServiceDto> services, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors.map((c) => c.withOpacity(0.3)).toList()),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          ...services.map((service) => _buildModernServiceCard(service, colors)),
        ],
      ),
    );
  }

  Widget _buildModernServiceCard(ServiceDto service, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: service.isActive ? colors.first.withOpacity(0.2) : Colors.orange.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewServiceDetail(service),
          onLongPress: () => _showOfferManagement(service),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
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
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildModernServiceMeta(service, colors.first),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildModernStatusBadge(service),
                      const SizedBox(width: 8),
                      _buildServiceMenuButton(service, colors.first),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildModernPriceDisplay(service, colors.first)),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      _buildModernDurationChip(service),
                      const SizedBox(width: 8),
                      _buildOfferQuickAction(service, colors.first),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernServiceMeta(ServiceDto service, Color color) {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '${service.durationInMinutes} min',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.currency_rupee_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${service.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatusBadge(ServiceDto service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: service.isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            service.isActive ? 'Active' : 'Inactive',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPriceDisplay(ServiceDto service, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (service.hasActiveOffer && service.offerPrice != null) ...[
          // Offer price display
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'OFFER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${service.offerPrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDC2626),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '₹${service.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${service.savingsPercentage?.toStringAsFixed(0)}% OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          if (service.offerExpiryDate != null) ...[
            const SizedBox(height: 2),
            Text(
              service.offerExpiryText ?? '',
              style: TextStyle(
                fontSize: 10,
                color: service.offerExpiryDate!.isBefore(DateTime.now()) 
                    ? Colors.red.shade600 
                    : Colors.orange.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ] else ...[
          // Regular price display
          Text(
            '₹${service.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernDurationChip(ServiceDto service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            '${service.durationInMinutes}m',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferQuickAction(ServiceDto service, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: service.hasActiveOffer 
            ? Colors.orange.shade100 
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: service.hasActiveOffer 
              ? Colors.orange.shade300 
              : color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showOfferManagement(service),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              service.hasActiveOffer 
                  ? Icons.local_offer_rounded 
                  : Icons.local_offer_outlined,
              size: 18,
              color: service.hasActiveOffer 
                  ? Colors.orange.shade700 
                  : color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceMenuButton(ServiceDto service, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _showServiceBottomSheet(service),
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Icon(
              Icons.more_vert_rounded,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceBottomSheet(ServiceDto service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildServiceBottomSheet(service),
    );
  }

  Widget _buildModernUncategorizedSection(List<ServiceDto> services) {
    final isExpanded = _expandedCategoryIds.contains(-999);
    final colors = [Colors.grey.shade400, Colors.grey.shade600];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernUncategorizedHeader(services.length, isExpanded, colors),
          if (isExpanded) _buildModernCategoryServices(services, colors),
        ],
      ),
    );
  }

  Widget _buildModernUncategorizedHeader(int serviceCount, bool isExpanded, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uncategorized Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$serviceCount ${serviceCount == 1 ? 'service' : 'services'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpanded ? colors.first.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: isExpanded ? colors.first : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
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
                width: 70,
                height: 70,
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
                  size: 35,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Service Categories Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start by creating categories to organize your services, then add amazing services for your customers.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _buildEmptyStateButton(
                  onPressed: _managCategories,
                  icon: Icons.category_rounded,
                  label: 'Create Categories',
                  gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEmptyStateButton(
                  onPressed: _addService,
                  icon: Icons.add_business_rounded,
                  label: 'Add Service',
                  gradient: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _refreshServices,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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
        icon: Icons.local_offer_rounded,
        title: service.hasActiveOffer ? 'Manage Offer' : 'Set Offer',
        color: service.hasActiveOffer ? Colors.orange.shade700 : Colors.purple.shade700,
        onTap: () {
          Navigator.pop(context);
          _showOfferManagement(service);
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
