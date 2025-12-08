import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TCustomContainer extends ConsumerWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final Alignment? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  // Colors & Gradient
  final Color? lightColor;
  final Gradient? gradient;

  // Border & Shadow
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  // Background Image
  final DecorationImage? backgroundImage;

  // Shape
  final BoxShape shape;

  const TCustomContainer({
    super.key,
    this.child,
    this.alignment,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.lightColor,
    this.gradient,
    this.border,
    this.boxShadow,
    this.backgroundImage,
    this.shape = BoxShape.rectangle, // Default rectangle
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        shape: shape,
        color: gradient == null ? lightColor ?? Colors.white : null,
        gradient: gradient,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        border: border,
        image: backgroundImage,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
