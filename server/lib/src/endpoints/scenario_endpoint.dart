import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class ScenarioEndpoint extends Endpoint {
  Future<KeywordBriefing> getKeywordBriefing(
    Session session, {
    required String keyword,
  }) async {
    final normalizedKeyword = keyword.trim();
    final searchPhrase = _keywordSearchPhrase(normalizedKeyword);
    final vulnerabilities = await _fetchRecentVulnerabilities(searchPhrase);
    final news = await _fetchRecentNews(searchPhrase);

    return KeywordBriefing(
      keyword: normalizedKeyword,
      overview: _overviewForKeyword(normalizedKeyword),
      vulnerabilities: vulnerabilities,
      news: news,
      fetchedAt: DateTime.now().toUtc(),
    );
  }

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

    await _upsertUserProgress(session,
        userId: userId, score: result.score, now: now);

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
    final updatedStreak = _calculateStreak(
        existing.lastPlayedAt, now, existing.currentStreakDays);
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

  int _calculateStreak(
      DateTime? previous, DateTime now, int currentStreakDays) {
    if (previous == null) return 1;

    final previousDate =
        DateTime.utc(previous.year, previous.month, previous.day);
    final currentDate = DateTime.utc(now.year, now.month, now.day);
    final dayGap = currentDate.difference(previousDate).inDays;

    if (dayGap <= 0) return currentStreakDays;
    if (dayGap == 1) return currentStreakDays + 1;
    return 1;
  }
}

Future<List<KeywordArticle>> _fetchRecentVulnerabilities(String keyword) async {
  final client = HttpClient();
  try {
    final now = DateTime.now().toUtc();
    final start = now.subtract(const Duration(days: 90));
    final uri = Uri.https('services.nvd.nist.gov', '/rest/json/cves/2.0', {
      'keywordSearch': keyword,
      'resultsPerPage': '4',
      'pubStartDate': start.toIso8601String(),
      'pubEndDate': now.toIso8601String(),
    });
    final request = await client.getUrl(uri);
    final response = await request.close();
    final payload = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const <KeywordArticle>[];
    }

    final json = jsonDecode(payload) as Map<String, dynamic>;
    final vulnerabilities =
        (json['vulnerabilities'] as List<dynamic>? ?? const <dynamic>[])
            .take(4)
            .map((item) => item as Map<String, dynamic>)
            .map((item) => item['cve'] as Map<String, dynamic>? ?? const {})
            .map((cve) {
      final id = cve['id'] as String? ?? 'Unknown CVE';
      final description =
          ((cve['descriptions'] as List<dynamic>? ?? const <dynamic>[])
                  .cast<Map<String, dynamic>?>()
                  .firstWhere(
                    (entry) => (entry?['lang'] as String?) == 'en',
                    orElse: () => null,
                  )?['value'] as String?) ??
              'No summary available.';
      final published = cve['published'] as String? ?? '';
      return KeywordArticle(
        title: id,
        source: 'NVD',
        url: 'https://nvd.nist.gov/vuln/detail/$id',
        snippet: description,
        publishedLabel: _formatPublishedLabel(published),
        category: 'Vulnerability',
      );
    }).toList();

    return vulnerabilities;
  } catch (_) {
    return const <KeywordArticle>[];
  } finally {
    client.close(force: true);
  }
}

