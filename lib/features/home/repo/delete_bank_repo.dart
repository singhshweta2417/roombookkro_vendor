import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class BankDeleteRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  BankDeleteRepository(this.apiServices, this.apiUrl);

  Future<dynamic> bankDeleteApi(data) async {
    final response = await apiServices.getDeleteApiResponse(
      apiUrl.bankDelete! + data,
    );
    return response;
  }
}

final bankDeleteProvider = Provider<BankDeleteRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return BankDeleteRepository(api, apiUrl);
});
