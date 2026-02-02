import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';

class AnimatedHintTextField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> hints;
  final Color fillColor;

  const AnimatedHintTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hints,
    required this.fillColor,
  });

  @override
  ConsumerState<AnimatedHintTextField> createState() =>
      _AnimatedHintTextFieldState();
}

class _AnimatedHintTextFieldState extends ConsumerState<AnimatedHintTextField> {
  int _currentHintIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.controller.text.isEmpty) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % widget.hints.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: AppColors.iconColor(ref)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border:
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.borderColor(ref),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: AppColors.text(ref)),
        labelStyle: TextStyle(color: AppColors.text(ref)),
        filled: true,
        fillColor: AppColors.background(ref),
        hintText: widget.hints[_currentHintIndex],
      ),
      style: TextStyle(fontSize: 16, color: AppColors.text(ref)),
    );
  }
}
