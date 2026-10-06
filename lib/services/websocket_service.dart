import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../core/constants/api_endpoints.dart';

class WebSocketService {
  StompClient? _client;
  final void Function(Map<String, dynamic>) onStockUpdate;
  final void Function()? onConnect;

  WebSocketService({required this.onStockUpdate, this.onConnect});

  void connect() {
    _client = StompClient(
      config: StompConfig(
        url: ApiEndpoints.wsUrl,
        onConnect: _handleConnect,
        onWebSocketError: (e) => print('[WS] error: $e'),
        onStompError: (f) => print('[WS] stomp: ${f.body}'),
        onDisconnect: (_) => print('[WS] disconnected'),
        stompConnectHeaders: {},
        webSocketConnectHeaders: {
          'Origin': 'http://192.168.0.158:8080',
        },
      ),
    );
    _client!.activate();
  }

  void _handleConnect(StompFrame frame) {
    print('[WS] connected');
    onConnect?.call();
    _client!.subscribe(
      destination: ApiEndpoints.stockUpdatesTopic,
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!);
          if (data is Map<String, dynamic>) onStockUpdate(data);
        } catch (e) {
          print('[WS] parse error: $e');
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }
}
