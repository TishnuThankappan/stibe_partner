import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/api/image_upload_service.dart';

class AddServiceScreen extends StatefulWidget {
  final int salonId;
  final List<ServiceCategoryDto> categories;

  const AddServiceScreen({
    super.key,
    required this.salonId,
    required this.categories,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceManagementService _serviceService = ServiceManagementService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _bufferBeforeController = TextEditingController();
  final _bufferAfterController = TextEditingController();
  final _maxBookingsController = TextEditingController();
  final _discountController = TextEditingController();

  // Form values
  int? _selectedCategoryId;
  bool _requiresStaffAssignment = true;
  bool _isPopular = false;
  String? _imageUrl;
  List<String> _tags = [];
  final _tagController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _durationController.text = '30'; // Default duration
    _maxBookingsController.text = '1'; // Default max bookings
    _bufferBeforeController.text = '0';
    _bufferAfterController.text = '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _bufferBeforeController.dispose();
    _bufferAfterController.dispose();
    _maxBookingsController.dispose();
    _discountController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add New Service',
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveService,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildCategorySection(),
                    const SizedBox(height: 24),
                    _buildSettingsSection(),
                    const SizedBox(height: 24),
                    _buildTagsSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Service Name *',
            hintText: 'e.g., Deep Cleansing Facial',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Service name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Describe what this service includes...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      title: 'Pricing & Duration',
      icon: Icons.attach_money,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  hintText: '0.00',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes) *',
                  hintText: '30',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Duration is required';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Enter valid duration';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _discountController,
          decoration: const InputDecoration(
            labelText: 'Discount Percentage (Optional)',
            hintText: '0',
            suffixText: '%',
            border: OutlineInputBorder(),
            helperText: 'Promotional discount for this service',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final discount = double.tryParse(value);
              if (discount == null || discount < 0 || discount > 100) {
                return 'Enter a valid percentage (0-100)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return _buildSection(
      title: 'Service Image',
      icon: Icons.image,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _imageUrl != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _imageUrl = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : _buildImagePlaceholder(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.gallery),
                icon: _isUploadingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library),
                label: Text(_isUploadingImage ? 'Uploading...' : 'Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Service Image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'Category',
      icon: Icons.category,
      children: [
        DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Service Category',
            border: OutlineInputBorder(),
            helperText: 'Choose a category for better organization',
          ),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('No Category'),
            ),
            ...widget.categories.map((category) => DropdownMenuItem<int>(
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
      ],
    );
  }

  Widget _buildSettingsSection() {
    return _buildSection(
      title: 'Service Settings',
      icon: Icons.settings,
      children: [
        SwitchListTile(
          title: const Text('Requires Staff Assignment'),
          subtitle: const Text('This service needs a staff member to be assigned'),
          value: _requiresStaffAssignment,
          onChanged: (value) {
            setState(() {
              _requiresStaffAssignment = value;
            });
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Popular Service'),
          subtitle: const Text('Mark this as a popular/featured service'),
          value: _isPopular,
          onChanged: (value) {
            setState(() {
              _isPopular = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _maxBookingsController,
          decoration: const InputDecoration(
            labelText: 'Max Concurrent Bookings',
            hintText: '1',
            border: OutlineInputBorder(),
            helperText: 'How many clients can book this service at the same time',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final maxBookings = int.tryParse(value);
              if (maxBookings == null || maxBookings <= 0) {
                return 'Enter a valid number';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bufferBeforeController,
                decoration: const InputDecoration(
                  labelText: 'Buffer Before (min)',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _bufferAfterController,
                decoration: const InputDecoration(
                  labelText: 'Buffer After (min)',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return _buildSection(
      title: 'Tags',
      icon: Icons.local_offer,
      children: [
        Row(
          children: [
            Expanded(
              child:                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Add Tag',
                    hintText: 'e.g., relaxing, anti-aging',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: _addTag,
                ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text),
              child: const Text('Add'),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeTag(tag),
            )).toList(),
          ),
        ],
      ],
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveService,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                'Create Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // Helper methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final uploadedUrl = await _imageUploadService.uploadSingleImage(imageFile);
        
        setState(() {
          _imageUrl = uploadedUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _addTag(String tagText) {
    final tag = tagText.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateServiceRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        durationInMinutes: int.parse(_durationController.text),
        imageUrl: _imageUrl,
        categoryId: _selectedCategoryId,
        maxConcurrentBookings: int.tryParse(_maxBookingsController.text) ?? 1,
        requiresStaffAssignment: _requiresStaffAssignment,
        bufferTimeBeforeMinutes: int.tryParse(_bufferBeforeController.text) ?? 0,
        bufferTimeAfterMinutes: int.tryParse(_bufferAfterController.text) ?? 0,
        tags: _tags,
        discountPercentage: _discountController.text.isNotEmpty 
            ? double.tryParse(_discountController.text) 
            : null,
        isPopular: _isPopular,
      );

      await _serviceService.createService(widget.salonId, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating service: ${e.toString().replaceFirst('Exception: ', '')}'),
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
}
