import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';

class OtpRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  OtpRepository(this.apiServices, this.apiUrl);

  Future<dynamic> sentOtpApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(
      apiUrl.sendOtp!,data
    );
    return response;
  }
  Future<dynamic> verifyOtpApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(
      apiUrl.verifyOtp!,data
    );
    return response;
  }

}

final otpProvider = Provider<OtpRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return OtpRepository(api, apiUrl);
});
