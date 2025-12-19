import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../../auth/model/get_enum_model.dart';

class RoomTypeRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  RoomTypeRepository(this.apiServices, this.apiUrl);

  Future<GetEnumModel> roomTypeApi(dynamic data) async {
    final response = await apiServices.getGetApiResponse(
      apiUrl.roomType! + data,
    );
    return GetEnumModel.fromJson(response);
  }
}

final roomTypeRepoProvider = Provider<RoomTypeRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return RoomTypeRepository(api, apiUrl);
});
