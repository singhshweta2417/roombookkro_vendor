import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepository();
});

class SplashRepository {
  SplashRepository();

  Future<String> getInitialRoute(bool isOnboardingDone, bool isLoggedIn) async {
    await Future.delayed(const Duration(seconds: 2));

    print('🎯 Onboarding done: $isOnboardingDone');
    print('🚪 Is logged in: $isLoggedIn');

    // If user is logged in, go to home regardless of onboarding status
    if (isLoggedIn) {
      return '/bottomNavigationPage';
    }
    // If not logged in, check onboarding status
    else if (!isOnboardingDone) {
      return '/onboarding';
    } else {
      return '/login';
    }
  }
}