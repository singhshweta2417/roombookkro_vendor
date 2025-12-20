import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/navigator_key_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../generated/assets.dart';
import '../view_model/on_board_view_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load onboarding data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      if (state is OnboardInitial) {
        ref.read(onboardingProvider.notifier).loadOnboardingData();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleNext(int totalPages) async {
    if (_currentPage < totalPages - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      await ref.read(onboardingProvider.notifier).completeOnboarding();

      if (mounted) {
        ref.read(navigatorKeyProvider).currentState?.pushReplacementNamed(
          AppRoutes.login,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardState = ref.watch(onboardingProvider);

    return CustomScaffold(
      padding: EdgeInsets.zero,
      child: _buildContent(context, onboardState),
    );
  }

  Widget _buildContent(BuildContext context, OnboardState state) {
    if (state is OnboardLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary(ref),
        ),
      );
    }

    if (state is OnboardError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            AppText(
              text: 'Something went wrong',
              fontSize: AppConstants.eighteen,
              fontType: FontType.bold,
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AppText(
                text: state.error,
                fontSize: AppConstants.fourteen,
                textAlign: TextAlign.center,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(onboardingProvider.notifier).loadOnboardingData();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is OnboardSuccess) {
      final pages = state.onboard;

      if (pages.isEmpty) {
        // Fallback if no data
        return Center(
          child: AppText(
            text: 'No onboarding data available',
            fontSize: AppConstants.sixteen,
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _buildOnboardingPage(
                  context,
                  pages[index],
                  index,
                  pages.length,
                );
              },
            ),
          ),
          _buildPageIndicator(pages.length),
          SizedBox(height: context.sh * 0.02),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildOnboardingPage(
      BuildContext context,
      dynamic page,
      int index,
      int totalPages,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.sw * 0.05),
      child: Column(
        children: [
          SizedBox(height: context.sh * 0.05),

          // Image Container
          Container(
            height: context.sh * 0.45,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.imagesBubbleImage),
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: context.sh * 0.04),

          // Title
          AppText(
            text: page.title?.toString() ?? '',
            fontSize: AppConstants.eighteen,
            fontType: FontType.bold,
          ),

          SizedBox(height: context.sh * 0.01),

          // App Name
          AppText(
            text: "RoomBookKaro",
            fontSize: AppConstants.thirty,
            fontType: FontType.bold,
            color: AppColors.secondary(ref),
          ),

          SizedBox(height: context.sh * 0.03),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sw * 0.05),
            child: AppText(
              textAlign: TextAlign.center,
              text: page.description?.toString() ?? '',
              fontSize: AppConstants.sixteen,
              color: Colors.grey[700],
            ),
          ),

          SizedBox(height: context.sh * 0.05),

          // Next/Get Started Button
          PrimaryButton(
            onTap: _isNavigating ? null : () => _handleNext(totalPages),
            label: _currentPage == totalPages - 1 ? "Get Started" : "Next",
            borderRadius: BorderRadius.circular(30),
          ),

          SizedBox(height: context.sh * 0.015),

          // Skip Button
          PrimaryButton(
            onTap: _isNavigating ? null : _completeOnboarding,
            borderRadius: BorderRadius.circular(30),
            color: Colors.transparent,
            border: Border.all(color: AppColors.secondary(ref), width: 2),
            label: "Skip",
            textColor: AppColors.secondary(ref),
          ),

          SizedBox(height: context.sh * 0.03),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.secondary(ref)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
