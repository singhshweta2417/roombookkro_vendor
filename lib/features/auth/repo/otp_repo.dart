import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';

class OtpRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  OtpRepository(this.apiServices, this.apiUrl);

  Future<dynamic> sentOtpApi(dynamic phoneNumber) async {
    final response = await apiServices.getGetApiResponse(
      "${apiUrl.sendOtp!}mode=test&digit=4&mobile=$phoneNumber",
    );
    return response;
  }

  Future<dynamic> verifyOtpApi(
    dynamic phoneNumber,
    dynamic myControllers,
  ) async {
    final response = await apiServices.getGetApiResponse(
      "${apiUrl.verifyOtp!}$phoneNumber&otp=$myControllers",
    );
    return response;
  }
}

final otpProvider = Provider<OtpRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return OtpRepository(api, apiUrl);
});
