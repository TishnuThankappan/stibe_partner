import 'package:flutter/material.dart';
import 'package:stibe_partner/screens/salons/staff/enhanced_staff_management_screen.dart';

class StaffManagementScreen extends StatelessWidget {
  final int salonId;
  final String? salonName;
  
  const StaffManagementScreen({
    super.key, 
    required this.salonId,
    this.salonName,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedStaffManagementScreen(
      salonId: salonId,
      salonName: salonName ?? 'Unknown Salon',
    );
  }
}
