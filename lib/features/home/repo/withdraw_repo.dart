import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/features/auth/model/deposit_history_model.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class WithdrawRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  WithdrawRepository(this.apiServices, this.apiUrl);

  Future<dynamic> withdrawApi(data) async {
    final response = await apiServices.getPostApiResponse(
      apiUrl.withdrawRequest!,
      data,
    );
    return response;
  }
}

final withdrawProvider = Provider<WithdrawRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return WithdrawRepository(api, apiUrl);
});
