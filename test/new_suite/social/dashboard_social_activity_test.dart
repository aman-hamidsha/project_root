import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cs310_app/src/features/dashboard/domain/dashboard_social_data.dart';

void main() {
  group('DashboardSocialActivity', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'basic_auth_accounts_v1': jsonEncode(<String, String>{
          'alice': 'pw1',
          'bob': 'pw2',
        }),
        'basic_auth_session_v1': 'alice',
      });
    });

    test('records XP and creates a streak day for the current user', () async {
      final award = await DashboardSocialActivity.recordCurrentUserActivity(
        type: UserActivityType.quizCompletion,
        activityId: 'quiz:basics',
        xp: 60,
      );
      final snapshot = await DashboardSocialActivity.loadSnapshot();

      expect(award, isNotNull);
      expect(award!.tracked, isTrue);
      expect(award.unlockedStreakDay, isTrue);
      expect(snapshot.currentStreakDays, 1);
      expect(snapshot.todayXp, 60);
      expect(snapshot.weeklyXp, 60);
      expect(snapshot.completedToday, isTrue);
      expect(snapshot.leaderboard.first.isCurrentUser, isTrue);
    });

    test('deduplicates the same activity on the same day', () async {
      final first = await DashboardSocialActivity.recordCurrentUserActivity(
        type: UserActivityType.simulatorDecision,
        activityId: 'sms:delivery_fee',
        xp: 50,
      );
      final second = await DashboardSocialActivity.recordCurrentUserActivity(
        type: UserActivityType.simulatorDecision,
        activityId: 'sms:delivery_fee',
        xp: 50,
      );
      final snapshot = await DashboardSocialActivity.loadSnapshot();

      expect(first!.tracked, isTrue);
      expect(second!.tracked, isFalse);
      expect(snapshot.todayXp, 50);
      expect(snapshot.weeklyXp, 50);
    });

    test('continues a streak when previous activity was yesterday', () async {
      final prefs = await SharedPreferences.getInstance();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey = _dateKey(yesterday);

      await prefs.setString(
        'dashboard_social_profiles_v2',
        jsonEncode(<String, Object>{
          'alice': <String, Object>{
            'username': 'alice',
            'totalXp': 120,
            'currentStreakDays': 3,
            'longestStreakDays': 3,
            'lastActiveOn': yesterdayKey,
            'xpByDate': <String, int>{yesterdayKey: 35},
            'activityCountByDate': <String, int>{yesterdayKey: 1},
            'awardedEventKeys': <String>[],
          },
        }),
      );

      final award = await DashboardSocialActivity.recordCurrentUserActivity(
        type: UserActivityType.lessonStudy,
        activityId: 'lesson:basics',
        xp: 22,
      );
      final snapshot = await DashboardSocialActivity.loadSnapshot();

      expect(award, isNotNull);
      expect(award!.currentStreakDays, 4);
      expect(snapshot.currentStreakDays, 4);
      expect(snapshot.longestStreakDays, 4);
    });

    test('ranks users by total XP and marks the active user', () async {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _dateKey(DateTime.now());

      await prefs.setString(
        'dashboard_social_profiles_v2',
        jsonEncode(<String, Object>{
          'alice': <String, Object>{
            'username': 'alice',
            'totalXp': 180,
            'currentStreakDays': 2,
            'longestStreakDays': 2,
            'lastActiveOn': todayKey,
            'xpByDate': <String, int>{todayKey: 40},
            'activityCountByDate': <String, int>{todayKey: 1},
            'awardedEventKeys': <String>[],
          },
          'bob': <String, Object>{
            'username': 'bob',
            'totalXp': 260,
            'currentStreakDays': 5,
            'longestStreakDays': 5,
            'lastActiveOn': todayKey,
            'xpByDate': <String, int>{todayKey: 55},
            'activityCountByDate': <String, int>{todayKey: 1},
            'awardedEventKeys': <String>[],
          },
        }),
      );

      final snapshot = await DashboardSocialActivity.loadSnapshot();

      expect(snapshot.leaderboard.length, 2);
      expect(snapshot.leaderboard.first.displayName, 'Bob');
      expect(snapshot.leaderboard.first.rank, 1);
      expect(snapshot.currentUserEntry, isNotNull);
      expect(snapshot.currentUserEntry!.displayName, 'Alice');
      expect(snapshot.globalRank, 2);
    });
  });
}

String _dateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.toIso8601String().split('T').first;
}
