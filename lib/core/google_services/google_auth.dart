import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/data/reset_data.dart';
import '../../features/auth/data/user_view.dart';
import '../../features/auth/view_model/auth_view_model.dart';
import '../routes/app_routes.dart';
import '../routes/navigator_key_provider.dart';

class GoogleUserState {
  final GoogleSignInAccount? user;
  final bool isLoading;
  final String? error;

  const GoogleUserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  GoogleUserState copyWith({
    GoogleSignInAccount? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return GoogleUserState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final googleSignInProvider =
StateNotifierProvider<GoogleSignInNotifier, GoogleUserState>((ref) {
  return GoogleSignInNotifier(ref);
});

class GoogleSignInNotifier extends StateNotifier<GoogleUserState> {
  final Ref ref;

  GoogleSignInNotifier(this.ref) : super(const GoogleUserState());

  // ✅ Firebase Console se ye values dalein (Optional for Android)
  String? clientId; // Web Client ID
  String? serverClientId; // Server Client ID

  static const List<String> scopes = <String>[
    'email',
    'profile',
  ];

  // ✅ Simple and Working Sign-In Method
  Future<void> signIn() async {
    try {
      print("🔵 Starting Google Sign-In...");
      state = state.copyWith(isLoading: true, error: null);

      // Get GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Initialize
      await googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );
      print("🟢 GoogleSignIn initialized");

      // Listen to authentication events
      final eventSubscription = googleSignIn.authenticationEvents.listen(
            (GoogleSignInAuthenticationEvent event) {
          _handleAuthenticationEvent(event);
        },
        onError: (error) {
          _handleAuthenticationError(error);
        },
      );

      // ✅ Attempt lightweight authentication (returns GoogleSignInAccount? not bool)
      print("🔵 Attempting lightweight authentication...");
      final GoogleSignInAccount? account =
      await googleSignIn.attemptLightweightAuthentication();

      if (account != null) {
        print("🟢 Lightweight auth successful: ${account.email}");
        state = state.copyWith(user: account, isLoading: false);
      } else {
        print("⚠️ Lightweight auth returned null - user needs to sign in manually");
        state = state.copyWith(isLoading: false);
      }

    } catch (e) {
      print("🔴 Google Sign-In Error: $e");
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        clearUser: true,
      );
    }
  }

  // ✅ Handle authentication events
  Future<void> _handleAuthenticationEvent(
      GoogleSignInAuthenticationEvent event) async {
    print("🟡 Authentication Event: ${event.runtimeType}");

    if (event is GoogleSignInAuthenticationEventSignIn) {
      final user = event.user;
      print("🟢 User signed in: ${user.email}");
      state = state.copyWith(user: user, isLoading: false);

      // Get authorization if needed
      try {
        final auth = await user.authorizationClient.authorizationForScopes(scopes);
        if (auth != null) {
          print("🟢 Authorization obtained");
        }
      } catch (e) {
        print("⚠️ Authorization error: $e");
      }
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      print("🔴 User signed out");
      state = state.copyWith(clearUser: true, isLoading: false);
    }
  }

  // ✅ Handle authentication errors
  Future<void> _handleAuthenticationError(Object e) async {
    print("🔴 Google Authentication Error: $e");
    state = state.copyWith(
      clearUser: true,
      isLoading: false,
      error: e.toString(),
    );
  }

  // ✅ Get current signed-in user
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

      final account = await googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        state = state.copyWith(user: account);
      }
      return account;
    } catch (e) {
      print("🔴 Get current user error: $e");
      return null;
    }
  }

  // ✅ Sign out
  Future<void> signOut() async {
    try {
      print("🔵 Starting logout...");
      state = state.copyWith(isLoading: true);

      await GoogleSignIn.instance.disconnect();
      print("🟢 Google Sign-out successful");

      final userView = ref.read(userViewModelProvider);
      final navigatorKey = ref.read(navigatorKeyProvider);

      await userView.clearAll();
      print("🟢 User local data cleared");

      resetAllFormFields(ref);
      print("🟢 Form fields reset");

      ref.invalidate(authViewModelProvider);
      print("🟢 Auth provider invalidated");

      navigatorKey.currentState?.pushReplacementNamed(AppRoutes.login);
      print("🟢 Navigation → Login screen");

      state = const GoogleUserState(user: null, isLoading: false);
      print("🟢 State updated → user=null");
    } catch (e) {
      print("🔴 Sign-out error: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ✅ Fetch Google Contacts (Optional)
  Future<void> fetchContacts(GoogleSignInAccount user) async {
    print("🔵 Fetching Google Contacts...");

    try {
      final contactScopes = ['https://www.googleapis.com/auth/contacts.readonly'];

      final auth = await user.authorizationClient.authorizationForScopes(contactScopes);
      if (auth == null) {
        print("🔴 Failed to get authorization for contacts");
        return;
      }

      final headers = await user.authorizationClient.authorizationHeaders(contactScopes);
      if (headers == null) {
        print("🔴 Failed to get headers");
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://people.googleapis.com/v1/people/me/connections'
              '?requestMask.includeField=person.names',
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print("🔴 Google People API Failed: ${response.statusCode}");
        return;
      }

      print("🟢 Contacts fetch success");
      final data = json.decode(response.body) as Map<String, dynamic>;
      _pickFirstNamedContact(data);
    } catch (e) {
      print("🔴 Contact fetch error: $e");
    }
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    print("🔵 Parsing first contact name...");
    final connections = data['connections'] as List?;
    final contact = connections?.firstWhere(
          (c) => c['names'] != null,
      orElse: () => null,
    );

    if (contact == null) {
      print("⚠️ No contact found");
      return null;
    }

    final names = contact['names'] as List;
    final name = names.firstWhere(
          (n) => n['displayName'] != null,
      orElse: () => null,
    );

    print("🟢 First contact name: ${name?['displayName']}");
    return name?['displayName'];
  }
}