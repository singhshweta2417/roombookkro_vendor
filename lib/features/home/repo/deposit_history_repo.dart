import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/features/auth/model/deposit_history_model.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class DepositHistoryRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  DepositHistoryRepository(this.apiServices, this.apiUrl);

  Future<DepositHistoryModel> depositHistoryApi(data) async {
    final response = await apiServices.getGetApiResponse(
      apiUrl.depositHistory! + data,
    );
    return DepositHistoryModel.fromJson(response);
  }
}

final depositHistoryProvider = Provider<DepositHistoryRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return DepositHistoryRepository(api, apiUrl);
});
