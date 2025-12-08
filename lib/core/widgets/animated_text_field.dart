import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedHintTextField extends StatefulWidget {
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
  State<AnimatedHintTextField> createState() => _AnimatedHintTextFieldState();
}

class _AnimatedHintTextFieldState extends State<AnimatedHintTextField> {
  int _currentHintIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.controller.text.isEmpty) {
        setState(() {
          _currentHintIndex =
              (_currentHintIndex + 1) % widget.hints.length;
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
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.fillColor,
        hintText: widget.hints[_currentHintIndex],
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}