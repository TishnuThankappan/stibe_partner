import 'package:flutter/material.dart' hide OutlinedButton;
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/models/user_model.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/custom_text_field.dart';
import 'package:stibe_partner/widgets/location_picker.dart';

class BusinessProfileSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;
  
  const BusinessProfileSetupScreen({
    super.key,
    required this.onSetupComplete,
  });

  @override
  State<BusinessProfileSetupScreen> createState() => _BusinessProfileSetupScreenState();
}

class _BusinessProfileSetupScreenState extends State<BusinessProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();  final _businessAddressController = TextEditingController();
  final _businessCityController = TextEditingController();
  final _businessStateController = TextEditingController();
  final _businessZipController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessWebsiteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  final List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Hair Salon',
    'Barbershop',
    'Nail Salon',
    'Spa',
    'Beauty Salon',
    'Massage',
    'Skin Care',
    'Makeup',
    'Hair Removal',
    'Eyebrows & Lashes',
  ];
  
  int _currentStep = 0;
    @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessCityController.dispose();
    _businessStateController.dispose();
    _businessZipController.dispose();
    _businessDescriptionController.dispose();
    _businessPhoneController.dispose();
    _businessWebsiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }    Future<void> _submitBusinessInfo() async {
    if (_formKey.currentState!.validate()) {
      print('📋 Form validation passed');
      
      if (_selectedCategories.isEmpty) {
        print('⚠️ No service categories selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one service category'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Validate location coordinates
      if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
        print('⚠️ Location coordinates not provided');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide your business location'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final latitude = double.tryParse(_latitudeController.text);
      final longitude = double.tryParse(_longitudeController.text);
      
      if (latitude == null || longitude == null) {
        print('⚠️ Invalid location coordinates');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid location coordinates'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create location object
      final location = Location(
        latitude: latitude,
        longitude: longitude,
      );
      
      print('🚀 Submitting business info...');
      
      final success = await authProvider.submitBusinessInfo(
        name: _businessNameController.text.trim(),
        address: _businessAddressController.text.trim(),
        city: _businessCityController.text.trim(),
        state: _businessStateController.text.trim(),
        zipCode: _businessZipController.text.trim(),
        description: _businessDescriptionController.text.trim(),
        location: location,
        serviceCategories: _selectedCategories,
      );
      
      if (success && mounted) {
        print('✅ Business setup completed successfully');
        widget.onSetupComplete();
      } else {
        print('❌ Business setup failed');
        // Error is already displayed by the AuthProvider
      }
    } else {
      print('❌ Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Business Profile Setup',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,            onStepContinue: () {
              if (_currentStep < 2) {
                // Validate current step before proceeding
                if (_currentStep == 1 && _selectedCategories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one service category'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                setState(() {
                  _currentStep += 1;
                });
              } else {
                _submitBusinessInfo();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: _currentStep == 2 ? 'Submit' : 'Continue',
                        onPressed: details.onStepContinue!,
                        isLoading: authProvider.isLoading,
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          text: 'Back',
                          onPressed: details.onStepCancel!,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Basic Information'),
                content: _buildBasicInfoStep(),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Services & Categories'),
                content: _buildServicesStep(),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Location'),
                content: _buildLocationStep(),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
            ],
          ),
        ),
      ),
    );
  }
    Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Business Name',
          hintText: 'Enter your business name',
          controller: _businessNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your business name';
            }
            return null;
          },
          prefix: const Icon(Icons.business),
          required: true,
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Street Address',
          hintText: 'Enter your street address',
          controller: _businessAddressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your street address';
            }
            return null;
          },
          prefix: const Icon(Icons.location_on_outlined),
          required: true,
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                label: 'City',
                hintText: 'Enter city',
                controller: _businessCityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
                prefix: const Icon(Icons.location_city),
                required: true,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              flex: 2,
              child: CustomTextField(
                label: 'State',
                hintText: 'State/Province',
                controller: _businessStateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
                prefix: const Icon(Icons.map),
                required: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                label: 'ZIP/Postal Code',
                hintText: 'Enter ZIP code',
                controller: _businessZipController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ZIP code';
                  }
                  if (value.length < 4) {
                    return 'Invalid ZIP code';
                  }
                  return null;
                },
                prefix: const Icon(Icons.local_post_office),
                required: true,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Empty space to balance the layout
            const Expanded(
              flex: 3,
              child: SizedBox(),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Business Description',
          hintText: 'Tell us about your business',
          controller: _businessDescriptionController,
          maxLines: 3,
          prefix: const Icon(Icons.description_outlined),
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Business Phone',
          hintText: 'Enter your business phone number',
          controller: _businessPhoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your business phone number';
            }
            return null;
          },
          prefix: const Icon(Icons.phone_outlined),
          required: true,
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Business Website',
          hintText: 'Enter your business website (optional)',
          controller: _businessWebsiteController,
          keyboardType: TextInputType.url,
          prefix: const Icon(Icons.language_outlined),
        ),
      ],
    );
  }
  
  Widget _buildServicesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select service categories that your business offers:',
          style: AppTextStyles.subtitle,
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        
        if (_selectedCategories.isEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Please select at least one category',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildLocationStep() {
    return LocationPicker(
      initialLatitude: _latitudeController.text.isNotEmpty ? double.tryParse(_latitudeController.text) : null,
      initialLongitude: _longitudeController.text.isNotEmpty ? double.tryParse(_longitudeController.text) : null,
      title: 'Business Location',
      subtitle: 'Get your current location or use demo coordinates for testing.',
      onLocationSelected: (latitude, longitude, isDemo) {
        setState(() {
          _latitudeController.text = latitude.toString();
          _longitudeController.text = longitude.toString();
        });
      },
      showDemoOption: true,
    );
  }
}
