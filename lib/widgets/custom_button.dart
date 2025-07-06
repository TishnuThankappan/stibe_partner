import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData? icon;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;
  final double? loadingSize;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.icon,
    this.isOutlined = false,
    this.padding,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = isOutlined ? Colors.transparent : AppColors.primary;
    final defaultTextColor = isOutlined ? AppColors.primary : Colors.white;
    final defaultBorderColor = isOutlined ? AppColors.primary : Colors.transparent;
    
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isLoading ? (backgroundColor ?? defaultBackgroundColor).withOpacity(0.7) : (backgroundColor ?? defaultBackgroundColor),
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? defaultBorderColor,
                width: isOutlined ? 1.5 : 0,
              ),
            ),
            padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: loadingSize ?? 24,
                      height: loadingSize ?? 24,
                      child: LoadingIndicator.button(
                        color: textColor ?? defaultTextColor,
                        size: loadingSize ?? 20.0,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: textColor ?? defaultTextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? defaultTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double? loadingSize;
  
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.padding,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
      padding: padding,
      loadingSize: loadingSize,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double? loadingSize;
  
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.padding,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.secondary,
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
      padding: padding,
      loadingSize: loadingSize,
    );
  }
}

class OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? textColor;
  final double? loadingSize;
  
  const OutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.padding,
    this.borderColor,
    this.textColor,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? AppColors.primary,
      borderColor: borderColor ?? AppColors.primary,
      width: width,
      height: height,
      icon: icon,
      isOutlined: true,
      padding: padding,
      loadingSize: loadingSize,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double? loadingSize;
  
  const DangerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.padding,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
      padding: padding,
      loadingSize: loadingSize,
    );
  }
}
