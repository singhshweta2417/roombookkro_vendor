import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../model/statics_model.dart';

class StaticsRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  StaticsRepository(this.apiServices, this.apiUrl);

  Future<StaticsModel> staticsApi(String vendorId) async {
    final response = await apiServices.getGetApiResponse(
      "${apiUrl.vendorStatics}$vendorId",
    );

    return StaticsModel.fromJson(response);
  }
}

final staticsProvider = Provider<StaticsRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return StaticsRepository(api, apiUrl);
});
