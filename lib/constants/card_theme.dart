import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class SharedCardTheme {
  // Shared card decoration
  static BoxDecoration cardDecoration({
    bool isActive = true,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: isActive ? Colors.white : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      border: isActive 
          ? null 
          : Border.all(color: borderColor ?? Colors.orange.shade300, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Shared filter container decoration
  static BoxDecoration filterContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Shared category/role container decoration
  static BoxDecoration categoryContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Shared expandable header decoration
  static BoxDecoration expandableHeaderDecoration({
    required bool isExpanded,
    Color? color,
  }) {
    return BoxDecoration(
      color: isExpanded 
          ? (color ?? AppColors.primary).withOpacity(0.15) 
          : (color ?? AppColors.primary).withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
      border: Border.all(
        color: isExpanded 
            ? (color ?? AppColors.primary).withOpacity(0.5) 
            : Colors.transparent,
        width: 1,
      ),
    );
  }

  // Shared status chip
  static Widget statusChip({
    required bool isActive,
    String? activeText,
    String? inactiveText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pause_circle,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? (activeText ?? 'Active') : (inactiveText ?? 'Inactive'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Shared category/role chip
  static Widget categoryChip({
    required String text,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8, left: 8),
      child: Chip(
        avatar: Icon(
          icon,
          size: 16,
          color: color ?? AppColors.primary,
        ),
        label: Text(text),
        backgroundColor: Colors.grey.shade50,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // Shared empty state
  static Widget emptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shared filter section
  static Widget filterSection({
    required bool showInactive,
    required ValueChanged<bool> onToggle,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: filterContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Display Options:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Toggle for active/inactive items
              Row(
                children: [
                  Text(
                    'Show Inactive',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: showInactive,
                    onChanged: onToggle,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Shared count badge
  static Widget countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
