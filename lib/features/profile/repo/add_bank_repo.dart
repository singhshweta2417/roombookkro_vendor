import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class AddBankRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  AddBankRepository(this.apiServices, this.apiUrl);

  Future<dynamic> addBankApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(
      apiUrl.addBank!,
      data,
    );
    return response;
  }
}

final addBankRepoProvider = Provider<AddBankRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return AddBankRepository(api, apiUrl);
});
