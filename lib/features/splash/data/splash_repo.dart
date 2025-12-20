import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepository();
});

class SplashRepository {
  SplashRepository();

  String getInitialRoute(bool isOnboardingDone, bool isLoggedIn) {
    // Remove the artificial delay - handle timing in ViewModel instead

    // Decision tree for routing
    if (isLoggedIn) {
      return '/bottomNavigationPage';
    } else if (!isOnboardingDone) {
      return '/onboarding';
    } else {
      return '/login';
    }
  }
}