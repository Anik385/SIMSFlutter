import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import 'jwt_interceptor.dart';

class DioClient {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static late final Dio dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    dio.interceptors.add(JwtInterceptor(_storage));
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => print('[DIO] $o'),
    ));
  }

  static FlutterSecureStorage get storage => _storage;
}