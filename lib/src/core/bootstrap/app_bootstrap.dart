import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:cs310_client/cs310_client.dart';

import '../backend/serverpod_client.dart';
import '../config/backend_config.dart';

class AppBootstrap {
  AppBootstrap({
    required this.client,
    required this.auth,
  });

  final Client client;
  final FlutterAuthSessionManager auth;

  static Future<AppBootstrap> initialize() async {
    final auth = FlutterAuthSessionManager();
    final client = createServerpodClient(BackendConfig.serverUrl)
      ..authKeyProvider = auth
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = auth;

    await auth.initialize();

    return AppBootstrap(client: client, auth: auth);
  }
}
