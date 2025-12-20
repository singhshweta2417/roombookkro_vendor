import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/features/auth/model/withdraw_history_model.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class WithdrawHistoryRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  WithdrawHistoryRepository(this.apiServices, this.apiUrl);

  Future<WithdrawHistoryModel> withdrawHistoryApi(data) async {
    final response = await apiServices.getGetApiResponse(
      apiUrl.withdrawHistory! + data,
    );
    return WithdrawHistoryModel.fromJson(response);
  }
}

final withdrawHistoryProvider = Provider<WithdrawHistoryRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return WithdrawHistoryRepository(api, apiUrl);
});
