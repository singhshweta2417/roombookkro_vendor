import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/bookings/view_model/booking_view_model.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import 'booking_list_widget.dart';

final bookingTabProvider = StateProvider<int>((ref) => 0);

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final bookingNotifier = ref.read(getBookingProvider.notifier);
      bookingNotifier.getBookingHisApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(bookingTabProvider);
    return CustomScaffold(
      appBar: CustomAppBar(
        showActions: true,
        leading: Icon(Icons.home, color: AppColors.iconColor(ref)),
        middle: AppText(
          text: "My Booking",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabItem(ref, 0, "Upcoming"),
              _tabItem(ref, 1, "Completed"),
              _tabItem(ref, 2, "Cancelled"),
            ],
          ),
        ),
      ),
      child: IndexedStack(
        index: selectedTab,
        children: [
          buildBookingList("Upcoming", ref),
          buildBookingList("Completed", ref),
          buildBookingList("Cancelled", ref),
        ],
      ),
    );
  }

  Widget _tabItem(WidgetRef ref, int index, String text) {
    final selected = ref.watch(bookingTabProvider) == index;
    return GestureDetector(
      onTap: () => ref.read(bookingTabProvider.notifier).state = index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AppText(
              text: text,
              fontType: FontType.bold,
              color: selected ? Colors.green : Colors.grey,
              fontSize: AppConstants.eighteen,
            ),
          ),
          if (selected) Container(height: 2, width: 70, color: Colors.green),
        ],
      ),
    );
  }
}
