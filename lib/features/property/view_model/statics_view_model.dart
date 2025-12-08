import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/data/user_view.dart';
import '../../auth/model/statics_model.dart';
import '../../auth/repo/statics_repo.dart';

class StaticsViewModel extends StateNotifier<StaticsState> {
  final StaticsRepository _staticsRepo;
  final Ref ref;

  StaticsViewModel(this._staticsRepo, this.ref) : super(const StaticsInitial());

  /// ---- View statics API ----
  Future<void> staticsApi(context) async {
    state = const StaticsLoading();
    try {
      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      if (userID == null || userID.isEmpty) {
        state = const StaticsError("User ID not found. Please log in again.");
        return;
      }
      // Call API
      final response = await _staticsRepo.staticsApi(userID);
      if (response.status == 200) {
        final staticsData = response;
        state = StaticsSuccess(
          statics: staticsData,
        );
      }
    } catch (error) {
      state = StaticsError(error.toString());
    }
  }
}

/// ---- Statics States ----
abstract class StaticsState {
  final bool isLoading;
  const StaticsState({this.isLoading = false});
}

class StaticsInitial extends StaticsState {
  const StaticsInitial() : super(isLoading: false);
}

class StaticsSuccess extends StaticsState {
  final StaticsModel? statics;
  const StaticsSuccess({this.statics})
    : super(isLoading: false);
}

class StaticsError extends StaticsState {
  final String error;
  const StaticsError(this.error) : super(isLoading: false);
}

class StaticsLoading extends StaticsState {
  const StaticsLoading() : super(isLoading: true);
}

/// ---- Provider ----
final staticsVMProvider = StateNotifierProvider<StaticsViewModel, StaticsState>((
  ref,
) {
  final staticsRepo = ref.read(staticsProvider);
  return StaticsViewModel(staticsRepo, ref);
});
