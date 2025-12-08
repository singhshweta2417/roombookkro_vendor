import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/auth/view_model/auth_view_model.dart';
import 'package:room_book_kro_vendor/features/auth/view_model/otp_view_model.dart';
import '../../core/widgets/app_text.dart';


class OTPFields extends ConsumerStatefulWidget {
  const OTPFields({super.key});

  @override
  ConsumerState<OTPFields> createState() => _OTPFieldsState();
}

class _OTPFieldsState extends ConsumerState<OTPFields> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
        (_) => TextEditingController(),
  );
  bool isOtpVerified = false;
  bool _isOtpSubmitted = false;

  String? phone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (phone == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      phone = args?['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _handlePaste(String text) {
    if (text.length == 4) {
      for (int i = 0; i < 4; i++) {
        _controllers[i].text = text[i];
        ref.read(otpProvider.notifier).updateField(i, text[i]);
      }
      _focusNodes[3].requestFocus();
      _onCompleted();
    }
  }


  void _onCompleted() async {
    if (_isOtpSubmitted) return;
    _isOtpSubmitted = true;

    final otp = _controllers.map((c) => c.text).join();

    if (phone != null) {
      debugPrint("Calling verifyOtpApi for phone: $phone, OTP: $otp");
      try {
        final response = await ref
            .read(otpRepoProvider.notifier)
            .verifyOtpApi(context, phone!, otp);

        // ✅ Check if OTP verified successfully
        if (response["error"] == "200") {
          setState(() {
            isOtpVerified = true; // Enable button
          });
        } else {
          setState(() {
            isOtpVerified = false; // Keep disabled
          });
        }

        debugPrint("OTP API called successfully");
      } catch (e) {
        debugPrint("Error calling OTP API: $e");
        _isOtpSubmitted = false;
        setState(() {
          isOtpVerified = false;
        });
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    ref.watch(otpProvider);
    final authState = ref.watch(authViewModelProvider);
    return CustomScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: context.sh * 0.05),
          AppText(
            text: "Enter your OTP",
            fontType: FontType.bold,
            fontSize: AppConstants.thirty,
          ),
          SizedBox(height: context.sh * 0.002),
          AppText(
            text: "Verify Your OTP Here",
            fontType: FontType.medium,
            fontSize: AppConstants.eighteen,
          ),
          SizedBox(height: context.sh * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return TCustomContainer(
                width: 60,
                child: TextField(
                  controller: _controllers[index],
                  autofocus: index == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  focusNode: _focusNodes[index],
                  cursorColor: AppColors.secondary(ref),
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.secondary(ref)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.secondary(ref)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.secondary(ref)),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.length > 1) {
                      _handlePaste(val);
                      return;
                    }

                    ref.read(otpProvider.notifier).updateField(index, val);

                    if (val.isNotEmpty && index < 3) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }

                    final currentOtp = ref.read(otpProvider).join();
                    if (!currentOtp.contains("") && currentOtp.length == 4) {
                      _onCompleted();
                      print("jdbvjdsb");
                    }
                  },
                  onSubmitted: (_) {
                    if (index == 3) _onCompleted();
                  },
                ),
              );
            }),
          ),
          SizedBox(height: context.sh * 0.08),
      PrimaryButton(
        isLoading: authState.isLoading,
        color: AppColors.secondary(ref).withValues(alpha: isOtpVerified ? 1 : 0.5),
        width: context.sw,
        label: "Continue",
        onTap: () async {
          if (!isOtpVerified) return;
          if (_controllers.isNotEmpty &&
              !_controllers.any((c) => c.text.isEmpty)) {
            final phone = this.phone ?? '';
            await ref.read(authViewModelProvider.notifier).signUpApi(
              actionType: "login",
              phone: phone,
              context: context
            );
          } else {
            await ref
                .read(authViewModelProvider.notifier)
                .signUpApi(actionType: "guest",context: context);
          }
        },
      )
      ],
      ),
    );
  }
}

final otpProvider = StateNotifierProvider<OTPNotifier, List<String>>((ref) {
  return OTPNotifier();
});

class OTPNotifier extends StateNotifier<List<String>> {
  OTPNotifier() : super(List.filled(4, ""));

  void updateField(int index, String value) {
    final newList = [...state];
    newList[index] = value;
    state = newList;
  }
}
