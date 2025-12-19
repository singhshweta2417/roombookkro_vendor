import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/model/get_enum_model.dart';
import '../repo/get_enum_repo.dart';

class GetPropertyTypeViewModel extends StateNotifier<GetPropertyTypeState> {
  final AddPropertyTypeRepository _getPropertyTypeRepo;
  final Ref ref;

  GetPropertyTypeViewModel(this._getPropertyTypeRepo, this.ref)
    : super(const GetPropertyTypeInitial());

  Future<void> propertyTypeApi() async {
    try {
      state = const GetPropertyTypeLoading();
      final response = await _getPropertyTypeRepo.propertyTypeApi();

      if (response.status == true) {
        if (response.data?.propertyType != null) {
          state = GetPropertyTypeSuccess(
            propertyType: response,
            message: response.msg ?? 'Properties loaded successfully',
          );
        } else {
          state = const GetPropertyTypeError('No property types available');
        }
      } else {
        state = GetPropertyTypeError(
          response.msg ?? 'Failed to load properties',
        );
      }
    } catch (error) {
      state = GetPropertyTypeError(error.toString());
    }
  }
}

/// --------------------
/// STATE CLASSES
/// --------------------
abstract class GetPropertyTypeState {
  final bool isLoading;
  const GetPropertyTypeState({this.isLoading = false});
}

class GetPropertyTypeInitial extends GetPropertyTypeState {
  const GetPropertyTypeInitial() : super(isLoading: false);
}

class GetPropertyTypeLoading extends GetPropertyTypeState {
  const GetPropertyTypeLoading() : super(isLoading: true);
}

class GetPropertyTypeSuccess extends GetPropertyTypeState {
  final GetEnumModel propertyType;
  final String message;

  const GetPropertyTypeSuccess({
    required this.propertyType,
    required this.message,
  }) : super(isLoading: false);
}

class GetPropertyTypeError extends GetPropertyTypeState {
  final String error;

  const GetPropertyTypeError(this.error) : super(isLoading: false);
}

/// --------------------
/// PROVIDER
/// --------------------
final getPropertyTypeProvider =
    StateNotifierProvider<GetPropertyTypeViewModel, GetPropertyTypeState>((
      ref,
    ) {
      final repo = ref.read(propertyTypeRepoProvider);
      return GetPropertyTypeViewModel(repo, ref);
    });
