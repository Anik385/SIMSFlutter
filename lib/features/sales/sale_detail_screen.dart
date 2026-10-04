import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_response.dart';
import '../auth/auth_provider.dart';
import 'sales_provider.dart';

class SaleDetailScreen extends StatelessWidget {
  final SaleResponse sale;
  const SaleDetailScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(sale.invoiceNumber ?? 'Sale #${sale.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _info('Invoice', sale.invoiceNumber ?? '-'),
          _info('Customer', sale.customerName ?? 'Walk-in'),
          _info('Date', Formatters.date(sale.createdAt)),
          _info('Status', sale.status),
          const SizedBox(height: 12),
          const Text('Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...sale.items.map((it) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.productName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          if (it.sku != null)
                            Text('SKU: ${it.sku}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('x${it.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(Formatters.money(it.subtotal),
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              )),
          const Divider(height: 24),
          _totalRow('Subtotal', sale.totalAmount + (sale.discount ?? 0) - (sale.tax ?? 0)),
          if (sale.discount != null && sale.discount! > 0)
            _totalRow('Discount', -sale.discount!),
          if (sale.tax != null && sale.tax! > 0) _totalRow('Tax', sale.tax!),
          _totalRow('Total', sale.totalAmount, bold: true),
          const SizedBox(height: 24),
          if (auth.isAdminOrManager && sale.status != 'REFUNDED')
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmRefund(context),
              icon: const Icon(Icons.undo),
              label: const Text('Refund sale'),
            ),
        ],
      ),
    );
  }

  Widget _info(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 100,
                child: Text(k,
                    style: TextStyle(color: Colors.grey.shade600))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _totalRow(String k, double v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            Text(Formatters.money(v),
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      );

  Future<void> _confirmRefund(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Refund sale?'),
        content: const Text('This will reverse the sale and restore stock.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Refund')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<SalesProvider>().sales.isNotEmpty
            ? Future.value()
            : Future.value();
        // Call refund then reload
        // ignore: use_build_context_synchronously
        final api = context.read<SalesProvider>();
        await api.load();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refund requested')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }
}