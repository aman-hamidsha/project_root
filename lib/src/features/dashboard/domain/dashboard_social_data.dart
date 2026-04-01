import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    required this.todayXp,
    required this.totalXp,
    required this.completedToday,
    required this.currentLevelLabel,
    required this.todayStatusTitle,
    required this.todayStatusBody,
    required this.activity,
    required this.leaderboard,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final int globalRank;
  final int weeklyXp;
  final int weeklyGoalXp;
  final int todayXp;
  final int totalXp;
  final bool completedToday;
  final String currentLevelLabel;
  final String todayStatusTitle;
  final String todayStatusBody;
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

enum UserActivityType {
  lessonStudy,
  lessonCheck,
  quizCompletion,
  simulatorDecision,
}

extension UserActivityTypeMeta on UserActivityType {
  int get defaultXp {
    switch (this) {
      case UserActivityType.lessonStudy:
        return 22;
      case UserActivityType.lessonCheck:
        return 28;
      case UserActivityType.quizCompletion:
        return 55;
      case UserActivityType.simulatorDecision:
        return 45;
    }
  }

  String get label {
    switch (this) {
      case UserActivityType.lessonStudy:
        return 'lesson study';
      case UserActivityType.lessonCheck:
        return 'lesson challenge';
      case UserActivityType.quizCompletion:
        return 'quiz run';
      case UserActivityType.simulatorDecision:
        return 'simulator decision';
    }
  }
}

class ActivityAward {
  const ActivityAward({
    required this.tracked,
    required this.unlockedStreakDay,
    required this.leveledUp,
    required this.xpEarned,
    required this.currentStreakDays,
    required this.totalXp,
    required this.levelLabel,
    required this.headline,
    required this.message,
  });

  final bool tracked;
  final bool unlockedStreakDay;
  final bool leveledUp;
  final int xpEarned;
  final int currentStreakDays;
  final int totalXp;
  final String levelLabel;
  final String headline;
  final String message;

  bool get shouldCelebrate => unlockedStreakDay || leveledUp;
}

class _StoredUserSocialProfile {
  const _StoredUserSocialProfile({
    required this.username,
    required this.totalXp,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.lastActiveOn,
    required this.xpByDate,
    required this.activityCountByDate,
    required this.awardedEventKeys,
  });

  const _StoredUserSocialProfile.empty(this.username)
    : totalXp = 0,
      currentStreakDays = 0,
      longestStreakDays = 0,
      lastActiveOn = null,
      xpByDate = const <String, int>{},
      activityCountByDate = const <String, int>{},
      awardedEventKeys = const <String>{};

  final String username;
  final int totalXp;
  final int currentStreakDays;
  final int longestStreakDays;
  final String? lastActiveOn;
  final Map<String, int> xpByDate;
  final Map<String, int> activityCountByDate;
  final Set<String> awardedEventKeys;

  _StoredUserSocialProfile copyWith({
    int? totalXp,
    int? currentStreakDays,
    int? longestStreakDays,
    String? lastActiveOn,
    Map<String, int>? xpByDate,
    Map<String, int>? activityCountByDate,
    Set<String>? awardedEventKeys,
  }) {
    return _StoredUserSocialProfile(
      username: username,
      totalXp: totalXp ?? this.totalXp,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      lastActiveOn: lastActiveOn ?? this.lastActiveOn,
      xpByDate: xpByDate ?? this.xpByDate,
      activityCountByDate: activityCountByDate ?? this.activityCountByDate,
      awardedEventKeys: awardedEventKeys ?? this.awardedEventKeys,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'username': username,
      'totalXp': totalXp,
      'currentStreakDays': currentStreakDays,
      'longestStreakDays': longestStreakDays,
      'lastActiveOn': lastActiveOn,
      'xpByDate': xpByDate,
      'activityCountByDate': activityCountByDate,
      'awardedEventKeys': awardedEventKeys.toList(growable: false),
    };
  }

