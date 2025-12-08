library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

/// ****** Here is  also CircularIndicator Widget   **********
/// ****** The Primary Button Has Cupertino CircularProgressIndicator *****

class PrimaryButton extends ConsumerStatefulWidget {
  final String? label;
  final bool isLoading;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final double? space;
  final void Function()? onTap;
  final Color? color;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape? shape;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Widget? child;

  const PrimaryButton({
    super.key,
    this.label,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.space,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.borderRadius,
    this.shape,
    this.border,
    this.boxShadow,
    this.child,
    this.isLoading = false,
  });

  @override
  ConsumerState<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends ConsumerState<PrimaryButton> {
  bool _isDialogShowing = false; // dialog flag

  void _showLoadingPopup() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black26,
          builder: (context) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {}
              },
              child: Center(
                child: Container(
                  width: context.sw * 0.35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.0),
                    border: Border.all(color: AppColors.borderColor(ref)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CupertinoActivityIndicator(
                        radius: 12,
                        color: Colors.black,
                      ),
                      Flexible(
                        child: AppText(
                          text: "Loading...",
                          fontSize: context.sh * 0.018,
                          fontType: FontType.semiBold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ).then((_) {
          _isDialogShowing = false;
        });
      }
    });
  }

  void _hideLoadingPopup() {
    if (_isDialogShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _isDialogShowing = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _hideLoadingPopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // show/hide popup based on isLoading
    if (widget.isLoading) {
      _showLoadingPopup();
    } else {
      _hideLoadingPopup();
    }

    return InkWell(
      onTap: widget.isLoading ? null : widget.onTap,
      child: Container(
        margin: widget.margin,
        alignment: Alignment.center,
        padding: widget.padding,
        height: widget.height ?? 45,
        width: widget.width ?? 335,
        decoration: BoxDecoration(
          border: widget.border,
          shape: widget.shape ?? BoxShape.rectangle,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          color: widget.color ?? AppColors.secondary(ref),
          boxShadow: widget.boxShadow,
        ),
        child:
            widget.child ??
            (widget.icon == null
                ? AppText(
                    text: widget.label ?? "CLICK",
                    color: widget.textColor ?? Colors.white,
                    fontSize: widget.fontSize ?? 16,
                    fontType: FontType.semiBold,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.iconColor ?? Colors.white,
                        size: widget.iconSize,
                      ),
                      SizedBox(width: widget.space ?? 5),
                      AppText(
                        text: widget.label ?? "",
                        color: widget.textColor ?? Colors.white,
                        fontSize: widget.fontSize ?? 16,
                        fontType: FontType.semiBold,
                      ),
                    ],
                  )),
      ),
    );
  }
}
