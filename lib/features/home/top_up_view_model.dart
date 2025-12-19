import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/model/top_up_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/top_up_repo.dart';


class TopUpViewModel extends StateNotifier<TopUpState> {
  final TopUpRepository _getTopUpRepo;
  final Ref ref;

  TopUpViewModel(this._getTopUpRepo, this.ref) : super(TopUpInitial());

  Future<void> topUpApi() async {
    state = TopUpLoading();
    try {
      final value = await _getTopUpRepo.topUpApi();

      if (value.status == true) {
        state = TopUpSuccess(
          topUpList: value.data!,
          message:value.msg!,
        );
      }
    } catch (error) {
      state = TopUpError(error.toString());
    }
  }
}

abstract class TopUpState {
  const TopUpState();
}

class TopUpInitial extends TopUpState {
  const TopUpInitial();
}

class TopUpSuccess extends TopUpState {
  final List<Data> topUpList;
  final String message;

  const TopUpSuccess({required this.topUpList, required this.message});
}

class TopUpError extends TopUpState {
  final String error;

  const TopUpError(this.error);
}

class TopUpLoading extends TopUpState {
  const TopUpLoading();
}

// Use the renamed repository provider
final getTopUpProvider = StateNotifierProvider<TopUpViewModel, TopUpState>((
    ref,
    ) {
  final getTopUpRepo = ref.read(topUpRepoProvider);
  return TopUpViewModel(getTopUpRepo, ref);
});
final selectedAmountProvider = StateProvider<Data?>((ref) => null);