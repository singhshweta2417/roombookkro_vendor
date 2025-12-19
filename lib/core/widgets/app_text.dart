import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import '../constants/app_fonts.dart';

class AppText extends ConsumerWidget {
  const AppText({
    super.key,
    required this.text,
    this.fontType = FontType.regular,
    this.fontSize,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration, // 👈 added
  });

  final String text;
  final FontType fontType;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration; // 👈 added new parameter

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fonts = ref.watch(fontProvider);
    final baseStyle = fonts[fontType]!;

    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: baseStyle.copyWith(
        fontSize: fontSize ?? AppConstants.sixteen,
        color: color ?? AppColors.text(ref),
        height: 0,
        decoration: decoration, // 👈 added here
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class AppConstants {
  static const double fortyFive = 45.0;
  static const double forty = 40.0;
  static const double thirty = 30.0;
  static const double thirtyFive = 35.0;
  static const double twentyFive = 25.0;
  static const double sixteen = 16.0;
  static const double fourteen = 14.0;
  static const double eighteen = 18.0;
  static const double twelve = 12.0;
  static const double thirteen = 13.0;
  static const double twenty = 20.0;
  static const double twentyTwo = 22.0;
}


///////*****Call it like this******/////
//AppText(
//             text: title,
//             fontType: FontType.bold,
//             fontSize: 18,
//             color: Colors.white,
//           ),