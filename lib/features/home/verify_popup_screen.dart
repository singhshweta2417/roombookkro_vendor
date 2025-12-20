// ============================================================
// verification_dialog.dart
// Create this file in: lib/core/widgets/verification_dialog.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';

class VerificationDialog {
  static void show(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _VerificationDialogContent(ref: ref),
        );
      },
    );
  }
}

class _VerificationDialogContent extends StatefulWidget {
  final WidgetRef ref;

  const _VerificationDialogContent({required this.ref});

  @override
  State<_VerificationDialogContent> createState() =>
      _VerificationDialogContentState();
}

class _VerificationDialogContentState
    extends State<_VerificationDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TCustomContainer(
          // padding: const EdgeInsets.all(24),
            lightColor: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing circle animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    // Icon
                    Icon(
                      Icons.access_time_rounded,
                      size: 40,
                      color: Colors.orange.shade600,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              AppText(
                text: "Verification Pending",
                fontSize: AppConstants.twenty,
                fontType: FontType.bold,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              AppText(
                text:
                "Your account is currently under verification. You'll be able to add properties once verified.",
                fontSize: AppConstants.fourteen,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Additional info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        text: "This usually takes 24-48 hours",
                        fontSize: AppConstants.twelve,
                        color: Colors.blue.shade700,
                        fontType: FontType.medium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: AppColors.secondary(widget.ref),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppText(
                        text: "Got it",
                        fontSize: AppConstants.fourteen,
                        fontType: FontType.semiBold,
                        color: AppColors.secondary(widget.ref),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Optional: Navigate to support/help screen
                        // Navigator.pushNamed(context, AppRoutes.support);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary(widget.ref),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppText(
                        text: "Contact Support",
                        fontSize: AppConstants.fourteen,
                        fontType: FontType.semiBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ALTERNATIVE: Bottom Sheet Style Dialog
// ============================================================

class VerificationBottomSheet {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Icon with gradient background
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade300,
                      Colors.orange.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              AppText(
                text: "Verification in Progress",
                fontSize: AppConstants.twentyTwo,
                fontType: FontType.bold,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              AppText(
                text:
                "We're reviewing your account details. You'll receive a notification once verification is complete.",
                fontSize: AppConstants.fourteen,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Timeline
              _buildTimelineStep(
                icon: Icons.check_circle,
                title: "Account Created",
                isCompleted: true,
                ref: ref,
              ),
              _buildTimelineConnector(),
              _buildTimelineStep(
                icon: Icons.hourglass_empty,
                title: "Verification Pending",
                isCompleted: false,
                ref: ref,
              ),
              _buildTimelineConnector(),
              _buildTimelineStep(
                icon: Icons.verified,
                title: "Ready to Add Properties",
                isCompleted: false,
                ref: ref,
              ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary(ref),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    text: "Okay, Got it!",
                    fontSize: AppConstants.sixteen,
                    fontType: FontType.semiBold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to support
                },
                child: AppText(
                  text: "Need Help? Contact Support",
                  fontSize: AppConstants.fourteen,
                  color: AppColors.secondary(ref),
                  fontType: FontType.medium,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required WidgetRef ref,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.secondary(ref)
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isCompleted ? Colors.white : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppText(
            text: title,
            fontSize: AppConstants.fourteen,
            fontType: isCompleted ? FontType.semiBold : FontType.regular,
            color: isCompleted ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  static Widget _buildTimelineConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Container(
        width: 2,
        height: 20,
        color: Colors.grey.shade300,
      ),
    );
  }
}

// ============================================================
// home_screen.dart - Updated Quick Actions
// ============================================================

// Replace the "Add Property" onTap with:
/*
"onTap": () {
  if (vendorVerify) {
    Navigator.pushNamed(context, AppRoutes.addRoom);
  } else {
    // Choose one of these two styles:

    // Option 1: Center Dialog with animation
    VerificationDialog.show(context, ref);

    // Option 2: Bottom Sheet with timeline
    // VerificationBottomSheet.show(context, ref);
  }
},
*/