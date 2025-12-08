import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/model/policy_model.dart';
import '../repo/policy_repo.dart';

class PolicyViewModel extends StateNotifier<PolicyState> {
  final PolicyRepository _policyRepo;
  final Ref ref;

  PolicyViewModel(this._policyRepo, this.ref) : super(const PolicyInitial());

  /// ---- View Policy API ----
  Future<void> policyApi(dynamic data) async {
    state = const PolicyLoading();
    try {
      final response = await _policyRepo.policyApi(data);

      if (response.status == 200) {
        final profileData = response.data;
        state = PolicySuccess(
          profile: profileData,
        );
      } else {
      }
    } catch (error, stackTrace) {
      print("❌ Policy View Error: $error");
      print("❌ StackTrace: $stackTrace");
      state = PolicyError(error.toString());
    }
  }
}

/// ---- Auth States ----
abstract class PolicyState {
  final bool isLoading;
  const PolicyState({this.isLoading = false});
}

class PolicyInitial extends PolicyState {
  const PolicyInitial() : super(isLoading: false);
}

class PolicySuccess extends PolicyState {
  final Data? profile;
  const PolicySuccess({this.profile})
      : super(isLoading: false);
}


class PolicyError extends PolicyState {
  final String error;
  const PolicyError(this.error) : super(isLoading: false);
}

class PolicyLoading extends PolicyState {
  const PolicyLoading() : super(isLoading: true);
}

/// ---- Provider ----
final policiesProvider = StateNotifierProvider<PolicyViewModel, PolicyState>((ref) {
  final policyRepo = ref.read(policyRepoProvider);
  return PolicyViewModel(policyRepo, ref);
});
