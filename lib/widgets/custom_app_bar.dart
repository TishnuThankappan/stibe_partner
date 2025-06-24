import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 0.5,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom == null ? kToolbarHeight : kToolbarHeight + bottom!.preferredSize.height);
}

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final bool autofocus;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  
  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.onClear,
    this.autofocus = false,
    this.controller,
    this.backgroundColor,
    this.iconColor,
    this.padding,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          onSubmitted: widget.onSearch,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: widget.iconColor ?? AppColors.textSecondary,
            ),
            suffixIcon: _showClearButton
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: widget.iconColor ?? AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _controller.clear();
                      if (widget.onClear != null) {
                        widget.onClear!();
                      }
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
    );
  }
}
