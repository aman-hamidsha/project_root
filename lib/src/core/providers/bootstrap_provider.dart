import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/app_bootstrap.dart';

/*
 * this file exposes the app bootstrap object through riverpod.
 * main() creates the real AppBootstrap and overrides this provider so the rest
 * of the widget tree can read the shared backend client and auth manager.
 */

final appBootstrapProvider = Provider<AppBootstrap>(
  // this throws by default on purpose so the app fails fast if main() forgets
  // to provide the real bootstrap dependency.
  (ref) => throw UnimplementedError('AppBootstrap must be overridden in main().'),
);
