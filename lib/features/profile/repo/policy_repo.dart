import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../../auth/model/policy_model.dart';

class PolicyRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  PolicyRepository(this.apiServices, this.apiUrl);

  Future<PolicyModel> policyApi(dynamic data) async {

    try {
      final response = await apiServices.getGetApiResponse(apiUrl.policyUrl!+data);
      return PolicyModel.fromJson(response);
    } catch (e, stackTrace) {
      print("❌ [Profile Update] Error: $e");
      print("❌ [Profile Update] StackTrace: $stackTrace");
      rethrow;
    }
  }
}

final policyRepoProvider = Provider<PolicyRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return PolicyRepository(api, apiUrl);
});
