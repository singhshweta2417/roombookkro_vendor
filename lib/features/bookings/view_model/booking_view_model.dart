// dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/data/user_view.dart';
import '../../auth/model/order_history_model.dart';
import '../repo/booking_repo.dart';

class BookingViewModel extends StateNotifier<BookingState> {
  final BookingHisRepository _getBookingRepo;
  final Ref ref;

  BookingViewModel(this._getBookingRepo, this.ref) : super(const BookingInitial());

  Future<void> getBookingHisApi() async {
    state = const BookingLoading();
    final userPref = ref.read(userViewModelProvider);
    final userID = await userPref.getUserId();
    try {
      final value = await _getBookingRepo.getBookingHisApi(userID.toString());

      if (value.status == true) {
        state = BookingSuccess(
          bookings: value.data,
          message: value.msg,
        );
      } else {
        state = BookingError(value.msg);
      }
    } catch (error) {
      state = BookingError(error.toString());
    }
  }
}

abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingSuccess extends BookingState {
  final OrderHistoryData bookings;
  final String message;

  const BookingSuccess({required this.bookings, required this.message});
}

class BookingError extends BookingState {
  final String error;

  const BookingError(this.error);
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

final getBookingProvider =
StateNotifierProvider<BookingViewModel, BookingState>((ref) {
  final bookingRepo = ref.read(bookingRepoProvider);
  return BookingViewModel(bookingRepo, ref);
});
