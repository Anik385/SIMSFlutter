import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../services/api_service.dart';

class ScannerProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  ProductResponse? product;
  bool loading = false;
  String? error;

  Future<void> lookup(String sku) async {
    loading = true;
    error = null;
    product = null;
    notifyListeners();
    try {
      product = await _api.getProductBySku(sku);
    } catch (e) {
      error = 'Product not found for SKU: $sku';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> adjust(int qty, String reason) async {
    if (product == null) return;
    await _api.adjustStock(
        productId: product!.id, quantity: qty, reason: reason);
    // Optimistically update
    product = ProductResponse(
      id: product!.id,
      name: product!.name,
      sku: product!.sku,
      description: product!.description,
      price: product!.price,
      quantity: product!.quantity + qty,
      lowStockThreshold: product!.lowStockThreshold,
      imageUrl: product!.imageUrl,
      categoryName: product!.categoryName,
      categoryId: product!.categoryId,
      locationName: product!.locationName,
      locationId: product!.locationId,
    );
    notifyListeners();
  }

  void reset() {
    product = null;
    error = null;
    notifyListeners();
  }
}