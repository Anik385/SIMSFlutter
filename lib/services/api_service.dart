import 'package:dio/dio.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';
import '../models/dashboard_stats.dart';
import '../models/jwt_response.dart';
import '../models/product_response.dart';
import '../models/sale_response.dart';

class ApiService {
  final Dio _dio = DioClient.dio;

  // ---------- AUTH ----------
  Future<JwtResponse> login(String email, String password) async {
    final res = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    if (res.statusCode == 200 && res.data != null) {
      return JwtResponse.fromJson(res.data);
    }
    throw Exception(
        res.data?['message'] ?? 'Login failed (${res.statusCode})');
  }

  // ---------- DASHBOARD ----------
  Future<DashboardStats> getDashboard() async {
    final res = await _dio.get(ApiEndpoints.dashboard);
    return DashboardStats.fromJson(res.data ?? {});
  }

  Future<List<SalesTrendPoint>> getSalesTrend({int days = 7}) async {
    final res = await _dio.get(
      ApiEndpoints.salesTrend,
      queryParameters: {'days': days},
    );
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? []);
    return (list as List).map((e) => SalesTrendPoint.fromJson(e)).toList();
  }

  Future<List<TopProduct>> getTopSelling({int limit = 5}) async {
    final res = await _dio.get(
      ApiEndpoints.topSelling,
      queryParameters: {'limit': limit},
    );
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? []);
    return (list as List).map((e) => TopProduct.fromJson(e)).toList();
  }

  Future<List<ProductResponse>> getLowStock() async {
    final res = await _dio.get(ApiEndpoints.lowStock);
    final data = res.data;
    final list = data is List ? data : (data['data'] ?? []);
    return (list as List).map((e) => ProductResponse.fromJson(e)).toList();
  }

  // ---------- PRODUCTS ----------
  Future<List<ProductResponse>> getProducts({String? search}) async {
    final res = await _dio.get(
      ApiEndpoints.products,
      queryParameters: search != null && search.isNotEmpty
          ? {'search': search}
          : null,
    );
    final data = res.data;
    final list = data is List ? data : (data['content'] ?? data['data'] ?? []);
    return (list as List).map((e) => ProductResponse.fromJson(e)).toList();
  }

  Future<ProductResponse> getProductBySku(String sku) async {
    final res = await _dio.get(ApiEndpoints.productBySku(sku));
    return ProductResponse.fromJson(res.data);
  }

  Future<ProductResponse> getProductById(int id) async {
    final res = await _dio.get(ApiEndpoints.productById(id));
    return ProductResponse.fromJson(res.data);
  }

  Future<ProductResponse> createProduct(Map<String, dynamic> payload) async {
    final res = await _dio.post(ApiEndpoints.products, data: payload);
    return ProductResponse.fromJson(res.data);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete(ApiEndpoints.productById(id));
  }

  // ---------- STOCK ----------
  Future<void> adjustStock({
    required int productId,
    required int quantity,
    required String reason,
  }) async {
    await _dio.post(ApiEndpoints.stockAdjust, data: {
      'productId': productId,
      'quantity': quantity,
      'reason': reason,
    });
  }

  // ---------- SALES ----------
  Future<List<SaleResponse>> getSales() async {
    final res = await _dio.get(ApiEndpoints.sales);
    final data = res.data;
    final list = data is List ? data : (data['content'] ?? data['data'] ?? []);
    return (list as List).map((e) => SaleResponse.fromJson(e)).toList();
  }

  Future<SaleResponse> getSaleById(int id) async {
    final res = await _dio.get(ApiEndpoints.saleById(id));
    return SaleResponse.fromJson(res.data);
  }

  Future<void> refundSale(int id) async {
    await _dio.post(ApiEndpoints.refundSale(id));
  }
}