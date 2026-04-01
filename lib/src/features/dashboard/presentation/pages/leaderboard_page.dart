import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../domain/dashboard_social_data.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF365D9E);

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
                  'Leaderboard',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ranked by real learning activity from registered users on this device. Lessons, quiz runs, and simulator decisions all add momentum.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: FutureBuilder<DashboardSocialSnapshot>(
                    future: ref
                        .watch(dashboardSocialRepositoryProvider)
                        .fetchDashboardSocialSnapshot(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final social = snapshot.data!;
                      return ListView(
                        children: [
                          _LeaderboardHeroCard(social: social),
                          const SizedBox(height: 16),
                          _LeaderboardPodiumCard(
                            entries: social.leaderboard.take(3).toList(),
                          ),
                          const SizedBox(height: 16),
                          _LeaderboardTableCard(entries: social.leaderboard),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardHeroCard extends StatelessWidget {
  const _LeaderboardHeroCard({required this.social});

  final DashboardSocialSnapshot social;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const <Color>[Color(0xFF0B3B84), Color(0xFF2A74EE)]
              : const <Color>[Color(0xFF2A74EE), Color(0xFF7CB4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: appShadows(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppSvgIcon(
                AppIcons.trophy,
                color: Colors.white,
                size: 22,
                semanticLabel: 'Leaderboard',
              ),
              const SizedBox(width: 10),
              Text(
                social.currentLevelLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _HeroStat(
                label: 'Current streak',
                value: '${social.currentStreakDays} days',
              ),
              _HeroStat(
                label: 'Longest streak',
                value: '${social.longestStreakDays} days',
              ),
              _HeroStat(label: 'Global rank', value: '#${social.globalRank}'),
              _HeroStat(label: 'Today', value: '${social.todayXp} XP'),
              _HeroStat(
                label: 'Weekly XP',
                value: '${social.weeklyXp}/${social.weeklyGoalXp}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPodiumCard extends StatelessWidget {
  const _LeaderboardPodiumCard({required this.entries});

  final List<LeaderboardEntry> entries;

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
            'Top learners this week',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: entries
                .map((entry) => _PodiumTile(entry: entry))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PodiumTile extends StatelessWidget {
  const _PodiumTile({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${entry.rank}',
            style: const TextStyle(
              color: Color(0xFF2A74EE),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.displayName,
            style: const TextStyle(
              color: Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${entry.xp} XP • ${entry.streakDays} day streak',
            style: const TextStyle(
              color: Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTableCard extends StatelessWidget {
  const _LeaderboardTableCard({required this.entries});

  final List<LeaderboardEntry> entries;

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
            'Leaderboard table',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: entry.isCurrentUser
                    ? const Color(0xFFE6F0FF)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF7FAFF)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
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
                        color: isDark ? Colors.white : const Color(0xFF17376C),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.xp} XP',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.78)
                          : const Color(0xFF4D6EA2),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.streakDays}d',
                    style: const TextStyle(
                      color: Color(0xFF2E9A59),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
