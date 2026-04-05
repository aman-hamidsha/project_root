import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app.dart';

/**
 * This is the main entry point of the application. 
 * It initializes the Flutter bindings and runs the app 
 * wrapped in a ProviderScope, which allows us to use 
 * Riverpod for state management throughout the app.
 */
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}
