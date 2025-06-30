import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class ServiceCategoriesScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServiceCategoriesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServiceCategoriesScreen> createState() => _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  List<ServiceCategoryDto> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _serviceService.getSalonCategories(widget.salonId);
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshCategories() async {
    await _loadCategories();
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category name';
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
            ],
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
                  await _serviceService.createServiceCategory(
                    widget.salonId,
                    CreateServiceCategoryRequest(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                    ),
                  );
                  Navigator.of(context).pop();
                  _refreshCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create category: $e'),
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
    );
  }

  void _showEditCategoryDialog(ServiceCategoryDto category) {
    final nameController = TextEditingController(text: category.name);
    final descriptionController = TextEditingController(text: category.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category name';
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
            ],
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
                  await _serviceService.updateServiceCategory(
                    widget.salonId,
                    category.id,
                    {
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim(),
                    },
                  );
                  Navigator.of(context).pop();
                  _refreshCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update category: $e'),
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

  void _showDeleteCategoryDialog(ServiceCategoryDto category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _serviceService.deleteServiceCategory(widget.salonId, category.id);
                Navigator.of(context).pop();
                _refreshCategories();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete category: $e'),
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
        title: 'Service Categories',
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
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
              'Error loading categories',
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
              onPressed: _refreshCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Categories Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first service category to organize your services',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(ServiceCategoryDto category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
          child: Icon(
            Icons.category,
            color: category.isActive ? AppColors.primary : Colors.grey.shade400,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: category.isActive ? null : Colors.grey.shade600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(category.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCategoryDialog(category);
                break;
              case 'toggle':
                _toggleCategoryStatus(category);
                break;
              case 'delete':
                _showDeleteCategoryDialog(category);
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
                leading: Icon(category.isActive ? Icons.visibility_off : Icons.visibility),
                title: Text(category.isActive ? 'Deactivate' : 'Activate'),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _toggleCategoryStatus(ServiceCategoryDto category) async {
    try {
      await _serviceService.updateServiceCategory(
        widget.salonId,
        category.id,
        {
          'isActive': !category.isActive,
        },
      );
      _refreshCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category ${!category.isActive ? 'activated' : 'deactivated'} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
