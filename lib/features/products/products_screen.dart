import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../auth/auth_provider.dart';
import 'product_detail_screen.dart';
import 'products_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductsProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: auth.isAdminOrManager
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _showAddProductDialog(context, p),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => p.setSearch(v),
              decoration: const InputDecoration(
                hintText: 'Search by name or SKU',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('All', p.categoryFilter == null,
                    () => p.setCategory(null)),
                ...p.categories.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _chip(
                          c, p.categoryFilter == c, () => p.setCategory(c)),
                    )),
              ],
            ),
          ),
          Expanded(
            child: p.loading && p.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => p.load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: p.filtered.length,
                      itemBuilder: (_, i) {
                        final prod = p.filtered[i];
                        return Dismissible(
                          key: ValueKey(prod.id),
                          direction: auth.isAdminOrManager
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) => p.delete(prod.id),
                          child: Container(
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
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: prod.imageUrl != null &&
                                          prod.imageUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: prod.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              _placeholder(),
                                        )
                                      : _placeholder(),
                                ),
                              ),
                              title: Text(prod.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text('SKU: ${prod.sku}'),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(Formatters.money(prod.price),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (prod.isLowStock
                                              ? AppColors.danger
                                              : AppColors.success)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('${prod.quantity}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: prod.isLowStock
                                                ? AppColors.danger
                                                : AppColors.success)),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: prod),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.inventory_2, color: AppColors.primary),
      );

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: TextStyle(
          color: active ? AppColors.primary : null,
          fontWeight: active ? FontWeight.bold : FontWeight.normal),
      side: BorderSide(color: active ? AppColors.primary : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Delete')),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext ctx, ProductsProvider p) {
    final name = TextEditingController();
    final sku = TextEditingController();
    final price = TextEditingController();
    final qty = TextEditingController();
    final desc = TextEditingController();

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Add product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(
                  controller: sku,
                  decoration: const InputDecoration(labelText: 'SKU')),
              const SizedBox(height: 8),
              TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Price')),
              const SizedBox(height: 8),
              TextField(
                  controller: qty,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Quantity')),
              const SizedBox(height: 8),
              TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (name.text.isEmpty || sku.text.isEmpty) return;
              try {
                await p.create({
                  'name': name.text.trim(),
                  'sku': sku.text.trim(),
                  'price': double.tryParse(price.text) ?? 0,
                  'quantity': int.tryParse(qty.text) ?? 0,
                  'description': desc.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}