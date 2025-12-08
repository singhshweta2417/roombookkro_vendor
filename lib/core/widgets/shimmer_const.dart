import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../theme/app_colors.dart';

/// Provider to control shimmer animation progress (0 → 1)
final shimmerAnimationProvider = StateProvider<double>((ref) => 0);

class CustomShimmer extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const CustomShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.padding,
  });

  @override
  ConsumerState<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends ConsumerState<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      ref.read(shimmerAnimationProvider.notifier).state = _controller.value;
    })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationValue = ref.watch(shimmerAnimationProvider);
    final baseColor = AppColors.shimmerBase(ref);
    final highlightColor = AppColors.shimmerHighLight(ref);

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1 - 0.3 + animationValue * 2, 0),
          end: Alignment(1 + 0.3 + animationValue * 2, 0),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Container(
        padding: widget.padding ?? EdgeInsets.zero,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
