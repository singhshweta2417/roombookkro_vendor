import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_container.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/model/order_history_model.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Order orderHis = args['booking'] as Order;
    final String label = args['label'] as String;

    final checkInDate = DateTime.parse(orderHis.checkInDate);
    final checkOutDate = DateTime.parse(orderHis.checkOutDate);
    final nights = checkOutDate.difference(checkInDate).inDays;

    return CustomScaffold(
      padding: EdgeInsets.zero,
      appBar: CustomAppBar(
        middle: AppText(
          text: 'Booking Details',
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            _buildStatusBanner(context, ref, orderHis, label, checkInDate, checkOutDate, nights),

            SizedBox(height: context.sh * 0.02),

            // Guest Information Card
            _buildGuestInfoCard(context, ref, orderHis),

            SizedBox(height: context.sh * 0.02),

            // Property Details Card
            _buildPropertyDetailsCard(context, ref, orderHis),

            SizedBox(height: context.sh * 0.02),

            // Booking Information Card
            _buildBookingInfoCard(context, ref, orderHis, checkInDate, checkOutDate, nights),

            SizedBox(height: context.sh * 0.02),

            // Payment Information Card
            _buildPaymentInfoCard(context, ref, orderHis),

            SizedBox(height: context.sh * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, WidgetRef ref, Order orderHis, String label, DateTime checkInDate, DateTime checkOutDate, int nights) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (label == "Cancelled") {
      statusColor = Colors.red.shade700;
      statusIcon = Icons.cancel_rounded;
      statusText = "Booking Cancelled";
    } else if (label == "Completed") {
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.check_circle_rounded;
      statusText = "Completed";
    } else {
      statusColor = Colors.green.shade700;
      statusIcon = Icons.event_available_rounded;
      statusText = "Upcoming";
    }

    return TCustomContainer(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      lightColor: statusColor,
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: statusText,
                      color: Colors.white,
                      fontSize: 18,
                      fontType: FontType.bold,
                    ),
                    SizedBox(height: 4),
                    AppText(
                      text: "${DateFormat("dd MMM").format(checkInDate)} - ${DateFormat("dd MMM yyyy").format(checkOutDate)} • $nights ${nights > 1 ? 'nights' : 'night'}",
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfoCard(BuildContext context, WidgetRef ref, Order orderHis) {
    return TCustomContainer(
      padding: EdgeInsets.all(20),
      lightColor: AppColors.background(ref),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded, color: Colors.blue.shade700, size: 24),
              ),
              SizedBox(width: 12),
              AppText(
                text: "Guest Information",
                fontSize: 18,
                fontType: FontType.bold,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoRow(context, Icons.badge_rounded, "Guest Name", orderHis.bookingFor ?? 'N/A'),
          SizedBox(height: 12),
          _buildInfoRow(context, Icons.phone_rounded, "Contact", orderHis.userPhone ?? 'N/A'),
          SizedBox(height: 12),
          _buildInfoRow(context, Icons.groups_rounded, "Number of Guests", "${orderHis.nog ?? 0} guest${(orderHis.nog ?? 0) > 1 ? 's' : ''}"),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsCard(BuildContext context, WidgetRef ref, Order orderHis) {
    return TCustomContainer(
      padding: EdgeInsets.all(20),
      lightColor: AppColors.background(ref),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.apartment_rounded, color: Colors.orange.shade700, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: orderHis.residencyName ?? 'Property',
                  fontSize: 18,
                  fontType: FontType.bold,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: Colors.grey.shade600, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: AppText(
                  text: orderHis.address ?? 'Address not available',
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.directions_rounded,
                  label: "Directions",
                  color: Colors.blue,
                  onTap: () async {
                    final latitude = orderHis.coordinates?.lat?.toDouble();
                    final longitude = orderHis.coordinates?.lng?.toDouble();
                    if (latitude != null && longitude != null) {
                      final Uri googleMapUrl = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
                      );
                      if (await canLaunchUrl(googleMapUrl)) {
                        await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.call_rounded,
                  label: "Call Property",
                  color: Colors.green,
                  onTap: () => makePhoneCall(orderHis.contactNumber ?? ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard(BuildContext context, WidgetRef ref, Order orderHis, DateTime checkInDate, DateTime checkOutDate, int nights) {
    return TCustomContainer(
      padding: EdgeInsets.all(20),
      lightColor: AppColors.background(ref),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_note_rounded, color: Colors.purple.shade700, size: 24),
              ),
              SizedBox(width: 12),
              AppText(
                text: "Booking Details",
                fontSize: 18,
                fontType: FontType.bold,
              ),
            ],
          ),
          SizedBox(height: 20),

          // Check-in & Check-out
          Row(
            children: [
              Expanded(
                child: _buildDateBox(
                  context,
                  ref,
                  "Check-in",
                  DateFormat('dd MMM').format(checkInDate),
                  DateFormat('yyyy').format(checkInDate),
                  DateFormat('hh:mm a').format(checkInDate),
                  Colors.green,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400),
                    SizedBox(height: 4),
                    AppText(
                      text: "$nights ${nights > 1 ? 'nights' : 'night'}",
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildDateBox(
                  context,
                  ref,
                  "Check-out",
                  DateFormat('dd MMM').format(checkOutDate),
                  DateFormat('yyyy').format(checkOutDate),
                  DateFormat('hh:mm a').format(checkOutDate),
                  Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          Divider(height: 1),
          SizedBox(height: 20),

          _buildInfoRow(context, Icons.confirmation_number_rounded, "Booking ID", orderHis.orderId ?? 'N/A'),
          SizedBox(height: 12),
          _buildInfoRow(context, Icons.meeting_room_rounded, "Room Type", orderHis.roomType ?? 'Classic'),
          SizedBox(height: 12),
          _buildInfoRow(context, Icons.calendar_today_rounded, "Booked On", DateFormat('dd MMM yyyy').format(DateTime.parse(orderHis.createdAt))),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context, WidgetRef ref, Order orderHis) {
    return TCustomContainer(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      lightColor: AppColors.background(ref),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: Colors.green.shade700, size: 24),
              ),
              SizedBox(width: 12),
              AppText(
                text: "Payment Information",
                fontSize: 18,
                fontType: FontType.bold,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildPaymentRow(context, "Total Amount", "₹${orderHis.totalAmount ?? 0}"),
          if ((orderHis.discount ?? 0) > 0) ...[
            SizedBox(height: 12),
            _buildPaymentRow(context, "Discount", "- ₹${orderHis.discount}", color: Colors.green),
          ],
          SizedBox(height: 16),
          Divider(height: 1),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "Final Amount",
                fontSize: 16,
                fontType: FontType.bold,
              ),
              AppText(
                text: "₹${orderHis.finalAmount ?? 0}",
                fontSize: 24,
                fontType: FontType.bold,
                color: Colors.green.shade700,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow(context, Icons.payment_rounded, "Payment Method", orderHis.paymentMethod.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDateBox(BuildContext context, WidgetRef ref, String label, String date, String year, String time, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            fontSize: 12,
            color: accentColor.withOpacity(0.8),
            fontType: FontType.semiBold,
          ),
          SizedBox(height: 8),
          AppText(
            text: date,
            fontSize: 16,
            fontType: FontType.bold,
          ),
          AppText(
            text: year,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 4),
          AppText(
            text: time,
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 12),
        Expanded(
          child: AppText(
            text: label,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Flexible(
          child: AppText(
            text: value,
            fontSize: 14,
            fontType: FontType.semiBold,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(BuildContext context, String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(text: label, fontSize: 14, color: Colors.grey.shade700),
        AppText(
          text: value,
          fontSize: 16,
          fontType: FontType.semiBold,
          color: color,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            AppText(
              text: label,
              fontSize: 14,
              fontType: FontType.semiBold,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }
}