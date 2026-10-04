import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';
import '../../models/jwt_response.dart';
import '../../services/api_service.dart';
import '../../services/websocket_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = DioClient.storage;

  bool isLoggedIn = false;
  bool loading = false;
  bool bootstrapping = true;
  String? email;
  String? role;
  ThemeMode themeMode = ThemeMode.light;
  WebSocketService? _ws;

  Future<void> bootstrap() async {
    final token = await _storage.read(key: 'jwt_token');
    email = await _storage.read(key: 'user_email');
    role = await _storage.read(key: 'user_role');
    isLoggedIn = token != null && token.isNotEmpty;

    final prefs = await SharedPreferences.getInstance();
    themeMode = (prefs.getBool('dark_mode') ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;

    if (isLoggedIn) _startWebSocket();
    bootstrapping = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, bool remember) async {
    loading = true;
    notifyListeners();
    try {
      final JwtResponse res = await _api.login(email, password);
      await _storage.write(key: 'jwt_token', value: res.token);
      await _storage.write(key: 'user_email', value: res.email);
      await _storage.write(key: 'user_role', value: res.role);

      this.email = res.email;
      role = res.role;
      isLoggedIn = true;
      _startWebSocket();
      return true;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _ws?.disconnect();
    _ws = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_role');
    isLoggedIn = false;
    email = null;
    role = null;
    notifyListeners();
  }

  bool get isAdminOrManager =>
      role == 'ADMIN' || role == 'MANAGER' || role == 'ROLE_ADMIN' ||
      role == 'ROLE_MANAGER';

  Future<void> toggleDarkMode(bool value) async {
    themeMode = value ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  void _startWebSocket() {
    _ws = WebSocketService(
      onStockUpdate: (_) {},
    )..connect();
  }
}