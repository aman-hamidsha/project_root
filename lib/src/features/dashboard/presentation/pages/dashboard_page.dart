import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../../auth/application/auth_controller.dart';
import '../../domain/dashboard_social_data.dart';
import '../../../lessons/domain/lesson_progress_store.dart';

/**
 * DashboardPage is the main home screen shown to authenticated users.
 * It watches the auth state to display the current username, loads lesson
 * progress and social/leaderboard data, and renders either a wide (tablet/desktop)
 * or narrow (mobile) layout depending on screen width. Also contains buttons
 * for navigating to the Guide, Settings, and signing out.
 */

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final activeUsername = authState.username;
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
                          const SizedBox(width: 10),
                          const ThemeToggleButton(),
                        ],
                      ),
                      const SizedBox(height: 26),
                      if (activeUsername != null) ...[
                        _SignedInBanner(username: activeUsername),
                        const SizedBox(height: 16),
                      ],
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
                        child: FutureBuilder<_DashboardHomeData>(
                          future: _loadDashboardHomeData(
                            ref.read(dashboardSocialRepositoryProvider),
                          ),
                          builder: (context, snapshot) {
                            final data =
                                snapshot.data ??
                                const _DashboardHomeData(
                                  progress: LessonProgressSnapshot.empty(),
                                  social: null,
                                );
                            return wide
                                ? _WideLayout(
                                    progress: data.progress,
                                    social: data.social,
                                  )
                                : _NarrowLayout(
                                    progress: data.progress,
                                    social: data.social,
                                  );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/guide'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: surfaceColor.withValues(
                                  alpha: isDark ? 0.22 : 0.9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppSvgIcon(
                                    AppIcons.bookOpen,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                    semanticLabel: 'Guide',
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Guide'),
                                ],
                              ),
                            ),
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppSvgIcon(
                                    AppIcons.signOut,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                    semanticLabel: 'Sign out',
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Sign out'),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go('/settings'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: surfaceColor.withValues(
                                  alpha: isDark ? 0.22 : 0.9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppSvgIcon(
                                    AppIcons.settings,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                    semanticLabel: 'Settings',
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Settings'),
                                ],
                              ),
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

/**
 * _SignedInBanner displays a small card at the top of the dashboard
 * showing who is currently logged in. It formats the username by splitting
 * on underscores and capitalising each word, so "john_doe" renders as "John Doe".
 */
