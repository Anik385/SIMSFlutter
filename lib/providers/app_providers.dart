import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../features/auth/auth_provider.dart';
import '../features/dashboard/dashboard_provider.dart';
import '../features/products/products_provider.dart';
import '../features/scanner/scanner_provider.dart';
import '../features/sales/sales_provider.dart';
import '../services/api_service.dart';

final List<SingleChildWidget> appProviders = [
  Provider<ApiService>(create: (_) => ApiService()),
  ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
  ChangeNotifierProvider(create: (_) => DashboardProvider()),
  ChangeNotifierProvider(create: (_) => ProductsProvider()),
  ChangeNotifierProvider(create: (_) => ScannerProvider()),
  ChangeNotifierProvider(create: (_) => SalesProvider()),
];