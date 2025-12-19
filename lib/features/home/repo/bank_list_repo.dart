import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/features/auth/model/bank_detail_list_model.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class BankHistoryRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  BankHistoryRepository(this.apiServices, this.apiUrl);

  Future<BankDetailsListModel> bankHistoryApi(data) async {
    final response = await apiServices.getGetApiResponse(
      apiUrl.bankDetailsUser! + data,
    );
    return BankDetailsListModel.fromJson(response);
  }
}

final bankHistoryProvider = Provider<BankHistoryRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return BankHistoryRepository(api, apiUrl);
});
