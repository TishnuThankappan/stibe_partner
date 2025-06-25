import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Sample activity items - in production, these would come from a data source
        _buildActivityItem(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          title: 'Appointment Completed',
          description: 'Sarah Johnson - Haircut & Styling',
          time: '2 hours ago',
        ),
        _buildActivityDivider(),
        _buildActivityItem(
          icon: Icons.add_circle,
          iconColor: AppColors.primary,
          title: 'New Appointment',
          description: 'Mike Smith - Beard Trim',
          time: '3 hours ago',
        ),
        _buildActivityDivider(),
        _buildActivityItem(
          icon: Icons.attach_money,
          iconColor: AppColors.accent,
          title: 'Payment Received',
          description: '\$120 - Hair Coloring',
          time: '5 hours ago',
        ),
        _buildActivityDivider(),
        _buildActivityItem(
          icon: Icons.cancel,
          iconColor: AppColors.error,
          title: 'Appointment Cancelled',
          description: 'John Doe - Haircut',
          time: 'Yesterday',
        ),
      ],
    );
  }
  
  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityDivider() {
    return const Divider(
      color: AppColors.divider,
      thickness: 1,
      height: 1,
    );
  }
}
