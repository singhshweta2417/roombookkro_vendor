import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/model/onboard_model.dart';
import '../data/onboard_repo.dart';

class OnBoardViewModel extends StateNotifier<OnboardState> {
  final OnboardRepository _onboardRepo;
  final Ref ref;

  OnBoardViewModel(this._onboardRepo, this.ref) : super(const OnboardInitial());

  Future<void> onboardApi() async {
    state = const OnboardLoading();
    try {
      final value = await _onboardRepo.onboardApi();

      if (value.status == 200) {
        state = OnboardSuccess(onboard: value.data ?? []);
      } else {
        state = OnboardError(value.message ?? 'Failed to load onboard data');
      }
    } catch (error) {
      state = OnboardError(error.toString());
    }
  }

  /// ✅ Save onboarding completion to SharedPreferences
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}

// --- STATES ---
abstract class OnboardState {
  const OnboardState();
}

class OnboardInitial extends OnboardState {
  const OnboardInitial();
}

class OnboardLoading extends OnboardState {
  const OnboardLoading();
}

class OnboardSuccess extends OnboardState {
  final List<Data> onboard;
  const OnboardSuccess({required this.onboard});
}

class OnboardError extends OnboardState {
  final String error;
  const OnboardError(this.error);
}

// --- PROVIDER ---
final onboardingProvider =
StateNotifierProvider<OnBoardViewModel, OnboardState>((ref) {
  final repo = ref.read(onboardRepoProvider);
  return OnBoardViewModel(repo, ref);
});
