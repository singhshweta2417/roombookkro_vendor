import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import '../theme/theme_provider.dart';

final scaffoldColorProvider = Provider<Color>((ref) {
  final theme = ref.watch(appThemeProvider); // ProviderRef works
  return theme.background;
});


class CustomScaffold extends ConsumerWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;

  const CustomScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.padding,
    this.backgroundColor,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(scaffoldColorProvider);

    return Scaffold(
      appBar: appBar,
      backgroundColor:backgroundColor?? Colors.transparent,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation:
      floatingActionButtonLocation ?? FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      body: SafeArea(
        top: false,
        child: Container(
          width: context.sw,
          height: context.sh,
          padding:
          padding ?? EdgeInsets.symmetric(horizontal: context.sw * 0.03),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : color,
          ),
          child: child,
        ),
      ),
    );
  }
}
