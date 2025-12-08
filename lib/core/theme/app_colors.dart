import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

class AppColors {
  static Color primary(WidgetRef ref) => ref.watch(appThemeProvider).primary;
  static Color secondary(WidgetRef ref) => ref.watch(appThemeProvider).secondary;
  static Color background(WidgetRef ref) => ref.watch(appThemeProvider).background;
  static Color borderColor(WidgetRef ref) => ref.watch(appThemeProvider).borderColor;
  static Color text(WidgetRef ref) => ref.watch(appThemeProvider).text;
  static Color greyText(WidgetRef ref) => ref.watch(appThemeProvider).greyText;
  static Color iconColor(WidgetRef ref) => ref.watch(appThemeProvider).iconColor;
  static Color textFieldBg(WidgetRef ref) => ref.watch(appThemeProvider).textFieldBg;
  static Color error(WidgetRef ref) => ref.watch(appThemeProvider).error;
  static Color pending(WidgetRef ref) => ref.watch(appThemeProvider).pending;
  static Color shimmerBase(WidgetRef ref) => ref.watch(appThemeProvider).shimmerBase;
  static Color shimmerHighLight(WidgetRef ref) => ref.watch(appThemeProvider).shimmerHighLight;
  static Color heartColor(WidgetRef ref) => ref.watch(appThemeProvider).heartColor;
}
