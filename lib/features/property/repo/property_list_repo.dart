import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../property_model.dart';

class GetPropertyRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  GetPropertyRepository(this.apiServices, this.apiUrl);

  Future<AddPropertyListModel> getPropertyViewApi(dynamic data) async {
    final response = await apiServices.getGetApiResponse(apiUrl.getVendorProperty!+data);
    return AddPropertyListModel.fromJson(response);
  }
}

// In your get_property_repo.dart file, change this:
final getProperty = Provider<GetPropertyRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return GetPropertyRepository(api, apiUrl);
});
