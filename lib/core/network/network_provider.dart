import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_api_services.dart';
import 'network_api_services.dart';

final networkApiProvider = Provider<BaseApiServices>((ref) {
  return NetworkApiServices();
});
