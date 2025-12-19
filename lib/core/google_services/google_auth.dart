import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/reset_data.dart';
import '../../features/auth/data/user_view.dart';
import '../../features/auth/view_model/auth_view_model.dart';
import '../routes/app_routes.dart';
import '../routes/navigator_key_provider.dart';

/// --- Provider Declaration ---
final googleAuthProvider =
    StateNotifierProvider<GoogleAuthNotifier, AsyncValue<UserCredential?>>(
      (ref) => GoogleAuthNotifier(ref),
    );

/// --- Google Auth Notifier ---
class GoogleAuthNotifier extends StateNotifier<AsyncValue<UserCredential?>> {
  final Ref ref;

  GoogleAuthNotifier(this.ref) : super(const AsyncValue.data(null));

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;

  /// Initialize Google Sign-In
  static Future<void> _initSignin() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            "943821563103-1f6qi2u4b6v178a8hq12iqpotgk1cbn6.apps.googleusercontent.com",
      );
      _isInitialized = true;
    }
  }

  /// --- Google Sign-In ---
  Future<void> signInWithGoogle(BuildContext context) async {
    state = const AsyncValue.loading();

    try {
      await _initSignin();
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: "NO_ID_TOKEN",
          message: "Failed to get ID token",
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;
      // Save user data
      final userView = ref.read(userViewModelProvider);
      await userView.saveUserId(user.uid);
      await userView.saveUserType("google");
      await userView.saveUserName(user.displayName ?? "");
      await userView.saveUserEmail(user.email ?? "");
      await userView.saveUserImage(user.photoURL ?? "");

      state = AsyncValue.data(userCredential);
      final authVM = ref.read(authViewModelProvider.notifier);
      await authVM.signUpApi(
        actionType: "login",
        mail: user.email,
        name: user.displayName,
        phone: user.phoneNumber,
        context: context,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// --- Google Sign-Out ---
  Future<void> signOut(ref) async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    final userView = ref.read(userViewModelProvider);
    final navigatorKey = ref.read(navigatorKeyProvider);
    await userView.clearAll();
    resetAllFormFields(ref);
    ref.invalidate(authViewModelProvider);
    state = const AsyncValue.data(null);
    navigatorKey.currentState?.pushReplacementNamed(AppRoutes.login);
  }
}
