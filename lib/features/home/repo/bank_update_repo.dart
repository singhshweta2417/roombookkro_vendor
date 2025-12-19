import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class BankUpdateRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  BankUpdateRepository(this.apiServices, this.apiUrl);

  Future<dynamic> bankUpdateApi(String bankId, Map<String, dynamic> data) async {
    final response = await apiServices.getPutApiResponse(
      apiUrl.bankUpdate! + bankId,
      data,
    );
    return response;
  }
}

final bankUpdateProvider = Provider<BankUpdateRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return BankUpdateRepository(api, apiUrl);
});
