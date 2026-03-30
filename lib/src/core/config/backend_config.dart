class BackendConfig {
  static const String serverUrl = String.fromEnvironment(
    'SERVERPOD_SERVER_URL',
    defaultValue: 'http://localhost:8080/',
  );
}
