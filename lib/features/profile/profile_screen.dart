import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/features/profile/view_model/profile_view_model.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/google_services/google_auth.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../../core/widgets/custom_toggle.dart';
import '../../core/widgets/primary_button.dart';

// ===== Profile Screen =====
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == AppThemeMode.dark;
    final authState = ref.watch(updateProvider);
    final username = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.username
        : "User";
    final mail = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.email
        : "user@gmail.com";
    final userImage = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.userImage
        : "";
    return CustomScaffold(
      appBar: CustomAppBar(
        autoImplyLeading: false,
        middle: AppText(
          text: "Profile",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
      ),
      child: ListView(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userImage.toString(),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppText(text: username.toString(), fontSize: 18, fontType: FontType.bold),
              AppText(text:mail.toString(), color: Colors.grey),
              const SizedBox(height: 20),
            ],
          ),
          const Divider(),
          // ===== Menu Options =====
          _menuTile(ref, Icons.notifications_none, () {
            Navigator.pushNamed(context, AppRoutes.notificationScreen);
          }, "My Notification"),
          _menuTile(ref, Icons.wallet, () {
            Navigator.pushNamed(context, AppRoutes.walletScreen);
          }, "My Wallet"),
          _menuTile(ref, Icons.notifications_none, () {
            Navigator.pushNamed(context, AppRoutes.addBankAccountScreen);
          }, "Add Bank"),
          _menuTile(ref, Icons.person_outline, () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.personalProfileScreen);
          }, "Edit Profile"),
          Row(
            children: [
              Icon(Icons.brightness_4_outlined),
              SizedBox(width: context.sw * 0.045),
              AppText(
                text: "Dark Mode",
                fontType: FontType.bold,
                fontSize: AppConstants.eighteen,
              ),
              Spacer(),
              CustomSlidingToggleButton(
                initialValue: isDarkMode,
                activeColor: AppColors.secondary(ref),
                inactiveColor: Colors.grey,
                onToggle: (value) async {
                  final newMode = value
                      ? AppThemeMode.dark
                      : AppThemeMode.light;
                  ref.read(themeModeProvider.notifier).state = newMode;
                  await ref.read(themeRepositoryProvider).saveTheme(newMode);
                },
              ),
            ],
          ),
          _menuTile(ref, Icons.info_outline, () {
            Navigator.pushNamed(
              context,
              AppRoutes.policyScreen,
              arguments: {"id": "0", "title": "Help Center"},
            );
          }, "Help Center"),
          _menuTile(ref, Icons.lock_outline, () {
            Navigator.pushNamed(
              context,
              AppRoutes.policyScreen,
              arguments: {"id": "1", "title": "Privacy Policy"},
            );
          }, "Privacy Policy"),
          _menuTile(ref, Icons.info_outline, () {
            Navigator.pushNamed(
              context,
              AppRoutes.policyScreen,
              arguments: {"id": "2", "title": "Return Policy"},
            );
          }, "Return Policy"),
          _menuTile(ref, Icons.info_outline, () {
            Navigator.pushNamed(
              context,
              AppRoutes.policyScreen,
              arguments: {"id": "3", "title": "Terms&Conditions"},
            );
          }, "Terms&Conditions"),
          _menuTile(ref, Icons.contact_phone_outlined, () {
            Navigator.pushNamed(
              context,
              AppRoutes.policyScreen,
              arguments: {"id": "4", "title": "Contact Us"},
            );
          }, "Contact Us"),
          _menuTile(
            ref,
            Icons.logout,
            () => _showLogoutDialog(context, ref),
            "Logout",
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    WidgetRef ref,
    IconData icon,
    VoidCallback onTap,
    String title, {
    Color? iconColor,
    Color? textColor,
    Widget? toggle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.iconColor(ref)),
      title: AppText(
        text: title,
        fontType: FontType.bold,
        fontSize: AppConstants.eighteen,
        color: textColor,
      ),
      trailing: toggle != null
          ? SizedBox(width: 60, height: 30, child: toggle)
          : Icon(Icons.chevron_right, color: AppColors.iconColor(ref)),
      onTap: onTap,
    );
  }
}

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: AppColors.background(ref),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.sh * 0.02),
          AppText(
            text: "Logout",
            fontSize: 20,
            color: Colors.red,
            fontType: FontType.bold,
          ),
          const SizedBox(height: 15),
          AppText(
            text: "Are you sure you want to log out?",
            fontSize: 16,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrimaryButton(
                margin: EdgeInsets.symmetric(horizontal: context.sw * 0.025),
                onTap: () => Navigator.pop(context),
                width: context.sw * 0.43,
                color: Colors.transparent,
                border: Border.all(color: AppColors.secondary(ref)),
                label: "Cancel",
                textColor: AppColors.secondary(ref),
              ),
              PrimaryButton(
                margin: EdgeInsets.symmetric(horizontal: context.sw * 0.025),
                onTap: () async {
                  await ref.read(googleAuthProvider.notifier).signOut(ref);
                },
                width: context.sw * 0.43,
                label: "Yes, Logout",
              ),
            ],
          ),
          SizedBox(height: context.sh * 0.02),
        ],
      );
    },
  );
}
