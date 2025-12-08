import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/base_api_services.dart';
import '../../../../core/network/network_provider.dart';
import '../../../../core/routes/api_url.dart';

class CreateCouponRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  CreateCouponRepository(this.apiServices, this.apiUrl);

  Future<dynamic> createCouponApi(data) async {
    // Use POST request for creating coupons
    final response = await apiServices.getPostApiResponse(
      apiUrl.createCoupon!,
      data,
    );
    return response;
  }
}

final createCouponProvider = Provider<CreateCouponRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return CreateCouponRepository(api, apiUrl);
});