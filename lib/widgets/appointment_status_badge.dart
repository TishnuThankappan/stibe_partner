import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class AppointmentStatusBadge extends StatelessWidget {
  final String status;
  final double? width;
  final double? height;
  final double? fontSize;
  
  const AppointmentStatusBadge({
    super.key,
    required this.status,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText = status.toUpperCase();
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppColors.pending;
        break;
      case 'confirmed':
        backgroundColor = AppColors.confirmed;
        break;
      case 'completed':
        backgroundColor = AppColors.completed;
        break;
      case 'cancelled':
        backgroundColor = AppColors.cancelled;
        break;
      default:
        backgroundColor = AppColors.primary;
    }
    
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: fontSize ?? 12,
          ),
        ),
      ),
    );
  }
}
