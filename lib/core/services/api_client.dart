import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import 'secure_storage_service.dart';

/// Singleton Dio client used by repositories. Adds auth headers, request
/// logging, and a hook for certificate pinning in production.
class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;
  static ApiClient? _instance;

  static ApiClient init({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Client': 'mythrix.flutter/${AppConstants.appVersion}',
        },
      ),
    );

    final logger = Logger();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.instance.readSecure(AppConstants.kAuthToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            logger.w('API ${e.requestOptions.method} ${e.requestOptions.path} → ${e.response?.statusCode}');
          }
          if (e.response?.statusCode == 401) {
            // TODO: refresh-token flow / sign-out trigger.
          }
          handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          logPrint: (o) => logger.d(o.toString()),
        ),
      );
    }

    _instance = ApiClient._(dio);
    return _instance!;
  }

  static ApiClient get instance {
    final i = _instance;
    if (i == null) throw StateError('ApiClient not initialized.');
    return i;
  }
}
