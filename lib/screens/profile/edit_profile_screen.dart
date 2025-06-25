import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/widgets/app_button.dart';
import 'package:stibe_partner/widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _profileImage;
  String? _currentProfileImageUrl;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _currentProfileImageUrl = user.formattedProfileImage;
      
      // Debug output
      print('🖼️ Edit Profile screen profile picture URL: $_currentProfileImageUrl');
      print('🖼️ Original profile picture URL: ${user.profileImage}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Upload image if selected
      String? profileImageUrl = _currentProfileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await authProvider.uploadProfileImage(_profileImage!);
      }
      
      // Update profile
      final success = await authProvider.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
        profileImage: profileImageUrl,
      );
      
      if (success && mounted) {
        // Refresh the user profile to ensure updated data
        await authProvider.refreshProfile();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.error ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null 
                                ? FileImage(_profileImage!) as ImageProvider
                                : null,
                            child: _profileImage == null 
                                ? (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _currentProfileImageUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('🖼️ Error loading profile image in edit screen: $error');
                                            print('🖼️ Failed URL: $_currentProfileImageUrl');
                                            print('🖼️ StackTrace: $stackTrace');
                                            return Text(
                                              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '',
                                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                            );
                                          },
                                        ),
                                      ) 
                                    : Text(
                                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '',
                                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                      ))
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                iconSize: 20,
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    
                    // Email (read-only)
                    AppTextField(
                      label: 'Email',
                      initialValue: user.email,
                      enabled: false,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    
                    // First Name
                    AppTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    
                    // Last Name
                    AppTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    
                    // Phone Number
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: AppSizes.spacingS),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                    ],
                    
                    // Update button
                    AppButton(
                      text: 'Update Profile',
                      isLoading: _isLoading,
                      onPressed: _updateProfile,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
