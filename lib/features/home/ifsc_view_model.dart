import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/model/ifsc_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/ifsc_repo.dart';

class IfscViewModel extends StateNotifier<IfscState> {
  final IfscRepository _getIfscRepo;
  final Ref ref;

  IfscViewModel(this._getIfscRepo, this.ref) : super(IfscInitial());

  Future<void> ifscApi(dynamic ifsc) async {
    state = IfscLoading();
    final data = {"ifsc": ifsc};
    try {
      final value = await _getIfscRepo.ifscApi(data);

      if (value.status == true) {
        state = IfscSuccess(ifscList: value, message: value.message.toString());
      }
    } catch (error) {
      state = IfscError(error.toString());
    }
  }
}

abstract class IfscState {
  const IfscState();
}

class IfscInitial extends IfscState {
  const IfscInitial();
}

class IfscSuccess extends IfscState {
  final IfscModel ifscList;
  final String message;

  const IfscSuccess({required this.ifscList, required this.message});
}

class IfscError extends IfscState {
  final String error;

  const IfscError(this.error);
}

class IfscLoading extends IfscState {
  const IfscLoading();
}

// Use the renamed repository provider
final getIfscProvider = StateNotifierProvider<IfscViewModel, IfscState>((ref) {
  final getIfscRepo = ref.read(ifscProvider);
  return IfscViewModel(getIfscRepo, ref);
});
