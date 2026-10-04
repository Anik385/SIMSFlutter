import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'scanner_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    _handled = true;
    context.read<ScannerProvider>().lookup(code);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ScannerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          if (p.loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (p.product != null) _productSheet(context, p),
          if (p.error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Material(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(p.error!,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productSheet(BuildContext context, ScannerProvider p) {
    final prod = p.product!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prod.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('SKU: ${prod.sku}',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _handled = false;
                      p.reset();
                    },
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stock: ${prod.quantity}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(Formatters.money(prod.price),
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _action('+1', () => _adjust(context, p, 1)),
                const SizedBox(width: 8),
                _action('-1', () => _adjust(context, p, -1)),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _custom(context, p),
                    child: const Text('Custom'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(String label, VoidCallback onTap) => SizedBox(
        width: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      );

  Future<void> _adjust(BuildContext context, ScannerProvider p, int qty) async {
    await p.adjust(qty, qty > 0 ? 'Scan add' : 'Scan remove');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adjusted by $qty'), backgroundColor: AppColors.success),
    );
  }

  Future<void> _custom(BuildContext context, ScannerProvider p) async {
    final qty = TextEditingController();
    final reason = ValueNotifier<String>('Adjustment');
    final reasons = ['Adjustment', 'Damage', 'Return', 'Restock', 'Correction'];
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom adjustment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Quantity (e.g. -3 or 5)'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: reason,
              builder: (_, v, __) => DropdownButtonFormField<String>(
                value: v,
                items: reasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (x) => reason.value = x ?? 'Adjustment',
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () async {
              final n = int.tryParse(qty.text);
              if (n == null) return;
              Navigator.pop(context);
              await p.adjust(n, reason.value);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Adjusted by $n'),
                    backgroundColor: AppColors.success),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}