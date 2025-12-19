import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ✅ Timer Variables
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes = 120 seconds
  bool _canResend = false;
  bool _isResending = false;

  // ✅ Check if all fields are filled
  bool get _allFieldsFilled => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (phone == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      phone = args?['phone'] ?? '';
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ✅ Start Timer Function - Fixed
  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 120;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  // ✅ Resend OTP Function
  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      for (var controller in _controllers) {
        controller.clear();
      }
      ref.read(otpProvider.notifier).reset();

      setState(() {
        isOtpVerified = false;
        _isOtpSubmitted = false;
      });

      // TODO: Call your resend OTP API here
      // await ref.read(authViewModelProvider.notifier).resendOtpApi(phone!);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("OTP sent successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _startTimer();
      _focusNodes[0].requestFocus();
    } catch (e) {
      debugPrint("Error resending OTP: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text("Failed to resend OTP"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handlePaste(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length >= 4) {
      for (int i = 0; i < 4; i++) {
        _controllers[i].text = digitsOnly[i];
        ref.read(otpProvider.notifier).updateField(i, digitsOnly[i]);
      }
      setState(() {});
      _focusNodes[3].requestFocus();

      Future.delayed(const Duration(milliseconds: 100), () {
        _onCompleted();
      });
    }
  }

  void _onCompleted() async {
    if (_isOtpSubmitted) {
      debugPrint("OTP already being submitted, skipping...");
      return;
    }

    final otp = _controllers.map((c) => c.text).join();
    final hasEmptyField = _controllers.any((c) => c.text.isEmpty);

    if (otp.length != 4 || hasEmptyField) {
      debugPrint("OTP incomplete: $otp");
      return;
    }

    if (_remainingSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.timer_off, color: Colors.white),
              SizedBox(width: 12),
              Text("OTP expired! Please request a new one."),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    _isOtpSubmitted = true;
    debugPrint("Starting OTP verification for phone: $phone, OTP: $otp");

    if (phone != null && phone!.isNotEmpty) {
      try {
        final response = await ref
            .read(otpRepoProvider.notifier)
            .verifyOtpApi(context, phone!, otp);

        debugPrint("OTP API Response: $response");

        if (response["error"] == "200") {
          setState(() {
            isOtpVerified = true;
          });
          // ✅ Timer यहाँ cancel नहीं करना है - यह continue button पर होगा
          debugPrint("✅ OTP verified successfully");
        } else {
          setState(() {
            isOtpVerified = false;
          });
          debugPrint("❌ OTP verification failed: ${response["error"]}");
        }
      } catch (e, stackTrace) {
        debugPrint("❌ Error calling OTP API: $e");
        debugPrint("Stack trace: $stackTrace");
        setState(() {
          isOtpVerified = false;
        });
      } finally {
        _isOtpSubmitted = false;
        debugPrint("OTP submission flag reset");
      }
    } else {
      debugPrint("❌ Phone number is null or empty");
      _isOtpSubmitted = false;
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
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (KeyEvent event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      // ✅ Fixed: If current field is empty, move to previous and clear it
                      if (_controllers[index].text.isEmpty && index > 0) {
                        Future.microtask(() {
                          _controllers[index - 1].clear();
                          ref
                              .read(otpProvider.notifier)
                              .updateField(index - 1, "");
                          _focusNodes[index - 1].requestFocus();
                          setState(() {});
                        });
                      }
                    }
                  },
                  child: TextField(
                    controller: _controllers[index],
                    autofocus: index == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    focusNode: _focusNodes[index],
                    cursorColor: AppColors.secondary(ref),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondary(ref)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondary(ref)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.secondary(ref),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      debugPrint("Field $index changed: '$val'");

                      // Handle paste
                      if (val.length > 1) {
                        debugPrint("Paste detected");
                        _handlePaste(val);
                        return;
                      }

                      // ✅ Handle backspace/delete
                      if (val.isEmpty) {
                        ref.read(otpProvider.notifier).updateField(index, "");
                        setState(() {});
                        // Don't auto-move on backspace, let RawKeyboardListener handle it
                        return;
                      }

                      // Handle digit entry
                      final digit = val.length > 1 ? val[val.length - 1] : val;

                      _controllers[index].text = digit;
                      _controllers[index].selection =
                          TextSelection.fromPosition(
                            TextPosition(offset: digit.length),
                          );

                      ref.read(otpProvider.notifier).updateField(index, digit);
                      setState(() {});

                      // ✅ Auto-move to next field
                      if (index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      } else {
                        // Last field - unfocus and check completion
                        FocusScope.of(context).unfocus();
                      }

                      // Check if all fields filled
                      Future.delayed(const Duration(milliseconds: 100), () {
                        final allFilled = _controllers.every(
                          (c) => c.text.isNotEmpty,
                        );
                        final currentOtp = _controllers
                            .map((c) => c.text)
                            .join();

                        debugPrint("All filled: $allFilled, OTP: $currentOtp");

                        if (allFilled && currentOtp.length == 4) {
                          debugPrint("🎯 Starting verification...");
                          _onCompleted();
                        }
                      });
                    },
                    onTap: () {
                      // ✅ Select all on tap for easy replacement
                      if (_controllers[index].text.isNotEmpty) {
                        _controllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _controllers[index].text.length,
                        );
                      }
                    },
                  ),
                ),
              );
            }),
          ),

          // Resend OTP Section
          SizedBox(height: context.sh * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: "Didn't receive OTP? ",
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              if (_isResending)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _canResend
                          ? AppColors.secondary(ref).withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _canResend
                            ? AppColors.secondary(ref)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: AppText(
                      text: _canResend
                          ? "Resend OTP"
                          : "Resend in ${_formatTime(_remainingSeconds)}",
                      fontSize: 14,
                      fontType: FontType.semiBold,
                      color: _canResend
                          ? AppColors.secondary(ref)
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.sh * 0.08),
          PrimaryButton(
            isLoading: authState.isLoading,
            color: AppColors.secondary(
              ref,
            ).withValues(alpha: (isOtpVerified && _allFieldsFilled) ? 1 : 0.5),
            width: context.sw,
            label: "Continue",
            onTap: () async {
              if (!isOtpVerified || !_allFieldsFilled) return;

              // ✅ यहाँ timer cancel करें
              _timer?.cancel();

              if (_controllers.isNotEmpty &&
                  !_controllers.any((c) => c.text.isEmpty)) {
                final phone = this.phone ?? '';
                await ref
                    .read(authViewModelProvider.notifier)
                    .signUpApi(
                      actionType: "login",
                      phone: phone,
                      context: context,
                    );
              } else {
                await ref
                    .read(authViewModelProvider.notifier)
                    .signUpApi(actionType: "guest", context: context);
              }
            },
          ),
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

  void reset() {
    state = List.filled(4, "");
  }
}
