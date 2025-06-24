import 'package:flutter/material.dart' hide OutlinedButton;
import 'package:provider/provider.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/models/user_model.dart';
import 'package:stibe_partner/providers/auth_provider.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/custom_text_field.dart';

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
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
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
    _businessDescriptionController.dispose();
    _businessPhoneController.dispose();
    _businessWebsiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
  
  Future<void> _submitBusinessInfo() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create location object
      final location = Location(
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
      );
      
      final success = await authProvider.submitBusinessInfo(
        name: _businessNameController.text.trim(),
        address: _businessAddressController.text.trim(),
        description: _businessDescriptionController.text.trim(),
        location: location,
        serviceCategories: _selectedCategories,
      );
      
      if (success && mounted) {
        widget.onSetupComplete();
      }
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
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
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
          label: 'Business Address',
          hintText: 'Enter your business address',
          controller: _businessAddressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your business address';
            }
            return null;
          },
          prefix: const Icon(Icons.location_on_outlined),
          required: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your business location coordinates:',
          style: AppTextStyles.subtitle,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'These coordinates will be used to show your business on the map.',
          style: AppTextStyles.caption,
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Latitude',
                hintText: 'e.g. 37.7749',
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
                prefix: const Icon(Icons.my_location),
                required: true,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: CustomTextField(
                label: 'Longitude',
                hintText: 'e.g. -122.4194',
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
                prefix: const Icon(Icons.my_location),
                required: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Map Preview',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        OutlinedButton(
          text: 'Get Current Location',
          onPressed: () {
            // Request current location
            // For demo purposes, set some sample coordinates
            setState(() {
              _latitudeController.text = '40.7128';
              _longitudeController.text = '-74.0060';
            });
          },
          icon: Icons.my_location,
          width: double.infinity,
        ),
      ],
    );
  }
}
