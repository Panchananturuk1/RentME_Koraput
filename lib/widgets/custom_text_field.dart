import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText ? _isObscured : false,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      style: TextStyle(
        fontSize: 16.sp,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: AppTheme.textHint,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: AppTheme.textSecondary,
                size: 20.sp,
              )
            : null,
        suffixIcon: _buildSuffixIcon(),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
        counterText: '',
        errorStyle: TextStyle(
          fontSize: 12.sp,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: _toggleObscureText,
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.textSecondary,
          size: 20.sp,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconTap,
        icon: Icon(
          widget.suffixIcon,
          color: AppTheme.textSecondary,
          size: 20.sp,
        ),
      );
    }

    return null;
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16.sp,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.textHint,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textSecondary,
            size: 20.sp,
          ),
          suffixIcon: showClearButton && 
                      controller != null && 
                      controller!.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller!.clear();
                    if (onClear != null) onClear!();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.textSecondary,
                    size: 20.sp,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }
}