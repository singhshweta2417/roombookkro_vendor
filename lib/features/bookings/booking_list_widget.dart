import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/features/bookings/view_model/booking_view_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/navigator_key_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/shimmer_const.dart';
import '../../../generated/assets.dart';
import '../auth/data/user_view.dart';
import '../auth/model/order_history_model.dart';

Widget buildBookingList(String label, WidgetRef ref) {
  final userPref = ref.read(userViewModelProvider);
  return FutureBuilder<String?>(
    future: userPref.getUserType(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final userType = snapshot.data ?? "";
      if (userType == "3") {
        final navigatorKey = ref.read(navigatorKeyProvider);
        return Center(
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.08),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 48,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 24),
                AppText(
                  text: "Authentication Required",
                  fontType: FontType.bold,
                  fontSize: 20,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                AppText(
                  text: "Please login to view your bookings",
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                PrimaryButton(
                  onTap: () async {
                    final userView = ref.read(userViewModelProvider);
                    await userView.clearAll();
                    navigatorKey.currentState?.pushReplacementNamed(
                      AppRoutes.login,
                    );
                  },
                  label: "Login Now",
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          ),
        );
      }
      return Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(getBookingProvider);
          if (state is BookingLoading) {
            return ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: 16),
              itemBuilder: (context, index) => const CustomShimmer(
                width: double.infinity,
                height: 140,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            );
          } else if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 16),
                  AppText(
                    text: 'Error loading bookings',
                    fontType: FontType.semiBold,
                    fontSize: 16,
                  ),
                  SizedBox(height: 8),
                  AppText(
                    text: state.error,
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (state is BookingSuccess)
          {
            List<Order> bookingsList = [];
            if (label == "Upcoming") {
              bookingsList = state.bookings.timeWise.upcoming;
            } else if (label == "Completed") {
              bookingsList = state.bookings.timeWise.past;
            } else if (label == "Cancelled") {
              bookingsList = state.bookings.timeWise.cancelled;
            }
            if (bookingsList.isEmpty) {
              return _buildEmptyState(context, label);
            }
            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(getBookingProvider.notifier).getBookingHisApi();
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: context.sh*0.015),
                itemCount: bookingsList.length,
                itemBuilder: (context, index) {
                  final booking = bookingsList[index];
                  return _buildBookingCard(context, ref, booking, label);
                },
              ),
            );
          } else {
            return _buildEmptyState(context, "");
          }
        },
      );
    },
  );
}

Widget _buildEmptyState(BuildContext context, String label) {
  IconData icon;
  String title;
  String subtitle;

  switch (label) {
    case "Upcoming":
      icon = Icons.event_available_rounded;
      title = "No Upcoming Bookings";
      subtitle = "You don't have any upcoming reservations";
      break;
    case "Completed":
      icon = Icons.check_circle_outline_rounded;
      title = "No Completed Bookings";
      subtitle = "Your completed bookings will appear here";
      break;
    case "Cancelled":
      icon = Icons.cancel_outlined;
      title = "No Cancelled Bookings";
      subtitle = "You don't have any cancelled reservations";
      break;
    default:
      icon = Icons.inbox_rounded;
      title = "No Bookings";
      subtitle = "Your bookings will appear here";
  }

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 64, color: Colors.grey.shade400),
        ),
        SizedBox(height: 24),
        AppText(
          text: title,
          fontType: FontType.bold,
          fontSize: 18,
          color: Colors.grey.shade700,
        ),
        SizedBox(height: 8),
        AppText(
          text: subtitle,
          fontSize: 14,
          color: Colors.grey.shade500,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildBookingCard(
  BuildContext context,
  WidgetRef ref,
  Order booking,
  String label,
) {
  final checkIn = DateTime.parse(booking.checkInDate);
  final checkOut = DateTime.parse(booking.checkOutDate);
  final nights = checkOut.difference(checkIn).inDays;

  Color statusColor;
  IconData statusIcon;
  String statusText;

  if (label == "Cancelled") {
    statusColor = Colors.red;
    statusIcon = Icons.cancel_rounded;
    statusText = "Cancelled";
  } else if (label == "Completed") {
    statusColor = Colors.blue;
    statusIcon = Icons.check_circle_rounded;
    statusText = "Completed";
  } else {
    statusColor = Colors.green;
    statusIcon = Icons.event_available_rounded;
    statusText = "Upcoming";
  }

  return InkWell(
    onTap: () {
      Navigator.pushNamed(
        context,
        AppRoutes.bookingDetailsScreen,
        arguments: {"booking": booking, "label": label},
      );
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.background(ref),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: context.sh * 0.18,
                  width: double.infinity,
                  child:
                      booking.residencyImage != null &&
                          booking.residencyImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: booking.residencyImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            Assets.imagesBedRoom,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(Assets.imagesBedRoom, fit: BoxFit.cover),
                ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha:0.4),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      AppText(
                        text: statusText,
                        color: Colors.white,
                        fontSize: 12,
                        fontType: FontType.semiBold,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Name
                AppText(
                  text: booking.residencyName ?? 'Property Name',
                  fontSize: 18,
                  fontType: FontType.bold,
                  maxLines: 2,
                ),
                SizedBox(height: 12),

                // Date and Guests Info
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: context.sh * 0.02,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        text:
                            "${DateFormat('dd MMM').format(checkIn)} - ${DateFormat('dd MMM yyyy').format(checkOut)}",
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        text: "$nights ${nights > 1 ? 'nights' : 'night'}",
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontType: FontType.semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: context.sh * 0.02,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 6),
                    AppText(
                      text:
                          "${booking.nog ?? 0} guest${(booking.nog ?? 0) > 1 ? 's' : ''}",
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),

                SizedBox(height: context.sh * 0.02),

                // Booking ID and Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "Booking ID",
                          fontSize: context.sh * 0.018,
                          color: AppColors.text(ref),
                        ),
                        SizedBox(height: context.sh * 0.005),
                        AppText(
                          text: booking.orderId ?? 'N/A',
                          fontSize: context.sh * 0.015,
                          fontType: FontType.semiBold,
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppText(
                        text: "₹${booking.finalAmount ?? 0}",
                        fontSize: context.sh * 0.02,
                        fontType: FontType.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
