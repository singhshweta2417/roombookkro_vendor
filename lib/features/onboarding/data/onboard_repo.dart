import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';
import '../../auth/model/onboard_model.dart';

class OnboardRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  OnboardRepository(this.apiServices, this.apiUrl);

  Future<OnboardModel> onboardApi() async {
    try {
      final response = await apiServices.getGetApiResponse(
        apiUrl.getOnboardPage!,
      );
      return OnboardModel.fromJson(response);
    } catch (e) {
      // Re-throw with more context if needed
      throw Exception('Failed to fetch onboarding data: $e');
    }
  }
}

final onboardRepoProvider = Provider<OnboardRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return OnboardRepository(api, apiUrl);
});