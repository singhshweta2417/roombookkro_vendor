// ================= Field Type Enum =================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum FieldType {
  name(1),
  mobile(2),
  email(3),
  password(4),
  username(5),
  dob(6),
  dropdown(7),
  occupation(8),
  search(9),
  oldPassword(10),
  confirmPassword(11);

  final int code;
  const FieldType(this.code);
}

// ================= Validation State =================
class FieldState {
  final String value;
  final String? error;

  FieldState({this.value = "", this.error});

  FieldState copyWith({String? value, String? error}) {
    return FieldState(
      value: value ?? this.value,
      error: error,
    );
  }
}

// ================= Notifier =================
class FieldNotifier extends StateNotifier<FieldState> {
  final int status;
  final String countryCode;
  final Ref? ref;

  FieldNotifier({required this.status, this.countryCode = '+91', this.ref})
      : super(FieldState());

  void updateValue(String val) {
    String? error;

    switch (status) {
      case 1: // Name
        if (val.isEmpty) {
          error = "Name is required";
        } else if (!RegExp(r'^[A-Za-z ]+$').hasMatch(val)) {
          error = "Name should contain only letters";
        }
        break;

      case 2: // Mobile
        int requiredLen = (countryCode == '+91') ? 10 : 12;
        if (val.isEmpty) {
          error = "Mobile number is required";
        } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
          error = "Only digits allowed";
        } else if (val.length != requiredLen) {
          error = "Must be $requiredLen digits";
        }
        break;

      case 3: // Email
        final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (val.isEmpty) {
          error = "Email is required";
        } else if (!regex.hasMatch(val)) {
          error = "Invalid email format";
        }
        break;

      case 4: // Password
        bool hasMinLength = val.length >= 8;
        bool hasUpper = RegExp(r'[A-Z]').hasMatch(val);
        bool hasLower = RegExp(r'[a-z]').hasMatch(val);
        bool hasNumber = RegExp(r'\d').hasMatch(val);
        bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val);

        if (val.isEmpty) {
          error = "Password required";
        } else if (!hasMinLength ||
            !hasUpper ||
            !hasLower ||
            !hasNumber ||
            !hasSpecial) {
          error = "Weak password";
        }
        break;

      case 5: // Username
        if (val.isEmpty) {
          error = "Username required";
        } else if (val.length < 2) {
          error = "Too short";
        } else if (val.length > 30) {
          error = "Too long";
        } else if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(val)) {
          error = "Only letters, numbers, . and _ allowed";
        }
        break;

      case 6: // DOB
        if (val.isEmpty) {
          error = "Date of Birth required";
        } else {
          final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
          if (!regex.hasMatch(val)) {
            error = "Format must be dd/MM/yyyy";
          } else {
            try {
              final parts = val.split('/');
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final dob = DateTime(year, month, day);
              final now = DateTime.now();
              final age = now.year -
                  dob.year -
                  ((now.month < dob.month ||
                      (now.month == dob.month && now.day < dob.day))
                      ? 1
                      : 0);

              if (dob.isAfter(now)) {
                error = "DOB cannot be in future";
              } else if (age < 18) {
                error = "Must be at least 18 years old";
              } else if (age > 100) {
                error = "Invalid age";
              }
            } catch (_) {
              error = "Invalid date";
            }
          }
        }
        break;

      case 7: // Dropdown
        if (val.isEmpty) {
          error = "Please make a selection";
        }
        break;

      case 8: // Occupation
        if (val.isEmpty) {
          error = "Occupation is required";
        } else if (val.length < 2) {
          error = "Occupation too short";
        } else if (val.length > 50) {
          error = "Occupation too long";
        } else if (!RegExp(r'^[A-Za-z\s\-&]+$').hasMatch(val)) {
          error = "Only letters, spaces, hyphens, and & allowed";
        }
        break;

      case 10: // Old Password
        if (val.isEmpty) error = "Old password is required";
        break;

      case 11: // Confirm password
        if (val.isEmpty) {
          error = "Please confirm your password";
        } else if (ref != null) {
          final newPasswordState = ref!.read(newPasswordProvider);
          if (val != newPasswordState.value) {
            error = "Passwords do not match";
          }
        }
        break;
    }

    state = state.copyWith(value: val, error: error);
  }
  void validate(String value) {
    updateValue(value);
  }


  void reset() => state = FieldState(value: "", error: null);
}

// ================= Providers =================
final nameFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 1, ref: ref);
});
final mobileFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 2, countryCode: '+91', ref: ref);
});
final emailFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 3, ref: ref);
});
final passwordFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 4, ref: ref);
});
final usernameFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 5, ref: ref);
});
final dobFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 6, ref: ref);
});
final genderDropdownProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 7, ref: ref);
});
final occupationFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 8, ref: ref);
});
final searchFieldProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 9, ref: ref);
});
final oldPasswordProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 10, ref: ref);
});
final newPasswordProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 4, ref: ref);
});
final confirmPasswordProvider =
StateNotifierProvider<FieldNotifier, FieldState>((ref) {
  return FieldNotifier(status: 11, ref: ref);
});