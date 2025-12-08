import 'package:dio/dio.dart';

abstract class BaseApiServices {
  Future<dynamic> getGetApiResponse(String url);

  Future<dynamic> getPostApiResponse(String url, dynamic data);

// BaseApiServices class mein
  Future<dynamic> getGetFormDataApiResponse(String url, FormData data);
  Future<dynamic> getPutFormDataApiResponse(String url, FormData data);
}
