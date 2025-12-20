import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/model/onboard_model.dart';
import '../data/onboard_repo.dart';

class OnBoardViewModel extends StateNotifier<OnboardState> {
  final OnboardRepository _onboardRepo;
  final Ref ref;

  OnBoardViewModel(this._onboardRepo, this.ref) : super(const OnboardInitial());

  Future<void> loadOnboardingData() async {
    // Prevent multiple simultaneous loads
    if (state is OnboardLoading) return;

    state = const OnboardLoading();

    try {
      final value = await _onboardRepo.onboardApi();

      if (mounted) {
        if (value.status == 200 && value.data != null) {
          state = OnboardSuccess(onboard: value.data!);
        } else {
          state = OnboardError(
            value.message ?? 'Failed to load onboarding data',
          );
        }
      }
    } catch (error) {
      if (mounted) {
        state = OnboardError(error.toString());
      }
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (e) {
      // Log error but don't throw - we still want to navigate
      debugPrint('Error saving onboarding status: $e');
    }
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
