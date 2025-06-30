import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/screens/salons/location_picker_screen.dart';
import 'package:stibe_partner/widgets/app_button.dart';
import 'package:stibe_partner/widgets/app_text_field.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/api/image_upload_service.dart';

class EditSalonScreen extends StatefulWidget {
  final SalonDto salon;

  const EditSalonScreen({super.key, required this.salon});

  @override
  State<EditSalonScreen> createState() => _EditSalonScreenState();
}

class _EditSalonScreenState extends State<EditSalonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File> _newSalonImages = [];
  List<String> _existingImageUrls = [];
  List<String> _imagesToDelete = [];
  
  // Profile picture
  File? _newProfilePicture;
  String? _existingProfilePictureUrl;
  bool _removeProfilePicture = false;
  
  // Location
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedLocationName;
  
  // Business hours
  Map<String, Map<String, dynamic>> _businessHours = {};

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize form fields with existing salon data
    _nameController.text = widget.salon.name;
    _addressController.text = widget.salon.address;
    _cityController.text = widget.salon.city;
    _stateController.text = widget.salon.state;
    _zipController.text = widget.salon.zipCode;
    _phoneController.text = widget.salon.phoneNumber;
    _emailController.text = widget.salon.email;
    _descriptionController.text = widget.salon.description;
    
    // Initialize location
    _selectedLatitude = widget.salon.latitude;
    _selectedLongitude = widget.salon.longitude;
    _selectedLocationName = '${widget.salon.address}, ${widget.salon.city}';
    
    // Initialize existing images
    _existingImageUrls = List<String>.from(widget.salon.imageUrls);
    
    // Initialize existing profile picture
    _existingProfilePictureUrl = widget.salon.profilePictureUrl;
    
    // Initialize business hours
    if (widget.salon.businessHours != null) {
      // Parse business hours from JSON string if available
      // For now, use default hours
    }
    
    _businessHours = {
      'Monday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
      'Tuesday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
      'Wednesday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
      'Thursday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
      'Friday': {'isOpen': true, 'open': '09:00', 'close': '19:00'},
      'Saturday': {'isOpen': true, 'open': '08:00', 'close': '17:00'},
      'Sunday': {'isOpen': false, 'open': '10:00', 'close': '16:00'},
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _newSalonImages.addAll(images.map((image) => File(image.path)));
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
  }

  void _removeNewImage(int index) {
    setState(() {
      _newSalonImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      final imageUrl = _existingImageUrls[index];
      _imagesToDelete.add(imageUrl);
      _existingImageUrls.removeAt(index);
    });
  }

  // Profile picture methods
  Future<void> _pickProfilePicture() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _newProfilePicture = File(pickedFile.path);
          _removeProfilePicture = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeCurrentProfilePicture() {
    setState(() {
      _newProfilePicture = null;
      _removeProfilePicture = true;
    });
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _selectedLatitude,
          initialLongitude: _selectedLongitude,
          initialLocationName: _selectedLocationName,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedLocationName = result['locationName'];
      });
    }
  }

  Future<void> _updateSalon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Delete removed images from server storage first
      if (_imagesToDelete.isNotEmpty) {
        try {
          print('🗑️ Deleting ${_imagesToDelete.length} images from server storage...');
          final salonService = SalonService();
          await salonService.deleteSalonImages(widget.salon.id, _imagesToDelete);
          print('✅ Successfully deleted ${_imagesToDelete.length} images from server storage');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully deleted ${_imagesToDelete.length} images from server'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('❌ Image deletion failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: Failed to delete some images from server. The salon will still be updated.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Upload new images if any are selected
      List<String> newUploadedImageUrls = [];
      if (_newSalonImages.isNotEmpty) {
        try {
          print('📤 Uploading ${_newSalonImages.length} new salon images...');
          final imageUploadService = ImageUploadService();
          newUploadedImageUrls = await imageUploadService.uploadImages(_newSalonImages);
          print('✅ Uploaded ${newUploadedImageUrls.length} new images successfully');
        } catch (e) {
          print('❌ Image upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: New image upload failed. Salon will be updated without new images.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Upload new profile picture if selected
      String? finalProfilePictureUrl = _existingProfilePictureUrl;
      if (_newProfilePicture != null) {
        try {
          print('📤 Uploading new profile picture...');
          final imageUploadService = ImageUploadService();
          final profilePictureUrls = await imageUploadService.uploadImages([_newProfilePicture!]);
          if (profilePictureUrls.isNotEmpty) {
            finalProfilePictureUrl = profilePictureUrls.first;
            print('✅ Profile picture uploaded successfully: $finalProfilePictureUrl');
          }
        } catch (e) {
          print('❌ Profile picture upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: Profile picture upload failed.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else if (_removeProfilePicture) {
        finalProfilePictureUrl = ""; // Send empty string to remove
      }

      // Combine existing images (minus deleted ones) with newly uploaded images
      final allImageUrls = [..._existingImageUrls, ...newUploadedImageUrls];

      // Prepare business hours data
      final businessHours = <String, Map<String, dynamic>>{};
      _businessHours.forEach((day, hours) {
        businessHours[day] = {
          'isOpen': hours['isOpen'],
          'open': hours['open'],
          'close': hours['close'],
        };
      });

      print('Updating salon with:');
      print('- Name: ${_nameController.text}');
      print('- Description: ${_descriptionController.text}');
      print('- Address: ${_addressController.text}');
      print('- City: ${_cityController.text}');
      print('- State: ${_stateController.text}');
      print('- ZIP: ${_zipController.text}');
      print('- Phone: ${_phoneController.text}');
      print('- Email: ${_emailController.text}');
      print('- Existing images: ${_existingImageUrls.length}');
      print('- New images: ${newUploadedImageUrls.length}');
      print('- Images to delete: ${_imagesToDelete.length}');
      print('- Total images: ${allImageUrls.length}');
      print('- Location: ${_selectedLocationName ?? "Not changed"}');

      // Create update request
      final updateRequest = UpdateSalonRequest(
        id: widget.salon.id,
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        openingTime: "${widget.salon.openingTime}:00", // Convert HH:mm to HH:mm:ss
        closingTime: "${widget.salon.closingTime}:00", // Convert HH:mm to HH:mm:ss
        businessHours: _businessHours.isNotEmpty ? _businessHours : null,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        imageUrls: allImageUrls.isNotEmpty ? allImageUrls : null,
        profilePictureUrl: finalProfilePictureUrl,
        isActive: widget.salon.isActive,
      );

      // Call the update API
      final salonService = SalonService();
      await salonService.updateSalon(updateRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Salon "${_nameController.text}" updated successfully!\n'
              '${allImageUrls.length} total images\n'
              '${_selectedLocationName != null ? "Location: $_selectedLocationName" : "Location not changed"}'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating salon: $_errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
        title: 'Edit Salon',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 16),
              ],

              // Basic Information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _nameController,
                label: 'Salon Name',
                hintText: 'Enter salon name',
                prefixIcon: const Icon(Icons.store),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter salon name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Brief description of your salon',
                prefixIcon: const Icon(Icons.description),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Profile Picture
              _buildSectionHeader('Profile Picture'),
              const SizedBox(height: 16),
              _buildProfilePictureSection(),
              const SizedBox(height: 24),

              // Salon Images
              _buildSectionHeader('Salon Images'),
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 24),

              // Location Information
              _buildSectionHeader('Location'),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _addressController,
                label: 'Street Address',
                hintText: 'Enter street address',
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'Enter city',
                      prefixIcon: const Icon(Icons.location_city),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'Enter state',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _zipController,
                label: 'ZIP Code',
                hintText: 'Enter ZIP code',
                prefixIcon: const Icon(Icons.markunread_mailbox),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ZIP code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Picker
              _buildLocationPicker(),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'Enter email address',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Business Hours
              _buildSectionHeader('Business Hours'),
              const SizedBox(height: 16),
              _buildBusinessHours(),
              const SizedBox(height: 32),

              // Update Button
              AppButton(
                text: 'Update Salon',
                onPressed: _isLoading ? null : () => _updateSalon(),
                isLoading: _isLoading,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing Images
        if (_existingImageUrls.isNotEmpty) ...[
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
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(index),
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
              onTap: _pickImages,
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
                    'Add New Photos',
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
        
        // Display new selected images
        if (_newSalonImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '${_newSalonImages.length} new image${_newSalonImages.length == 1 ? '' : 's'} selected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newSalonImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _newSalonImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeNewImage(index),
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
                      // New image indicator
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
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
        ],
      ],
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectLocation,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precise Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedLocationName != null
                            ? 'Location: $_selectedLocationName'
                            : 'Tap to update location on map',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedLocationName != null 
                              ? Colors.green.shade700 
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (_selectedLatitude != null && _selectedLongitude != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Lat: ${_selectedLatitude!.toStringAsFixed(4)}, Lng: ${_selectedLongitude!.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  _selectedLocationName != null 
                      ? Icons.check_circle 
                      : Icons.arrow_forward_ios,
                  color: _selectedLocationName != null 
                      ? Colors.green 
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessHours() {
    return Column(
      children: _businessHours.entries.map((entry) {
        final day = entry.key;
        final hours = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: hours['isOpen'],
                onChanged: (value) {
                  setState(() {
                    _businessHours[day]!['isOpen'] = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              if (hours['isOpen']) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelector(
                          hours['open'],
                          (time) {
                            setState(() {
                              _businessHours[day]!['open'] = time;
                            });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('-'),
                      ),
                      Expanded(
                        child: _buildTimeSelector(
                          hours['close'],
                          (time) {
                            setState(() {
                              _businessHours[day]!['close'] = time;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Closed',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelector(String currentTime, Function(String) onTimeChanged) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(currentTime.split(':')[0]),
            minute: int.parse(currentTime.split(':')[1]),
          ),
        );
        
        if (time != null) {
          final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          onTimeChanged(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currentTime,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    // Determine which image to show
    ImageProvider? currentImage;
    bool hasProfilePicture = false;
    
    if (_newProfilePicture != null) {
      currentImage = FileImage(_newProfilePicture!);
      hasProfilePicture = true;
    } else if (_existingProfilePictureUrl != null && !_removeProfilePicture) {
      currentImage = NetworkImage(_existingProfilePictureUrl!);
      hasProfilePicture = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Profile picture display
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: hasProfilePicture
                  ? ClipOval(
                      child: currentImage != null
                          ? Image(
                              image: currentImage,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                    )
                  : Icon(
                      Icons.store,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
            ),
            const SizedBox(width: 16),
            // Action buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Picture',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will be displayed as your salon\'s main image',
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
                          onPressed: _pickProfilePicture,
                          icon: const Icon(Icons.photo_camera, size: 18),
                          label: Text(
                            hasProfilePicture ? 'Change' : 'Upload',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                        ),
                      ),
                      if (hasProfilePicture) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeCurrentProfilePicture,
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}
