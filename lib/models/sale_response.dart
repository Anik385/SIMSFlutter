class SaleItemResponse {
  final int? id;
  final int? productId;
  final String productName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemResponse({
    this.id,
    this.productId,
    required this.productName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItemResponse.fromJson(Map<String, dynamic> j) => SaleItemResponse(
        id: j['id'],
        productId: j['productId'] ?? j['product']?['id'],
        productName:
            j['productName'] ?? j['product']?['name'] ?? 'Unknown product',
        sku: j['sku'] ?? j['product']?['sku'],
        quantity: j['quantity'] ?? 0,
        unitPrice: (j['unitPrice'] ?? j['price'] ?? 0).toDouble(),
        subtotal: (j['subtotal'] ?? j['total'] ?? 0).toDouble(),
      );
}

class SaleResponse {
  final int id;
  final String? invoiceNumber;
  final String? customerName;
  final DateTime? createdAt;
  final double totalAmount;
  final double? discount;
  final double? tax;
  final String status;
  final List<SaleItemResponse> items;

  SaleResponse({
    required this.id,
    this.invoiceNumber,
    this.customerName,
    this.createdAt,
    required this.totalAmount,
    this.discount,
    this.tax,
    required this.status,
    required this.items,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> j) => SaleResponse(
        id: j['id'] ?? 0,
        invoiceNumber: j['invoiceNumber'] ?? j['invoiceNo'],
        customerName: j['customerName'] ?? j['customer']?['name'],
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
        totalAmount: (j['totalAmount'] ?? j['total'] ?? 0).toDouble(),
        discount: (j['discount'] ?? 0).toDouble(),
        tax: (j['tax'] ?? 0).toDouble(),
        status: j['status'] ?? 'COMPLETED',
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => SaleItemResponse.fromJson(e))
            .toList(),
      );
}