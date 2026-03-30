import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../auth/application/auth_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF5A77A6);
    final surfaceColor = isDark ? const Color(0xFF0A3C86) : Colors.white;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const <Color>[Color(0xFF04153E), Color(0xFF08255E)]
                : const <Color>[Color(0xFFF7FAFF), Color(0xFFEAF2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool wide = constraints.maxWidth >= 900;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Aman Hamidsha © 2025',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/sim/email'),
                              child: Ink(
                                width: 80,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: appShadows(isDark),
                                ),
                                // TODO(hamidsha): Replace this text with a mail icon when you add icons back.
                                child: Center(
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const ThemeToggleButton(),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Welcome back.',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: wide
                            ? const _WideLayout()
                            : const _NarrowLayout(),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .signOut();
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: surfaceColor.withValues(
                                  alpha: isDark ? 0.22 : 0.9,
                                ),
                              ),
                              child: const Text('Sign out'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor: surfaceColor.withValues(
                                  alpha: isDark ? 0.22 : 0.9,
                                ),
                              ),
                              child: const Text('Settings'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _SectionTitle('Lessons'),
        const SizedBox(height: 10),
        _LessonsButton(onTap: () => context.go('/lessons')),
        const SizedBox(height: 18),
        const _SectionTitle('Streak'),
        const SizedBox(height: 10),
        const _SquareStatCard(title: '12 days'),
        const SizedBox(height: 18),
        const _SectionTitle('Simulators'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 160,
              child: _SimButton(
                label: 'E-Mail',
                onTap: () => context.go('/sim/email'),
              ),
            ),
            SizedBox(
              width: 160,
              child: _SimButton(
                label: 'SMS',
                onTap: () => context.go('/sim/sms'),
              ),
            ),
            SizedBox(
              width: 160,
              child: _SimButton(
                label: 'Crypto',
                onTap: () => context.go('/sim/crypto'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Lessons'),
              const SizedBox(height: 10),
              _LessonsButton(onTap: () => context.go('/lessons')),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Streak'),
              const SizedBox(height: 10),
              const _SquareStatCard(title: '12 days'),
              const SizedBox(height: 18),
              const _SectionTitle('Simulators'),
              const SizedBox(height: 10),
              _SimButton(
                label: 'E-Mail',
                onTap: () => context.go('/sim/email'),
              ),
              const SizedBox(height: 12),
              _SimButton(label: 'SMS', onTap: () => context.go('/sim/sms')),
              const SizedBox(height: 12),
              _SimButton(
                label: 'Crypto',
                onTap: () => context.go('/sim/crypto'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDark
            ? Colors.white.withValues(alpha: 0.48)
            : const Color(0xFF5A77A6),
        height: 1,
      ),
    );
  }
}

class _LessonsButton extends StatelessWidget {
  const _LessonsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark
                ? const Color(0xFF0A3C86)
                : theme.colorScheme.primary,
            foregroundColor: isDark
                ? Colors.white
                : theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadowColor: Colors.transparent,
            elevation: 0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: appShadows(isDark),
            ),
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(minHeight: 28),
              child: const Text('Go To Lessons'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareStatCard extends StatelessWidget {
  const _SquareStatCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark
                ? Colors.white.withValues(alpha: 0.48)
                : const Color(0xFF17376C),
          ),
        ),
      ),
    );
  }
}

class _SimButton extends StatelessWidget {
  const _SimButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      splashColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A3C86) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: appShadows(isDark),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.48)
                    : const Color(0xFF17376C),
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            // TODO(hamidsha): Reintroduce simulator icons here during a later polish pass.
            const Text(
              'Open module',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A77A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
