import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/api/comprehensive_staff_service.dart';

class EditStaffScreen extends StatefulWidget {
  final StaffDto staff;

  const EditStaffScreen({
    super.key,
    required this.staff,
  });

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComprehensiveStaffService _staffService = ComprehensiveStaffService();
  
  // Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _hourlyRateController;
  late final TextEditingController _commissionRateController;
  late final TextEditingController _experienceController;
  late final TextEditingController _certificationsController;
  late final TextEditingController _languagesController;
  late final TextEditingController _instagramController;

  // Form values
  late String _selectedRole;
  late String _selectedEmploymentType;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TimeOfDay _lunchStart;
  late TimeOfDay _lunchEnd;
  late bool _isActive;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.staff.firstName);
    _lastNameController = TextEditingController(text: widget.staff.lastName);
    _phoneController = TextEditingController(text: widget.staff.phoneNumber);
    _bioController = TextEditingController(text: widget.staff.bio);
    _hourlyRateController = TextEditingController(text: widget.staff.hourlyRate.toString());
    _commissionRateController = TextEditingController(text: widget.staff.commissionRate.toString());
    _experienceController = TextEditingController(text: widget.staff.experienceYears.toString());
    _certificationsController = TextEditingController(text: widget.staff.certifications);
    _languagesController = TextEditingController(text: widget.staff.languages);
    _instagramController = TextEditingController(text: widget.staff.instagramHandle);
    
    _selectedRole = widget.staff.role;
    _selectedEmploymentType = widget.staff.employmentType;
    _isActive = widget.staff.isActive;
    
    // Parse time strings to TimeOfDay
    _startTime = _parseTimeString(widget.staff.startTime);
    _endTime = _parseTimeString(widget.staff.endTime);
    _lunchStart = _parseTimeString(widget.staff.lunchBreakStart);
    _lunchEnd = _parseTimeString(widget.staff.lunchBreakEnd);
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
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
        title: Text('Edit ${widget.staff.firstName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isActive ? Icons.check_circle : Icons.cancel,
                    color: _isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isActive ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        Text(
                          _isActive ? 'Active - Can receive bookings' : 'Inactive - Cannot receive bookings',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isActive ? Colors.green.shade600 : Colors.red.shade600,
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
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
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
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              maxLines: 3,
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
              label: 'Instagram Handle',
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
                    onPressed: _isLoading ? null : _updateStaff,
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
                        : const Text('Update Staff'),
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

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = StaffUpdateRequest(
        id: widget.staff.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
        bio: _bioController.text.trim(),
        isActive: _isActive,
        startTime: _timeToApiFormat(_startTime),
        endTime: _timeToApiFormat(_endTime),
        lunchBreakStart: _timeToApiFormat(_lunchStart),
        lunchBreakEnd: _timeToApiFormat(_lunchEnd),
        experienceYears: int.parse(_experienceController.text),
        hourlyRate: double.tryParse(_hourlyRateController.text),
        commissionRate: double.parse(_commissionRateController.text),
        employmentType: _selectedEmploymentType,
        certifications: _certificationsController.text.trim(),
        languages: _languagesController.text.trim(),
        instagramHandle: _instagramController.text.trim(),
      );

      await _staffService.updateStaff(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.staff.firstName} has been updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating staff: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