Future<List<KeywordArticle>> _fetchRecentNews(String keyword) async {
  final client = HttpClient();
  try {
    final query = '$keyword cybersecurity vulnerability';
    final uri = Uri.parse(
      'https://news.google.com/rss/search?q=${Uri.encodeQueryComponent(query)}&hl=en-GB&gl=GB&ceid=GB:en',
    );
    final request = await client.getUrl(uri);
    final response = await request.close();
    final payload = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const <KeywordArticle>[];
    }

    final itemRegExp = RegExp(r'<item>([\s\S]*?)</item>', multiLine: true);
    final titleRegExp =
        RegExp(r'<title><!\[CDATA\[(.*?)\]\]></title>|<title>(.*?)</title>');
    final linkRegExp = RegExp(r'<link>(.*?)</link>');
    final pubDateRegExp = RegExp(r'<pubDate>(.*?)</pubDate>');
    final sourceRegExp = RegExp(r'<source[^>]*>(.*?)</source>');
    final descriptionRegExp = RegExp(
      r'<description><!\[CDATA\[(.*?)\]\]></description>|<description>([\s\S]*?)</description>',
      multiLine: true,
    );

    return itemRegExp
        .allMatches(payload)
        .take(4)
        .map((match) => match.group(1) ?? '')
        .map((item) {
      final titleMatch = titleRegExp.firstMatch(item);
      final descriptionMatch = descriptionRegExp.firstMatch(item);
      final title = _cleanHtml(
          titleMatch?.group(1) ?? titleMatch?.group(2) ?? 'Recent article');
      final description = _cleanHtml(
        descriptionMatch?.group(1) ?? descriptionMatch?.group(2) ?? '',
      );
      final source = _cleanHtml(
        sourceRegExp.firstMatch(item)?.group(1) ?? 'Google News',
      );
      final link = linkRegExp.firstMatch(item)?.group(1) ?? '';
      final pubDate = pubDateRegExp.firstMatch(item)?.group(1) ?? '';
      return KeywordArticle(
        title: title,
        source: source,
        url: link,
        snippet: description.isEmpty
            ? 'Recent article related to $keyword.'
            : description,
        publishedLabel: _formatPublishedLabel(pubDate),
        category: 'News',
      );
    }).toList();
  } catch (_) {
    return const <KeywordArticle>[];
  } finally {
    client.close(force: true);
  }
}

String _overviewForKeyword(String keyword) {
  final normalized = keyword.toLowerCase();
  const overviews = <String, String>{
    'phishing':
        'Phishing remains one of the most common entry points for credential theft, malware delivery, and payment fraud, so recent incidents often involve impersonation, fake portals, or social pressure.',
    'smishing':
        'Smishing trends usually involve delivery fees, fake banking alerts, and urgent account prompts sent over SMS to push victims toward malicious links or code sharing.',
    'malware':
        'Recent malware reporting often focuses on how malicious software is delivered, how it persists, and what kinds of data or access it tries to steal.',
    'ransomware':
        'Ransomware coverage typically centers on intrusion methods, stolen data, operational disruption, and recovery challenges after encryption or extortion.',
    'evil twin':
        'Evil twin reporting usually overlaps with rogue hotspot attacks, fake captive portals, and traffic interception attempts on open wireless networks.',
    'vpn':
        'VPN-related stories often include both privacy benefits and vulnerability reporting around client software, gateways, and remote access infrastructure.',
    'https':
        'HTTPS news often relates to certificate issues, browser trust warnings, downgrade attempts, or secure transport vulnerabilities.',
    'deepfake':
        'Deepfake coverage often focuses on impersonation, misinformation, and how convincing synthetic media is being used in fraud or influence campaigns.',
    'sim swapping':
        'SIM swapping incidents usually involve account takeover, interception of SMS-based codes, and abuse of recovery workflows.',
    'osint':
        'OSINT-related reporting often shows how public data can be aggregated into targeting profiles for scams, social engineering, and identity abuse.',
    'permissions':
        'Permissions issues often surface when apps or services request more access than needed, creating privacy or security exposure if misused.',
  };
  return overviews[normalized] ??
      'This live briefing pulls recent vulnerability records and article headlines related to the selected keyword so the lesson content stays connected to current security events.';
}

String _keywordSearchPhrase(String keyword) {
  const aliases = <String, String>{
    'evil twin': '"evil twin" wifi hotspot',
    'vpn': 'vpn vulnerability',
    'https': 'tls https certificate vulnerability',
    'deepfake': 'deepfake cybersecurity fraud',
    'sim swapping': '"SIM swapping"',
    'voice clone': '"voice clone" scam',
    'osint': 'osint social engineering',
    'permissions': 'app permissions privacy vulnerability',
    'mfa fatigue': '"MFA fatigue"',
    'session token': '"session token" vulnerability',
    'certificate warning': 'certificate validation vulnerability',
    'captive portal': '"captive portal" phishing',
  };
  return aliases[keyword.toLowerCase()] ?? keyword;
}

String _cleanHtml(String value) {
  final decoded = value
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ');

  return decoded
      .replaceAll(RegExp(r'<a\b[^>]*>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'</a>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'https?://\S+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _formatPublishedLabel(String raw) {
  if (raw.isEmpty) {
    return 'Recent';
  }

  DateTime? date = DateTime.tryParse(raw);
  if (date == null) {
    try {
      date = HttpDate.parse(raw);
    } catch (_) {
      date = null;
    }
  }

  if (date == null) {
    return raw;
  }

  final utc = date.toUtc();
  final month = <int, String>{
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  }[utc.month]!;
  return '$month ${utc.day}, ${utc.year}';
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
