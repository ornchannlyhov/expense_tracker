import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiService._(this._dio, this._secureStorage);
  static ApiService? _instance;

  factory ApiService() {
    _instance ??= _initialize();
    return _instance!;
  }

  static ApiService _initialize() {
      final dio = Dio(BaseOptions(
        baseUrl: kApiBaseUrl, connectTimeout: kApiTimeoutDuration,
        receiveTimeout: kApiTimeoutDuration,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ));
      final secureStorage = FlutterSecureStorage();
      final service = ApiService._(dio, secureStorage);
      service._setupInterceptors();
      return service;
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _secureStorage;

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: kAuthTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) print('--> ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) print('<-- ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) print('<-- Error ${e.response?.statusCode} ${e.requestOptions.uri}\n   Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }
}

Dio getDioInstance() => ApiService().dio;
FlutterSecureStorage getSecureStorageInstance() => ApiService().storage;