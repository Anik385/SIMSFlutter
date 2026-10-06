import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_providers.dart';
import 'core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.init();
  runApp(
    MultiProvider(
      providers: appProviders,
      child: const SimsApp(),
    ),
  );
}
