import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialActivityDay {
  const SocialActivityDay({
    required this.label,
    required this.completed,
    required this.intensity,
  });

  final String label;
  final bool completed;
  final double intensity;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.displayName,
    required this.rank,
    required this.xp,
    required this.streakDays,
    required this.isCurrentUser,
  });

  final String id;
  final String displayName;
  final int rank;
  final int xp;
  final int streakDays;
  final bool isCurrentUser;
}

class DashboardSocialSnapshot {
  const DashboardSocialSnapshot({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.globalRank,
    required this.weeklyXp,
    required this.weeklyGoalXp,
    required this.currentLevelLabel,
    required this.activity,
    required this.leaderboard,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final int globalRank;
  final int weeklyXp;
  final int weeklyGoalXp;
  final String currentLevelLabel;
  final List<SocialActivityDay> activity;
  final List<LeaderboardEntry> leaderboard;

  double get weeklyGoalProgress =>
      weeklyGoalXp == 0 ? 0 : (weeklyXp / weeklyGoalXp).clamp(0, 1);

  LeaderboardEntry? get currentUserEntry {
    for (final entry in leaderboard) {
      if (entry.isCurrentUser) {
        return entry;
      }
    }
    return null;
  }
}

/// UI-facing repository contract.
/// Replace the mock implementation with a Serverpod-backed repository later
/// without changing the dashboard widgets or leaderboard screens.
abstract class DashboardSocialRepository {
  Future<DashboardSocialSnapshot> fetchDashboardSocialSnapshot();
}

class MockDashboardSocialRepository implements DashboardSocialRepository {
  const MockDashboardSocialRepository();

  @override
  Future<DashboardSocialSnapshot> fetchDashboardSocialSnapshot() async {
    return const DashboardSocialSnapshot(
      currentStreakDays: 12,
      longestStreakDays: 19,
      globalRank: 4,
      weeklyXp: 420,
      weeklyGoalXp: 600,
      currentLevelLabel: 'Threat Spotter Lv. 3',
      activity: <SocialActivityDay>[
        SocialActivityDay(label: 'Mon', completed: true, intensity: 0.7),
        SocialActivityDay(label: 'Tue', completed: true, intensity: 0.85),
        SocialActivityDay(label: 'Wed', completed: false, intensity: 0.15),
        SocialActivityDay(label: 'Thu', completed: true, intensity: 0.95),
        SocialActivityDay(label: 'Fri', completed: true, intensity: 0.8),
        SocialActivityDay(label: 'Sat', completed: true, intensity: 0.65),
        SocialActivityDay(label: 'Sun', completed: true, intensity: 0.9),
      ],
      leaderboard: <LeaderboardEntry>[
        LeaderboardEntry(
          id: 'user_1',
          displayName: 'Maya',
          rank: 1,
          xp: 980,
          streakDays: 27,
          isCurrentUser: false,
        ),
        LeaderboardEntry(
          id: 'user_2',
          displayName: 'Ethan',
          rank: 2,
          xp: 915,
          streakDays: 24,
          isCurrentUser: false,
        ),
        LeaderboardEntry(
          id: 'user_3',
          displayName: 'Noor',
          rank: 3,
          xp: 870,
          streakDays: 20,
          isCurrentUser: false,
        ),
        LeaderboardEntry(
          id: 'current_user',
          displayName: 'You',
          rank: 4,
          xp: 820,
          streakDays: 12,
          isCurrentUser: true,
        ),
        LeaderboardEntry(
          id: 'user_5',
          displayName: 'Ava',
          rank: 5,
          xp: 760,
          streakDays: 10,
          isCurrentUser: false,
        ),
      ],
    );
  }
}

final dashboardSocialRepositoryProvider = Provider<DashboardSocialRepository>(
  (ref) => const MockDashboardSocialRepository(),
);
