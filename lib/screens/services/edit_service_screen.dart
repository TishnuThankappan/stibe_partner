import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/api/image_upload_service.dart';
import 'dart:io';

class EditServiceScreen extends StatefulWidget {
  final int salonId;
  final ServiceDto service;

  const EditServiceScreen({
    super.key,
    required this.salonId,
    required this.service,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceManagementService _serviceService = ServiceManagementService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _tagsController;
  late TextEditingController _bufferBeforeController;
  late TextEditingController _bufferAfterController;
  late TextEditingController _maxConcurrentController;
  late TextEditingController _discountController;

  // Form state
  List<ServiceCategoryDto> _categories = [];
  int? _selectedCategoryId;
  bool _requiresStaffAssignment = true;
  bool _isActive = true;
  bool _isPopular = false;
  
  // Image handling
  File? _selectedImage;
  String? _currentImageUrl;
  bool _removeCurrentImage = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCategories();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(text: widget.service.description);
    _priceController = TextEditingController(text: widget.service.price.toString());
    _durationController = TextEditingController(text: widget.service.durationInMinutes.toString());
    _tagsController = TextEditingController(text: widget.service.tags.join(', '));
    _bufferBeforeController = TextEditingController(text: widget.service.bufferTimeBeforeMinutes.toString());
    _bufferAfterController = TextEditingController(text: widget.service.bufferTimeAfterMinutes.toString());
    _maxConcurrentController = TextEditingController(text: widget.service.maxConcurrentBookings.toString());
    _discountController = TextEditingController(text: (widget.service.discountPercentage ?? 0).toString());

    _selectedCategoryId = widget.service.categoryId;
    _requiresStaffAssignment = widget.service.requiresStaffAssignment;
    _isActive = widget.service.isActive;
    _isPopular = widget.service.isPopular;
    _currentImageUrl = widget.service.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    _bufferBeforeController.dispose();
    _bufferAfterController.dispose();
    _maxConcurrentController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _serviceService.getSalonCategories(widget.salonId);
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _removeCurrentImage = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _removeCurrentImage = true;
      _currentImageUrl = null;
    });
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _currentImageUrl;

      // Handle image upload/removal
      if (_selectedImage != null) {
        print('📸 Uploading new image...');
        imageUrl = await _imageUploadService.uploadServiceImage(_selectedImage!);
        print('✅ Image uploaded: $imageUrl');
      } else if (_removeCurrentImage) {
        imageUrl = null;
      }

      // Parse tags
      List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Parse numeric fields
      final price = double.parse(_priceController.text);
      final duration = int.parse(_durationController.text);
      final bufferBefore = int.parse(_bufferBeforeController.text);
      final bufferAfter = int.parse(_bufferAfterController.text);
      final maxConcurrent = int.parse(_maxConcurrentController.text);
      final discount = double.tryParse(_discountController.text);

      print('🔧 Updating service: ${widget.service.id}');
      final updateRequest = UpdateServiceRequest(
        id: widget.service.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        durationInMinutes: duration,
        categoryId: _selectedCategoryId,
        requiresStaffAssignment: _requiresStaffAssignment,
        bufferTimeBeforeMinutes: bufferBefore,
        bufferTimeAfterMinutes: bufferAfter,
        maxConcurrentBookings: maxConcurrent,
        isActive: _isActive,
        isPopular: _isPopular,
        imageUrl: imageUrl,
        tags: tags,
        discountPercentage: discount,
      );
      
      final updatedService = await _serviceService.updateService(widget.salonId, updateRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedService);
      }
    } catch (e) {
      print('❌ Error updating service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update service: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Service',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateService,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Update',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildPricingSection(),
              const SizedBox(height: 24),
              _buildTimingSection(),
              const SizedBox(height: 24),
              _buildAdvancedSection(),
              const SizedBox(height: 24),
              _buildStatusSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null || (_currentImageUrl != null && !_removeCurrentImage)) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : NetworkImage(_currentImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change Image'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Image'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.spa),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter service name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter service description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('No Category'),
                ),
                ..._categories.map((category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                helperText: 'e.g., relaxing, popular, premium',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final discount = double.tryParse(value);
                        if (discount == null || discount < 0 || discount > 100) {
                          return 'Enter valid discount (0-100)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timing & Capacity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter duration';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Please enter valid duration';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxConcurrentController,
                    decoration: const InputDecoration(
                      labelText: 'Max Concurrent',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter max concurrent';
                      }
                      final max = int.tryParse(value);
                      if (max == null || max <= 0) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bufferBeforeController,
                    decoration: const InputDecoration(
                      labelText: 'Buffer Before (min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter buffer time';
                      }
                      final buffer = int.tryParse(value);
                      if (buffer == null || buffer < 0) {
                        return 'Please enter valid buffer time';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bufferAfterController,
                    decoration: const InputDecoration(
                      labelText: 'Buffer After (min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter buffer time';
                      }
                      final buffer = int.tryParse(value);
                      if (buffer == null || buffer < 0) {
                        return 'Please enter valid buffer time';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Requires Staff Assignment'),
              subtitle: const Text('Service must be assigned to a staff member'),
              value: _requiresStaffAssignment,
              onChanged: (value) {
                setState(() {
                  _requiresStaffAssignment = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Visibility',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Service is available for booking'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Popular'),
              subtitle: const Text('Mark as popular service'),
              value: _isPopular,
              onChanged: (value) {
                setState(() {
                  _isPopular = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
