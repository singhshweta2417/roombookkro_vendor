import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/user_view.dart';
import '../data/splash_repo.dart';

class SplashState {
  final bool isReady;
  final bool isLoading;
  final String? nextRoute;
  final String? error;

  SplashState({
    this.isReady = false,
    this.isLoading = false,
    this.nextRoute,
    this.error,
  });

  SplashState copyWith({
    bool? isReady,
    bool? isLoading,
    String? nextRoute,
    String? error,
  }) {
    return SplashState(
      isReady: isReady ?? this.isReady,
      isLoading: isLoading ?? this.isLoading,
      nextRoute: nextRoute ?? this.nextRoute,
      error: error ?? this.error,
    );
  }
}

class SplashViewModel extends StateNotifier<SplashState> {
  final SplashRepository repository;
  final Ref ref;

  SplashViewModel(this.repository, this.ref) : super(SplashState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Read the values here in the ViewModel, not in the repository
      final prefs = await SharedPreferences.getInstance();
      final isOnboardingDone = prefs.getBool('onboarding_completed') ?? false;

      final userPref = ref.read(userViewModelProvider);
      final isLoggedIn = await userPref.isLoggedIn();

      final route = await repository.getInitialRoute(
        isOnboardingDone,
        isLoggedIn,
      );

      state = state.copyWith(isReady: true, isLoading: false, nextRoute: route);
    } catch (error) {
      state = state.copyWith(
        isReady: true,
        isLoading: false,
        nextRoute: '/onboarding', // fallback route
        error: error.toString(),
      );
    }
  }
}

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashState>(
      (ref) => SplashViewModel(ref.read(splashRepositoryProvider), ref),
    );
