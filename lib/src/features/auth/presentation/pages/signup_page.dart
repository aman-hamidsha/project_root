import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_controller.dart';
import '../../domain/auth_state.dart';
import '../widgets/auth_wireframe_shell.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  bool get _usernameIsValid =>
      RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(_usernameController.text.trim());
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _passwordIsValid =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          AuthWireframeField(
            controller: _passwordController,
            hintText: 'enter password',
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          AuthWireframeField(
            controller: _confirmPasswordController,
            hintText: 'confirm password',
            obscureText: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _GuidanceCard(
            usernameIsValid: _usernameIsValid,
            hasMinLength: _hasMinLength,
            hasUppercase: _hasUppercase,
            hasLowercase: _hasLowercase,
            hasNumber: _hasNumber,
            passwordsMatch:
                _confirmPasswordController.text.isNotEmpty &&
                _passwordController.text == _confirmPasswordController.text,
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
            label: _isSubmitting ? 'Creating...' : 'Create Account',
            onPressed: _isSubmitting ? () {} : _signup,
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Already have an account? Log in'),
          ),
        ],
      ),
    );
  }

  Future<void> _signup() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (!_usernameIsValid) {
      _showError(
        'Username must be 3-20 characters and use only letters, numbers, or underscores.',
      );
      return;
    }

    if (!_passwordIsValid) {
      _showError(
        'Password must be at least 8 characters and include uppercase, lowercase, and a number.',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match.');
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      _showError('Enter your username and password.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(username: username, password: password);
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ref.read(authControllerProvider.notifier).setError(message);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.usernameIsValid,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.passwordsMatch,
  });

  final bool usernameIsValid;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool passwordsMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2F61),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF284CFF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account requirements',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _RequirementText(
            met: usernameIsValid,
            label: 'Username is 3-20 chars with letters, numbers, or _',
          ),
          _RequirementText(met: hasMinLength, label: 'At least 8 characters'),
          _RequirementText(
            met: hasUppercase,
            label: 'At least 1 uppercase letter',
          ),
          _RequirementText(
            met: hasLowercase,
            label: 'At least 1 lowercase letter',
          ),
          _RequirementText(met: hasNumber, label: 'At least 1 number'),
          _RequirementText(met: passwordsMatch, label: 'Passwords match'),
        ],
      ),
    );
  }
}

class _RequirementText extends StatelessWidget {
  const _RequirementText({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '${met ? 'OK' : 'NO'}  $label',
        style: TextStyle(
          color: met ? const Color(0xFF9FFFC6) : const Color(0xFFFFC5C5),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
