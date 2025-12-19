import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';
import '../../auth/model/create_session_model.dart';

class CreateSessionRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  CreateSessionRepository(this.apiServices, this.apiUrl);

  Future<CreateSessionModel> getCreateSessionApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(
      apiUrl.createSession!,
      data,
    );
    return CreateSessionModel.fromJson(response);
  }
}

final createSessionProvider = Provider<CreateSessionRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return CreateSessionRepository(api, apiUrl);
});
