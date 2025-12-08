import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/data/user_view.dart';
import '../property_model.dart';
import '../repo/property_list_repo.dart';


/// ViewModel for handling Property List
class GetPropertyViewModel extends StateNotifier<GetPropertyState> {
  final GetPropertyRepository _getPropertyRepo;
  final Ref ref;

  GetPropertyViewModel(this._getPropertyRepo, this.ref)
      : super(const GetPropertyInitial());

  Future<void> getPropertyList() async {
    try {
      state = const GetPropertyLoading();

      final userPref = ref.read(userViewModelProvider);
      final userId = await userPref.getUserId();

      final response =
      await _getPropertyRepo.getPropertyViewApi(userId.toString());

      if (response.success == true) {
        state = GetPropertySuccess(
          propertyLists: response,
          message: 'Properties loaded successfully',
        );
      } else {
        state = const GetPropertyError('Failed to load properties');
      }
    } catch (error) {
      state = GetPropertyError(error.toString());
    }
  }
}

/// STATE CLASSES
abstract class GetPropertyState {
  const GetPropertyState();
}

class GetPropertyInitial extends GetPropertyState {
  const GetPropertyInitial();
}

class GetPropertyLoading extends GetPropertyState {
  const GetPropertyLoading();
}

class GetPropertySuccess extends GetPropertyState {
  final AddPropertyListModel propertyLists;
  final String message;

  const GetPropertySuccess({
    required this.propertyLists,
    required this.message,
  });
}

class GetPropertyError extends GetPropertyState {
  final String error;

  const GetPropertyError(this.error);
}

/// PROVIDER
final getPropertyProvider =
StateNotifierProvider<GetPropertyViewModel, GetPropertyState>((ref) {
  final repo = ref.read(getProperty); // repository provider
  return GetPropertyViewModel(repo, ref);
});


