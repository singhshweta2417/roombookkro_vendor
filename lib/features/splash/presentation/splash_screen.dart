import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/navigator_key_provider.dart';
import '../../../generated/assets.dart';
import '../view_model/splash_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final String slogan = "Find a Room, Feel at Home.";
  String displayedText = "";
  int charIndex = 0;
  Timer? _timer;
  bool _hasNavigated = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        ref.read(splashViewModelProvider.notifier).initialize();
      }
    });
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (charIndex < slogan.length) {
        if (mounted) {
          setState(() {
            displayedText += slogan[charIndex];
            charIndex++;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToNextScreen(String route) {
    if (_hasNavigated || _isDisposed || !mounted) return;

    _hasNavigated = true;

    // Cancel typing animation before navigation
    _timer?.cancel();

    // Use a slight delay to ensure smooth transition
    Future.microtask(() {
      if (mounted) {
        final navigator = ref.read(navigatorKeyProvider).currentState;
        navigator?.pushReplacementNamed(route);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashViewModelProvider, (prev, next) {
      if (next.isReady && next.nextRoute != null) {
        _navigateToNextScreen(next.nextRoute!);
      }

      // Optional: Handle errors
      if (next.error != null) {
        debugPrint('Splash error: ${next.error}');
      }
    });

    final splashState = ref.watch(splashViewModelProvider);

    return CustomScaffold(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sw * 0.05,
          vertical: context.sh * 0.03,
        ),
        height: context.sh,
        width: context.sw,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagesSplashBg),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "Welcome to",
              fontType: FontType.bold,
              fontSize: AppConstants.twentyFive,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            AppText(
              text: "RoomBookKaro! 👋",
              fontType: FontType.semiBold,
              fontSize: AppConstants.forty,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            // Ensure minimum height for text to prevent layout shifts
            SizedBox(
              height: 24,
              child: AppText(
                text: displayedText,
                fontType: FontType.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            if (splashState.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}