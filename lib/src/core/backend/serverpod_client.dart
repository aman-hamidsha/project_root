import 'package:cs310_client/cs310_client.dart';
/**
 * Creates and returns a configured Serverpod client instance.
 * 
 * This client is used to communicate with the Serverpod backend,
 * handling API requests and responses. The provided host defines
 * the server endpoint the client will connect to.
 */

Client createServerpodClient(String host) {
  return Client(host);
}
