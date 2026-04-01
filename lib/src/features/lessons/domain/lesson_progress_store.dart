import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LessonCatalogEntry {
  const LessonCatalogEntry({
    required this.id,
    required this.shortLabel,
    required this.title,
    required this.summary,
  });

  final String id;
  final String shortLabel;
  final String title;
  final String summary;
}

const List<LessonCatalogEntry> lessonCatalog = <LessonCatalogEntry>[
  LessonCatalogEntry(
    id: 'basics',
    shortLabel: 'Chapter 1',
    title: 'Basics',
    summary:
        'Security foundations, authentication, least privilege, updates, backups, and defense in depth.',
  ),
  LessonCatalogEntry(
    id: 'social_engineering',
    shortLabel: 'Chapter 2',
    title: 'Social Engineering',
    summary:
        'Urgency, authority, phishing, smishing, vishing, baiting, and safer verification habits.',
  ),
  LessonCatalogEntry(
    id: 'everyday_threats',
    shortLabel: 'Chapter 3',
    title: 'Everyday Threats',
    summary:
        'Password reuse, malware, fake sites, ransomware, risky installers, and safer defaults.',
  ),
  LessonCatalogEntry(
    id: 'public_wifi',
    shortLabel: 'Chapter 5',
    title: 'Public Wi-Fi Safety',
    summary:
        'Fake hotspots, evil twins, trusted SSIDs, HTTPS, VPNs, and safer network choices.',
  ),
  LessonCatalogEntry(
    id: 'emerging_threats',
    shortLabel: 'Chapter 6',
    title: 'Emerging Threats',
    summary:
        'Deepfakes, SIM swapping, voice cloning, crypto fraud, recovery scams, and OSINT targeting.',
  ),
  LessonCatalogEntry(
    id: 'social_media_safety',
    shortLabel: 'Chapter 7',
    title: 'Social Media Safety',
    summary:
        'Oversharing, fake profiles, doxxing, permissions, impersonation, and safer platform habits.',
  ),
];

class LessonProgressSnapshot {
  const LessonProgressSnapshot({
    required this.lastLessonId,
    required this.viewedLessonIds,
    required this.fillBlankMasteredIds,
    required this.matchMasteredIds,
  });

  const LessonProgressSnapshot.empty()
    : lastLessonId = 'basics',
      viewedLessonIds = const <String>{},
      fillBlankMasteredIds = const <String>{},
      matchMasteredIds = const <String>{};

  final String lastLessonId;
  final Set<String> viewedLessonIds;
  final Set<String> fillBlankMasteredIds;
  final Set<String> matchMasteredIds;

  LessonCatalogEntry get lastLesson {
    return lessonCatalog.firstWhere(
      (lesson) => lesson.id == lastLessonId,
      orElse: () => lessonCatalog.first,
    );
  }

  int get completedStepCount =>
      viewedLessonIds.length +
      fillBlankMasteredIds.length +
      matchMasteredIds.length;

  int get totalStepCount => lessonCatalog.length * 3;

  double get overallProgress =>
      totalStepCount == 0 ? 0 : completedStepCount / totalStepCount;

  int get completedLessonCount {
    return lessonCatalog
        .where((lesson) => progressForLesson(lesson.id) >= 1)
        .length;
  }

  double progressForLesson(String lessonId) {
    var completedSteps = 0;
    if (viewedLessonIds.contains(lessonId)) {
      completedSteps += 1;
    }
    if (fillBlankMasteredIds.contains(lessonId)) {
      completedSteps += 1;
    }
    if (matchMasteredIds.contains(lessonId)) {
      completedSteps += 1;
    }
    return completedSteps / 3;
  }

  String nextStepForLesson(String lessonId) {
    if (!viewedLessonIds.contains(lessonId)) {
      return 'Start the theory walkthrough.';
    }
    if (!fillBlankMasteredIds.contains(lessonId)) {
      return 'Complete the fill-in-the-blank check.';
    }
    if (!matchMasteredIds.contains(lessonId)) {
      return 'Finish the mix-and-match activity.';
    }
    return 'This lesson is complete and ready for quiz review.';
  }

  LessonProgressSnapshot copyWith({
    String? lastLessonId,
    Set<String>? viewedLessonIds,
    Set<String>? fillBlankMasteredIds,
    Set<String>? matchMasteredIds,
  }) {
    return LessonProgressSnapshot(
      lastLessonId: lastLessonId ?? this.lastLessonId,
      viewedLessonIds: viewedLessonIds ?? this.viewedLessonIds,
      fillBlankMasteredIds: fillBlankMasteredIds ?? this.fillBlankMasteredIds,
      matchMasteredIds: matchMasteredIds ?? this.matchMasteredIds,
    );
  }
}

class LessonProgressStore {
  const LessonProgressStore._();

  static const String _storageKey = 'lesson_progress_snapshot_v1';

  static Future<LessonProgressSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const LessonProgressSnapshot.empty();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LessonProgressSnapshot(
        lastLessonId:
            (json['lastLessonId'] as String?) ?? lessonCatalog.first.id,
        viewedLessonIds: _decodeSet(json['viewedLessonIds']),
        fillBlankMasteredIds: _decodeSet(json['fillBlankMasteredIds']),
        matchMasteredIds: _decodeSet(json['matchMasteredIds']),
      );
    } catch (_) {
      return const LessonProgressSnapshot.empty();
    }
  }

  static Future<LessonProgressSnapshot> updateSelection(String lessonId) async {
    final snapshot = await load();
    final viewed = Set<String>.from(snapshot.viewedLessonIds)..add(lessonId);
    final updated = snapshot.copyWith(
      lastLessonId: lessonId,
      viewedLessonIds: viewed,
    );
    await _save(updated);
    return updated;
  }

  static Future<LessonProgressSnapshot> setFillBlankMastered(
    String lessonId,
    bool mastered,
  ) async {
    final snapshot = await load();
    final masteredIds = Set<String>.from(snapshot.fillBlankMasteredIds);
    if (mastered) {
      masteredIds.add(lessonId);
    }
    final updated = snapshot.copyWith(fillBlankMasteredIds: masteredIds);
    await _save(updated);
    return updated;
  }

  static Future<LessonProgressSnapshot> setMatchMastered(
    String lessonId,
    bool mastered,
  ) async {
    final snapshot = await load();
    final masteredIds = Set<String>.from(snapshot.matchMasteredIds);
    if (mastered) {
      masteredIds.add(lessonId);
    }
    final updated = snapshot.copyWith(matchMasteredIds: masteredIds);
    await _save(updated);
    return updated;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<void> _save(LessonProgressSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'lastLessonId': snapshot.lastLessonId,
        'viewedLessonIds': snapshot.viewedLessonIds.toList(growable: false),
        'fillBlankMasteredIds': snapshot.fillBlankMasteredIds.toList(
          growable: false,
        ),
        'matchMasteredIds': snapshot.matchMasteredIds.toList(growable: false),
      }),
    );
  }

  static Set<String> _decodeSet(Object? value) {
    if (value is! List) {
      return <String>{};
    }
    return value.whereType<String>().toSet();
  }
}
