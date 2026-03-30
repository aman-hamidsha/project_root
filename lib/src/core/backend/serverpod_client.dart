import 'package:cs310_client/cs310_client.dart';
import 'package:serverpod_client/serverpod_client.dart';

Client createServerpodClient(
  String host, {
  AuthenticationKeyManager? authenticationKeyManager,
}) {
  return Client(host, authenticationKeyManager: authenticationKeyManager);
}
