import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/app_text.dart';

class Utils {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(String message, BuildContext context, {Color? color}) {
    if (_isShowing) {
      _overlayEntry?.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: 50, // screen ke bottom se distance
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            decoration: BoxDecoration(
              color: color ?? Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: AppText(
              text: message,
              color: Colors.white,
              fontSize: 13,
              textAlign: TextAlign.center,
              maxLines: message.length,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;

    _startTimer();
  }

  static void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry?.remove();
        _isShowing = false;
        _overlayEntry = null;
      }
    });
  }
}
