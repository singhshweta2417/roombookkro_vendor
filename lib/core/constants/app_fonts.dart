import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FontType { regular, medium, semiBold, bold, black }

final fontProvider = Provider<Map<FontType, TextStyle>>((ref) {
  const String fontFamily = "Urbanist";
  return {
    FontType.regular: const TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
    ),
    FontType.medium: const TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    ),
    FontType.semiBold: const TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    ),
    FontType.bold: const TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
    ),
    FontType.black: const TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w900,
    ),
  };
});
///////*****See the app text once ******/////
//AppText(
//             text: title,
//             fontType: FontType.bold,
//             fontSize: 18,
//             color: Colors.white,
//           ),