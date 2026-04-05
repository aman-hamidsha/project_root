import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import 'theme.dart';

/**
 * The App widget is the root of the application. 
 * It uses ConsumerWidget from Riverpod to access the app's state, \
 * such as the router and theme mode.
 * It builds a MaterialApp.router, which is configured with the app's router 
 * and themes.
 */

class App extends ConsumerWidget {
  const App({super.key}); // constructor with optional key

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(
      appRouterProvider,
    ); // watching the router to get GoRouter instance
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CS310',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: themeMode,
      routerConfig: router, // attach GoRouter config for navigation
    );
  }
}
