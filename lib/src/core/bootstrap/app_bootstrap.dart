import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:cs310_client/cs310_client.dart';

import '../backend/serverpod_client.dart';
import '../config/backend_config.dart';

/*
 * this file wires up the app's backend bootstrap step.
 * it creates the shared Serverpod client, connects it to flutter auth session
 * storage, and returns the objects the rest of the app needs during startup.
 */

class AppBootstrap {
  AppBootstrap({
    required this.client,
    required this.auth,
  });

  final Client client;
  final FlutterAuthSessionManager auth;

  static Future<AppBootstrap> initialize() async {
    // auth session manager persists auth state locally and also supplies tokens
    // back to the client for authenticated backend requests.
    final auth = FlutterAuthSessionManager();
    final client = createServerpodClient(BackendConfig.serverUrl)
      ..authKeyProvider = auth
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = auth;

    // the auth manager must be initialized before the app starts using the
    // client so any saved session can be restored first.
    await auth.initialize();

    return AppBootstrap(client: client, auth: auth);
  }
}
