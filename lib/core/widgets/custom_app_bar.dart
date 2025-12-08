import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? middle;
  final Color? backgroundColor;
  final Color? leadingIconColor;
  final bool autoImplyLeading;
  final bool centerOfTitle;
  final bool showActions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onTapTextField;

  const CustomAppBar({
    super.key,
    this.leading,
    this.leadingIconColor,
    this.trailing,
    this.middle,
    this.backgroundColor,
    this.autoImplyLeading = true,
    this.centerOfTitle = false,
    this.showActions = false,
    this.bottom,
    this.onTapTextField,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      bottomOpacity: 1.0,
      elevation: 2.0,
      leadingWidth: 50,
      automaticallyImplyLeading: autoImplyLeading,
      centerTitle: centerOfTitle,
      backgroundColor: backgroundColor??AppColors.background(ref),
      title: middle,
      titleSpacing: autoImplyLeading != true ? context.sw * 0.025 : 0,
      leading: autoImplyLeading
          ? leading ??
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              SystemSound.play(SystemSoundType.click);
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: context.sw * 0.01),
              padding: EdgeInsets.only(left: context.sw * 0.025),
              child: Icon(
                Icons.arrow_back_ios,
                color:leadingIconColor?? AppColors.text(ref),

              ),
            ),
          )
          : null,
      actions: showActions
          ? [
        if (trailing != null)
          trailing!
        else
          const SizedBox(width: 20),
      ]
          : null,
      bottom: bottom,
    );
  }
}
