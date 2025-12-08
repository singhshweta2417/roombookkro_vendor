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
    final response = await apiServices.getGetApiResponse(apiUrl.getOnboardPage!);
    return OnboardModel.fromJson(response);
  }
}

// In your get_property_repo.dart file, change this:
final onboardRepoProvider = Provider<OnboardRepository>((
    ref,
    ) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return OnboardRepository(api, apiUrl);
});
