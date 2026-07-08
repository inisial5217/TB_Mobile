import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_ecommerce/core/constants.dart';

// singleton dio http client dengan interceptors
class DioEcommerceClient {
  static DioEcommerceClient? _instance;
  late Dio _dio;

  // callback untuk force logout saat 401
  Function? onUnauthorized;

  // private constructor init
  DioEcommerceClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Constants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // pasang interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequestInterceptor,
        onResponse: _onResponseInterceptor,
        onError: _onErrorInterceptor,
      ),
    );
  }

  // singleton factory
  factory DioEcommerceClient() {
    _instance ??= DioEcommerceClient._internal();
    return _instance!;
  }

  // akses dio instance
  Dio get dio => _dio;

  // interceptor request: inject token otomatis
  Future<void> _onRequestInterceptor(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(Constants.tokenStorageKey);
    if (storedToken != null && storedToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $storedToken';
    }
    if (kDebugMode) {
      debugPrint('🌐 [${options.method}] ${options.uri}');
    }
    handler.next(options);
  }

  // interceptor response: log sukses
  void _onResponseInterceptor(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('✅ [${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  // interceptor error: tangani 401 & error global
  Future<void> _onErrorInterceptor(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint(
          '❌ [${error.response?.statusCode}] ${error.requestOptions.uri}');
    }

    // force logout jika token invalid
    if (error.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenStorageKey);
      await prefs.remove(Constants.userRoleKey);
      onUnauthorized?.call();
    }

    handler.next(error);
  }

  // helper: parse error message dari api response
  static String parseErrorMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Constants.networkErrorMsg;
    }

    if (error.type == DioExceptionType.connectionError) {
      return Constants.networkErrorMsg;
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? Constants.serverErrorMsg;
    }

    if (error.response?.statusCode == 401) {
      return Constants.unauthorizedMsg;
    }

    if (error.response?.statusCode != null &&
        error.response!.statusCode! >= 500) {
      return Constants.serverErrorMsg;
    }

    return Constants.serverErrorMsg;
  }
}
