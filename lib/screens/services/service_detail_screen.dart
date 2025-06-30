import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/screens/services/edit_service_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceDto service;
  final int salonId;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    required this.salonId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServiceManagementService _serviceService = ServiceManagementService();
  late ServiceDto _service;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _service.name,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
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
                value: 'toggle_status',
                child: ListTile(
                  leading: Icon(_service.isActive ? Icons.pause_circle : Icons.play_circle),
                  title: Text(_service.isActive ? 'Deactivate' : 'Activate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Delete Service', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshService,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceHeader(),
                    const SizedBox(height: 24),
                    _buildServiceDetails(),
                    const SizedBox(height: 24),
                    _buildPricingInfo(),
                    const SizedBox(height: 24),
                    _buildSettingsInfo(),
                    const SizedBox(height: 24),
                    if (_service.tags.isNotEmpty) ...[
                      _buildTagsSection(),
                      const SizedBox(height: 24),
                    ],
                    _buildAnalyticsSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
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
      child: Column(
        children: [
          // Service Image
          if (_service.imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  _service.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                ),
              ),
            ),
          
          // Service Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _service.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _service.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _service.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_service.categoryName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _service.categoryName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  _service.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                if (_service.isPopular) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                          size: 16,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Popular Service',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
    return _buildSection(
      title: 'Service Details',
      icon: Icons.info_outline,
      children: [
        _buildDetailRow(
          icon: Icons.access_time,
          label: 'Duration',
          value: _service.formattedDuration,
          color: Colors.blue.shade600,
        ),
        _buildDetailRow(
          icon: Icons.people,
          label: 'Max Concurrent Bookings',
          value: _service.maxConcurrentBookings.toString(),
          color: Colors.purple.shade600,
        ),
        if (_service.bufferTimeBeforeMinutes > 0)
          _buildDetailRow(
            icon: Icons.schedule,
            label: 'Buffer Before',
            value: '${_service.bufferTimeBeforeMinutes} min',
            color: Colors.orange.shade600,
          ),
        if (_service.bufferTimeAfterMinutes > 0)
          _buildDetailRow(
            icon: Icons.schedule,
            label: 'Buffer After',
            value: '${_service.bufferTimeAfterMinutes} min',
            color: Colors.orange.shade600,
          ),
        _buildDetailRow(
          icon: Icons.assignment_ind,
          label: 'Staff Assignment',
          value: _service.requiresStaffAssignment ? 'Required' : 'Optional',
          color: _service.requiresStaffAssignment ? Colors.red.shade600 : Colors.green.shade600,
        ),
      ],
    );
  }

  Widget _buildPricingInfo() {
    return _buildSection(
      title: 'Pricing Information',
      icon: Icons.attach_money,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceCard(
                title: 'Base Price',
                price: _service.formattedPrice,
                subtitle: 'Original pricing',
                color: Colors.green,
              ),
            ),
            if (_service.discountPercentage != null && _service.discountPercentage! > 0) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceCard(
                  title: 'Discounted Price',
                  price: _service.priceWithDiscount,
                  subtitle: '${_service.discountPercentage!.toStringAsFixed(1)}% off',
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String price,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsInfo() {
    return _buildSection(
      title: 'Service Settings',
      icon: Icons.settings,
      children: [
        _buildSettingTile(
          icon: Icons.assignment_ind,
          title: 'Staff Assignment Required',
          value: _service.requiresStaffAssignment,
        ),
        _buildSettingTile(
          icon: Icons.star,
          title: 'Popular Service',
          value: _service.isPopular,
        ),
        _buildSettingTile(
          icon: Icons.visibility,
          title: 'Active Service',
          value: _service.isActive,
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? Colors.green.shade600 : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? Colors.green.shade600 : Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return _buildSection(
      title: 'Tags',
      icon: Icons.local_offer,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _service.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return _buildSection(
      title: 'Performance Analytics',
      icon: Icons.analytics,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                icon: Icons.event,
                title: 'Total Bookings',
                value: _service.bookingCount.toString(),
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnalyticsCard(
                icon: Icons.star,
                title: 'Average Rating',
                value: _service.averageRating > 0 
                    ? _service.averageRating.toStringAsFixed(1)
                    : 'N/A',
                color: Colors.amber.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper methods
  Future<void> _refreshService() async {
    try {
      final updatedService = await _serviceService.getServiceById(widget.salonId, _service.id);
      setState(() {
        _service = updatedService;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing service: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          service: _service,
          salonId: widget.salonId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _refreshService();
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _navigateToEdit();
        break;
      case 'toggle_status':
        _toggleServiceStatus();
        break;
      case 'duplicate':
        _duplicateService();
        break;
      case 'delete':
        _deleteService();
        break;
    }
  }

  Future<void> _toggleServiceStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedService = await _serviceService.toggleServiceStatus(
        widget.salonId,
        _service.id,
        !_service.isActive,
      );

      setState(() {
        _service = updatedService;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Service ${_service.isActive ? "activated" : "deactivated"} successfully!',
            ),
            backgroundColor: _service.isActive ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _duplicateService() async {
    final newName = '${_service.name} (Copy)';

    try {
      await _serviceService.duplicateService(
        widget.salonId,
        _service.id,
        newName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service duplicated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _deleteService() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${_service.name}"?',
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
      await _serviceService.deleteService(widget.salonId, _service.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return to previous screen
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
