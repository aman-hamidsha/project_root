import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/app_bootstrap.dart';

final appBootstrapProvider = Provider<AppBootstrap>(
  (ref) => throw UnimplementedError('AppBootstrap must be overridden in main().'),
);
