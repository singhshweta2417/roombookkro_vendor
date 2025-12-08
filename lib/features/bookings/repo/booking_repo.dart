import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';
import '../../auth/model/order_history_model.dart';

class BookingHisRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  BookingHisRepository(this.apiServices, this.apiUrl);

  Future<OrderHistoryModel> getBookingHisApi(dynamic data) async {
    final response = await apiServices.getGetApiResponse(
      apiUrl.vendorOrderHistory!+
      data,
    );
    return OrderHistoryModel.fromJson(response);
  }

}

// In your get_property_repo.dart file, change this:
final bookingRepoProvider = Provider<BookingHisRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return BookingHisRepository(api, apiUrl);
});
