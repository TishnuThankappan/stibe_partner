import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class ServicePackagesScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServicePackagesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServicePackagesScreen> createState() => _ServicePackagesScreenState();
}

class _ServicePackagesScreenState extends State<ServicePackagesScreen> {
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  List<ServicePackageDto> _packages = [];
  List<ServiceDto> _availableServices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final [packages, services] = await Future.wait([
        _serviceService.getServicePackages(widget.salonId),
        _serviceService.getSalonServices(widget.salonId),
      ]);

      setState(() {
        _packages = packages as List<ServicePackageDto>;
        _availableServices = services as List<ServiceDto>;
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

  void _showCreatePackageDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final discountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    Set<int> selectedServiceIds = <int>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Service Package'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Package Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter package name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Package Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount Percentage (Optional)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final discount = double.tryParse(value);
                        if (discount == null || discount < 0 || discount > 100) {
                          return 'Please enter valid discount (0-100)';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _availableServices.length,
                      itemBuilder: (context, index) {
                        final service = _availableServices[index];
                        final isSelected = selectedServiceIds.contains(service.id);
                        
                        return CheckboxListTile(
                          title: Text(service.name),
                          subtitle: Text('\$${service.price.toStringAsFixed(2)} - ${service.durationInMinutes}min'),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedServiceIds.add(service.id);
                              } else {
                                selectedServiceIds.remove(service.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedServiceIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one service'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await _serviceService.createServicePackage(
                      widget.salonId,
                      CreateServicePackageRequest(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: double.parse(priceController.text),
                        serviceIds: selectedServiceIds.toList(),
                        discountPercentage: discountController.text.isNotEmpty 
                            ? double.parse(discountController.text) 
                            : null,
                      ),
                    );
                    Navigator.of(context).pop();
                    _refreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Package created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create package: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPackageDetails(ServicePackageDto package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(package.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                package.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '\$${package.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (package.discountPercentage != null) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${package.discountPercentage!.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text('${package.totalDurationMinutes} minutes'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Included Services:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...package.services.map((service) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${service.name} (\$${service.price.toStringAsFixed(2)} - ${service.durationInMinutes}min)',
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: package.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      package.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Created: ${_formatDate(package.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditPackageDialog(package);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEditPackageDialog(ServicePackageDto package) {
    final nameController = TextEditingController(text: package.name);
    final descriptionController = TextEditingController(text: package.description);
    final priceController = TextEditingController(text: package.price.toString());
    final discountController = TextEditingController(
      text: package.discountPercentage?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Package'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter package name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Package Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Percentage (Optional)',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final discount = double.tryParse(value);
                      if (discount == null || discount < 0 || discount > 100) {
                        return 'Please enter valid discount (0-100)';
                      }
                    }
                    return null;
                  },
                ),
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _serviceService.updateServicePackage(
                    widget.salonId,
                    package.id,
                    {
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'price': double.parse(priceController.text),
                      'discountPercentage': discountController.text.isNotEmpty 
                          ? double.parse(discountController.text) 
                          : null,
                    },
                  );
                  Navigator.of(context).pop();
                  _refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Package updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update package: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeletePackageDialog(ServicePackageDto package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "${package.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _serviceService.deleteServicePackage(widget.salonId, package.id);
                Navigator.of(context).pop();
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Package deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete package: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Service Packages',
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _availableServices.isNotEmpty ? _showCreatePackageDialog : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildBody(),
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
              'Error loading packages',
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
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Packages Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _availableServices.isEmpty
                  ? 'Create some services first before making packages'
                  : 'Create your first service package to bundle services together',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_availableServices.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _showCreatePackageDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Package'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        return _buildPackageCard(package);
      },
    );
  }

  Widget _buildPackageCard(ServicePackageDto package) {
    final originalPrice = package.services.fold<double>(0, (sum, service) => sum + service.price);
    final savings = originalPrice - package.price;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPackageDetails(package),
        borderRadius: BorderRadius.circular(8),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditPackageDialog(package);
                          break;
                        case 'toggle':
                          _togglePackageStatus(package);
                          break;
                        case 'delete':
                          _showDeletePackageDialog(package);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: ListTile(
                          leading: Icon(package.isActive ? Icons.visibility_off : Icons.visibility),
                          title: Text(package.isActive ? 'Deactivate' : 'Activate'),
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
              const SizedBox(height: 8),
              Text(
                package.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '\$${package.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (savings > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Save \$${savings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (package.discountPercentage != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${package.discountPercentage!.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: package.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      package.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${package.totalDurationMinutes} minutes',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.spa, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${package.services.length} services',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _togglePackageStatus(ServicePackageDto package) async {
    try {
      await _serviceService.updateServicePackage(
        widget.salonId,
        package.id,
        {
          'isActive': !package.isActive,
        },
      );
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Package ${!package.isActive ? 'activated' : 'deactivated'} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update package: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
