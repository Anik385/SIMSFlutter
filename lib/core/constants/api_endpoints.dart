class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.158:8080';
  // Raw WebSocket endpoint (matches /ws-native above)
  static const String wsUrl = 'ws://192.168.0.158:8080/ws-native';

  // Auth
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';

  // Products
  static const String products = '/api/v1/products';
  static String productById(int id) => '/api/v1/products/$id';
  static String productBySku(String sku) => '/api/v1/products/sku/$sku';

  // Categories / Locations
  static const String categories = '/api/v1/categories';
  static const String locations = '/api/v1/locations';

  // Stock
  static const String stockAdjust = '/api/v1/stock/adjust';

  // Sales
  static const String sales = '/api/v1/sales';
  static String saleById(int id) => '/api/v1/sales/$id';
  static String refundSale(int id) => '/api/v1/sales/$id/refund';

  // Customers
  static const String customers = '/api/v1/customers';

  // Reports
  static const String dashboard = '/api/v1/reports/dashboard';
  static const String salesTrend = '/api/v1/reports/sales-trend';
  static const String topSelling = '/api/v1/reports/top-selling';
  static const String lowStock = '/api/v1/reports/low-stock';

  // WebSocket topics
  // ... rest of your endpoints unchanged
  static const String stockUpdatesTopic = '/topic/stock-updates';
}
