import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

final themeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.light; // default
});

final appThemeProvider = Provider<AppTheme>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == AppThemeMode.light ? lightTheme : darkTheme;
});

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository(ref);
});

class ThemeRepository {
  final Ref ref;
  ThemeRepository(this.ref);

  static const _themeKey = "selectedTheme";

  Future<void> saveTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == AppThemeMode.light ? 'light' : 'dark',
    );
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    if (saved != null) {
      final mode = saved == 'light' ? AppThemeMode.light : AppThemeMode.dark;
      ref.read(themeModeProvider.notifier).state = mode;
    }
  }
}


/////////******** Call it like this *********///////
// ElevatedButton(
// style: ElevatedButton.styleFrom(
// backgroundColor: AppColors.secondary(ref),
// ),
// onPressed: () {
// // Theme toggle
// final theme = ref.read(themeModeProvider.notifier);
// theme.state = theme.state == AppThemeMode.light
// ? AppThemeMode.dark
//     : AppThemeMode.light;
// },
// child: Text(
// "Toggle Theme",
// style: TextStyle(color: AppColors.text(ref)),
// ),
// ),