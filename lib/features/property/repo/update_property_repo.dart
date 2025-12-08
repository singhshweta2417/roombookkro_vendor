
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';

class UpdatePropertyRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  UpdatePropertyRepository(this.apiServices, this.apiUrl);

  Future<dynamic> updatePropertyApi(FormData  data,residenceId) async {

    final response = await apiServices.getPutFormDataApiResponse(apiUrl.updateProperty!+residenceId, data);
    return response;
  }
}

final updatePropertyRepoProvider = Provider<UpdatePropertyRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return UpdatePropertyRepository(api, apiUrl);
});
