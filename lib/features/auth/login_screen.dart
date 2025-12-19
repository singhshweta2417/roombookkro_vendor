import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/auth/view_model/otp_view_model.dart';
import '../../core/google_services/google_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_container.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../generated/assets.dart';
import '../../../core/widgets/custom_text_field/text_field_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  bool rememberMe = false;
  bool obscure = true;
  TextEditingController phoneCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpRepoProvider);
    final googleState = ref.watch(googleAuthProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showLogoutDialog(context, ref);
          if (shouldPop == true) {
            Navigator.of(context).pop();
          }
        }
      },
      child: CustomScaffold(
        padding: EdgeInsets.symmetric(horizontal: context.sw * 0.04),
        child: ListView(
          shrinkWrap: true,
          children: [
            TCustomContainer(
              margin: EdgeInsets.symmetric(vertical: context.sh * 0.03),
              height: context.sh * 0.15,
              width: context.sh * 0.15,
              lightColor: AppColors.secondary(ref),
              shape: BoxShape.circle,
              backgroundImage: const DecorationImage(
                image: AssetImage(Assets.imagesExcitedWomen),
              ),
            ),
            AppText(
              textAlign: TextAlign.center,
              text: "Login to Your Account",
              fontType: FontType.semiBold,
              fontSize: AppConstants.thirty,
            ),
            SizedBox(height: context.sh * 0.03),
            CustomTextField(
              fieldType: FieldType.mobile,
              controller: phoneCont,
              keyboardType: TextInputType.phone,
              hintText: "Enter your phone",
              onChanged: (val) {
                print("Phone: $val");
              },
              labelFontType: FontType.regular,
              maxLength: 10,
            ),
            SizedBox(height: context.sh * 0.02),
            PrimaryButton(
              isLoading: otpState.isLoading,
              onTap: () async {
                if (phoneCont.text.isNotEmpty && phoneCont.text.length == 10) {
                  await ref
                      .read(otpRepoProvider.notifier)
                      .sentOtpApi(context, phoneCont.text.toString());
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AppText(
                        text: 'Please enter correct number',
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
              width: context.sw,
              borderRadius: BorderRadius.circular(30),
              label: "Sent Otp",
            ),
            SizedBox(height: context.sh * 0.02),
            AppText(
              textAlign: TextAlign.center,
              text: "or continue with",
              fontType: FontType.semiBold,
              fontSize: AppConstants.twenty,
              color: AppColors.text(ref),
            ),
            SizedBox(height: context.sh * 0.01),
            InkWell(
              onTap: googleState.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(googleAuthProvider.notifier)
                          .signInWithGoogle(context);
                    },
              child: TCustomContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sw * 0.015,
                  vertical: context.sh * 0.015,
                ),
                border: Border.all(color: AppColors.borderColor(ref), width: 2),
                height: context.sh * 0.07,
                shape: BoxShape.circle,
                lightColor: googleState.isLoading
                    ? Colors.grey.shade200
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: googleState.isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary(ref),
                          ),
                        ),
                      )
                    : Image.asset(Assets.iconGoogleIcon),
              ),
            ),
            SizedBox(height: context.sh * 0.01),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.registerScreen);
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    color: AppColors.text(ref),
                    fontSize: AppConstants.sixteen,
                  ),
                  children: [
                    TextSpan(
                      text: " Sign Up",
                      style: TextStyle(
                        fontFamily: "Urbanist",
                        color: AppColors.secondary(ref),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.sh * 0.01),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _showLogoutDialog(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<bool>(
    backgroundColor: AppColors.background(ref),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return TCustomContainer(
        lightColor: AppColors.background(ref),
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.sh * 0.02),
            AppText(
              text: "Want to Exit?",
              fontSize: 20,
              color: Colors.red,
              fontType: FontType.bold,
            ),
            const SizedBox(height: 15),
            AppText(
              text: "Are you sure you want to Exit?",
              fontSize: 16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onTap: () => Navigator.pop(context, false),
                    color: Colors.transparent,
                    border: Border.all(color: AppColors.secondary(ref)),
                    label: "Cancel",
                    textColor: AppColors.secondary(ref),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: PrimaryButton(
                    onTap: () async {
                      SystemNavigator.pop();
                    },
                    label: "Yes, Exit",
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sh * 0.03),
          ],
        ),
      );
    },
  );
}
