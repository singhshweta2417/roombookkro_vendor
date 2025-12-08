import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../../auth/model/amenities_model.dart';

class AmenitiesPropertyRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  AmenitiesPropertyRepository(this.apiServices, this.apiUrl);

  Future<AmenitiesModel> getAmenitiesPropertyViewApi() async {
    final response = await apiServices.getGetApiResponse(apiUrl.getAmenities!);
    return AmenitiesModel.fromJson(response);
  }
}

final getAmenitiesProperty = Provider<AmenitiesPropertyRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return AmenitiesPropertyRepository(api, apiUrl);
});
