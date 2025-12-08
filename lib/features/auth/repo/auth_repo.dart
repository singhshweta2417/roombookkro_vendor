import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';
import '../model/user_model.dart';

class AuthRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  AuthRepository(this.apiServices, this.apiUrl);

  Future<UserModel> signUpApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(apiUrl.signUpUrl!, data);
    return UserModel.fromJson(response);
  }

}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return AuthRepository(api, apiUrl);
});
