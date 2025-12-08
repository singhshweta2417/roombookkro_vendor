import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/model/amenities_model.dart';
import '../repo/aminities_property_repo.dart';

/// ViewModel for handling Property List
class AmenitiesPropertyViewModel
    extends StateNotifier<GetAmenitiesPropertyState> {
  final AmenitiesPropertyRepository _getPropertyRepo;
  final Ref ref;

  AmenitiesPropertyViewModel(this._getPropertyRepo, this.ref)
    : super(const GetAmenitiesPropertyInitial());

  Future<void> getAmenitiesPropertyViewApi() async {
    try {
      state = const GetAmenitiesPropertyLoading();
      final response = await _getPropertyRepo.getAmenitiesPropertyViewApi();
      state = GetAmenitiesPropertySuccess(
        amenitiesPropertyLists: response,
        message: 'Properties loaded successfully',
      );
    } catch (error) {
      state = GetAmenitiesPropertyError(error.toString());
    }
  }
}

/// STATE CLASSES
abstract class GetAmenitiesPropertyState {
  const GetAmenitiesPropertyState();
}

class GetAmenitiesPropertyInitial extends GetAmenitiesPropertyState {
  const GetAmenitiesPropertyInitial();
}

class GetAmenitiesPropertyLoading extends GetAmenitiesPropertyState {
  const GetAmenitiesPropertyLoading();
}

class GetAmenitiesPropertySuccess extends GetAmenitiesPropertyState {
  final AmenitiesModel amenitiesPropertyLists;
  final String message;

  const GetAmenitiesPropertySuccess({
    required this.amenitiesPropertyLists,
    required this.message,
  });
}

class GetAmenitiesPropertyError extends GetAmenitiesPropertyState {
  final String error;

  const GetAmenitiesPropertyError(this.error);
}

/// PROVIDER
final getAmenitiesPropertyProvider =
    StateNotifierProvider<
      AmenitiesPropertyViewModel,
      GetAmenitiesPropertyState
    >((ref) {
      final repo = ref.read(getAmenitiesProperty); // repository provider
      return AmenitiesPropertyViewModel(repo, ref);
    });
