import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_wireframe_shell.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWireframeShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthWireframePrimaryButton(
            label: 'Sign Up',
            onPressed: () => context.go('/signup'),
          ),
          const SizedBox(height: 18),
          AuthWireframePrimaryButton(
            label: 'Log In',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
