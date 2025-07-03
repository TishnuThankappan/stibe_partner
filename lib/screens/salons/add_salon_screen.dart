import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/app_button.dart';
import 'package:stibe_partner/widgets/app_text_field.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/screens/salons/location_picker_screen.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/api/image_upload_service.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class AddSalonScreen extends StatefulWidget {
  const AddSalonScreen({super.key});

  @override
  State<AddSalonScreen> createState() => _AddSalonScreenState();
}

class _AddSalonScreenState extends State<AddSalonScreen> {
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
  final List<File> _salonImages = [];
  File? _profilePicture;
  
  // Location
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedLocationName;
  
  // Business hours
  final Map<String, Map<String, dynamic>> _businessHours = {
    'Monday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'Tuesday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'Wednesday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'Thursday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'Friday': {'isOpen': true, 'open': '09:00', 'close': '19:00'},
    'Saturday': {'isOpen': true, 'open': '08:00', 'close': '17:00'},
    'Sunday': {'isOpen': false, 'open': '10:00', 'close': '16:00'},
  };

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
          _salonImages.addAll(images.map((image) => File(image.path)));
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
          _profilePicture = File(pickedFile.path);
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

  void _removeImage(int index) {
    setState(() {
      _salonImages.removeAt(index);
    });
  }

  void _removeProfilePicture() {
    setState(() {
      _profilePicture = null;
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

  Future<void> _createSalon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Upload profile picture first if selected
      String? profilePictureUrl;
      if (_profilePicture != null) {
        try {
          print('📤 Uploading profile picture...');
          final imageUploadService = ImageUploadService();
          final profilePictureUrls = await imageUploadService.uploadImages([_profilePicture!]);
          if (profilePictureUrls.isNotEmpty) {
            profilePictureUrl = profilePictureUrls.first;
            print('✅ Profile picture uploaded successfully: $profilePictureUrl');
          }
        } catch (e) {
          print('❌ Profile picture upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: Profile picture upload failed. Salon will be created without profile picture.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Upload images if any are selected
      List<String> uploadedImageUrls = [];
      if (_salonImages.isNotEmpty) {
        try {
          print('📤 Uploading ${_salonImages.length} salon images...');
          final imageUploadService = ImageUploadService();
          uploadedImageUrls = await imageUploadService.uploadImages(_salonImages);
          print('✅ Uploaded ${uploadedImageUrls.length} images successfully');
        } catch (e) {
          print('❌ Image upload failed: $e');
          // Continue with salon creation even if image upload fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: Image upload failed. Salon will be created without images.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Prepare business hours data
      final businessHours = <String, Map<String, dynamic>>{};
      _businessHours.forEach((day, hours) {
        businessHours[day] = {
          'isOpen': hours['isOpen'],
          'open': hours['open'],
          'close': hours['close'],
        };
      });

      // Convert opening and closing times to proper format
      final openingTime = '${_businessHours.values.first['open']}:00';
      final closingTime = '${_businessHours.values.first['close']}:00';

      print('Creating salon with:');
      print('- Name: ${_nameController.text}');
      print('- Description: ${_descriptionController.text}');
      print('- Address: ${_addressController.text}');
      print('- City: ${_cityController.text}');
      print('- State: ${_stateController.text}');
      print('- ZIP: ${_zipController.text}');
      print('- Phone: ${_phoneController.text}');
      print('- Email: ${_emailController.text}');
      print('- Images: ${_salonImages.length} photos selected, ${uploadedImageUrls.length} uploaded');
      print('- Image URLs: $uploadedImageUrls');
      print('- Location: ${_selectedLocationName ?? "Not selected"}');
      print('- Business Hours: $businessHours');
      if (_selectedLatitude != null && _selectedLongitude != null) {
        print('- Coordinates: $_selectedLatitude, $_selectedLongitude');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      final salonService = SalonService();
      final request = CreateSalonRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        openingTime: openingTime,
        closingTime: closingTime,
        businessHours: businessHours,
        currentLatitude: _selectedLatitude,
        currentLongitude: _selectedLongitude,
        useCurrentLocation: _selectedLatitude != null && _selectedLongitude != null,
        imageUrls: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null, // Add uploaded image URLs
        profilePictureUrl: profilePictureUrl,
      );

      final salon = await salonService.createSalon(request);

      print('✅ Salon created successfully: ${salon.toJson()}');

      if (mounted) {
        final imagesMessage = uploadedImageUrls.isNotEmpty 
            ? '${uploadedImageUrls.length} image${uploadedImageUrls.length == 1 ? '' : 's'} uploaded successfully!'
            : _salonImages.isNotEmpty 
                ? 'Images selected but upload failed'
                : 'No images selected';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Salon "${salon.name}" created successfully!\n'
              '$imagesMessage\n'
              '${_selectedLocationName != null ? "Location: $_selectedLocationName" : "No location selected"}'
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
            content: Text('Error creating salon: $_errorMessage'),
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
      appBar: const CustomAppBar(
        title: 'Add New Salon',
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
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
                      Icon(Icons.error, color: Colors.red.shade600),
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
                label: 'Description (Optional)',
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
              
              _buildLocationPicker(),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'City',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'State',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _zipController,
                      label: 'ZIP Code',
                      hintText: 'ZIP',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
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

              // Create Button
              AppButton(
                text: 'Create Salon',
                onPressed: _isLoading ? null : () => _createSalon(),
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

  Widget _buildBusinessHours() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: _businessHours.entries.map((entry) {
          final day = entry.key;
          final hours = entry.value;
          final isLast = entry.key == _businessHours.keys.last;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: hours['isOpen'],
                  onChanged: (value) {
                    setState(() {
                      _businessHours[day]!['isOpen'] = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 16),
                if (hours['isOpen']) ...[
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            value: hours['open'],
                            onChanged: (value) {
                              setState(() {
                                _businessHours[day]!['open'] = value;
                              });
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('to'),
                        ),
                        Expanded(
                          child: _buildTimeField(
                            value: hours['close'],
                            onChanged: (value) {
                              setState(() {
                                _businessHours[day]!['close'] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
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
      ),
    );
  }

  Widget _buildTimeField({
    required String value,
    required Function(String) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(value.split(':')[0]),
            minute: int.parse(value.split(':')[1]),
          ),
        );
        if (time != null) {
          final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          onChanged(timeString);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Images Button
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
                    'Add Salon Photos',
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
        
        // Display selected images
        if (_salonImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '${_salonImages.length} image${_salonImages.length == 1 ? '' : 's'} selected',
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
              itemCount: _salonImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _salonImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
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
        ],
      ],
    );
  }

  Widget _buildProfilePictureSection() {
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
              child: _profilePicture != null
                  ? ClipOval(
                      child: Image.file(
                        _profilePicture!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
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
                    'This will be displayed as your salon\'s main image (Optional)',
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
                            _profilePicture != null ? 'Change' : 'Upload',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                        ),
                      ),
                      if (_profilePicture != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeProfilePicture,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Location on Map',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedLocationName != null
                            ? _selectedLocationName!
                            : 'Tap to select precise location on map',
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
}
