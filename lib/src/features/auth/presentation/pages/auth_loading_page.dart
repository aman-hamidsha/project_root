import 'package:flutter/material.dart';

/*
 * this file contains the temporary loading screen shown while the app figures
 * out the current auth state and the router decides where the user should go.
 */

class AuthLoadingPage extends StatelessWidget {
  const AuthLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
