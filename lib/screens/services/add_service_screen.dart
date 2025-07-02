import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class AddServiceScreen extends StatefulWidget {
  final int salonId;
  final String salonName;
  final ServiceDto? service; // For editing

  const AddServiceScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    this.service,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _durationController = TextEditingController();
  final _productsUsedController = TextEditingController();
  final _maxConcurrentBookingsController = TextEditingController();
  final _bufferTimeBeforeController = TextEditingController();
  final _bufferTimeAfterController = TextEditingController();
  
  // Form state
  bool _isLoading = false;
  bool _isActive = true;
  bool _requiresStaffAssignment = false;
  int? _selectedCategoryId;
  String? _profileImageUrl;
  List<String> _galleryImages = [];
  List<ServiceCategoryDto> _categories = [];
  
  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // If editing, populate fields
    if (widget.service != null) {
      _populateFormWithService(widget.service!);
    } else {
      // Default values for new service
      _maxConcurrentBookingsController.text = '1';
      _bufferTimeBeforeController.text = '0';
      _bufferTimeAfterController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    _durationController.dispose();
    _productsUsedController.dispose();
    _maxConcurrentBookingsController.dispose();
    _bufferTimeBeforeController.dispose();
    _bufferTimeAfterController.dispose();
    super.dispose();
  }

  void _populateFormWithService(ServiceDto service) {
    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _priceController.text = service.price.toStringAsFixed(0);
    _offerPriceController.text = service.offerPrice?.toStringAsFixed(0) ?? '';
    _durationController.text = service.durationInMinutes.toString();
    _productsUsedController.text = service.productsUsed ?? '';
    _maxConcurrentBookingsController.text = service.maxConcurrentBookings.toString();
    _bufferTimeBeforeController.text = service.bufferTimeBeforeMinutes.toString();
    _bufferTimeAfterController.text = service.bufferTimeAfterMinutes.toString();
    
    _isActive = service.isActive;
    _requiresStaffAssignment = service.requiresStaffAssignment;
    _selectedCategoryId = service.categoryId;
    _profileImageUrl = service.imageUrl;
    _galleryImages = service.serviceImages ?? [];
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _serviceService.getServiceCategories(widget.salonId);
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImageUrl = pickedFile.path; // Store local path temporarily
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      print('🔧 Picking gallery images...');
      final List<XFile> images = await _picker.pickMultiImage();
      print('📱 Picked ${images.length} images');
      
      if (images.isNotEmpty) {
        final newPaths = images.map((image) => image.path).toList();
        print('📁 New image paths: $newPaths');
        
        setState(() {
          _galleryImages.addAll(newPaths);
        });
        
        print('✅ Gallery images updated. Total count: ${_galleryImages.length}');
        print('📋 All gallery images: $_galleryImages');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${images.length} images selected for gallery'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('ℹ️ No images selected');
      }
    } catch (e) {
      print('❌ Error picking gallery images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload profile image if selected and is a local file
      String? uploadedProfileImageUrl;
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty && !_profileImageUrl!.startsWith('http')) {
        try {
          print('🔧 Uploading profile image: $_profileImageUrl');
          uploadedProfileImageUrl = await _serviceService.uploadServiceProfileImage(
            widget.salonId,
            File(_profileImageUrl!),
          );
          print('✅ Profile image uploaded: $uploadedProfileImageUrl');
        } catch (e) {
          print('❌ Profile image upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload profile image: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else if (_profileImageUrl != null && _profileImageUrl!.startsWith('http')) {
        // Keep existing URL if editing
        uploadedProfileImageUrl = _profileImageUrl;
      }

      // Upload gallery images if selected and are local files
      List<String> uploadedGalleryUrls = [];
      final localGalleryImages = _galleryImages
          .where((path) => !path.startsWith('http'))
          .map((path) => File(path))
          .toList();
      
      print('🔍 Debug Gallery Images:');
      print('  Total gallery images: ${_galleryImages.length}');
      print('  Gallery image paths: $_galleryImages');
      print('  Local gallery images count: ${localGalleryImages.length}');
      print('  Local gallery paths: ${localGalleryImages.map((f) => f.path).toList()}');
      
      if (localGalleryImages.isNotEmpty) {
        try {
          print('🔧 Uploading ${localGalleryImages.length} gallery images for salon ${widget.salonId}');
          
          // Show uploading message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploading ${localGalleryImages.length} gallery images...'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          uploadedGalleryUrls = await _serviceService.uploadServiceGalleryImages(
            widget.salonId,
            localGalleryImages,
          );
          print('✅ Gallery images uploaded successfully: $uploadedGalleryUrls');
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${uploadedGalleryUrls.length} gallery images uploaded successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('❌ Gallery images upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload gallery images: $e'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        print('ℹ️ No local gallery images to upload');
      }

      // Keep existing gallery URLs if editing
      final existingGalleryUrls = _galleryImages
          .where((path) => path.startsWith('http'))
          .toList();
      
      final allGalleryUrls = [...existingGalleryUrls, ...uploadedGalleryUrls];
      
      print('🔍 Final Gallery URLs Debug:');
      print('  Existing URLs: $existingGalleryUrls');
      print('  Uploaded URLs: $uploadedGalleryUrls');
      print('  All URLs: $allGalleryUrls');

      // Create or update service
      if (widget.service == null) {
        // Creating new service
        final request = CreateServiceRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          durationInMinutes: int.parse(_durationController.text),
          imageUrl: uploadedProfileImageUrl,
          categoryId: _selectedCategoryId,
          maxConcurrentBookings: int.parse(_maxConcurrentBookingsController.text),
          requiresStaffAssignment: _requiresStaffAssignment,
          bufferTimeBeforeMinutes: int.parse(_bufferTimeBeforeController.text),
          bufferTimeAfterMinutes: int.parse(_bufferTimeAfterController.text),
          offerPrice: _offerPriceController.text.isNotEmpty 
              ? double.parse(_offerPriceController.text) 
              : null,
          productsUsed: _productsUsedController.text.trim().isNotEmpty 
              ? _productsUsedController.text.trim() 
              : null,
          serviceImages: allGalleryUrls.isNotEmpty ? allGalleryUrls : null,
          tags: [],
          metadata: null,
          discountPercentage: null,
          isPopular: false,
        );

        print('🔧 Creating service for salon ${widget.salonId}');
        print('📤 Request: ${request.toJson()}');

        final service = await _serviceService.createService(widget.salonId, request);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service "${service.name}" created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Updating existing service
        final request = UpdateServiceRequest(
          id: widget.service!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          durationInMinutes: int.parse(_durationController.text),
          isActive: _isActive,
          imageUrl: uploadedProfileImageUrl,
          categoryId: _selectedCategoryId,
          maxConcurrentBookings: int.parse(_maxConcurrentBookingsController.text),
          requiresStaffAssignment: _requiresStaffAssignment,
          bufferTimeBeforeMinutes: int.parse(_bufferTimeBeforeController.text),
          bufferTimeAfterMinutes: int.parse(_bufferTimeAfterController.text),
          offerPrice: _offerPriceController.text.isNotEmpty 
              ? double.parse(_offerPriceController.text) 
              : null,
          productsUsed: _productsUsedController.text.trim().isNotEmpty 
              ? _productsUsedController.text.trim() 
              : null,
          serviceImages: allGalleryUrls.isNotEmpty ? allGalleryUrls : null,
          tags: [],
          metadata: null,
          discountPercentage: null,
          isPopular: false,
        );

        print('🔧 Updating service ${widget.service!.id} for salon ${widget.salonId}');
        print('📤 Request: ${request.toJson()}');

        final service = await _serviceService.updateService(widget.salonId, request);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service "${service.name}" updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('❌ Service save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving service: ${e.toString().replaceFirst('Exception: ', '')}'),
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

  void _suggestCategory() {
    // TODO: Implement AI category suggestion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI category suggestion coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.service == null ? 'Add Service' : 'Edit Service',
        centerTitle: true,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveService,
              child: Text(
                widget.service == null ? 'CREATE' : 'UPDATE',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
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
                    // Service Image Section
                    _buildImageSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Basic Information
                    _buildBasicInfoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Pricing Section
                    _buildPricingSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Category Section
                    _buildCategorySection(),
                    
                    const SizedBox(height: 24),
                    
                    // Advanced Settings
                    _buildAdvancedSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Gallery Section
                    _buildGallerySection(),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.service == null ? 'Create Service' : 'Update Service',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return _buildSection(
      title: 'Service Image',
      icon: Icons.image_outlined,
      child: Column(
        children: [
          // Profile Image
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _profileImageUrl!.startsWith('http')
                          ? Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            )
                          : Image.file(
                              File(_profileImageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            ),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickProfileImage,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(_profileImageUrl != null ? 'Change Image' : 'Add Image'),
                ),
              ),
              if (_profileImageUrl != null) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _profileImageUrl = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Icon(Icons.delete),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add service image',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recommended: 1000x1000px',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          // Service Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Service Name *',
              hintText: 'e.g., Hair Cut & Style',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Service name is required';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your service...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          
          const SizedBox(height: 16),
          
          // Duration
          TextFormField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: 'Duration (minutes) *',
              hintText: 'e.g., 30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: 'min',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Duration is required';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Please enter a valid duration';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Products Used
          TextFormField(
            controller: _productsUsedController,
            decoration: InputDecoration(
              labelText: 'Products Used (Optional)',
              hintText: 'e.g., Premium hair care products, organic oils',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      title: 'Pricing',
      icon: Icons.currency_rupee,
      child: Column(
        children: [
          // Regular Price
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Regular Price (₹) *',
              hintText: 'e.g., 500',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixText: '₹ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Price is required';
              }
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Offer Price
          TextFormField(
            controller: _offerPriceController,
            decoration: InputDecoration(
              labelText: 'Offer Price (₹) - Optional',
              hintText: 'e.g., 400',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixText: '₹ ',
              helperText: 'Leave empty if no offer',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final offerPrice = double.tryParse(value);
                if (offerPrice == null || offerPrice <= 0) {
                  return 'Please enter a valid offer price';
                }
                final regularPrice = double.tryParse(_priceController.text);
                if (regularPrice != null && offerPrice >= regularPrice) {
                  return 'Offer price must be less than regular price';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'Category',
      icon: Icons.category_outlined,
      child: Column(
        children: [
          // Category Dropdown
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Service Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('No Category'),
              ),
              ..._categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // AI Suggestion Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _suggestCategory,
              icon: const Icon(Icons.psychology),
              label: const Text('AI Suggest Category'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return _buildSection(
      title: 'Advanced Settings',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          // Active Status
          SwitchListTile(
            title: const Text('Service Active'),
            subtitle: const Text('Make this service available for booking'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          
          const Divider(),
          
          // Staff Assignment Required
          SwitchListTile(
            title: const Text('Requires Staff Assignment'),
            subtitle: const Text('Customer must select a staff member'),
            value: _requiresStaffAssignment,
            onChanged: (value) {
              setState(() {
                _requiresStaffAssignment = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 16),
          
          // Max Concurrent Bookings
          TextFormField(
            controller: _maxConcurrentBookingsController,
            decoration: InputDecoration(
              labelText: 'Max Concurrent Bookings',
              hintText: '1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'How many customers can book this service at the same time',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              final count = int.tryParse(value);
              if (count == null || count <= 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Buffer Time Before
          TextFormField(
            controller: _bufferTimeBeforeController,
            decoration: InputDecoration(
              labelText: 'Buffer Time Before (minutes)',
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: 'min',
              helperText: 'Preparation time before the service',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              final time = int.tryParse(value);
              if (time == null || time < 0) {
                return 'Please enter a valid time';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Buffer Time After
          TextFormField(
            controller: _bufferTimeAfterController,
            decoration: InputDecoration(
              labelText: 'Buffer Time After (minutes)',
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: 'min',
              helperText: 'Cleanup time after the service',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              final time = int.tryParse(value);
              if (time == null || time < 0) {
                return 'Please enter a valid time';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return _buildSection(
      title: 'Service Gallery',
      icon: Icons.photo_library_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add images to showcase your service (Optional)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Add Gallery Images Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickGalleryImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Gallery Images'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Gallery Images Grid
          if (_galleryImages.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${_galleryImages.length} image(s) selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle, color: Colors.orange, size: 8),
                const SizedBox(width: 4),
                Text('Local', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(width: 8),
                Icon(Icons.circle, color: Colors.green, size: 8),
                const SizedBox(width: 4),
                Text('Uploaded', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            
            const SizedBox(height: 8),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                return _buildGalleryImageCard(_galleryImages[index], index);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGalleryImageCard(String imagePath, int index) {
    final isLocalFile = !imagePath.startsWith('http');
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocalFile ? Colors.orange.shade300 : Colors.green.shade300,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          ),
          
          // Status indicator
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              decoration: BoxDecoration(
                color: isLocalFile ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: Icon(
                isLocalFile ? Icons.upload_outlined : Icons.cloud_done,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
          
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _galleryImages.removeAt(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
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
            child: child,
          ),
        ],
      ),
    );
  }
}
