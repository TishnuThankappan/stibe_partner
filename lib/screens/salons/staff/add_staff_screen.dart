import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/api/comprehensive_staff_service.dart';

class AddStaffScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const AddStaffScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComprehensiveStaffService _staffService = ComprehensiveStaffService();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _commissionRateController = TextEditingController(text: '40');
  final _experienceController = TextEditingController(text: '0');
  final _certificationsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _instagramController = TextEditingController();

  // Form values
  String _selectedRole = 'Stylist';
  String _selectedEmploymentType = 'Full-Time';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _lunchStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _lunchEnd = const TimeOfDay(hour: 14, minute: 0);
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _commissionRateController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _languagesController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Staff Member'),
            Text(
              widget.salonName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            _buildSectionHeader('Personal Information', Icons.person),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'First name is required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Last name is required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Professional Information Section
            _buildSectionHeader('Professional Information', Icons.work),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: ComprehensiveStaffService.getAvailableRoles()
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Role is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedEmploymentType,
              decoration: const InputDecoration(
                labelText: 'Employment Type',
                border: OutlineInputBorder(),
              ),
              items: ComprehensiveStaffService.getEmploymentTypes()
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedEmploymentType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _experienceController,
              label: 'Years of Experience',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Experience is required';
                final exp = int.tryParse(value!);
                if (exp == null || exp < 0) return 'Please enter valid experience';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _bioController,
              label: 'Bio (Optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Work Schedule Section
            _buildSectionHeader('Work Schedule', Icons.access_time),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () => _selectTime(_startTime, (time) => _startTime = time),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () => _selectTime(_endTime, (time) => _endTime = time),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Lunch Start',
                    time: _lunchStart,
                    onTap: () => _selectTime(_lunchStart, (time) => _lunchStart = time),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: 'Lunch End',
                    time: _lunchEnd,
                    onTap: () => _selectTime(_lunchEnd, (time) => _lunchEnd = time),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Financial Information Section
            _buildSectionHeader('Financial Information', Icons.attach_money),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _hourlyRateController,
                    label: 'Hourly Rate (₹)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isNotEmpty == true) {
                        final rate = double.tryParse(value!);
                        if (rate == null || rate < 0) return 'Please enter valid rate';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _commissionRateController,
                    label: 'Commission Rate (%)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Commission rate is required';
                      final rate = double.tryParse(value!);
                      if (rate == null || rate < 0 || rate > 100) {
                        return 'Rate must be between 0-100';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Additional Information Section
            _buildSectionHeader('Additional Information', Icons.info),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _certificationsController,
              label: 'Certifications (comma-separated)',
              hint: 'e.g., Hair Cutting, Color Specialist, Keratin Treatment',
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _languagesController,
              label: 'Languages (comma-separated)',
              hint: 'e.g., English, Hindi, Tamil',
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _instagramController,
              label: 'Instagram Handle (Optional)',
              hint: '@username',
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addStaff,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('Add Staff Member'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          time.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _selectTime(TimeOfDay currentTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  String _timeToApiFormat(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _addStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = StaffRegistrationRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        bio: _bioController.text.trim(),
        salonId: widget.salonId,
        startTime: _timeToApiFormat(_startTime),
        endTime: _timeToApiFormat(_endTime),
        lunchBreakStart: _timeToApiFormat(_lunchStart),
        lunchBreakEnd: _timeToApiFormat(_lunchEnd),
        experienceYears: int.parse(_experienceController.text),
        hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0.0,
        commissionRate: double.parse(_commissionRateController.text),
        employmentType: _selectedEmploymentType,
        certifications: _certificationsController.text.trim(),
        languages: _languagesController.text.trim(),
        instagramHandle: _instagramController.text.trim(),
      );

      await _staffService.registerStaff(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_firstNameController.text} ${_lastNameController.text} added successfully!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'They will receive an email to verify their account and set up login.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Enhanced error message for better user experience
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        // Show detailed error in SnackBar with action to dismiss
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Failed to Add Staff Member',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        
        // Note: Form data is automatically preserved as we don't clear controllers or navigate away
      }
    }
  }
}
