import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_container.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/utils/context_extensions.dart';
import '../../core/utils/utils.dart';
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

  /// ---- INITIAL DATA LOAD ----
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(updateProvider);
    final username = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.username
        : "";
    final userImage = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.userImage
        : "";
    final vendorVerify = (authState is ProfileSuccess && authState.profile != null)
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

            /// WELCOME CARD
            _buildWelcomeCard(username.toString()),
            SizedBox(height: context.sh * 0.025),

            /// QUICK ACTIONS
            _buildQuickActions(context,vendorVerify),
            SizedBox(height: context.sh * 0.025),

            /// SECTION TITLE
            AppText(
              text: "Overview",
              fontSize: AppConstants.eighteen,
              fontType: FontType.bold,
            ),
            SizedBox(height: context.sh * 0.015),

            /// PROPERTY STATS GRID
            _buildStatsGrid(context),
            SizedBox(height: context.sh * 0.015),
            const GraphScreen(),
            SizedBox(height: context.sh * 0.03),
          ],
        ),
      ),
    );
  }

  /// --------------------------------------------
  ///            UI SECTIONS
  /// --------------------------------------------

  Widget _buildWelcomeCard(String username) {
    return TCustomContainer(
      padding: EdgeInsets.all(20),
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
                    SizedBox(height: 4),
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(getGreetingEmoji(), style: TextStyle(fontSize: 32)),
              ),
            ],
          ),
          SizedBox(height: 12),
          AppText(
            text: "Manage your properties & bookings seamlessly",
            fontSize: AppConstants.thirteen,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }

  /// QUICK ACTION BUTTONS
  Widget _buildQuickActions(BuildContext context,bool vendorVerify) {
    List<Map<String, dynamic>> items = [
      {
        "icon": Icons.add_business_rounded,
        "title": "Add Property",
        "onTap": () {
          if (vendorVerify) {
            // ✅ Verified - Allow navigation
            Navigator.pushNamed(context, AppRoutes.addRoom);
          } else {
            Utils.show(
              "Please wait for vendor verification to add properties",
              context,
            );
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
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: item["onTap"] as void Function()?,
            child: Container(
              width: 90,
              padding: EdgeInsets.all(12),
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item["color"],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item["icon"], size: 24, color: Colors.white),
                  ),
                  SizedBox(height: 8),
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

  /// PROPERTY STATS GRID
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
            SizedBox(width: 12),
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
        SizedBox(height: 12),
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
            SizedBox(width: 12),
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

  /// SINGLE STAT BOX
  Widget _statBox(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Icon(Icons.trending_up_rounded, color: color, size: 16),
            ],
          ),
          SizedBox(height: 12),
          AppText(
            text: title,
            fontSize: AppConstants.thirteen,
            color: AppColors.greyText(ref),
          ),
          SizedBox(height: 4),
          AppText(
            text: value,
            fontSize: AppConstants.twenty,
            fontType: FontType.bold,
          ),
        ],
      ),
    );
  }

  /// TOP APP BAR
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
            margin: EdgeInsets.only(right: 8),
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
