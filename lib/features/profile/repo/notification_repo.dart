import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';
import '../../auth/model/notification_model.dart';

class NotificationRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  NotificationRepository(this.apiServices, this.apiUrl);

  Future<NotificationModel> notificationApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(
      apiUrl.notification!,
      data,
    );
    return NotificationModel.fromJson(response);
  }
}

final notificationRepoProvider = Provider<NotificationRepository>((
  ref,
) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return NotificationRepository(api, apiUrl);
});
