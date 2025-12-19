import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/utils/utils.dart';
import '../../auth/data/user_view.dart';
import '../../auth/model/profile_model.dart';
import '../repo/profile_repo.dart';

class ProfileViewModel extends StateNotifier<AuthState> {
  final ProfileRepository _profileRepo;
  final Ref ref;

  ProfileViewModel(this._profileRepo, this.ref) : super(const AuthInitial());

  /// ---- Update Profile API ----
  Future<void> profileUpdateApi({
    String? name,
    String? mail,
    String? contact,
    String? dob,
    String? userImage,
    String? gender,
    String? walletBalance,
    context
  }) async {
    state = const AuthLoading();
    final data = {
      "name": name,
      "email": mail,
      "phone": contact,
      "DOB":dob,
      "userImage": userImage,
      "gender": gender,
      "walletBalance":walletBalance
    };
    try {
      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      final response = await _profileRepo.profileUpdateApi(userID, data);
      if (response["status"] == 200) {
        state = ProfileSuccess(
          message: response["message"] ?? "Profile updated successfully",
        );
        Utils.show(response["message"].toString(), context);
        Future.delayed(Duration(milliseconds: 100), () {
          if (context != null && Navigator.canPop(context)) {
            Navigator.pop(context!);
          }
        });
      } else {
        state = AuthError(response["message"] ?? "Something went wrong");
        Utils.show(response["message"].toString(), context);
      }
    } on BadRequestException {
      state = AuthError("No Changes Detected");
      Utils.show("No Changes Detected", context);
    } catch (error) {
      state = AuthError(error.toString());
    }
  }

  /// ---- View Profile API ----
  Future<void> profileViewApi(context) async {
    state = const AuthLoading();
    try {
      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      if (userID == null || userID.isEmpty) {
        state = const AuthError("User ID not found. Please log in again.");
        return;
      }
      // Call API
      final response = await _profileRepo.profileViewApi(userID);
      if (response.status == 200) {
        final profileData = response.profile;
        state = ProfileSuccess(
          message: response.message ?? "Profile fetched successfully",
          profile: profileData,
        );
      } else {
        state = AuthError(response.message ?? "Something went wrong");
      }
    } catch (error) {
      state = AuthError(error.toString());
    }
  }

}

/// ---- Auth States ----
abstract class AuthState {
  final bool isLoading;
  const AuthState({this.isLoading = false});
}

class AuthInitial extends AuthState {
  const AuthInitial() : super(isLoading: false);
}

class ProfileSuccess extends AuthState {
  final String message;
  final Profile? profile;
  const ProfileSuccess({required this.message, this.profile})
      : super(isLoading: false);
}


class AuthError extends AuthState {
  final String error;
  const AuthError(this.error) : super(isLoading: false);
}

class AuthLoading extends AuthState {
  const AuthLoading() : super(isLoading: true);
}

/// ---- Provider ----
final updateProvider = StateNotifierProvider<ProfileViewModel, AuthState>((ref) {
  final profileRepo = ref.read(profileUpdateProvider);
  return ProfileViewModel(profileRepo, ref);
});
