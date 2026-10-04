class ProductResponse {
  final int id;
  final String name;
  final String sku;
  final String? description;
  final double price;
  final int quantity;
  final int? lowStockThreshold;
  final String? imageUrl;
  final String? categoryName;
  final int? categoryId;
  final String? locationName;
  final int? locationId;

  ProductResponse({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    required this.price,
    required this.quantity,
    this.lowStockThreshold,
    this.imageUrl,
    this.categoryName,
    this.categoryId,
    this.locationName,
    this.locationId,
  });

  bool get isLowStock =>
      lowStockThreshold != null && quantity <= lowStockThreshold!;

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed',
      sku: json['sku'] ?? '',
      description: json['description'],
      price: (json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? json['stock'] ?? 0,
      lowStockThreshold:
          json['lowStockThreshold'] ?? json['reorderLevel'] ?? 10,
      imageUrl: json['imageUrl'] ?? json['image'],
      categoryName: json['categoryName'] ?? json['category']?['name'],
      categoryId: json['categoryId'] ?? json['category']?['id'],
      locationName: json['locationName'] ?? json['location']?['name'],
      locationId: json['locationId'] ?? json['location']?['id'],
    );
  }
}