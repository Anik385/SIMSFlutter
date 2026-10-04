import 'package:flutter/material.dart';
import '../../models/dashboard_stats.dart';
import '../../models/product_response.dart';
import '../../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  DashboardStats stats = DashboardStats.empty();
  List<SalesTrendPoint> trend = [];
  List<TopProduct> topProducts = [];
  List<ProductResponse> lowStock = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.getDashboard(),
        _api.getSalesTrend(),
        _api.getTopSelling(),
        _api.getLowStock(),
      ]);
      stats = results[0] as DashboardStats;
      trend = results[1] as List<SalesTrendPoint>;
      topProducts = results[2] as List<TopProduct>;
      lowStock = results[3] as List<ProductResponse>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}