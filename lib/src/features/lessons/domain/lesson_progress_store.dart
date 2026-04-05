import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// This file defines the lesson catalog plus the local persistence helpers
// that track which parts of each lesson the user has completed.

/** Metadata for a single lesson entry in the catalog: id, label, title, and summary. */
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

/** The full ordered list of all seven lessons available in the app. */
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
    id: 'account_recovery',
    shortLabel: 'Chapter 4',
    title: 'Account Recovery And Identity Protection',
    summary:
        'Recovery flows, MFA fatigue, session tokens, breach response, and safer identity-proofing habits.',
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

/** A snapshot of the user's lesson progress across all three step types: view, fill-blank, and match. */
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

  /** Returns the catalog entry for the last lesson the user visited, falling back to the first lesson if not found. */
  LessonCatalogEntry get lastLesson {
    return lessonCatalog.firstWhere(
      (lesson) => lesson.id == lastLessonId,
      orElse: () => lessonCatalog.first,
    );
  }

  /** Counts every completed lesson step across the entire catalog. */
  int
  get completedStepCount => // total number of completed steps across all lessons, counting each step type separately
      viewedLessonIds.length +
      fillBlankMasteredIds.length +
      matchMasteredIds.length;

  /** Returns the maximum number of trackable lesson steps. */
  int get totalStepCount => lessonCatalog.length * 3; // maximum possible steps

  /** Converts the total completed steps into a 0-1 overall progress value. */
  double get overallProgress =>
      totalStepCount == 0 ? 0 : completedStepCount / totalStepCount;

  /** Counts lessons where all three tracked steps have been completed. */
  int get completedLessonCount {
    return lessonCatalog
        .where((lesson) => progressForLesson(lesson.id) >= 1)
        .length;
  }

  /** Returns per-lesson completion as a fraction of its three tracked steps. */
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

  /** Describes the next incomplete step the UI should encourage for a lesson. */
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

/** Handles reading and writing lesson progress snapshots from local storage. */
class LessonProgressStore {
  const LessonProgressStore._();

  static const String _storageKey = 'lesson_progress_snapshot_v1';

  /** Loads the saved lesson snapshot, or returns an empty one if none exists. */
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

  /** Marks a lesson as selected and records its theory step as viewed. */
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

  /** Adds a lesson to the fill-in-the-blank mastered set when completed. */
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

  /** Adds a lesson to the match activity mastered set when completed. */
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

  /** Clears the saved snapshot so lesson progress starts from scratch. */
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /** Serializes the snapshot back into SharedPreferences as JSON. */
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

  /** Coerces a decoded JSON list into a string set. */
  static Set<String> _decodeSet(Object? value) {
    if (value is! List) {
      return <String>{};
    }
    return value.whereType<String>().toSet();
  }
}
