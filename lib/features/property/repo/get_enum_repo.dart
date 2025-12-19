import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../../auth/model/get_enum_model.dart';

class AddPropertyTypeRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  AddPropertyTypeRepository(this.apiServices, this.apiUrl);

  Future<GetEnumModel> propertyTypeApi() async {
    final response = await apiServices.getGetApiResponse(apiUrl.propertyType!);
    return GetEnumModel.fromJson(response);
  }
}

final propertyTypeRepoProvider = Provider<AddPropertyTypeRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return AddPropertyTypeRepository(api, apiUrl);
});
