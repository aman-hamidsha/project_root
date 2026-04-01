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
import 'package:cs310_client/src/protocol/protocol.dart' as _i2;

abstract class ScenarioResponse implements _i1.SerializableModel {
  ScenarioResponse._({
    this.id,
    required this.userId,
    required this.simulator,
    required this.scenarioId,
    this.scenarioType,
    required this.actionsSelected,
    required this.replyText,
    required this.score,
    required this.grade,
    required this.summary,
    required this.createdAt,
  });

  factory ScenarioResponse({
    int? id,
    required String userId,
    required String simulator,
    required String scenarioId,
    String? scenarioType,
    required List<String> actionsSelected,
    required String replyText,
    required int score,
    required String grade,
    required String summary,
    required DateTime createdAt,
  }) = _ScenarioResponseImpl;

  factory ScenarioResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ScenarioResponse(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      simulator: jsonSerialization['simulator'] as String,
      scenarioId: jsonSerialization['scenarioId'] as String,
      scenarioType: jsonSerialization['scenarioType'] as String?,
      actionsSelected: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['actionsSelected'],
      ),
      replyText: jsonSerialization['replyText'] as String,
      score: jsonSerialization['score'] as int,
      grade: jsonSerialization['grade'] as String,
      summary: jsonSerialization['summary'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String simulator;

  String scenarioId;

  String? scenarioType;

  List<String> actionsSelected;

  String replyText;

  int score;

  String grade;

  String summary;

  DateTime createdAt;

  /// Returns a shallow copy of this [ScenarioResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ScenarioResponse copyWith({
    int? id,
    String? userId,
    String? simulator,
    String? scenarioId,
    String? scenarioType,
    List<String>? actionsSelected,
    String? replyText,
    int? score,
    String? grade,
    String? summary,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScenarioResponse',
      if (id != null) 'id': id,
      'userId': userId,
      'simulator': simulator,
      'scenarioId': scenarioId,
      if (scenarioType != null) 'scenarioType': scenarioType,
      'actionsSelected': actionsSelected.toJson(),
      'replyText': replyText,
      'score': score,
      'grade': grade,
      'summary': summary,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ScenarioResponseImpl extends ScenarioResponse {
  _ScenarioResponseImpl({
    int? id,
    required String userId,
    required String simulator,
    required String scenarioId,
    String? scenarioType,
    required List<String> actionsSelected,
    required String replyText,
    required int score,
    required String grade,
    required String summary,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         simulator: simulator,
         scenarioId: scenarioId,
         scenarioType: scenarioType,
         actionsSelected: actionsSelected,
         replyText: replyText,
         score: score,
         grade: grade,
         summary: summary,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ScenarioResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ScenarioResponse copyWith({
    Object? id = _Undefined,
    String? userId,
    String? simulator,
    String? scenarioId,
    Object? scenarioType = _Undefined,
    List<String>? actionsSelected,
    String? replyText,
    int? score,
    String? grade,
    String? summary,
    DateTime? createdAt,
  }) {
    return ScenarioResponse(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      simulator: simulator ?? this.simulator,
      scenarioId: scenarioId ?? this.scenarioId,
      scenarioType: scenarioType is String? ? scenarioType : this.scenarioType,
      actionsSelected:
          actionsSelected ?? this.actionsSelected.map((e0) => e0).toList(),
      replyText: replyText ?? this.replyText,
      score: score ?? this.score,
      grade: grade ?? this.grade,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
