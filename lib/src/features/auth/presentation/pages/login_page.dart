import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_controller.dart';
import '../../domain/auth_state.dart';
import '../widgets/auth_wireframe_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthWireframeShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthWireframeField(
            controller: _usernameController,
            hintText: 'enter username',
          ),
          const SizedBox(height: 18),
          AuthWireframeField(
            controller: _passwordController,
            hintText: 'enter password',
            obscureText: true,
          ),
          const SizedBox(height: 18),
          if (authState.status == AuthStatus.unauthenticated &&
              authState.errorMessage != null) ...[
            Text(
              authState.errorMessage!,
              style: const TextStyle(
                color: Color(0xFFFFB4B4),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
          ],
          AuthWireframePrimaryButton(
            label: _isSubmitting ? 'Logging In...' : 'Log In',
            onPressed: _isSubmitting ? () {} : _login,
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Need an account? Start sign up'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Enter both username and password.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(username: username, password: password);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(Object error) {
    final message = error.toString();
    ref.read(authControllerProvider.notifier).setError(message);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
