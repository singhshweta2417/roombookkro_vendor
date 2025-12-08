import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/base_api_services.dart';
import '../../../core/network/network_provider.dart';
import '../../../core/routes/api_url.dart';

class AddOfferRepository {
  final BaseApiServices apiServices;
  final ApiUrl apiUrl;

  AddOfferRepository(this.apiServices, this.apiUrl);

  Future<dynamic> addPropertyApi(dynamic data) async {
    final response = await apiServices.getPostApiResponse(apiUrl.create!, data);
    return response;
  }
}

final createCouponRepoProvider = Provider<AddOfferRepository>((ref) {
  final api = ref.read(networkApiProvider);
  final apiUrl = ref.read(apiUrlProvider);
  return AddOfferRepository(api, apiUrl);
});
