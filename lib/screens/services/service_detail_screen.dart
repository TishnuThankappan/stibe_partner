import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceDto service;
  final int salonId;
  final String salonName;
  
  const ServiceDetailScreen({
    super.key, 
    required this.service,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServiceManagementService _serviceService = ServiceManagementService();
  bool _isLoading = false;
  late ServiceDto _currentService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentService = widget.service;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToEditService() async {
    try {
      Navigator.pushNamed(
        context,
        '/add-service',
        arguments: {
          'salonId': widget.salonId,
          'salonName': widget.salonName,
          'service': _currentService,
        },
      ).then((result) {
        if (result == true && mounted) {
          // Refresh service data
          setState(() {});
        }
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to open edit screen: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _toggleServiceStatus() async {
    final bool currentStatus = _currentService.isActive;
    final bool newStatus = !currentStatus;
    
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Activate Service' : 'Deactivate Service'),
        content: Text(
          newStatus 
            ? 'Are you sure you want to activate this service? It will become available for booking again.'
            : 'Are you sure you want to deactivate this service? It will be hidden from customers but you can reactivate it anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedService = await _serviceService.updateService(
        widget.salonId,
        UpdateServiceRequest(id: _currentService.id, isActive: newStatus),
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Service ${newStatus ? 'activated' : 'deactivated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

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

  Future<void> _deleteService() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete "${_currentService.name}"? This action cannot be undone.\n\n'
          'Note: If this service has existing bookings, it will be deactivated instead of deleted.',
        ),
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

    setState(() {
      _isLoading = true;
    });

    try {
      await _serviceService.deleteService(widget.salonId, _currentService.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return to services list
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _currentService.name,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _navigateToEditService();
                  break;
                case 'toggle':
                  _toggleServiceStatus();
                  break;
                case 'delete':
                  _deleteService();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Service'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: ListTile(
                  leading: Icon(
                    _currentService.isActive ? Icons.pause_circle : Icons.play_circle,
                    color: _currentService.isActive ? Colors.orange : Colors.green,
                  ),
                  title: Text(_currentService.isActive ? 'Deactivate' : 'Activate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Service Header
                _buildServiceHeader(),
                
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Gallery'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildGalleryTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service image and basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: _currentService.imageUrl != null && _currentService.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _currentService.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
              
              const SizedBox(width: 16),
              
              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service name and status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentService.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _currentService.isActive ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentService.isActive ? 'Active' : 'Inactive',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Category
                    if (_currentService.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentService.categoryName!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Price and duration
                    Row(
                      children: [
                        // Price
                        if (_currentService.offerPrice != null && _currentService.offerPrice! < _currentService.price) ...[
                          Text(
                            '₹${_currentService.offerPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${_currentService.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '₹${_currentService.price.toStringAsFixed(0)}',
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
                                '${_currentService.durationInMinutes} min',
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
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_outlined,
            size: 24,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            'Image',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
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
          // Description
          if (_currentService.description.isNotEmpty) ...[
            _buildInfoCard(
              title: 'Description',
              icon: Icons.description_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentService.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Products Used
          if (_currentService.productsUsed != null && _currentService.productsUsed!.isNotEmpty) ...[
            _buildInfoCard(
              title: 'Products Used',
              icon: Icons.inventory_2_outlined,
              content: Text(
                _currentService.productsUsed!,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Service Details
          _buildInfoCard(
            title: 'Service Details',
            icon: Icons.info_outline,
            content: Column(
              children: [
                _buildDetailRow('Duration', '${_currentService.durationInMinutes} minutes'),
                _buildDetailRow('Price', '₹${_currentService.price.toStringAsFixed(0)}'),
                if (_currentService.offerPrice != null)
                  _buildDetailRow('Offer Price', '₹${_currentService.offerPrice!.toStringAsFixed(0)}'),
                if (_currentService.categoryName != null)
                  _buildDetailRow('Category', _currentService.categoryName!),
                _buildDetailRow('Status', _currentService.isActive ? 'Active' : 'Inactive'),
                _buildDetailRow('Max Concurrent Bookings', '${_currentService.maxConcurrentBookings}'),
                _buildDetailRow('Requires Staff Assignment', _currentService.requiresStaffAssignment ? 'Yes' : 'No'),
                if (_currentService.bufferTimeBeforeMinutes > 0)
                  _buildDetailRow('Buffer Time Before', '${_currentService.bufferTimeBeforeMinutes} minutes'),
                if (_currentService.bufferTimeAfterMinutes > 0)
                  _buildDetailRow('Buffer Time After', '${_currentService.bufferTimeAfterMinutes} minutes'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Statistics
          _buildInfoCard(
            title: 'Statistics',
            icon: Icons.analytics_outlined,
            content: Column(
              children: [
                _buildDetailRow('Total Bookings', '${_currentService.bookingCount}'),
                _buildDetailRow('Average Rating', _currentService.averageRating > 0 
                    ? '${_currentService.averageRating.toStringAsFixed(1)} ⭐' 
                    : 'No ratings yet'),
                _buildDetailRow('Popular', _currentService.isPopular ? 'Yes' : 'No'),
                _buildDetailRow('Created', '${_currentService.createdAt.day}/${_currentService.createdAt.month}/${_currentService.createdAt.year}'),
                _buildDetailRow('Last Updated', '${_currentService.updatedAt.day}/${_currentService.updatedAt.month}/${_currentService.updatedAt.year}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    final galleryImages = _currentService.serviceImages ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Service Gallery',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addGalleryImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Image'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (galleryImages.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Gallery Images',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add images to showcase your service',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return _buildGalleryImageCard(galleryImages[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildInfoCard(
            title: 'Quick Actions',
            icon: Icons.flash_on_outlined,
            content: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Service'),
                  subtitle: const Text('Modify service details, pricing, and description'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _navigateToEditService,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    _currentService.isActive ? Icons.pause_circle : Icons.play_circle,
                    color: _currentService.isActive ? Colors.orange : Colors.green,
                  ),
                  title: Text(_currentService.isActive ? 'Deactivate Service' : 'Activate Service'),
                  subtitle: Text(_currentService.isActive 
                      ? 'Hide this service from customers'
                      : 'Make this service available for booking'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _toggleServiceStatus,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Service', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Permanently remove this service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                  onTap: _deleteService,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Advanced Settings
          _buildInfoCard(
            title: 'Advanced Settings',
            icon: Icons.settings_outlined,
            content: Column(
              children: [
                _buildSettingRow(
                  'Service ID',
                  '#${_currentService.id}',
                  null,
                ),
                _buildSettingRow(
                  'Salon',
                  _currentService.salonName,
                  null,
                ),
                _buildSettingRow(
                  'Max Concurrent Bookings',
                  '${_currentService.maxConcurrentBookings}',
                  () {
                    // TODO: Implement edit functionality
                  },
                ),
                _buildSettingRow(
                  'Staff Assignment Required',
                  _currentService.requiresStaffAssignment ? 'Yes' : 'No',
                  () {
                    // TODO: Implement edit functionality
                  },
                ),
                if (_currentService.bufferTimeBeforeMinutes > 0)
                  _buildSettingRow(
                    'Buffer Time Before',
                    '${_currentService.bufferTimeBeforeMinutes} minutes',
                    () {
                      // TODO: Implement edit functionality
                    },
                  ),
                if (_currentService.bufferTimeAfterMinutes > 0)
                  _buildSettingRow(
                    'Buffer Time After',
                    '${_currentService.bufferTimeAfterMinutes} minutes',
                    () {
                      // TODO: Implement edit functionality
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, VoidCallback? onTap) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: onTap != null ? const Icon(Icons.edit, size: 16) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildGalleryImageCard(String imageUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                  onPressed: () => _removeGalleryImage(index),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addGalleryImage() async {
    // TODO: Implement image picker and upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery image upload feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _removeGalleryImage(int index) async {
    // TODO: Implement image removal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery image removal feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
