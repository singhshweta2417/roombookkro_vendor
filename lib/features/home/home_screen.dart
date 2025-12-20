import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_container.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/utils/context_extensions.dart';
import '../bottom/bottom_screen.dart';
import '../profile/view_model/profile_view_model.dart';
import '../property/view_model/property_list_view_model.dart';
import 'home_widgets/chart_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String address = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  _loadInitialData() async {
    ref.read(updateProvider.notifier).profileViewApi(context);
    ref.read(getPropertyProvider.notifier).getPropertyList();
  }

  String getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12 && h >= 5) return "Good Morning";
    if (h < 17) return "Good Afternoon";
    if (h < 21) return "Good Evening";
    return "Good Night";
  }

  String getGreetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12 && h >= 5) return "👋";
    if (h < 17) return "☀️";
    if (h < 21) return "🌆";
    return "🌙";
  }

  /// ✨ BEAUTIFUL VERIFICATION DIALOG
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: VerificationDialogContent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(updateProvider);
    final username = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.username
        : "";
    final userImage = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.userImage
        : "";
    final vendorVerify =
    (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.vendorVerify ?? false
        : false;

    return CustomScaffold(
      appBar: _buildAppBar(username.toString(), userImage.toString()),
      child: RefreshIndicator(
        color: AppColors.secondary(ref),
        onRefresh: () async => _loadInitialData(),
        child: ListView(
          children: [
            SizedBox(height: context.sh * 0.02),
            _buildWelcomeCard(username.toString()),
            SizedBox(height: context.sh * 0.025),
            _buildQuickActions(context, vendorVerify),
            SizedBox(height: context.sh * 0.025),
            AppText(
              text: "Overview",
              fontSize: AppConstants.eighteen,
              fontType: FontType.bold,
            ),
            SizedBox(height: context.sh * 0.015),
            _buildStatsGrid(context),
            SizedBox(height: context.sh * 0.015),
            const GraphScreen(),
            SizedBox(height: context.sh * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String username) {
    return TCustomContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          AppColors.secondary(ref),
          AppColors.secondary(ref).withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: getGreeting(),
                      fontSize: AppConstants.sixteen,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      text: username,
                      fontSize: AppConstants.twentyTwo,
                      fontType: FontType.bold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(getGreetingEmoji(), style: const TextStyle(fontSize: 32)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: "Manage your properties & bookings seamlessly",
            fontSize: AppConstants.thirteen,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool vendorVerify) {
    List<Map<String, dynamic>> items = [
      {
        "icon": Icons.add_business_rounded,
        "title": "Add Property",
        "onTap": () {
          if (vendorVerify) {
            Navigator.pushNamed(context, AppRoutes.addRoom);
          } else {
            _showVerificationDialog(); // ✨ Beautiful Dialog
          }
        },
        "color": Colors.blue,
      },
      {
        "icon": Icons.calendar_month_rounded,
        "title": "Bookings",
        "onTap": () => ref.read(bottomNavProvider.notifier).setIndex(1),
        "color": Colors.orange,
      },
      {
        "icon": Icons.local_offer_rounded,
        "title": "Offers",
        "onTap": () => Navigator.pushNamed(context, AppRoutes.offerScreen),
        "color": Colors.green,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: item["onTap"] as void Function()?,
            child: Container(
              width: 90,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item["color"] as Color).withAlpha(40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (item["color"] as Color).withAlpha(80),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item["color"],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item["icon"], size: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    text: item["title"],
                    fontSize: 11,
                    fontType: FontType.medium,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final propertyState = ref.watch(getPropertyProvider);

    int propertyCount = 0;
    int totalRooms = 0;

    if (propertyState is GetPropertySuccess) {
      propertyCount = propertyState.propertyLists.availablePropertiesCount ?? 0;
      totalRooms = propertyState.propertyLists.overallRoomCount ?? 0;
    }

    final authState = ref.watch(updateProvider);
    final booking = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.vendorOrderCount
        : "0";
    final totalRevenue =
    (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.vendorRevenue
        : "0";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statBox(
                context,
                title: "Properties",
                value: propertyCount.toString(),
                icon: Icons.apartment_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statBox(
                context,
                title: "Total Rooms",
                value: totalRooms.toString(),
                icon: Icons.meeting_room_rounded,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statBox(
                context,
                title: "Bookings",
                value: booking.toString(),
                icon: Icons.book_online_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statBox(
                context,
                title: "Revenue",
                value: "₹$totalRevenue",
                icon: Icons.currency_rupee_rounded,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statBox(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Icon(Icons.trending_up_rounded, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: title,
            fontSize: AppConstants.thirteen,
            color: AppColors.greyText(ref),
          ),
          const SizedBox(height: 4),
          AppText(
            text: value,
            fontSize: AppConstants.twenty,
            fontType: FontType.bold,
          ),
        ],
      ),
    );
  }

  CustomAppBar _buildAppBar(String username, String userImage) {
    return CustomAppBar(
      showActions: true,
      leading: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary(ref), width: 2),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: userImage,
                fit: BoxFit.cover,
                width: 36,
                height: 36,
                placeholder: (_, __) =>
                const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
      middle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "Property Management",
            fontSize: AppConstants.twelve,
            color: AppColors.greyText(ref),
          ),
          AppText(
            text: "Dashboard",
            fontType: FontType.bold,
            fontSize: AppConstants.eighteen,
          ),
        ],
      ),
      trailing: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary(ref).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notificationScreen),
              icon: Icon(
                Icons.notifications_rounded,
                color: AppColors.secondary(ref),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ✨ BEAUTIFUL VERIFICATION DIALOG WIDGET
// ============================================================

class VerificationDialogContent extends ConsumerStatefulWidget {
  const VerificationDialogContent({super.key});

  @override
  ConsumerState<VerificationDialogContent> createState() =>
      _VerificationDialogContentState();
}

class _VerificationDialogContentState
    extends ConsumerState<VerificationDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TCustomContainer(
          padding: EdgeInsets.symmetric(
            horizontal: context.sw * 0.05,
            vertical: context.sh * 0.035,
          ),
          lightColor: AppColors.background(ref),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon animation
              TCustomContainer(
                width: context.sh * 0.12,
                height: context.sh * 0.12,
                lightColor: Colors.orange.shade50,
                shape: BoxShape.circle,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      builder: (_, scale, __) {
                        return Transform.scale(
                          scale: scale,
                          child: TCustomContainer(
                            width: context.sh * 0.08,
                            height: context.sh * 0.08,
                            lightColor: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      size: 40,
                      color: Colors.orange.shade600,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AppText(
                text: "Verification Pending",
                fontSize: AppConstants.twenty,
                fontType: FontType.bold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.sh * 0.015),
              AppText(
                text:
                "Your account is currently under verification. You'll be able to add properties once verified.",
                fontSize: AppConstants.fourteen,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.sh * 0.015),

              TCustomContainer(
                padding: const EdgeInsets.all(12),
                lightColor: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        text: "This usually takes 24–48 hours",
                        fontSize: AppConstants.twelve,
                        color: Colors.blue.shade700,
                        fontType: FontType.medium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: AppColors.secondary(ref),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppText(
                        text: "Got it",
                        fontSize: AppConstants.fourteen,
                        fontType: FontType.semiBold,
                        color: AppColors.secondary(ref),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      label: "Contact Support",
                      fontSize: AppConstants.fourteen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}