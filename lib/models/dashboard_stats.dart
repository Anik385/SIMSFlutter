class DashboardStats {
  final int totalProducts;
  final double totalRevenue;
  final double monthlyRevenue;
  final int lowStockCount;
  final int totalCustomers;
  final int totalSales;

  DashboardStats({
    required this.totalProducts,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.lowStockCount,
    this.totalCustomers = 0,
    this.totalSales = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        totalProducts: j['totalProducts'] ?? j['productCount'] ?? 0,
        totalRevenue: (j['totalRevenue'] ?? j['revenue'] ?? 0).toDouble(),
        monthlyRevenue:
            (j['monthlyRevenue'] ?? j['thisMonth'] ?? j['revenueThisMonth'] ?? 0)
                .toDouble(),
        lowStockCount: j['lowStockCount'] ?? j['lowStock'] ?? 0,
        totalCustomers: j['totalCustomers'] ?? 0,
        totalSales: j['totalSales'] ?? j['salesCount'] ?? 0,
      );

  static DashboardStats empty() => DashboardStats(
        totalProducts: 0,
        totalRevenue: 0,
        monthlyRevenue: 0,
        lowStockCount: 0,
      );
}

class SalesTrendPoint {
  final DateTime date;
  final double total;
  SalesTrendPoint(this.date, this.total);

  factory SalesTrendPoint.fromJson(Map<String, dynamic> j) => SalesTrendPoint(
        DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        (j['total'] ?? j['amount'] ?? 0).toDouble(),
      );
}

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;
  TopProduct(this.name, this.quantity, this.revenue);

  factory TopProduct.fromJson(Map<String, dynamic> j) => TopProduct(
        j['name'] ?? j['productName'] ?? 'Unknown',
        j['quantity'] ?? j['totalSold'] ?? 0,
        (j['revenue'] ?? 0).toDouble(),
      );
}