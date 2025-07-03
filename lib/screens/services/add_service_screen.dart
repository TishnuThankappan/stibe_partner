import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/app_text_field.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';
import 'package:stibe_partner/screens/services/manage_categories_screen.dart';

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
  int? _pendingCategoryId; // Store category ID when editing before categories load
  String? _profileImageUrl;
  List<String> _galleryImages = [];
  List<ServiceCategoryDto> _categories = [];
  String? _errorMessage;
  bool _isCategoriesLoading = true;
  
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
    _profileImageUrl = service.imageUrl;
    _galleryImages = service.serviceImages ?? [];
    
    // Store the pending category ID to be validated when categories load
    _pendingCategoryId = service.categoryId;
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });
    
    try {
      // Get service categories for the salon
      final categories = await _serviceService.getServiceCategories(widget.salonId);
      
      // Filter out any potential duplicates and ensure unique IDs
      final Map<int, ServiceCategoryDto> uniqueCategories = {};
      for (final category in categories) {
        uniqueCategories[category.id] = category;
      }
      
      setState(() {
        _categories = uniqueCategories.values.toList();
        _isCategoriesLoading = false;
        
        // Handle pending category ID from editing mode
        if (_pendingCategoryId != null) {
          final categoryExists = _categories.any((cat) => cat.id == _pendingCategoryId);
          _selectedCategoryId = categoryExists ? _pendingCategoryId : null;
          _pendingCategoryId = null; // Clear after processing
        } else if (_selectedCategoryId != null) {
          // Validate existing selected category ID
          final categoryExists = _categories.any((cat) => cat.id == _selectedCategoryId);
          if (!categoryExists) {
            _selectedCategoryId = null; // Reset if category doesn't exist
          }
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _categories = [];
        _selectedCategoryId = null;
        _pendingCategoryId = null;
        _isCategoriesLoading = false;
      });
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
      _errorMessage = null;
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
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.service == null ? 'Add Service' : 'Edit Service',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
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
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Basic Information
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Service Image
                    _buildSectionHeader('Service Image'),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Pricing
                    _buildSectionHeader('Pricing'),
                    const SizedBox(height: 16),
                    _buildPricingSection(),
                    const SizedBox(height: 24),

                    // Category
                    _buildSectionHeader('Category'),
                    const SizedBox(height: 16),
                    _buildCategorySection(),
                    const SizedBox(height: 24),

                    // Service Gallery
                    _buildSectionHeader('Service Gallery'),
                    const SizedBox(height: 16),
                    _buildGallerySection(),
                    const SizedBox(height: 24),

                    // Advanced Settings
                    _buildSectionHeader('Advanced Settings'),
                    const SizedBox(height: 16),
                    _buildAdvancedSection(),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
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
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 4,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
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
        
        Text(
          'This will be displayed as your service\'s main image',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickProfileImage,
                icon: const Icon(Icons.photo_camera, size: 18),
                label: Text(
                  _profileImageUrl != null ? 'Change' : 'Upload',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            ),
            if (_profileImageUrl != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _profileImageUrl = null;
                    });
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Remove', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
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
    return Column(
      children: [
        // Service Name
        AppTextField(
          controller: _nameController,
          label: 'Service Name',
          hintText: 'e.g., Hair Cut & Style',
          prefixIcon: const Icon(Icons.spa),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Service name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Description
        AppTextField(
          controller: _descriptionController,
          label: 'Description',
          hintText: 'Describe your service...',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        // Duration
        AppTextField(
          controller: _durationController,
          label: 'Duration (minutes)',
          hintText: 'e.g., 30',
          prefixIcon: const Icon(Icons.timer),
          keyboardType: TextInputType.number,
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
        AppTextField(
          controller: _productsUsedController,
          label: 'Products Used (Optional)',
          hintText: 'e.g., Premium hair care products, organic oils',
          prefixIcon: const Icon(Icons.inventory),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        // Regular Price
        AppTextField(
          controller: _priceController,
          label: 'Regular Price (₹)',
          hintText: 'e.g., 500',
          prefixIcon: const Icon(Icons.currency_rupee),
          keyboardType: TextInputType.number,
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
        AppTextField(
          controller: _offerPriceController,
          label: 'Offer Price (₹) - Optional',
          hintText: 'e.g., 400',
          prefixIcon: const Icon(Icons.local_offer),
          keyboardType: TextInputType.number,
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
    );
  }

  Widget _buildCategorySection() {
    return Column(
      children: [
        // Category Dropdown
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<int?>(
            value: !_isCategoriesLoading && _categories.isNotEmpty && _selectedCategoryId != null && 
                   _categories.any((cat) => cat.id == _selectedCategoryId) 
                   ? _selectedCategoryId 
                   : null,
            decoration: InputDecoration(
              labelText: 'Service Category',
              prefixIcon: _isCategoriesLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: _isCategoriesLoading 
                  ? 'Loading categories...' 
                  : _categories.isEmpty
                    ? 'No categories available'
                    : 'Select a category for this service',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: _isCategoriesLoading || _categories.isEmpty ? [] : [
              ..._categories.map((category) {
                IconData iconData;
                Color iconColor;
                
                // Assign icons based on category names
                switch(category.name.toLowerCase()) {
                  case 'hair care':
                    iconData = Icons.content_cut;
                    iconColor = Colors.brown;
                    break;
                  case 'facial':
                    iconData = Icons.face;
                    iconColor = Colors.orange;
                    break;
                  case 'nail care':
                    iconData = Icons.back_hand;
                    iconColor = Colors.pink;
                    break;
                  case 'massage':
                    iconData = Icons.spa;
                    iconColor = Colors.green;
                    break;
                  case 'body treatments':
                    iconData = Icons.accessibility_new;
                    iconColor = Colors.teal;
                    break;
                  case 'makeup':
                    iconData = Icons.brush;
                    iconColor = Colors.purple;
                    break;
                  case 'waxing':
                    iconData = Icons.waves;
                    iconColor = Colors.amber;
                    break;
                  default:
                    iconData = Icons.spa;
                    iconColor = Colors.blue;
                }
                
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(iconData, size: 18, color: iconColor),
                      const SizedBox(width: 12),
                      Text(category.name),
                    ],
                  ),
                );
              }),
            ],
            onChanged: _isCategoriesLoading || _categories.isEmpty ? null : (int? value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            icon: const Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Button to manage categories
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text("Can't find the category you need?"),
              onPressed: () => _navigateToManageCategories(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _navigateToManageCategories() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageCategoriesScreen(
          salonId: widget.salonId,
          salonName: widget.salonName,
        ),
      ),
    );
    
    // Refresh categories when returning from the manage categories screen
    if (result == true || result == null) {
      _loadCategories();
    }
  }

  Widget _buildAdvancedSection() {
    return Column(
      children: [
        // Active Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.visibility,
                color: Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Make this service available for booking',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Staff Assignment Required
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.people,
                color: Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requires Staff Assignment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer must select a staff member',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _requiresStaffAssignment,
                onChanged: (value) {
                  setState(() {
                    _requiresStaffAssignment = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Max Concurrent Bookings
        AppTextField(
          controller: _maxConcurrentBookingsController,
          label: 'Max Concurrent Bookings',
          hintText: '1',
          prefixIcon: const Icon(Icons.groups),
          keyboardType: TextInputType.number,
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
        
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _bufferTimeBeforeController,
                label: 'Buffer Before (min)',
                hintText: '0',
                prefixIcon: const Icon(Icons.schedule),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final time = int.tryParse(value);
                  if (time == null || time < 0) {
                    return 'Invalid time';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: _bufferTimeAfterController,
                label: 'Buffer After (min)',
                hintText: '0',
                prefixIcon: const Icon(Icons.schedule),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final time = int.tryParse(value);
                  if (time == null || time < 0) {
                    return 'Invalid time';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Column(
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
        
        // Display selected images
        if (_galleryImages.isNotEmpty) ...[
          Text(
            'Current Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _galleryImages[index].startsWith('http')
                            ? Image.network(
                                _galleryImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_galleryImages[index]),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
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
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      // Status indicator
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _galleryImages[index].startsWith('http') ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _galleryImages[index].startsWith('http') ? 'SAVED' : 'NEW',
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
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Add New Images Button
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickGalleryImages,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Gallery Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select multiple images',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
