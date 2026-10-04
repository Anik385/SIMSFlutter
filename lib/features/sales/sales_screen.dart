import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'sale_detail_screen.dart';
import 'sales_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SalesProvider>();
      p.load();
      p.startRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SalesProvider>();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Sales',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: p.loading && p.sales.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => p.load(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: p.sales.length,
                itemBuilder: (_, i) {
                  final s = p.sales[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: const Icon(Icons.receipt_long,
                            color: AppColors.primary),
                      ),
                      title: Text(s.invoiceNumber ?? 'Sale #${s.id}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${s.customerName ?? 'Walk-in'} • ${Formatters.date(s.createdAt)}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(Formatters.money(s.totalAmount),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success)),
                          const SizedBox(height: 4),
                          Text(s.status,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: s.status == 'REFUNDED'
                                      ? AppColors.danger
                                      : Colors.grey.shade600)),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SaleDetailScreen(sale: s)),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}