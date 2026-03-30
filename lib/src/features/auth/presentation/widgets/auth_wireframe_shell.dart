import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

class AuthWireframeShell extends StatelessWidget {
  const AuthWireframeShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 8,
              child: Text(
                'Aman Hamidsha © 2025',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              right: 72,
              top: 8,
              child: const ThemeToggleButton(),
            ),
            Positioned(
              right: 16,
              top: 8,
              child: _CornerButton(
                icon: Icons.close_rounded,
                onPressed: () => context.go('/landing'),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

class AuthWireframeField extends StatelessWidget {
  const AuthWireframeField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldFill =
        isDark ? const Color(0xFFA9C3E4) : const Color(0xFFFFFFFF);
    final fieldTextColor =
        isDark ? const Color(0xFF1E3EB7) : const Color(0xFF18407D);
    final borderColor =
        isDark ? const Color(0xFF284CFF) : theme.colorScheme.primary;

    return SizedBox(
      width: 320,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: fieldTextColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: fieldTextColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          filled: true,
          fillColor: fieldFill,
          border: _fieldBorder(borderColor),
          enabledBorder: _fieldBorder(borderColor),
          focusedBorder: _fieldBorder(borderColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: borderColor,
        width: 5,
      ),
    );
  }
}

class AuthWireframeActionButton extends StatelessWidget {
  const AuthWireframeActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFFA9C3E4) : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary,
            width: 5,
          ),
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }
}

class AuthWireframePrimaryButton extends StatelessWidget {
  const AuthWireframePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 194,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFFA9C3E4) : colorScheme.primary,
          foregroundColor:
              isDark ? const Color(0xFF284CFF) : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide(
            color: colorScheme.primary,
            width: 5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _CornerButton extends StatelessWidget {
  const _CornerButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFFA9C3E4) : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary,
            width: 4,
          ),
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
