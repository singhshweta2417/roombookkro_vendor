import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/features/auth/model/ifsc_model.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class IfscRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  IfscRepository(this.apiServices, this.apiUrl);

  Future<IfscModel> ifscApi(data) async {
    final response = await apiServices.getPostApiResponse(apiUrl.ifsc!, data);
    return IfscModel.fromJson(response);
  }
}

final ifscProvider = Provider<IfscRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return IfscRepository(api, apiUrl);
});
