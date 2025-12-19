// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_exception.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getGetApiResponse(String url) async {
    try {
      if (kDebugMode) print("GET -> $url");

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }
  @override
  Future<dynamic> getDeleteApiResponse(String url) async {
    try {
      if (kDebugMode) print("GET -> $url");

      final response = await http
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }
  @override
  Future<dynamic> getPutApiResponse(String url, dynamic data) async {
    try {
      if (kDebugMode) {
        print("POST -> $url");
        print("Body: $data");
      }

      final response = await http
          .put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }
  @override
  Future<dynamic> getPostApiResponse(String url, dynamic data) async {
    try {
      if (kDebugMode) {
        print("POST -> $url");
        print("Body: $data");
      }

      final response = await http
          .post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  @override
  Future<dynamic> getGetFormDataApiResponse(String url, FormData formData) async {
    try {
      final dio = Dio();

      if (kDebugMode) {
        print("DIO MULTIPART -> $url");
        print("Fields: ${formData.fields}");
        print("Files: ${formData.files.length}");
      }

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      return _returnDioResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw FetchDataException("Request timed out");
      } else if (e.error is SocketException) {
        throw FetchDataException("No Internet Connection");
      } else {
        if (e.response != null) {
          throw FetchDataException("Server Error: ${e.response?.statusCode} - ${e.response?.data}");
        } else {
          throw FetchDataException(e.message ?? "Unknown error occurred");
        }
      }
    }

  }
  @override
  Future<dynamic> getPutFormDataApiResponse(String url, FormData formData) async {
    try {
      final dio = Dio();

      if (kDebugMode) {
        print("DIO MULTIPART -> $url");
        print("Fields: ${formData.fields}");
        print("Files: ${formData.files.length}");
      }

      final response = await dio.patch(
        url,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      return _returnDioResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw FetchDataException("Request timed out");
      } else if (e.error is SocketException) {
        throw FetchDataException("No Internet Connection");
      } else {
        if (e.response != null) {
          throw FetchDataException("Server Error: ${e.response?.statusCode} - ${e.response?.data}");
        } else {
          throw FetchDataException(e.message ?? "Unknown error occurred");
        }
      }
    }

  }

  dynamic _returnDioResponse(Response response) {
    if (response.data == null || (response.data is String && response.data.isEmpty)) {
      return {};
    }

    if (kDebugMode) {
      print("Status: ${response.statusCode}");
      print("Response: ${response.data}");
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;

      case 400:
      case 422:
        throw BadRequestException(response.data.toString());

      case 401:
      case 403:
        throw UnauthorisedException(response.data.toString());

      case 404:
        throw FetchNotFoundException(response.data.toString());

      case 500:
        throw FetchDataException("Server Error: ${response.data}");

      default:
        throw FetchDataException(
            "Unexpected Error: ${response.statusCode} -> ${response.data}");
    }
  }

  dynamic _returnResponse(http.Response response) {
    if (response.body.isEmpty) return {};

    if (kDebugMode) {
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);

      case 400:
      case 422:
        throw BadRequestException(response.body);

      case 401:
      case 403:
        throw UnauthorisedException(response.body);

      case 404:
        throw FetchNotFoundException(response.body);

      case 500:
        throw FetchDataException("Server Error: ${response.body}");

      default:
        throw FetchDataException(
            "Unexpected Error: ${response.statusCode} -> ${response.body}");
    }
  }
}
