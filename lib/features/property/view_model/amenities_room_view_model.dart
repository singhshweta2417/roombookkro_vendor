import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/model/amenities_model.dart';
import '../repo/amenities_room_repo.dart';

/// ViewModel for handling Room Amenities List
class AmenitiesRoomViewModel extends StateNotifier<GetAmenitiesRoomState> {
  final AmenitiesRoomRepository _getPropertyRepo;
  final Ref ref;

  AmenitiesRoomViewModel(this._getPropertyRepo, this.ref)
      : super(const GetAmenitiesRoomInitial());

  Future<void> getAmenitiesRoomViewApi() async {
    try {
      state = const GetAmenitiesRoomLoading();
      final response = await _getPropertyRepo.getAmenitiesRoomViewApi();
      state = GetAmenitiesRoomSuccess(
        amenitiesRoomLists: response,
        message: 'Room facilities loaded successfully',
      );
    } catch (error) {
      state = GetAmenitiesRoomError(error.toString());
    }
  }
}

/// STATE CLASSES
abstract class GetAmenitiesRoomState {
  const GetAmenitiesRoomState();
}

class GetAmenitiesRoomInitial extends GetAmenitiesRoomState {
  const GetAmenitiesRoomInitial();
}

class GetAmenitiesRoomLoading extends GetAmenitiesRoomState {
  const GetAmenitiesRoomLoading();
}

class GetAmenitiesRoomSuccess extends GetAmenitiesRoomState {
  final AmenitiesModel amenitiesRoomLists;
  final String message;

  const GetAmenitiesRoomSuccess({
    required this.amenitiesRoomLists,
    required this.message,
  });
}

class GetAmenitiesRoomError extends GetAmenitiesRoomState {
  final String error;

  const GetAmenitiesRoomError(this.error);
}

/// PROVIDER
final getAmenitiesRoomProvider = StateNotifierProvider<
    AmenitiesRoomViewModel,
    GetAmenitiesRoomState>((ref) {
  final repo = ref.read(getAmenitiesRoom);
  return AmenitiesRoomViewModel(repo, ref);
});

