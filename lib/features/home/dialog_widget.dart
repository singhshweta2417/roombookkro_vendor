import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/features/bottom/bottom_screen.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/primary_button.dart';

const Color _primaryGreen = Color(0xFF38C172);

class PaymentSuccessDialog extends ConsumerWidget {
  final String message;
  const PaymentSuccessDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 120),
                painter: const DotBackgroundPainter(),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: _primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const AppText(
            text: 'Congratulations!',
            color: _primaryGreen,
            fontSize: 24,
            fontType: FontType.bold,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: AppText(
              text: message,
              textAlign: TextAlign.center,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            onTap: () {
              ref.read(bottomNavProvider.notifier).setIndex(1);
              // Navigator.pushNamedAndRemoveUntil(
              //   context,
              //   AppRoutes.bottomNavigationPage,
              //       (route) => false,
              // );
            },
            label: "Continue",
          ),
        ],
      ),
    );
  }
}

class DotBackgroundPainter extends CustomPainter {
  const DotBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primaryGreen.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 3, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 3, paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.9), 3, paint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.85), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