class _SignedInBanner extends StatelessWidget {
  const _SignedInBanner({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE5F3),
        ),
      ),
      child: Row(
        children: [
          AppSvgIcon(
            AppIcons.sparkles,
            color: const Color(0xFF2A74EE),
            size: 18,
            semanticLabel: 'Signed in',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Signed in as ${_displayName(username)}',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF17376C),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

/**
 * _NarrowLayout is the single-column layout used on mobile-sized screens.
 * It renders Lessons, Momentum, and Simulator sections stacked vertically
 * in a scrollable ListView. Simulator buttons are wrapped in a Wrap widget
 * so they flow into a grid rather than overflowing off screen.
 */
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.progress, required this.social});

  final LessonProgressSnapshot progress;
  final DashboardSocialSnapshot? social;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _SectionTitle('Lessons'),
        const SizedBox(height: 10),
        _LessonPreviewCard(
          progress: progress,
          onOpenLessons: () => context.go('/lessons'),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Momentum'),
        const SizedBox(height: 10),
        _MomentumCard(
          social: social,
          onOpenLeaderboard: () => context.go('/leaderboard'),
        ),
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
                iconAsset: AppIcons.envelope,
                onTap: () => context.go('/sim/email'),
              ),
            ),
            SizedBox(
              width: 160,
              child: _SimButton(
                label: 'SMS',
                iconAsset: AppIcons.chatBubble,
                onTap: () => context.go('/sim/sms'),
              ),
            ),
            SizedBox(
              width: 160,
              child: _SimButton(
                label: 'Crypto',
                iconAsset: AppIcons.banknotes,
                onTap: () => context.go('/sim/crypto'),
              ),
            ),
            SizedBox(
              width: 160,
              child: _SimButton(
                label: 'Wi-Fi',
                iconAsset: AppIcons.wifi,
                onTap: () => context.go('/sim/wifi'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/**
 * _WideLayout is the two-column layout used on screens 900px wide or more.
 * The left column takes up more space and shows the Lesson preview card,
 * while the right column holds the Momentum card and Simulator buttons
 * stacked vertically in a scrollable list.
 */
class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.progress, required this.social});

  final LessonProgressSnapshot progress;
  final DashboardSocialSnapshot? social;

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
              Expanded(
                child: _LessonPreviewCard(
                  progress: progress,
                  onOpenLessons: () => context.go('/lessons'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 4,
          child: ListView(
            children: [
              const _SectionTitle('Momentum'),
              const SizedBox(height: 10),
              _MomentumCard(
                social: social,
                onOpenLeaderboard: () => context.go('/leaderboard'),
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Simulators'),
              const SizedBox(height: 10),
              _SimButton(
                label: 'E-Mail',
                iconAsset: AppIcons.envelope,
                onTap: () => context.go('/sim/email'),
              ),
              const SizedBox(height: 12),
              _SimButton(
                label: 'SMS',
                iconAsset: AppIcons.chatBubble,
                onTap: () => context.go('/sim/sms'),
              ),
              const SizedBox(height: 12),
              _SimButton(
                label: 'Crypto',
                iconAsset: AppIcons.banknotes,
                onTap: () => context.go('/sim/crypto'),
              ),
              const SizedBox(height: 12),
              _SimButton(
                label: 'Wi-Fi',
                iconAsset: AppIcons.wifi,
                onTap: () => context.go('/sim/wifi'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/**
 * _SectionTitle renders a small uppercase-weight label used as a heading
 * above each section of the dashboard (e.g. "Lessons", "Momentum", "Simulators").
 * Colour adapts to light and dark themes.
 */
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

/**
 * _LessonPreviewCard shows the user's current lesson progress on a gradient
 * card. Displays the last lesson the user was on, an overall progress bar,
 * completed lesson count, and a button to continue or review the lesson.
 * Navigates to the lessons page when the button is tapped.
 */
class _LessonPreviewCard extends StatelessWidget {
  const _LessonPreviewCard({
    required this.progress,
    required this.onOpenLessons,
  });

  final LessonProgressSnapshot progress;
  final VoidCallback onOpenLessons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLesson = progress.lastLesson;
    final lessonProgress = progress.progressForLesson(currentLesson.id);
    return SizedBox(
      width: double.infinity,
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const <Color>[Color(0xFF0B3B84), Color(0xFF2A74EE)]
                : const <Color>[Color(0xFF2A74EE), Color(0xFF7CB4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: appShadows(isDark),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppSvgIcon(
                  AppIcons.bookOpen,
                  color: Colors.white,
                  size: 22,
                  semanticLabel: 'Lessons',
                ),
                const SizedBox(width: 10),
                Text(
                  'Resume Lessons',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${currentLesson.shortLabel} • ${currentLesson.title}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currentLesson.summary,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.overallProgress,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.24),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${progress.completedLessonCount}/${lessonCatalog.length} lessons completed • ${_progressPercent(progress.overallProgress)} overall',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last left off: ${progress.nextStepForLesson(currentLesson.id)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onOpenLessons,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      lessonProgress >= 1 ? 'Review Lesson' : 'Continue Lesson',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _progressPercent(double progressValue) {
    return '${(progressValue * 100).round()}%';
  }
}

/**
 * _MomentumCard shows the user's engagement stats, current streak, XP earned
 * today, level, weekly goal progress bar, a 7-day activity heatmap, and a
 * preview of the top 3 leaderboard entries. Shows a loading spinner while
 * social data is still being fetched. Includes a button to open the full leaderboard.
 */
class _MomentumCard extends StatelessWidget {
  const _MomentumCard({required this.social, required this.onOpenLeaderboard});

  final DashboardSocialSnapshot? social;
  final VoidCallback onOpenLeaderboard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (social == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A3C86) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: appShadows(isDark),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = social!.currentUserEntry;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSvgIcon(
                AppIcons.fire,
                color: const Color(0xFFFF8A3D),
                size: 22,
                semanticLabel: 'Streak',
              ),
              const SizedBox(width: 10),
              Text(
                '${social!.currentStreakDays} day streak',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF17376C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${social!.todayStatusTitle} • ${social!.todayStatusBody}',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MomentumChip(
                iconAsset: AppIcons.sparkles,
                label: '${social!.todayXp} XP today',
              ),
              _MomentumChip(
                iconAsset: AppIcons.trophy,
                label: 'Level ${social!.currentLevelLabel}',
              ),
              _MomentumChip(
                iconAsset: AppIcons.fire,
                label: 'Best ${social!.longestStreakDays}d',
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: social!.weeklyGoalProgress,
              minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE3EEFF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7FD5A5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: social!.activity
                .map(
                  (day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(
                        children: [
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFEAF2FF),
                                const Color(0xFF2A74EE),
                                day.intensity,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day.label,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.72)
                                  : const Color(0xFF4D6EA2),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF4F8FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSvgIcon(
                      AppIcons.trophy,
                      color: const Color(0xFF2A74EE),
                      size: 18,
                      semanticLabel: 'Leaderboard',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentUser == null
                          ? 'Leaderboard preview'
                          : 'You are #${currentUser.rank} this week',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF17376C),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...social!.leaderboard
                    .take(3)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(
                                '#${entry.rank}',
                                style: const TextStyle(
                                  color: Color(0xFF2A74EE),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.displayName,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : const Color(0xFF17376C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.xp} XP • ${entry.streakDays}d',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.68)
                                    : const Color(0xFF4D6EA2),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onOpenLeaderboard,
              child: const Text('Open Leaderboard'),
            ),
          ),
        ],
      ),
    );
  }
}

/**
 * _MomentumChip is a small pill-shaped badge used inside the MomentumCard
 * to display a single stat (e.g. XP today, current level, best streak)
 * with an icon on the left and a label on the right.
 */
class _MomentumChip extends StatelessWidget {
  const _MomentumChip({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            iconAsset,
            color: const Color(0xFF2A74EE),
            size: 16,
            semanticLabel: label,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/**
 * _DashboardHomeData is a simple data holder that bundles together the two
 * pieces of async data the dashboard needsthe user's lesson progress
 * snapshot and their social/leaderboard snapshot so they can be loaded
 * in a single FutureBuilder and passed down to the layout widgets together.
 */
class _DashboardHomeData {
  const _DashboardHomeData({required this.progress, required this.social});

  final LessonProgressSnapshot progress;
  final DashboardSocialSnapshot? social;
}

Future<_DashboardHomeData> _loadDashboardHomeData(
  DashboardSocialRepository socialRepository,
) async {
  final progress = await LessonProgressStore.load();
  final social = await socialRepository.fetchDashboardSocialSnapshot();
  return _DashboardHomeData(progress: progress, social: social);
}

/**
 * _SimButton is a tappable card used in both layouts to navigate to one of
 * the four scam simulator modules (Email, SMS, Crypto, Wi-Fi). Displays an
 * icon, the module name, and an "Open module" label. Height is fixed at 120px
 * and the card style adapts to light and dark themes.
 */
class _SimButton extends StatelessWidget {
  const _SimButton({
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              iconAsset,
              color: isDark ? Colors.white : const Color(0xFF17376C),
              size: 20,
              semanticLabel: label,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.48)
                    : const Color(0xFF17376C),
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Open module',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A77A6),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
