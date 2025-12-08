import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final userViewModelProvider = Provider<UserView>((ref) {
  return UserView(ref);
});

class UserView {
  final Ref _ref;

  UserView(this._ref);

  static const _tokenKey = "authToken";
  static const _userIdKey = "userId";
  static const _userTypeKey = "userType"; // ✅ NEW

  // Helper method to get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await _ref.read(sharedPreferencesProvider.future);
  }

  // ------------------- Token -------------------
  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_tokenKey, token);
    print('Token saved: $token');
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    final token = prefs.getString(_tokenKey);
    print('Retrieved token: $token');
    return token;
  }

  Future<void> clearToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
    print('Token cleared');
  }

  // ------------------- UserId -------------------
  Future<void> saveUserId(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userIdKey, userId);
    print('User ID saved: $userId');
  }

  Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    final userId = prefs.getString(_userIdKey);
    print('Retrieved user ID: $userId');
    return userId;
  }

  Future<void> clearUserId() async {
    final prefs = await _getPrefs();
    await prefs.remove(_userIdKey);
    print('User ID cleared');
  }
  Future<void> saveUserName(String name) async {
    final prefs = await _getPrefs();
    await prefs.setString("userName", name);
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await _getPrefs();
    await prefs.setString("userEmail", email);
  }

  Future<void> saveUserImage(String image) async {
    final prefs = await _getPrefs();
    await prefs.setString("userImage", image);
  }

  // ------------------- UserType (NEW) -------------------
  Future<void> saveUserType(String userType) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userTypeKey, userType);
    print('User Type saved: $userType');
  }

  Future<String?> getUserType() async {
    final prefs = await _getPrefs();
    final userType = prefs.getString(_userTypeKey);
    print('Retrieved user Type: $userType');
    return userType;
  }

  Future<void> clearUserType() async {
    final prefs = await _getPrefs();
    await prefs.remove(_userTypeKey);
    print('User Type cleared');
  }

  // ------------------- Checks -------------------
  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      final hasToken = token != null && token.isNotEmpty;
      print('Has token: $hasToken');
      return hasToken;
    } catch (e) {
      print('Error checking token: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final hasValidToken = await hasToken();
      final userId = await getUserId();
      final userType = await getUserType();
      final isLoggedIn = hasValidToken && userId != null && userId.isNotEmpty&&userType!="";
      print('Is logged in: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Clear all user data (logout)
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTypeKey);
    print('All user data cleared');
  }
}
