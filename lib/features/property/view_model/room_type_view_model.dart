import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/model/get_enum_model.dart';
import '../repo/get_room_type_repo.dart';

class RoomTypeViewModel extends StateNotifier<GetRoomTypeState> {
  final RoomTypeRepository _getPropertyTypeRepo;
  final Ref ref;

  RoomTypeViewModel(this._getPropertyTypeRepo, this.ref)
    : super(const GetRoomTypeInitial());

  Future<void> roomTypeApi(dynamic data) async {
    try {
      state = const GetRoomTypeLoading();
      final response = await _getPropertyTypeRepo.roomTypeApi(data);

      if (response.status == true) {
        if (response.data?.roomType != null) {
          state = GetRoomTypeSuccess(
            roomType: response.data!.roomType!,
            message: response.msg ?? 'Properties loaded successfully',
          );
        } else {
          state = const GetRoomTypeError('No property types available');
        }
      } else {
        state = GetRoomTypeError(
          response.msg ?? 'Failed to load properties',
        );
      }
    } catch (error) {
      state = GetRoomTypeError(error.toString());
    }
  }
}

/// --------------------
/// STATE CLASSES
/// --------------------
abstract class GetRoomTypeState {
  final bool isLoading;
  const GetRoomTypeState({this.isLoading = false});
}

class GetRoomTypeInitial extends GetRoomTypeState {
  const GetRoomTypeInitial() : super(isLoading: false);
}

class GetRoomTypeLoading extends GetRoomTypeState {
  const GetRoomTypeLoading() : super(isLoading: true);
}

class GetRoomTypeSuccess extends GetRoomTypeState {
  final RoomTypeData roomType;
  final String message;

  const GetRoomTypeSuccess({
    required this.roomType,
    required this.message,
  }) : super(isLoading: false);
}

class GetRoomTypeError extends GetRoomTypeState {
  final String error;

  const GetRoomTypeError(this.error) : super(isLoading: false);
}

/// --------------------
/// PROVIDER
/// --------------------
final getRoomTypeProvider =
    StateNotifierProvider<RoomTypeViewModel, GetRoomTypeState>((ref) {
      final repo = ref.read(roomTypeRepoProvider);
      return RoomTypeViewModel(repo, ref);
    });
