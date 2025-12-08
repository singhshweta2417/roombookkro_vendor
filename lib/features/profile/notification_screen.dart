import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/features/profile/view_model/notification_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../../core/widgets/shimmer_const.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notificationNotifier = ref.read(getNotificationProvider.notifier);
      notificationNotifier.notificationApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        showActions: true,
        middle: AppText(
          text: "Notification",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(getNotificationProvider);
          if (state is NotificationLoading) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: context.sh * 0.02),
              separatorBuilder: (_, __) =>
                  SizedBox(height: context.sh * 0.03),
              itemCount: 4,
              itemBuilder: (context, index) =>
                  CustomShimmer(width: context.sw, height: context.sh * 0.08),
            );
          } else if (state is NotificationError) {
            return Center(child: AppText(text: 'Error: ${state.error}'));
          } else if (state is NotificationSuccess) {
            if (state.notifications.isEmpty) {
              return const Center(child: AppText(text: 'No data available'));
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: context.sh * 0.02),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => SizedBox(height: context.sh * 0.02),
              itemBuilder: (context, index) {
                final item = state.notifications[index];
                String utcString = item.createdAt.toString();
                DateTime utcDateTime = DateTime.parse(utcString);
                DateTime localDateTime = utcDateTime.toLocal();
                String formattedTime = DateFormat(
                  'hh:mm a',
                ).format(localDateTime);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.secondary(
                            ref,
                          ).withValues(alpha: 0.2),
                          child: Icon(
                            Icons.notifications,
                            color: AppColors.secondary(ref),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: context.sw * 0.05),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: item.label?.toString() ?? 'N/A',
                              fontSize: context.sh * 0.02,
                              fontType: FontType.semiBold,
                            ),
                            AppText(
                              text:
                                  "${timeago.format(localDateTime)} | $formattedTime",
                              color: AppColors.text(ref).withValues(alpha: 0.5),
                              fontSize: context.sh * 0.02,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: context.sh * 0.01),
                    AppText(
                      text: item.description?.toString() ?? 'N/A',
                      fontSize: context.sh * 0.02,
                      color: AppColors.text(ref).withValues(alpha: 0.5),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(child: AppText(text: 'No data available'));
          }
        },
      ),
    );
  }
}
