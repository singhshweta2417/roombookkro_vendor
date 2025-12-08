import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../../auth/model/profile_model.dart';

class ProfileRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  ProfileRepository(this.apiServices, this.apiUrl);

  Future<dynamic> profileUpdateApi(dynamic userID, dynamic data) async {
    final url = "${apiUrl.profileUpdateUrl}$userID";

    try {
      final response = await apiServices.getPostApiResponse(url, data);
      return response;
    } catch (e, stackTrace) {
      print("❌ [Profile Update] Error: $e");
      print("❌ [Profile Update] StackTrace: $stackTrace");
      rethrow;
    }
  }

  Future<ProfileModel> profileViewApi(dynamic userID) async {
    final url = "${apiUrl.profileUpdateUrl}$userID";

    try {
      final response = await apiServices.getGetApiResponse(url);
      print("✅ [Profile Update] Response: $response");
      return ProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      print("❌ [Profile Update] Error: $e");
      print("❌ [Profile Update] StackTrace: $stackTrace");
      rethrow;
    }
  }
}

final profileUpdateProvider = Provider<ProfileRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return ProfileRepository(api, apiUrl);
});
