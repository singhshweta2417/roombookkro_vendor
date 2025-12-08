import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/data/user_view.dart';
import '../../auth/model/notification_model.dart';
import '../repo/notification_repo.dart';

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _getPropertyRepo;
  final Ref ref;

  NotificationViewModel(this._getPropertyRepo, this.ref)
    : super(NotificationInitial());

  Future<void> notificationApi() async {
    state = NotificationLoading();
    final userPref = ref.read(userViewModelProvider);
    final userID = await userPref.getUserId();
    Map data = {"userId": userID.toString()};
    try {
      final value = await _getPropertyRepo.notificationApi(data);

      if (value.status == true) {
        state = NotificationSuccess(
          notifications: value.data!,
          message: 'Properties loaded successfully',
        );
      }
    } catch (error) {
      state = NotificationError(error.toString());
    }
  }
}

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationSuccess extends NotificationState {
  final List<Data> notifications;
  final String message;

  const NotificationSuccess({
    required this.notifications,
    required this.message,
  });
}

class NotificationError extends NotificationState {
  final String error;

  const NotificationError(this.error);
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

// Use the renamed repository provider
final getNotificationProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      final getNotificationRepo = ref.read(notificationRepoProvider);
      return NotificationViewModel(getNotificationRepo, ref);
    });
