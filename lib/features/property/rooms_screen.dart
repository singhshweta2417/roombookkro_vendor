import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/features/property/property_model.dart';
import 'package:room_book_kro_vendor/features/property/view_model/property_list_view_model.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_container.dart';

class PropertyScreen extends ConsumerStatefulWidget {
  const PropertyScreen({super.key});
  @override
  ConsumerState<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends ConsumerState<PropertyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getPropertyProvider.notifier).getPropertyList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "My Properties",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(getPropertyProvider);

          if (state is GetPropertyLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary(ref).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      color: AppColors.secondary(ref),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: context.sh * 0.03),
                  AppText(
                    text: "Loading your properties...",
                    color: Colors.grey.shade700,
                    fontSize: AppConstants.sixteen,
                    fontType: FontType.medium,
                  ),
                ],
              ),
            );
          }

          if (state is GetPropertyError) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 20),
                    AppText(
                      text: "Oops! Something went wrong",
                      fontSize: 18,
                      fontType: FontType.bold,
                      color: Colors.red.shade900,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    AppText(
                      text: state.error,
                      color: Colors.red.shade700,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GetPropertySuccess) {
            if (state.propertyLists.data?.isEmpty ?? true) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_rounded,
                          size: 64,
                          color: Colors.blue.shade400,
                        ),
                      ),
                      SizedBox(height: 24),
                      AppText(
                        text: "No Properties Yet",
                        fontSize: 22,
                        fontType: FontType.bold,
                        color: Colors.grey.shade800,
                      ),
                      SizedBox(height: 12),
                      AppText(
                        text:
                            "Start by adding your first property\nto begin receiving bookings",
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add property action
                        },
                        icon: Icon(Icons.add_rounded),
                        label: Text("Add Property"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary(ref),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildPropertyContent(context, ref, state);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPropertyContent(
    BuildContext context,
    WidgetRef ref,
    GetPropertySuccess state,
  ) {
    return Column(
      children: [
        // Enhanced Stats Section
        _buildEnhancedStatsSection(context, ref, state),

        SizedBox(height: context.sh * 0.02),

        // Properties Grid
        Expanded(child: _gridPropertyList(context, ref, state)),
      ],
    );
  }

  Widget _buildEnhancedStatsSection(
    BuildContext context,
    WidgetRef ref,
    GetPropertySuccess state,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary(ref).withValues(alpha: 0.1),
            AppColors.secondary(ref).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary(ref).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary(ref),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              AppText(
                text: "Portfolio Overview",
                fontSize: 16,
                fontType: FontType.bold,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  context,
                  ref,
                  icon: Icons.apartment_rounded,
                  label: "Properties",
                  value: state.propertyLists.propertyCount?.toString() ?? "0",
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildModernStatCard(
                  context,
                  ref,
                  icon: Icons.meeting_room_rounded,
                  label: "Total Rooms",
                  value:
                      state.propertyLists.overallRoomCount?.toString() ?? "0",
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildModernStatCard(
                  context,
                  ref,
                  icon: Icons.verified_rounded,
                  label: "Verified",
                  value:
                      state.propertyLists.verifiedPropertiesCount?.toString() ??
                      "0",
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          AppText(
            text: value,
            fontSize: 24,
            fontType: FontType.bold,
            color: color,
          ),
          SizedBox(height: 4),
          AppText(
            text: label,
            fontSize: 11,
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _gridPropertyList(
    BuildContext context,
    WidgetRef ref,
    GetPropertySuccess state,
  ) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.propertyLists.data?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, i) {
        final propertyDetails = state.propertyLists.data![i];
        return _buildEnhancedPropertyCard(propertyDetails, ref, context);
      },
    );
  }

  Widget _buildEnhancedPropertyCard(
    Data hotel,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isAvailable = hotel.isAvailable ?? false;
    final isVerified = hotel.verifyProperty ?? false;
    final discountPercent = hotel.oldMrp != null && hotel.oldMrp != 0
        ? (((hotel.oldMrp! -
                          (hotel.pricePerNight ?? hotel.pricePerMonth ?? 0)) /
                      hotel.oldMrp!) *
                  100)
              .toInt()
        : 0;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.propertyDetailsScreen,
          arguments: hotel,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(ref),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isVerified
                ? Colors.green.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.15),
            width: isVerified ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: context.sh * 0.25,
                    width: double.infinity,
                    child: Image.network(
                      hotel.mainImage ?? '',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.grey.shade400,
                                size: 36,
                              ),
                              SizedBox(height: 8),
                              AppText(
                                text: "No Image",
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2.5,
                              color: AppColors.secondary(ref),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Enhanced Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Verified Badge
                if (isVerified)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          AppText(
                            text: "Verified",
                            color: Colors.white,
                            fontType: FontType.semiBold,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Rating Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade600,
                          size: 16,
                        ),
                        SizedBox(width: 3),
                        AppText(
                          text: hotel.rating?.toStringAsFixed(1) ?? "0.0",
                          color: Colors.black87,
                          fontType: FontType.bold,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                ),

                // Discount Badge
                if (discountPercent > 0)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AppText(
                        text: "$discountPercent% OFF",
                        color: Colors.white,
                        fontType: FontType.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),

                // Availability Status
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isAvailable ? Colors.green : Colors.red)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        AppText(
                          text: isAvailable ? "Available" : "Unavailable",
                          color: Colors.white,
                          fontType: FontType.semiBold,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Enhanced Details Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sw * 0.018,
                  vertical: context.sh * 0.012,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Name
                    AppText(
                      text: hotel.name ?? "Unnamed Property",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontSize: context.sh * 0.03,
                      fontType: FontType.bold,
                      color: Colors.black87,
                    ),

                    SizedBox(height: context.sh * 0.01),

                    // Property Type & Location
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hotel.type == "Hotel"
                                ? Colors.blue.shade50
                                : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hotel.type == "Hotel"
                                  ? Colors.blue.shade300
                                  : Colors.purple.shade300,
                              width: 1,
                            ),
                          ),
                          child: AppText(
                            text: hotel.type?.toUpperCase() ?? "TYPE",
                            fontSize: 9,
                            fontType: FontType.bold,
                            color: hotel.type == "Hotel"
                                ? Colors.blue.shade700
                                : Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.sh * 0.01),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: AppText(
                            text: hotel.city ?? "Unknown Location",
                            fontSize: context.sh * 0.015,
                            color: Colors.grey.shade600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.sh * 0.01),

                    // Rooms Info
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_rounded,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        AppText(
                          text:
                              "${hotel.availableRooms ?? 0} / ${hotel.totalRooms ?? 0}",
                          fontSize: 11,
                          fontType: FontType.semiBold,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 3),
                        AppText(
                          text: "rooms",
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),

                    Spacer(),

                    // Price Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    text:
                                        "₹${hotel.type == "hotel" ? (hotel.pricePerNight ?? 0) : (hotel.pricePerMonth ?? 0)}",
                                    fontSize: 16,
                                    fontType: FontType.bold,
                                    color: Colors.green.shade700,
                                  ),
                                  if ((hotel.oldMrp ?? 0) > 0) ...[
                                    SizedBox(width: 6),
                                    AppText(
                                      text: "₹${hotel.oldMrp}",
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ],
                                ],
                              ),
                              AppText(
                                text: hotel.type == "hotel"
                                    ? "/night"
                                    : "/month",
                                fontSize: 9,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