  factory _StoredUserSocialProfile.fromJson(Map<String, dynamic> json) {
    return _StoredUserSocialProfile(
      username: (json['username'] as String?) ?? 'user',
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreakDays: (json['currentStreakDays'] as num?)?.toInt() ?? 0,
      longestStreakDays: (json['longestStreakDays'] as num?)?.toInt() ?? 0,
      lastActiveOn: json['lastActiveOn'] as String?,
      xpByDate: DashboardSocialActivity._decodeIntMap(json['xpByDate']),
      activityCountByDate: DashboardSocialActivity._decodeIntMap(
        json['activityCountByDate'],
      ),
      awardedEventKeys: DashboardSocialActivity._decodeStringSet(
        json['awardedEventKeys'],
      ),
    );
  }
}

class DashboardSocialActivity {
  const DashboardSocialActivity._();

  static const String _profilesStorageKey = 'dashboard_social_profiles_v2';
  // Mirrors the local auth store keys currently used by the app.
  static const String _accountsStorageKey = 'basic_auth_accounts_v1';
  static const String _sessionStorageKey = 'basic_auth_session_v1';

  static Future<ActivityAward?> recordCurrentUserActivity({
    required UserActivityType type,
    required String activityId,
    int? xp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final username = _loadCurrentUsername(prefs);
    if (username == null || username.isEmpty) {
      return null;
    }

    final profiles = _loadProfiles(prefs);
    final existing = profiles[username] ?? _StoredUserSocialProfile.empty(username);
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final eventKey = '$todayKey|${type.name}|$activityId';
    final alreadyTracked = existing.awardedEventKeys.contains(eventKey);
    final previousLevel = _levelForXp(existing.totalXp);

    var updated = existing;
    var unlockedStreakDay = false;
    var xpEarned = 0;

    if (existing.lastActiveOn != todayKey) {
      unlockedStreakDay = true;
      final nextStreak = _nextStreak(
        previousDateKey: existing.lastActiveOn,
        currentDateKey: todayKey,
        currentStreak: existing.currentStreakDays,
      );
      updated = updated.copyWith(
        currentStreakDays: nextStreak,
        longestStreakDays: nextStreak > existing.longestStreakDays
            ? nextStreak
            : existing.longestStreakDays,
        lastActiveOn: todayKey,
      );
    }

    if (!alreadyTracked) {
      xpEarned = xp ?? type.defaultXp;
      final nextXpByDate = Map<String, int>.from(updated.xpByDate)
        ..update(todayKey, (value) => value + xpEarned, ifAbsent: () => xpEarned);
      final nextActivityCount = Map<String, int>.from(updated.activityCountByDate)
        ..update(todayKey, (value) => value + 1, ifAbsent: () => 1);
      final nextAwardedKeys = Set<String>.from(updated.awardedEventKeys)
        ..add(eventKey);

      updated = updated.copyWith(
        totalXp: updated.totalXp + xpEarned,
        xpByDate: _trimDateIntMap(nextXpByDate),
        activityCountByDate: _trimDateIntMap(nextActivityCount),
        awardedEventKeys: _trimAwardedKeys(nextAwardedKeys),
      );
    }

    profiles[username] = updated;
    await _saveProfiles(prefs, profiles);

    final nextLevel = _levelForXp(updated.totalXp);
    final leveledUp = nextLevel != previousLevel;

    return ActivityAward(
      tracked: !alreadyTracked,
      unlockedStreakDay: unlockedStreakDay,
      leveledUp: leveledUp,
      xpEarned: xpEarned,
      currentStreakDays: updated.currentStreakDays,
      totalXp: updated.totalXp,
      levelLabel: _levelLabel(updated.totalXp),
      headline: unlockedStreakDay
          ? 'Streak day secured'
          : leveledUp
          ? 'Level up'
          : 'Progress saved',
      message: unlockedStreakDay
          ? 'Nice work. Your ${updated.currentStreakDays}-day streak is alive.'
          : leveledUp
          ? 'You reached ${_levelLabel(updated.totalXp)}.'
          : 'You earned $xpEarned XP from this ${type.label}.',
    );
  }

  static Future<DashboardSocialSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredUsers = _loadRegisteredUsers(prefs);
    final currentUsername = _loadCurrentUsername(prefs);
    final storedProfiles = _loadProfiles(prefs);

    final profiles = <String, _StoredUserSocialProfile>{};
    for (final username in registeredUsers) {
      profiles[username] =
          storedProfiles[username] ?? _StoredUserSocialProfile.empty(username);
    }
    if (currentUsername != null && currentUsername.isNotEmpty) {
      profiles[currentUsername] =
          profiles[currentUsername] ?? _StoredUserSocialProfile.empty(currentUsername);
    }

    final sorted = profiles.values.toList()
      ..sort((a, b) {
        final xpCompare = b.totalXp.compareTo(a.totalXp);
        if (xpCompare != 0) return xpCompare;
        final streakCompare = b.currentStreakDays.compareTo(a.currentStreakDays);
        if (streakCompare != 0) return streakCompare;
        return a.username.compareTo(b.username);
      });

    final leaderboard = <LeaderboardEntry>[];
    var currentRank = 0;
    for (final profile in sorted) {
      currentRank += 1;
      leaderboard.add(
        LeaderboardEntry(
          id: profile.username,
          displayName: _displayNameFor(profile.username),
          rank: currentRank,
          xp: profile.totalXp,
          streakDays: profile.currentStreakDays,
          isCurrentUser: profile.username == currentUsername,
        ),
      );
    }

    final currentProfile = currentUsername == null
        ? const _StoredUserSocialProfile.empty('guest')
        : profiles[currentUsername] ?? _StoredUserSocialProfile.empty(currentUsername);
    final weeklyXp = _sumXpForRecentDays(currentProfile, 7);
    final todayKey = _dateKey(DateTime.now());
    final todayXp = currentProfile.xpByDate[todayKey] ?? 0;
    final completedToday =
        (currentProfile.activityCountByDate[todayKey] ?? 0) > 0;
    final activity = _recentActivityDays(currentProfile);

    return DashboardSocialSnapshot(
      currentStreakDays: currentProfile.currentStreakDays,
      longestStreakDays: currentProfile.longestStreakDays,
      globalRank: leaderboard.firstWhere(
        (entry) => entry.isCurrentUser,
        orElse: () => const LeaderboardEntry(
          id: 'guest',
          displayName: 'Guest',
          rank: 0,
          xp: 0,
          streakDays: 0,
          isCurrentUser: false,
        ),
      ).rank,
      weeklyXp: weeklyXp,
      weeklyGoalXp: 420,
      todayXp: todayXp,
      totalXp: currentProfile.totalXp,
      completedToday: completedToday,
      currentLevelLabel: _levelLabel(currentProfile.totalXp),
      todayStatusTitle: completedToday ? 'Today is counted' : 'Today is open',
      todayStatusBody: completedToday
          ? 'Your streak is protected for today. Keep learning if you want more XP.'
          : 'Complete one lesson, quiz, or simulator action to lock in today’s streak.',
      activity: activity,
      leaderboard: leaderboard,
    );
  }

