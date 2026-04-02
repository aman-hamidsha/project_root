import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../lessons/domain/lesson_progress_store.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Future<LessonProgressSnapshot> _lessonProgressFuture;

  @override
  void initState() {
    super.initState();
    _lessonProgressFuture = LessonProgressStore.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF365D9E);
    final selectedThemeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TopButton(
                      label: 'Back',
                      onTap: () => context.go('/dashboard'),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust how the app feels, review your local lesson progress, and reset training data when you want a clean start.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    children: [
                      _SettingsCard(
                        title: 'Account',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.username == null
                                  ? 'No local account is active.'
                                  : 'Signed in as ${_displayName(authState.username!)}',
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              authState.username == null
                                  ? 'Use Log In or Sign Up from the landing screen.'
                                  : 'This app restores the last saved local session automatically. Use switch account if you want to sign into a different profile.',
                              style: TextStyle(
                                color: subtitleColor,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                OutlinedButton(
                                  onPressed: authState.username == null
                                      ? () => context.go('/login')
                                      : () async {
                                          await ref
                                              .read(authControllerProvider.notifier)
                                              .switchAccount();
                                          if (!mounted) {
                                            return;
                                          }
                                          context.go('/login');
                                        },
                                  child: Text(
                                    authState.username == null
                                        ? 'Open Log In'
                                        : 'Switch Account',
                                  ),
                                ),
                                if (authState.username != null)
                                  OutlinedButton(
                                    onPressed: () async {
                                      await ref
                                          .read(authControllerProvider.notifier)
                                          .signOut();
                                      if (!mounted) {
                                        return;
                                      }
                                      context.go('/landing');
                                    },
                                    child: const Text('Sign Out'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsCard(
                        title: 'Appearance',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme mode',
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ThemeMode.values
                                  .map(
                                    (mode) => ChoiceChip(
                                      label: Text(_themeLabel(mode)),
                                      selected: selectedThemeMode == mode,
                                      onSelected: (_) {
                                        ref
                                            .read(themeModeProvider.notifier)
                                            .setMode(mode);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FutureBuilder<LessonProgressSnapshot>(
                        future: _lessonProgressFuture,
                        builder: (context, snapshot) {
                          final progress =
                              snapshot.data ??
                              const LessonProgressSnapshot.empty();
                          return _SettingsCard(
                            title: 'Learning Data',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lesson completion',
                                  style: TextStyle(
                                    color: titleColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress.overallProgress,
                                    minHeight: 10,
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : const Color(0xFFE3EEFF),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF7FD5A5),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${progress.completedLessonCount}/${lessonCatalog.length} lessons completed',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () async {
                                    await LessonProgressStore.reset();
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      _lessonProgressFuture =
                                          LessonProgressStore.load();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lesson progress has been reset.',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Reset Lesson Progress'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _SettingsCard(
                        title: 'Help And Navigation',
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/guide'),
                              child: const Text('Open Instruction Guide'),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go('/lessons'),
                              child: const Text('Open Lessons'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  String _displayName(String username) {
    return username
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE5F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary, width: 3),
        ),
        child: Center(
          child: AppSvgIcon(
            AppIcons.arrowLeft,
            color: colorScheme.primary,
            size: 20,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}
