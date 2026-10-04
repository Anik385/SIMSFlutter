import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_response.dart';
import 'products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductResponse product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.primaryDark.withOpacity(0.05)
              ]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          _row('Name', product.name),
          _row('SKU', product.sku),
          _row('Price', Formatters.money(product.price)),
          _row('Quantity', '${product.quantity}'),
          _row('Category', product.categoryName ?? '-'),
          _row('Location', product.locationName ?? '-'),
          if (product.description != null) _row('Description', product.description!),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 110,
                child: Text(k,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}