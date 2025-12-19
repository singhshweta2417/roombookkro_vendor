import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../../auth/model/amenities_model.dart';

class AmenitiesRoomRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  AmenitiesRoomRepository(this.apiServices, this.apiUrl);

  Future<AmenitiesModel> getAmenitiesRoomViewApi() async {
    final response = await apiServices.getGetApiResponse(
      apiUrl.getAmenitiesRoom!,
    );
    return AmenitiesModel.fromJson(response);
  }
}

final getAmenitiesRoom = Provider<AmenitiesRoomRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return AmenitiesRoomRepository(api, apiUrl);
});
