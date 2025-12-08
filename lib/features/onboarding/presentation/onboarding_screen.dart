import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../generated/assets.dart';
import '../view_model/on_board_view_model.dart';

final currentPageProvider = StateProvider<int>((ref) => 0);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule after first frame
    Future.microtask(() {
      final state = ref.read(onboardingProvider);
      if (state is OnboardInitial) {
        ref.read(onboardingProvider.notifier).onboardApi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final onboardState = ref.watch(onboardingProvider);
    final pageController = PageController();

    if (onboardState is OnboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (onboardState is OnboardError) {
      return Center(child: Text(onboardState.error));
    }

    return CustomScaffold(
      padding: EdgeInsets.zero,
      child: onboardState is OnboardSuccess
          ? PageView.builder(
        controller: pageController,
        itemCount: onboardState.onboard.length,
        onPageChanged: (index) {
          ref.read(currentPageProvider.notifier).state = index;
        },
        itemBuilder: (context, index) {
          final page = onboardState.onboard[index];
          return Column(
            children: [
              SizedBox(height: context.sh * 0.05),
              Container(
                height: context.sh * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.imagesBubbleImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(height: context.sh * 0.035),
              AppText(
                text: page.title.toString(),
                fontSize: AppConstants.eighteen,
                fontType: FontType.bold,
              ),
              SizedBox(height: context.sh * 0.01),
              AppText(
                text: "RoomBooKaro",
                fontSize: AppConstants.thirty,
                fontType: FontType.bold,
                color: AppColors.secondary(ref),
              ),
              SizedBox(height: context.sh * 0.03),
              AppText(
                textAlign: TextAlign.center,
                text: page.description.toString(),
                fontSize: AppConstants.sixteen,
              ),
              SizedBox(height: context.sh * 0.05),
              PrimaryButton(
                onTap: () async {
                  if (currentPage < onboardState.onboard.length - 1) {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    await ref
                        .read(onboardingProvider.notifier)
                        .completeOnboarding();
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.login);
                  }
                },
                label: currentPage == onboardState.onboard.length - 1
                    ? "Get Started"
                    : "Next",
                borderRadius: BorderRadius.circular(30),
              ),
              SizedBox(height: context.sh * 0.01),
              PrimaryButton(
                onTap: () async {
                  await ref
                      .read(onboardingProvider.notifier)
                      .completeOnboarding();
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.login);
                },
                borderRadius: BorderRadius.circular(30),
                color: Colors.transparent,
                border: Border.all(
                    color: AppColors.secondary(ref), width: 2),
                label: "Skip",
                textColor: AppColors.secondary(ref),
              ),
            ],
          );
        },
      )
          : const SizedBox.shrink(),
    );
  }
}



