import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/google_services/firebase_notifications.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/navigator_key_provider.dart';
import '../../../core/utils/utils.dart';
import '../data/user_view.dart';
import '../repo/auth_repo.dart';

/// --------------------
/// Auth ViewModel
/// --------------------
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final Ref ref;

  AuthViewModel(this._authRepo, this.ref) : super(const AuthInitial());
  String extractMessage(dynamic msg) {
    try {
      if (msg is String && msg.contains("{")) {
        final decoded = jsonDecode(msg);
        return decoded["message"].toString();
      }
      return msg.toString();
    } catch (_) {
      return msg.toString();
    }
  }

  /// SignUp & Login
  Future<void> signUpApi({
    required String actionType,
    String? name,
    String? mail,
    String? password,
    String? phone,
    String? date,
    context
  }) async {
    state = const AuthLoading();
    final fcmToken = await ref.read(notificationServiceProvider).getDeviceToken();
    final Map<String, dynamic> data = {
      "action": actionType,
      "name": name,
      "email": mail,
      "password": password,
      "user_type": "1",
      "phone": phone,
      "DOB": date,
      "fcmToken": fcmToken,
    };
    try {
      // Print debug logs only in debug mode
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        print("Request Data: $data");
      }
      final value = await _authRepo.signUpApi(data);

      if (value.status == 200) {
        final userPref = ref.read(userViewModelProvider);
        await userPref.saveToken(value.loginToken ?? '');
        await userPref.saveUserId(value.user?.userId?.toString() ?? '');
        await userPref.saveUserType(value.user?.userType ?? '');
        final navigatorKey = ref.read(navigatorKeyProvider);
        state = AuthSuccess(
          message: value.message ?? 'Login successful',
          userId: value.user?.userId?.toString() ?? '',
          userType: value.user?.userType ?? '',
        );
        Utils.show(value.message.toString(), context);
        Future.delayed(const Duration(milliseconds: 300), () {
          final currentState = navigatorKey.currentState;
          if (currentState != null) {
            currentState.pushNamed(
              AppRoutes.bottomNavigationPage,
            );
          }
        });
      } else {
        Utils.show(value.message.toString(), context);
        state = AuthError(value.message ?? "Unknown error occurred");
      }
    } on FetchNotFoundException catch (e) {
      final navigatorKey = ref.read(navigatorKeyProvider);
      Future.delayed(const Duration(milliseconds: 300), () {
        final currentState = navigatorKey.currentState;
        if (currentState != null) {
          currentState.pushNamed(
            AppRoutes.registerScreen,
            arguments: {"email": mail, "name": name, "phone": phone},
          );
        }
      });
      state = AuthError(e.message.toString());
      Utils.show(e.message.toString(), context);
    }
    on BadRequestException catch (e)
    {
      state = AuthError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);
    } on UnauthorisedException catch (e) {
      state = AuthError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);
    } on ServerException catch (e) {
      state = AuthError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);
    } on FetchDataException catch (e) {
      state = AuthError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);
    } catch (e) {
      Utils.show(e.toString(), context);
      state = AuthError("Unexpected error: $e");
    }
  }
}

/// --------------------
/// Auth States
/// --------------------
abstract class AuthState {
  final bool isLoading;
  const AuthState({this.isLoading = false});
}

class AuthInitial extends AuthState {
  const AuthInitial() : super(isLoading: false);
}

class AuthLoading extends AuthState {
  const AuthLoading() : super(isLoading: true);
}

class AuthSuccess extends AuthState {
  final String message;
  final String userId;
  final String? userType;

  const AuthSuccess({
    required this.message,
    required this.userId,
    this.userType,
  }) : super(isLoading: false);
}

class AuthError extends AuthState {
  final String error;
  const AuthError(this.error) : super(isLoading: false);
}

/// --------------------
/// Auth Provider
/// --------------------
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final authRepo = ref.read(authRepositoryProvider);
  return AuthViewModel(authRepo, ref);
});