  static String? _loadCurrentUsername(SharedPreferences prefs) {
    final username = prefs.getString(_sessionStorageKey);
    if (username == null || username.trim().isEmpty) {
      return null;
    }
    return username.trim().toLowerCase();
  }

  static Set<String> _loadRegisteredUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_accountsStorageKey);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String>{};
      }
      return decoded.keys.map((value) => value.trim().toLowerCase()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Map<String, _StoredUserSocialProfile> _loadProfiles(
    SharedPreferences prefs,
  ) {
    final raw = prefs.getString(_profilesStorageKey);
    if (raw == null || raw.isEmpty) {
      return <String, _StoredUserSocialProfile>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String, _StoredUserSocialProfile>{};
      }
      return decoded.map(
        (key, value) => MapEntry(
          key,
          _StoredUserSocialProfile.fromJson(
            (value as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        ),
      );
    } catch (_) {
      return <String, _StoredUserSocialProfile>{};
    }
  }

  static Future<void> _saveProfiles(
    SharedPreferences prefs,
    Map<String, _StoredUserSocialProfile> profiles,
  ) async {
    final json = profiles.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_profilesStorageKey, jsonEncode(json));
  }

  static int _nextStreak({
    required String? previousDateKey,
    required String currentDateKey,
    required int currentStreak,
  }) {
    if (previousDateKey == null) {
      return 1;
    }

    final previous = DateTime.tryParse(previousDateKey);
    final current = DateTime.tryParse(currentDateKey);
    if (previous == null || current == null) {
      return 1;
    }

    final gap = current.difference(previous).inDays;
    if (gap <= 0) {
      return currentStreak == 0 ? 1 : currentStreak;
    }
    if (gap == 1) {
      return currentStreak + 1;
    }
    return 1;
  }

  static int _sumXpForRecentDays(
    _StoredUserSocialProfile profile,
    int dayCount,
  ) {
    final now = DateTime.now();
    var total = 0;
    for (var index = 0; index < dayCount; index += 1) {
      final date = now.subtract(Duration(days: index));
      total += profile.xpByDate[_dateKey(date)] ?? 0;
    }
    return total;
  }

  static List<SocialActivityDay> _recentActivityDays(
    _StoredUserSocialProfile profile,
  ) {
    final now = DateTime.now();
    return List<SocialActivityDay>.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final key = _dateKey(date);
      final xp = profile.xpByDate[key] ?? 0;
      final completed = (profile.activityCountByDate[key] ?? 0) > 0;
      final intensity = xp <= 0 ? 0.0 : (xp / 70).clamp(0.22, 1.0).toDouble();
      return SocialActivityDay(
        label: _weekdayLabel(date.weekday),
        completed: completed,
        intensity: intensity,
      );
    });
  }

  static Map<String, int> _trimDateIntMap(Map<String, int> values) {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return Map<String, int>.fromEntries(
      values.entries.where((entry) {
        final parsed = DateTime.tryParse(entry.key);
        return parsed == null || !parsed.isBefore(cutoff);
      }),
    );
  }

  static Set<String> _trimAwardedKeys(Set<String> awardedKeys) {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return awardedKeys.where((key) {
      final dateKey = key.split('|').first;
      final parsed = DateTime.tryParse(dateKey);
      return parsed == null || !parsed.isBefore(cutoff);
    }).toSet();
  }

  static Map<String, int> _decodeIntMap(Object? value) {
    if (value is! Map) {
      return <String, int>{};
    }
    return value.map(
      (key, data) => MapEntry(key.toString(), (data as num).toInt()),
    );
  }

  static Set<String> _decodeStringSet(Object? value) {
    if (value is! List) {
      return <String>{};
    }
    return value.whereType<String>().toSet();
  }

  static String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }

  static String _displayNameFor(String username) {
    return username
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static int _levelForXp(int xp) => (xp ~/ 180) + 1;

  static String _levelLabel(int xp) {
    final level = _levelForXp(xp);
    final title = switch (level) {
      1 => 'Signal Starter',
      2 => 'Threat Spotter',
      3 => 'Shield Builder',
      4 => 'Scam Sleuth',
      5 => 'Defense Lead',
      _ => 'Risk Analyst',
    };
    return '$title Lv. $level';
  }
}

abstract class DashboardSocialRepository {
  Future<DashboardSocialSnapshot> fetchDashboardSocialSnapshot();
}

class LocalDashboardSocialRepository implements DashboardSocialRepository {
  const LocalDashboardSocialRepository();

  @override
  Future<DashboardSocialSnapshot> fetchDashboardSocialSnapshot() {
    return DashboardSocialActivity.loadSnapshot();
  }
}

final dashboardSocialRepositoryProvider = Provider<DashboardSocialRepository>(
  (ref) => const LocalDashboardSocialRepository(),
);
