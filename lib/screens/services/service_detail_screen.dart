import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/utils/image_utils.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';

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
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _editServicePrice() async {
    final TextEditingController controller = TextEditingController(
      text: _currentService.price.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Service Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set the regular price for this service:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                border: OutlineInputBorder(),
                hintText: 'Enter price in rupees',
                prefixText: '₹ ',
              ),
              onChanged: (value) {
                // Validate input as user types
                final price = double.tryParse(value);
                if (price != null && price <= 0) {
                  // Show validation hint
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid price greater than 0'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update Price'),
          ),
        ],
      ),
    );

    if (result != null && result != _currentService.price) {
      await _updateServicePricing(price: result);
    }
  }

  Future<void> _editOfferPrice() async {
    final TextEditingController controller = TextEditingController(
      text: _currentService.offerPrice?.toStringAsFixed(0) ?? '',
    );

    final result = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Offer Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set an offer price for this service (optional):',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Regular price: ₹${_currentService.price.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Offer Price (₹)',
                border: OutlineInputBorder(),
                hintText: 'Enter offer price or leave empty to remove',
                prefixText: '₹ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (_currentService.offerPrice != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(null), // Remove offer price
              child: const Text('Remove Offer', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                // Remove offer price
                Navigator.of(context).pop(null);
                return;
              }
              
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                if (value >= _currentService.price) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offer price must be less than regular price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid offer price'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set Offer'),
          ),
        ],
      ),
    );

    if (result != _currentService.offerPrice) {
      await _updateServicePricing(offerPrice: result);
    }
  }

  Future<void> _updateServicePricing({
    double? price,
    double? offerPrice,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updateRequest = UpdateServiceRequest(
        id: _currentService.id,
        price: price,
        offerPrice: offerPrice,
      );

      final updatedService = await _serviceService.updateService(
        widget.salonId,
        updateRequest,
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      // Show success message
      String message = '';
      if (price != null) {
        message = 'Service price updated to ₹${price.toStringAsFixed(0)}';
      } else if (offerPrice != null) {
        message = 'Offer price set to ₹${offerPrice.toStringAsFixed(0)}';
      } else if (offerPrice == null && _currentService.offerPrice == null) {
        message = 'Offer price removed successfully';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
            content: Text('Failed to update pricing: ${e.toString()}'),
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
          ? Center(child: LoadingIndicator.googleLoader())
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
          if ((_currentService.products != null && _currentService.products!.isNotEmpty) ||
              (_currentService.productsUsed != null && _currentService.productsUsed!.isNotEmpty)) ...[
            _buildInfoCard(
              title: 'Products Used',
              icon: Icons.inventory_2_outlined,
              content: _buildProductsSection(),
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
                  leading: const Icon(Icons.currency_rupee, color: Colors.green),
                  title: const Text('Change Price'),
                  subtitle: Text('Current: ₹${_currentService.price.toStringAsFixed(0)}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _editServicePrice,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.orange),
                  title: const Text('Set Offer Price'),
                  subtitle: Text(_currentService.offerPrice != null 
                      ? 'Current: ₹${_currentService.offerPrice!.toStringAsFixed(0)}'
                      : 'No offer price set'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _editOfferPrice,
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
                  () => _editMaxConcurrentBookings(),
                ),
                _buildSettingRow(
                  'Staff Assignment Required',
                  _currentService.requiresStaffAssignment ? 'Yes' : 'No',
                  () => _toggleStaffAssignmentRequired(),
                ),
                if (_currentService.bufferTimeBeforeMinutes > 0)
                  _buildSettingRow(
                    'Buffer Time Before',
                    '${_currentService.bufferTimeBeforeMinutes} minutes',
                    () => _editBufferTimeBefore(),
                  ),
                if (_currentService.bufferTimeAfterMinutes > 0)
                  _buildSettingRow(
                    'Buffer Time After',
                    '${_currentService.bufferTimeAfterMinutes} minutes',
                    () => _editBufferTimeAfter(),
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
    // Ensure the image URL is absolute
    final fullImageUrl = ImageUtils.getFullImageUrl(imageUrl);
    
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
              fullImageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
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
            // Add tap to view full screen (positioned before delete button)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _viewImageFullScreen(fullImageUrl),
                ),
              ),
            ),
            // Delete button - improved for better UX
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _removeGalleryImage(index),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Image index indicator (helps with organization)
            if ((_currentService.serviceImages?.length ?? 0) > 1)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty && mounted) {
        // Show immediate feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading ${images.length} image${images.length > 1 ? 's' : ''}...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );

        setState(() {
          _isLoading = true;
        });

        try {
          // Upload images to server
          final uploadedUrls = await _serviceService.uploadServiceGalleryImages(
            widget.salonId,
            images.map((img) => File(img.path)).toList(),
          );

          // Update the service with new gallery images
          final currentImages = _currentService.serviceImages ?? [];
          final updatedImages = [...currentImages, ...uploadedUrls];

          final updatedService = await _serviceService.updateService(
            widget.salonId,
            UpdateServiceRequest(
              id: _currentService.id,
              serviceImages: updatedImages,
            ),
          );

          setState(() {
            _currentService = updatedService;
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${images.length} image${images.length > 1 ? 's' : ''} added successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    // Scroll to gallery section or switch to gallery tab
                    if (_tabController.index != 1) {
                      _tabController.animateTo(1);
                    }
                  },
                ),
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
                content: Text('Error uploading images: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeGalleryImage(int index) async {
    // Add haptic feedback for immediate user response
    HapticFeedback.lightImpact();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final currentImages = _currentService.serviceImages ?? [];
      if (index < currentImages.length) {
        final removedImageUrl = currentImages[index];
        final updatedImages = List<String>.from(currentImages);
        updatedImages.removeAt(index);

        final updatedService = await _serviceService.updateService(
          widget.salonId,
          UpdateServiceRequest(
            id: _currentService.id,
            serviceImages: updatedImages,
          ),
        );

        setState(() {
          _currentService = updatedService;
          _isLoading = false;
        });

        if (mounted) {
          // Show success with undo option
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Image removed from gallery'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () => _undoImageRemoval(removedImageUrl, index),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to undo image removal
  Future<void> _undoImageRemoval(String imageUrl, int originalIndex) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentImages = _currentService.serviceImages ?? [];
      final updatedImages = List<String>.from(currentImages);
      
      // Insert the image back at its original position or at the end if index is out of bounds
      if (originalIndex <= updatedImages.length) {
        updatedImages.insert(originalIndex, imageUrl);
      } else {
        updatedImages.add(imageUrl);
      }

      final updatedService = await _serviceService.updateService(
        widget.salonId,
        UpdateServiceRequest(
          id: _currentService.id,
          serviceImages: updatedImages,
        ),
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image restored to gallery'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
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
            content: Text('Error restoring image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewImageFullScreen(String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageView(imageUrl: imageUrl);
        },
      ),
    );
  }

  // Advanced Settings Edit Methods
  Future<void> _editMaxConcurrentBookings() async {
    final TextEditingController controller = TextEditingController(
      text: _currentService.maxConcurrentBookings.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Max Concurrent Bookings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set the maximum number of concurrent bookings for this service:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Concurrent Bookings',
                border: OutlineInputBorder(),
                hintText: 'Enter a number (1-10)',
              ),
              onChanged: (value) {
                // Validate input
                final num = int.tryParse(value);
                if (num != null && (num < 1 || num > 10)) {
                  // Show validation error
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 10) {
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number between 1 and 10'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result != _currentService.maxConcurrentBookings) {
      await _updateServiceSetting(maxConcurrentBookings: result);
    }
  }

  Future<void> _toggleStaffAssignmentRequired() async {
    final newValue = !_currentService.requiresStaffAssignment;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Assignment'),
        content: Text(
          newValue 
            ? 'Require staff assignment for this service?\n\nThis means a specific staff member must be assigned when booking this service.'
            : 'Make staff assignment optional for this service?\n\nThis allows customers to book without selecting a specific staff member.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(newValue ? 'Require Assignment' : 'Make Optional'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateServiceSetting(requiresStaffAssignment: newValue);
    }
  }

  Future<void> _editBufferTimeBefore() async {
    final TextEditingController controller = TextEditingController(
      text: _currentService.bufferTimeBeforeMinutes.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Buffer Time Before'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set buffer time before the service starts (in minutes):',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'This creates a gap before the service to allow for preparation.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Buffer Time (minutes)',
                border: OutlineInputBorder(),
                hintText: 'Enter minutes (0-60)',
                suffixText: 'min',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 60) {
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number between 0 and 60'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result != _currentService.bufferTimeBeforeMinutes) {
      await _updateServiceSetting(bufferTimeBeforeMinutes: result);
    }
  }

  Future<void> _editBufferTimeAfter() async {
    final TextEditingController controller = TextEditingController(
      text: _currentService.bufferTimeAfterMinutes.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Buffer Time After'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set buffer time after the service ends (in minutes):',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'This creates a gap after the service for cleanup and setup.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Buffer Time (minutes)',
                border: OutlineInputBorder(),
                hintText: 'Enter minutes (0-60)',
                suffixText: 'min',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 60) {
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number between 0 and 60'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result != _currentService.bufferTimeAfterMinutes) {
      await _updateServiceSetting(bufferTimeAfterMinutes: result);
    }
  }

  Future<void> _updateServiceSetting({
    int? maxConcurrentBookings,
    bool? requiresStaffAssignment,
    int? bufferTimeBeforeMinutes,
    int? bufferTimeAfterMinutes,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updateRequest = UpdateServiceRequest(
        id: _currentService.id,
        maxConcurrentBookings: maxConcurrentBookings,
        requiresStaffAssignment: requiresStaffAssignment,
        bufferTimeBeforeMinutes: bufferTimeBeforeMinutes,
        bufferTimeAfterMinutes: bufferTimeAfterMinutes,
      );

      final updatedService = await _serviceService.updateService(
        widget.salonId,
        updateRequest,
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      // Show success message
      String settingName = '';
      if (maxConcurrentBookings != null) settingName = 'Max Concurrent Bookings';
      if (requiresStaffAssignment != null) settingName = 'Staff Assignment Requirement';
      if (bufferTimeBeforeMinutes != null) settingName = 'Buffer Time Before';
      if (bufferTimeAfterMinutes != null) settingName = 'Buffer Time After';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$settingName updated successfully'),
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
            content: Text('Failed to update setting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProductsSection() {
    // Check if we have structured products with images
    if (_currentService.products != null && _currentService.products!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Product button
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: _addNewProduct,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Product'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          // Existing products
          ...(_currentService.products!.map((product) => _buildProductCard(product)).toList()),
        ],
      );
    } 
    // Fallback to legacy text format
    else if (_currentService.productsUsed != null && _currentService.productsUsed!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentService.productsUsed!,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          // Add Product button for legacy format conversion
          OutlinedButton.icon(
            onPressed: _addNewProduct,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      );
    }
    
    // No products case
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'No products specified',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        // Add Product button
        OutlinedButton.icon(
          onPressed: _addNewProduct,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Product'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ServiceProductDto product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name, description, and edit button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  IconButton(
                    onPressed: () => _editProduct(product),
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 18,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete button
                  IconButton(
                    onPressed: () => _deleteProduct(product),
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 18,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Product images
          if (product.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: product.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _viewImageFullScreen(product.imageUrls[index]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          product.imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey.shade400,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Method to edit a product (update name, description, and images)
  Future<void> _editProduct(ServiceProductDto product) async {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description ?? '');
    List<String> updatedImageUrls = List.from(product.imageUrls);
    List<File> newLocalImages = [];
    bool hasChanges = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Edit Product'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter product name',
                    ),
                    onChanged: (value) => hasChanges = true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Product description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Enter product description',
                    ),
                    maxLines: 3,
                    onChanged: (value) => hasChanges = true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Current images
                  if (updatedImageUrls.isNotEmpty || newLocalImages.isNotEmpty) ...[
                    const Text(
                      'Product Images:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    
                    // Image grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Existing images
                        ...updatedImageUrls.asMap().entries.map((entry) {
                          final index = entry.key;
                          final imageUrl = entry.value;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      updatedImageUrls.removeAt(index);
                                      hasChanges = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        
                        // New local images
                        ...newLocalImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  file,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      newLocalImages.removeAt(index);
                                      hasChanges = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        
                        // Add image button
                        GestureDetector(
                          onTap: () async {
                            try {
                              final List<XFile> images = await _picker.pickMultiImage();
                              if (images.isNotEmpty) {
                                setDialogState(() {
                                  newLocalImages.addAll(
                                    images.map((img) => File(img.path)).toList(),
                                  );
                                  hasChanges = true;
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error picking images: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                  ] else ...[
                    // No images - show add button
                    const Text(
                      'Product Images:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final List<XFile> images = await _picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            setDialogState(() {
                              newLocalImages.addAll(
                                images.map((img) => File(img.path)).toList(),
                              );
                              hasChanges = true;
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error picking images: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: Colors.grey.shade600,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Product Images',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: hasChanges || nameController.text.trim() != product.name || 
                        descriptionController.text.trim() != (product.description ?? '')
                  ? () async {
                      await _saveProductChanges(
                        product,
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        updatedImageUrls,
                        newLocalImages,
                      );
                      if (mounted) Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // Save product changes
  Future<void> _saveProductChanges(
    ServiceProductDto originalProduct,
    String newName,
    String newDescription,
    List<String> updatedImageUrls,
    List<File> newLocalImages,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new local images if any
      List<String> uploadedImageUrls = [];
      if (newLocalImages.isNotEmpty) {
        try {
          uploadedImageUrls = await _serviceService.uploadProductImages(
            widget.salonId,
            newLocalImages,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload images: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Combine existing and new image URLs
      final allImageUrls = [...updatedImageUrls, ...uploadedImageUrls];

      // Find the product in the current service's products list and update it
      final currentProducts = _currentService.products ?? [];
      final updatedProducts = currentProducts.map((p) {
        if (p.id == originalProduct.id) {
          return ServiceProductDto(
            id: p.id,
            name: newName.isNotEmpty ? newName : p.name,
            description: newDescription.isNotEmpty ? newDescription : null,
            imageUrls: allImageUrls,
            isUploaded: true,
          );
        }
        return p;
      }).toList();

      // Update the service with the modified products
      final updateRequest = UpdateServiceRequest(
        id: _currentService.id,
        products: updatedProducts,
      );

      final updatedService = await _serviceService.updateService(
        widget.salonId,
        updateRequest,
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
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
            content: Text('Failed to update product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add a new product to the service
  Future<void> _addNewProduct() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    List<File> selectedImages = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_box_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Add New Product'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      border: OutlineInputBorder(),
                      hintText: 'Enter product name',
                    ),
                    autofocus: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Product description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Enter product description',
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Product images
                  const Text(
                    'Product Images:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  
                  if (selectedImages.isNotEmpty) ...[
                    // Image grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Selected images
                        ...selectedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  file,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        
                        // Add image button
                        GestureDetector(
                          onTap: () async {
                            try {
                              final List<XFile> images = await _picker.pickMultiImage();
                              if (images.isNotEmpty) {
                                setDialogState(() {
                                  selectedImages.addAll(
                                    images.map((img) => File(img.path)).toList(),
                                  );
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error picking images: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // No images - show add button
                    GestureDetector(
                      onTap: () async {
                        try {
                          final List<XFile> images = await _picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            setDialogState(() {
                              selectedImages.addAll(
                                images.map((img) => File(img.path)).toList(),
                              );
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error picking images: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: Colors.grey.shade600,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Product Images',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: nameController.text.trim().isNotEmpty
                  ? () async {
                      await _saveNewProduct(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        selectedImages,
                      );
                      if (mounted) Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  // Save new product
  Future<void> _saveNewProduct(
    String name,
    String description,
    List<File> images,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images if any
      List<String> uploadedImageUrls = [];
      if (images.isNotEmpty) {
        try {
          uploadedImageUrls = await _serviceService.uploadProductImages(
            widget.salonId,
            images,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload images: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Create new product
      final newProduct = ServiceProductDto(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
        name: name,
        description: description.isNotEmpty ? description : null,
        imageUrls: uploadedImageUrls,
        isUploaded: true,
      );

      // Add to existing products list
      final currentProducts = _currentService.products ?? [];
      final updatedProducts = [...currentProducts, newProduct];

      // Update the service with the new products
      final updateRequest = UpdateServiceRequest(
        id: _currentService.id,
        products: updatedProducts,
      );

      final updatedService = await _serviceService.updateService(
        widget.salonId,
        updateRequest,
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "$name" added successfully'),
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
            content: Text('Failed to add product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete a product from the service
  Future<void> _deleteProduct(ServiceProductDto product) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              const TextSpan(text: 'Are you sure you want to delete "'),
              TextSpan(
                text: product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '"? This action cannot be undone.'),
            ],
          ),
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Remove product from the list
      final currentProducts = _currentService.products ?? [];
      final updatedProducts = currentProducts
          .where((p) => p.id != product.id)
          .toList();

      // Update the service with the modified products
      final updateRequest = UpdateServiceRequest(
        id: _currentService.id,
        products: updatedProducts,
      );

      final updatedService = await _serviceService.updateService(
        widget.salonId,
        updateRequest,
      );

      setState(() {
        _currentService = updatedService;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${product.name}" deleted successfully'),
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
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
