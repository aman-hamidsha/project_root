/*
 * this file holds the app's backend configuration values.
 * right now it mainly exposes the server base url and reads it from a
 * compile-time dart define so different run targets can point at different
 * backends without needing source edits.
 */

class BackendConfig {
  // falls back to localhost for desktop and browser development on the same
  // machine unless a custom SERVERPOD_SERVER_URL is provided at launch.
  static const String serverUrl = String.fromEnvironment(
    'SERVERPOD_SERVER_URL',
    defaultValue: 'http://localhost:8080/',
  );
}
