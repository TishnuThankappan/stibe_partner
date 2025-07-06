import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/constants/card_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/screens/services/manage_categories_screen.dart';

class ServicesScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServicesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _isLoading = true;
  List<ServiceDto> _services = [];
  List<ServiceDto> _allServices = [];
  String? _errorMessage;
  bool _showInactiveServices = true; // Show all services by default
  
  // Category filter
  List<ServiceCategoryDto> _categories = [];
  bool _loadingCategories = true;
  
  // Expanded categories tracking
  Set<int> _expandedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadServices();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
    });

    try {
      final serviceService = ServiceManagementService();
      // Get both backend-created and predefined categories
      final categories = await serviceService.getServiceCategories(widget.salonId);
      
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
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
          ),
        );
      }
    }
  }

  void _filterServices() {
    // Only filter by active/inactive status
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.salonName} Services',
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageCategoriesScreen(
                    salonId: widget.salonId,
                    salonName: widget.salonName,
                  ),
                ),
              ).then((_) {
                // Refresh categories when returning from the manage categories screen
                _loadCategories();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Service',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-service',
                arguments: {
                  'salonId': widget.salonId,
                  'salonName': widget.salonName,
                },
              ).then((_) => _refreshServices());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshServices,
              child: Column(
                children: [
                  // Display categories section
                  if (!_loadingCategories && _categories.isNotEmpty) 
                    _buildCategoriesSection(),
                  
                  // Filter options
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Display Options:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            // Toggle for active/inactive services
                            Row(
                              children: [
                                Text(
                                  'Show Inactive',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: _showInactiveServices,
                                  onChanged: (value) {
                                    setState(() {
                                      _showInactiveServices = value;
                                      _filterServices();
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap on a category to see services',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Services list
                  Expanded(
                    child: _loadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : _categories.isEmpty
                            ? _buildEmptyState()
                            : _buildServicesList(),
                  ),
                ],
              ),
            ),
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
            const SizedBox(height: 100),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Services Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start offering amazing services to your customers by adding your first service.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add-service',
                  arguments: {
                    'salonId': widget.salonId,
                    'salonName': widget.salonName,
                  },
                ).then((_) => _refreshServices());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Manage'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageCategoriesScreen(
                          salonId: widget.salonId,
                          salonName: widget.salonName,
                        ),
                      ),
                    ).then((_) {
                      // Refresh categories when returning from the manage categories screen
                      _loadCategories();
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                
                // Determine icon based on category name
                IconData iconData;
                switch(category.name.toLowerCase()) {
                  case 'hair care':
                    iconData = Icons.content_cut;
                    break;
                  case 'skin care':
                    iconData = Icons.face;
                    break;
                  case 'nail care':
                    iconData = Icons.back_hand;
                    break;
                  case 'massage':
                    iconData = Icons.spa;
                    break;
                  case 'makeup':
                    iconData = Icons.brush;
                    break;
                  case 'hair removal':
                    iconData = Icons.waves;
                    break;
                  case 'men\'s grooming':
                    iconData = Icons.person;
                    break;
                  default:
                    iconData = Icons.spa;
                }
                
                return Container(
                  margin: const EdgeInsets.only(right: 8, left: 8),
                  child: Chip(
                    avatar: Icon(
                      iconData,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(category.name),
                    backgroundColor: Colors.grey.shade50,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
  
  Widget _buildServicesList() {
    // Group services by category
    final Map<int?, List<ServiceDto>> servicesByCategory = {};
    
    // Group services that don't have a category
    final List<ServiceDto> uncategorizedServices = [];
    
    // Process each service
    for (final service in _services) {
      if (service.categoryId == null) {
        uncategorizedServices.add(service);
      } else {
        if (!servicesByCategory.containsKey(service.categoryId)) {
          servicesByCategory[service.categoryId] = [];
        }
        servicesByCategory[service.categoryId]!.add(service);
      }
    }
    
    // Prepare the list items: headers and services
    final List<Widget> listItems = [];
    
    // First add all categories with expandable sections
    _categories.forEach((category) {
      final categoryServices = servicesByCategory[category.id] ?? [];
      
      // Add expandable category header
      listItems.add(
        _buildExpandableCategoryHeader(
          category, 
          categoryServices.length,
          isExpanded: _expandedCategoryIds.contains(category.id),
          onTap: () {
            setState(() {
              // Toggle expanded state
              if (_expandedCategoryIds.contains(category.id)) {
                _expandedCategoryIds.remove(category.id);
              } else {
                _expandedCategoryIds.add(category.id);
              }
            });
          },
        ),
      );
      
      // Only show services if category is expanded
      if (_expandedCategoryIds.contains(category.id)) {
        // Add services in this category
        categoryServices.forEach((service) {
          listItems.add(_buildServiceCard(service));
        });
        
        // Add a divider after expanded category
        listItems.add(Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          height: 32,
          indent: 16,
          endIndent: 16,
        ));
      }
    });
    
    // Add uncategorized services at the end if any
    if (uncategorizedServices.isNotEmpty) {
      // Create a fake category for uncategorized services
      final uncategorizedCategory = ServiceCategoryDto(
        id: -999, // Special ID for uncategorized
        name: 'Uncategorized',
        description: 'Services without a category',
        salonId: widget.salonId,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      listItems.add(
        _buildExpandableCategoryHeader(
          uncategorizedCategory,
          uncategorizedServices.length,
          isExpanded: _expandedCategoryIds.contains(-999),
          onTap: () {
            setState(() {
              // Toggle expanded state
              if (_expandedCategoryIds.contains(-999)) {
                _expandedCategoryIds.remove(-999);
              } else {
                _expandedCategoryIds.add(-999);
              }
            });
          },
        ),
      );
      
      // Only show services if uncategorized section is expanded
      if (_expandedCategoryIds.contains(-999)) {
        uncategorizedServices.forEach((service) {
          listItems.add(_buildServiceCard(service));
        });
      }
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: listItems,
    );
  }
  
  Widget _buildExpandableCategoryHeader(
    ServiceCategoryDto category, 
    int serviceCount, 
    {required bool isExpanded, required VoidCallback onTap}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isExpanded ? 16 : 8, top: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isExpanded 
              ? AppColors.primary.withOpacity(0.15) 
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: isExpanded 
                ? AppColors.primary.withOpacity(0.5) 
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(category.name),
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                serviceCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpanded ? "Hide" : "Show",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String categoryName) {
    // Return appropriate icons based on category names
    switch (categoryName.toLowerCase()) {
      case 'hair care':
        return Icons.content_cut;
      case 'facial':
        return Icons.face;
      case 'nail care':
        return Icons.pan_tool;
      case 'massage':
        return Icons.spa;
      case 'body treatments':
        return Icons.healing;
      case 'makeup':
        return Icons.brush;
      case 'waxing':
        return Icons.waves;
      case 'uncategorized':
        return Icons.category;
      default:
        return Icons.spa;
    }
  }

  Widget _buildServiceCard(ServiceDto service) {
    return Opacity(
      opacity: service.isActive ? 1.0 : 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: service.isActive ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: service.isActive 
              ? null 
              : Border.all(color: Colors.orange.shade300, width: 2),
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
            onTap: () {
              Navigator.pushNamed(
                context,
                '/service-detail',
                arguments: {
                  'service': service,
                  'salonId': widget.salonId,
                  'salonName': widget.salonName,
                },
              ).then((_) => _refreshServices());
            },
            onLongPress: () => _showServiceContextMenu(context, service),
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Image
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Image or placeholder
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                                ? Hero(
                                    tag: 'service_image_${service.id}',
                                    child: Image.network(
                                      service.imageUrl!,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildImagePlaceholder();
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return _buildImagePlaceholder();
                                      },
                                    ),
                                  )
                                : _buildImagePlaceholder(),
                          ),
                          
                          // Status indicator
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: service.isActive ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    service.isActive ? Icons.check_circle : Icons.pause_circle,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.isActive ? 'Active' : 'Inactive',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Service Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service name and category
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (service.categoryName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    service.categoryName!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Description
                          if (service.description.isNotEmpty)
                            Text(
                              service.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          
                          const SizedBox(height: 12),
                          
                          // Price and duration row
                          Row(
                            children: [
                              // Price
                              if (service.offerPrice != null && service.offerPrice! < service.price) ...[
                                Text(
                                  '₹${service.offerPrice!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${service.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '₹${service.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                              
                              const Spacer(),
                              
                              // Duration
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.durationInMinutes} min',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
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
                  ],
                ),
                
                // Inactive service banner
                if (!service.isActive)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'INACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_outlined,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Service Image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceContextMenu(BuildContext context, ServiceDto service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/service-detail',
                  arguments: {
                    'service': service,
                    'salonId': widget.salonId,
                    'salonName': widget.salonName,
                  },
                ).then((_) => _refreshServices());
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Service'),
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          ),
        );
      }
    }
  }
}
