import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class ServiceBulkOperationsScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServiceBulkOperationsScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServiceBulkOperationsScreen> createState() => _ServiceBulkOperationsScreenState();
}

class _ServiceBulkOperationsScreenState extends State<ServiceBulkOperationsScreen> {
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  List<ServiceDto> _services = [];
  Set<int> _selectedServiceIds = <int>{};
  bool _isLoading = true;
  bool _isSelectAll = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final services = await _serviceService.getSalonServices(widget.salonId);
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshServices() async {
    await _loadServices();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_isSelectAll) {
        _selectedServiceIds.clear();
        _isSelectAll = false;
      } else {
        _selectedServiceIds = _services.map((s) => s.id).toSet();
        _isSelectAll = true;
      }
    });
  }

  void _toggleServiceSelection(int serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
      _isSelectAll = _selectedServiceIds.length == _services.length;
    });
  }

  Future<void> _bulkActivateServices() async {
    if (_selectedServiceIds.isEmpty) return;

    try {
      for (final serviceId in _selectedServiceIds) {
        final request = UpdateServiceRequest(id: serviceId, isActive: true);
        await _serviceService.updateService(widget.salonId, request);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedServiceIds.length} services activated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _selectedServiceIds.clear();
        _isSelectAll = false;
      });
      
      _refreshServices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to activate services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _bulkDeactivateServices() async {
    if (_selectedServiceIds.isEmpty) return;

    try {
      for (final serviceId in _selectedServiceIds) {
        final request = UpdateServiceRequest(id: serviceId, isActive: false);
        await _serviceService.updateService(widget.salonId, request);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedServiceIds.length} services deactivated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _selectedServiceIds.clear();
        _isSelectAll = false;
      });
      
      _refreshServices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to deactivate services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _bulkUpdatePrices() async {
    if (_selectedServiceIds.isEmpty) return;

    final percentageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isIncrease = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Bulk Price Update'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Update prices for ${_selectedServiceIds.length} selected services'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Increase'),
                        value: true,
                        groupValue: isIncrease,
                        onChanged: (value) {
                          setDialogState(() {
                            isIncrease = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Decrease'),
                        value: false,
                        groupValue: isIncrease,
                        onChanged: (value) {
                          setDialogState(() {
                            isIncrease = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: percentageController,
                  decoration: const InputDecoration(
                    labelText: 'Percentage',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter percentage';
                    }
                    final percentage = double.tryParse(value);
                    if (percentage == null || percentage <= 0) {
                      return 'Please enter valid percentage';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final percentage = double.parse(percentageController.text);
        
        for (final serviceId in _selectedServiceIds) {
          final service = _services.firstWhere((s) => s.id == serviceId);
          final currentPrice = service.price;
          final newPrice = isIncrease 
              ? currentPrice * (1 + percentage / 100)
              : currentPrice * (1 - percentage / 100);
          
          final request = UpdateServiceRequest(id: serviceId, price: newPrice);
          await _serviceService.updateService(widget.salonId, request);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prices updated for ${_selectedServiceIds.length} services!'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedServiceIds.clear();
          _isSelectAll = false;
        });
        
        _refreshServices();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update prices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkUpdateCategory() async {
    if (_selectedServiceIds.isEmpty) return;

    try {
      final categories = await _serviceService.getSalonCategories(widget.salonId);
      
      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No categories available. Create categories first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      ServiceCategoryDto? selectedCategory;

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Bulk Category Update'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Update category for ${_selectedServiceIds.length} selected services'),
                const SizedBox(height: 16),
                DropdownButtonFormField<ServiceCategoryDto>(
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCategory,
                  items: categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  )).toList(),
                  onChanged: (category) {
                    setDialogState(() {
                      selectedCategory = category;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedCategory != null) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      );

      if (result == true && selectedCategory != null) {
        for (final serviceId in _selectedServiceIds) {
          final request = UpdateServiceRequest(id: serviceId, categoryId: selectedCategory!.id);
          await _serviceService.updateService(widget.salonId, request);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category updated for ${_selectedServiceIds.length} services!'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedServiceIds.clear();
          _isSelectAll = false;
        });
        
        _refreshServices();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _bulkDeleteServices() async {
    if (_selectedServiceIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Services'),
        content: Text(
          'Are you sure you want to delete ${_selectedServiceIds.length} selected services?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final serviceId in _selectedServiceIds) {
          await _serviceService.deleteService(widget.salonId, serviceId);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedServiceIds.length} services deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedServiceIds.clear();
          _isSelectAll = false;
        });
        
        _refreshServices();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete services: $e'),
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
        title: 'Bulk Operations',
        centerTitle: true,
        actions: [
          if (_selectedServiceIds.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedServiceIds.clear();
                  _isSelectAll = false;
                });
              },
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Selection',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_services.isNotEmpty) _buildSelectionHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshServices,
              child: _buildBody(),
            ),
          ),
          if (_selectedServiceIds.isNotEmpty) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isSelectAll,
            onChanged: (_) => _toggleSelectAll(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedServiceIds.isEmpty
                  ? 'Select services for bulk operations'
                  : '${_selectedServiceIds.length} of ${_services.length} services selected',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (_selectedServiceIds.isNotEmpty)
            Text(
              'Selected: ${_selectedServiceIds.length}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Services Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create some services first to perform bulk operations',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        final isSelected = _selectedServiceIds.contains(service.id);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (_) => _toggleServiceSelection(service.id),
            title: Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.formattedPrice),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: service.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (service.categoryName != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        service.categoryName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            secondary: service.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      service.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.spa, color: Colors.grey),
                      ),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.spa, color: Colors.grey),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkActivateServices,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkDeactivateServices,
                  icon: const Icon(Icons.visibility_off),
                  label: const Text('Deactivate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkUpdatePrices,
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Update Prices'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkUpdateCategory,
                  icon: const Icon(Icons.category),
                  label: const Text('Update Category'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _bulkDeleteServices,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Selected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
