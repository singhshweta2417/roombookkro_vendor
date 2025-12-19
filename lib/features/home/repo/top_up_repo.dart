import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';
import '../../auth/model/top_up_model.dart';

class TopUpRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  TopUpRepository(this.apiServices, this.apiUrl);

  Future<TopUpModel> topUpApi() async {
    final response = await apiServices.getGetApiResponse(
        apiUrl.topUp!
    );
    return TopUpModel.fromJson(response);
  }
}

final topUpRepoProvider = Provider<TopUpRepository>((
    ref,
    ) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return TopUpRepository(api, apiUrl);
});
