import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class ScenarioEndpoint extends Endpoint {
  Future<AnalysisResult> analyzeResponse(
    Session session, {
    required String simulator,
    required String scenarioId,
    required List<String> actionsSelected,
    required String replyText,
    String? scenarioType,
  }) async {
    final result = _ScenarioAnalyzer().analyze(
      simulator: simulator,
      actionsSelected: actionsSelected,
      replyText: replyText,
    );

    final userId = _getUserId(session);
    final now = DateTime.now().toUtc();

    await ScenarioResponse.db.insertRow(
      session,
      ScenarioResponse(
        userId: userId,
        simulator: simulator,
        scenarioId: scenarioId,
        scenarioType: scenarioType,
        actionsSelected: actionsSelected,
        replyText: replyText,
        score: result.score,
        grade: result.grade,
        summary: result.summary,
        createdAt: now,
      ),
    );

    await _upsertUserProgress(session, userId: userId, score: result.score, now: now);

    return result;
  }

  Future<UserProgress?> getUserProgress(Session session) async {
    final userId = _getUserId(session);
    return UserProgress.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
  }

  Future<List<ScenarioResponse>> listRecentResponses(
    Session session, {
    int limit = 10,
  }) async {
    final userId = _getUserId(session);
    final safeLimit = limit.clamp(1, 50);
    return ScenarioResponse.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: safeLimit,
    );
  }

  String _getUserId(Session session) {
    return session.authenticated?.userIdentifier ?? 'anonymous';
  }

  Future<void> _upsertUserProgress(
    Session session, {
    required String userId,
    required int score,
    required DateTime now,
  }) async {
    final existing = await UserProgress.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (existing == null) {
      await UserProgress.db.insertRow(
        session,
        UserProgress(
          userId: userId,
          totalPlayed: 1,
          totalScore: score,
          averageScore: score.toDouble(),
          currentStreakDays: 1,
          bestStreakDays: 1,
          lastPlayedAt: now,
        ),
      );
      return;
    }

    final updatedTotalPlayed = existing.totalPlayed + 1;
    final updatedTotalScore = existing.totalScore + score;
    final updatedAverageScore = updatedTotalScore / updatedTotalPlayed;
    final updatedStreak = _calculateStreak(existing.lastPlayedAt, now, existing.currentStreakDays);
    final updatedBestStreak = updatedStreak > existing.bestStreakDays
        ? updatedStreak
        : existing.bestStreakDays;

    await UserProgress.db.updateRow(
      session,
      existing.copyWith(
        totalPlayed: updatedTotalPlayed,
        totalScore: updatedTotalScore,
        averageScore: updatedAverageScore,
        currentStreakDays: updatedStreak,
        bestStreakDays: updatedBestStreak,
        lastPlayedAt: now,
      ),
    );
  }

  int _calculateStreak(DateTime? previous, DateTime now, int currentStreakDays) {
    if (previous == null) return 1;

    final previousDate = DateTime.utc(previous.year, previous.month, previous.day);
    final currentDate = DateTime.utc(now.year, now.month, now.day);
    final dayGap = currentDate.difference(previousDate).inDays;

    if (dayGap <= 0) return currentStreakDays;
    if (dayGap == 1) return currentStreakDays + 1;
    return 1;
  }
}

class _ScenarioAnalyzer {
  AnalysisResult analyze({
    required String simulator,
    required List<String> actionsSelected,
    required String replyText,
  }) {
    var score = 50;
    final goodChoices = <String>[];
    final mistakes = <String>[];
    final redFlagsFound = <String>[];
    final lowerReply = replyText.toLowerCase();
    final lowerSimulator = simulator.toLowerCase();

    const safeActions = {
      'report',
      'verify',
      'verify_friend',
      'call_bank',
      'ignore',
      'block',
      'walk_away',
      'decline',
    };
    const riskyActions = {
      'open_link',
      'pay_fee',
      'share_code',
      'send_details',
      'buy_card',
      'agree',
      'reply',
      'connect_wallet',
      'invest',
    };
    const riskyKeywords = [
      'click',
      'pay',
      'urgent',
      'fee',
      'code',
      'password',
      'wallet',
      'seed phrase',
      'bank details',
      'send money',
    ];
    const safeKeywords = [
      'report',
      'ignore',
      'verify',
      'scam',
      'suspicious',
      'call bank',
      'not interested',
      'block',
    ];

    for (final action in actionsSelected) {
      if (safeActions.contains(action)) {
        score += 15;
        goodChoices.add('Safe action selected: $action');
      } else if (riskyActions.contains(action)) {
        score -= 20;
        mistakes.add('Risky action selected: $action');
      }
    }

    for (final keyword in riskyKeywords) {
      if (lowerReply.contains(keyword)) {
        redFlagsFound.add(keyword);
        score -= 8;
      }
    }

    for (final keyword in safeKeywords) {
      if (lowerReply.contains(keyword)) {
        score += 5;
      }
    }

    if (lowerSimulator.contains('sms') || lowerSimulator.contains('email')) {
      if (replyText.trim().isEmpty && !actionsSelected.contains('report')) {
        score -= 5;
        mistakes.add('No response strategy was explained.');
      }
    }

    score = score.clamp(0, 100);
    final grade = _gradeForScore(score);

    return AnalysisResult(
      score: score,
      grade: grade,
      summary: _summaryForGrade(grade),
      goodChoices: goodChoices,
      mistakes: mistakes,
      redFlagsFound: redFlagsFound,
    );
  }

  String _gradeForScore(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'At Risk';
    return 'Dangerous';
  }

  String _summaryForGrade(String grade) {
    switch (grade) {
      case 'Excellent':
        return 'Well handled. The response was cautious and security-aware.';
      case 'Good':
        return 'Mostly safe, but there is still room to tighten the response.';
      case 'At Risk':
        return 'Some choices created unnecessary exposure to the scam.';
      default:
        return 'The response would likely lead to real harm in a live scam.';
    }
  }
}
