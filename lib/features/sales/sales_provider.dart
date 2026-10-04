import 'package:flutter/material.dart';
import '../../models/sale_response.dart';
import '../../services/api_service.dart';
import '../../services/websocket_service.dart';

class SalesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<SaleResponse> sales = [];
  bool loading = false;
  String? error;
  WebSocketService? _ws;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      sales = await _api.getSales();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void startRealtime() {
    _ws ??= WebSocketService(
      onStockUpdate: (_) => load(),
    )..connect();
  }

  @override
  void dispose() {
    _ws?.disconnect();
    super.dispose();
  }
}