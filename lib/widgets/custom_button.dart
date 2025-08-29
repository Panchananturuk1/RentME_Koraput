import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 48.h;
    final buttonWidth = width ?? double.infinity;

    if (isOutlined) {
      return SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? AppTheme.primaryColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: _buildButtonContent(),
        ),
      );
    }

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined 
                ? (backgroundColor ?? AppTheme.primaryColor)
                : (textColor ?? Colors.white),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: (fontSize ?? 16.sp) + 2,
            color: isOutlined 
                ? (backgroundColor ?? AppTheme.primaryColor)
                : (textColor ?? Colors.white),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16.sp,
              fontWeight: FontWeight.w600,
              color: isOutlined 
                  ? (backgroundColor ?? AppTheme.primaryColor)
                  : (textColor ?? Colors.white),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16.sp,
        fontWeight: FontWeight.w600,
        color: isOutlined 
            ? (backgroundColor ?? AppTheme.primaryColor)
            : (textColor ?? Colors.white),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 48.w;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: buttonSize * 0.5,
        ),
        tooltip: tooltip,
      ),
    );
  }
}