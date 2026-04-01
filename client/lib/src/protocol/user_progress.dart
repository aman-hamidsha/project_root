/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class UserProgress implements _i1.SerializableModel {
  UserProgress._({
    this.id,
    required this.userId,
    required this.totalPlayed,
    required this.totalScore,
    required this.averageScore,
    required this.currentStreakDays,
    required this.bestStreakDays,
    this.lastPlayedAt,
  });

  factory UserProgress({
    int? id,
    required String userId,
    required int totalPlayed,
    required int totalScore,
    required double averageScore,
    required int currentStreakDays,
    required int bestStreakDays,
    DateTime? lastPlayedAt,
  }) = _UserProgressImpl;

  factory UserProgress.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProgress(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      totalPlayed: jsonSerialization['totalPlayed'] as int,
      totalScore: jsonSerialization['totalScore'] as int,
      averageScore: (jsonSerialization['averageScore'] as num).toDouble(),
      currentStreakDays: jsonSerialization['currentStreakDays'] as int,
      bestStreakDays: jsonSerialization['bestStreakDays'] as int,
      lastPlayedAt: jsonSerialization['lastPlayedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastPlayedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  int totalPlayed;

  int totalScore;

  double averageScore;

  int currentStreakDays;

  int bestStreakDays;

  DateTime? lastPlayedAt;

  /// Returns a shallow copy of this [UserProgress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserProgress copyWith({
    int? id,
    String? userId,
    int? totalPlayed,
    int? totalScore,
    double? averageScore,
    int? currentStreakDays,
    int? bestStreakDays,
    DateTime? lastPlayedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProgress',
      if (id != null) 'id': id,
      'userId': userId,
      'totalPlayed': totalPlayed,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'currentStreakDays': currentStreakDays,
      'bestStreakDays': bestStreakDays,
      if (lastPlayedAt != null) 'lastPlayedAt': lastPlayedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserProgressImpl extends UserProgress {
  _UserProgressImpl({
    int? id,
    required String userId,
    required int totalPlayed,
    required int totalScore,
    required double averageScore,
    required int currentStreakDays,
    required int bestStreakDays,
    DateTime? lastPlayedAt,
  }) : super._(
         id: id,
         userId: userId,
         totalPlayed: totalPlayed,
         totalScore: totalScore,
         averageScore: averageScore,
         currentStreakDays: currentStreakDays,
         bestStreakDays: bestStreakDays,
         lastPlayedAt: lastPlayedAt,
       );

  /// Returns a shallow copy of this [UserProgress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserProgress copyWith({
    Object? id = _Undefined,
    String? userId,
    int? totalPlayed,
    int? totalScore,
    double? averageScore,
    int? currentStreakDays,
    int? bestStreakDays,
    Object? lastPlayedAt = _Undefined,
  }) {
    return UserProgress(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      totalPlayed: totalPlayed ?? this.totalPlayed,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      lastPlayedAt: lastPlayedAt is DateTime?
          ? lastPlayedAt
          : this.lastPlayedAt,
    );
  }
}
