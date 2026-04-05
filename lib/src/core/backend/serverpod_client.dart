import 'package:cs310_client/cs310_client.dart';

/**
 * this file exposes the small factory used to create the app's Serverpod
 * client. keeping client creation in one place makes it easier to change the
 * host, shared configuration, or auth wiring later without touching every
 * screen that needs backend access.
 */

Client createServerpodClient(String host) {
  // the host usually comes from a dart define so different platforms can point
  // at localhost, a lan ip, or a deployed server without code changes.
  return Client(host);
}
