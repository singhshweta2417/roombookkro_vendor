import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/home/repo/offer_repo.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/utils/utils.dart';
import '../auth/data/user_view.dart';

class CreateOfferViewModel extends StateNotifier<CreateOfferState> {
  final CreateCouponRepository _profileRepo;
  final Ref ref;

  CreateOfferViewModel(this._profileRepo, this.ref)
    : super(const CreateOfferInitial());

  /// ---- Update Profile API ----
  Future<void> createCouponApi({
    dynamic couponType,
    dynamic type,
    dynamic value,
    dynamic minOrderAmount,
    dynamic description,
    dynamic maxUses,
    dynamic residentId,
    context,
  }) async {
    final userPref = ref.read(userViewModelProvider);
    final userID = await userPref.getUserId();
    state = const CreateOfferLoading();
    final data = {
      "couponType": couponType,
      "type": type,
      "value": value,
      "minOrderAmount": minOrderAmount,
      "createdBy": userID,
      "createdByType": "1",
      "description": description,
      "residentId": residentId,
      "maxUses": maxUses,
    };
    try {
      final response = await _profileRepo.createCouponApi(data);
      if (response["status"] == true) {
        state = CreateOfferSuccess(
          message: response["msg"] ?? "Profile updated successfully",
        );
        Utils.show(response["msg"].toString(), context);
        Future.delayed(Duration(milliseconds: 100), () {
          if (context != null && Navigator.canPop(context)) {
            Navigator.pop(context!);
          }
        });
      } else {
        state = CreateOfferError(response["msg"] ?? "Something went wrong");
        Utils.show(response["msg"].toString(), context);
      }
    } on BadRequestException {
      state = CreateOfferError("No Changes Detected");
      Utils.show("No Changes Detected", context);
    } catch (error) {
      state = CreateOfferError(error.toString());
    }
  }
}

/// ---- Auth States ----
abstract class CreateOfferState {
  final bool isLoading;
  const CreateOfferState({this.isLoading = false});
}

class CreateOfferInitial extends CreateOfferState {
  const CreateOfferInitial() : super(isLoading: false);
}

class CreateOfferSuccess extends CreateOfferState {
  final String message;
  const CreateOfferSuccess({required this.message}) : super(isLoading: false);
}

class CreateOfferError extends CreateOfferState {
  final String error;
  const CreateOfferError(this.error) : super(isLoading: false);
}

class CreateOfferLoading extends CreateOfferState {
  const CreateOfferLoading() : super(isLoading: true);
}

/// ---- Provider ----
final createProvider =
    StateNotifierProvider<CreateOfferViewModel, CreateOfferState>((ref) {
      final offerRepo = ref.read(createCouponProvider);
      return CreateOfferViewModel(offerRepo, ref);
    });
