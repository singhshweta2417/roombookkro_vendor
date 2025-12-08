import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_text.dart';
import '../core/widgets/custom_scaffold.dart';
import '../core/widgets/primary_button.dart';
import '../main.dart';

class NoInternetConnection extends ConsumerWidget {
  const NoInternetConnection({super.key});

  Future<void> _checkAndRetry(BuildContext context) async {
    final result = await Connectivity().checkConnectivity();
    final hasInternet =
        result.isNotEmpty && result.first != ConnectivityResult.none;

    if (hasInternet && context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.splash);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText(
            text: "Still no internet connection",
            color: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return CustomScaffold(
      child: connectivityAsync.when(
        data: (connectivity) {
          if (connectivity != ConnectivityResult.none) {
            Future.microtask(() {
              if (context.mounted &&
                  ModalRoute.of(context)?.settings.name != AppRoutes.splash) {
                Navigator.pushReplacementNamed(context, AppRoutes.splash);
              }
            });
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 80, color: AppColors.secondary(ref)),
              SizedBox(height: context.sh * 0.03),
              const AppText(
                text: 'No Internet Connection',
                fontSize: 24,
                fontType: FontType.bold,
              ),
              SizedBox(height: context.sh * 0.02),
              const AppText(
                maxLines: 2,
                text: 'Please check your internet connection and try again',
                textAlign: TextAlign.center,
                fontSize: 16,
              ),
              SizedBox(height: context.sh * 0.05),
              PrimaryButton(
                onTap: () => _checkAndRetry(context),
                label: 'Retry',
                width: 150,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
