import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<ProductResponse> items = [];
  bool loading = false;
  String? error;
  String search = '';
  String? categoryFilter;

  List<String> get categories => items
      .map((e) => e.categoryName ?? '')
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();

  List<ProductResponse> get filtered {
    var list = items;
    if (search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(s) ||
              p.sku.toLowerCase().contains(s))
          .toList();
    }
    if (categoryFilter != null) {
      list = list.where((p) => p.categoryName == categoryFilter).toList();
    }
    return list;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _api.getProducts();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setSearch(String s) {
    search = s;
    notifyListeners();
  }

  void setCategory(String? c) {
    categoryFilter = c;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _api.deleteProduct(id);
    items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final created = await _api.createProduct(payload);
    items.insert(0, created);
    notifyListeners();
  }
}