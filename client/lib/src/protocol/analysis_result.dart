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

abstract class AnalysisResult implements _i1.SerializableModel {
  AnalysisResult._({
    required this.score,
    required this.grade,
    required this.summary,
    required this.goodChoices,
    required this.mistakes,
    required this.redFlagsFound,
  });

  factory AnalysisResult({
    required int score,
    required String grade,
    required String summary,
    required List<String> goodChoices,
    required List<String> mistakes,
    required List<String> redFlagsFound,
  }) = _AnalysisResultImpl;

  factory AnalysisResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnalysisResult(
      score: jsonSerialization['score'] as int,
      grade: jsonSerialization['grade'] as String,
      summary: jsonSerialization['summary'] as String,
      goodChoices: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['goodChoices'],
      ),
      mistakes: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['mistakes'],
      ),
      redFlagsFound: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['redFlagsFound'],
      ),
    );
  }

  int score;

  String grade;

  String summary;

  List<String> goodChoices;

  List<String> mistakes;

  List<String> redFlagsFound;

  /// Returns a shallow copy of this [AnalysisResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AnalysisResult copyWith({
    int? score,
    String? grade,
    String? summary,
    List<String>? goodChoices,
    List<String>? mistakes,
    List<String>? redFlagsFound,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnalysisResult',
      'score': score,
      'grade': grade,
      'summary': summary,
      'goodChoices': goodChoices.toJson(),
      'mistakes': mistakes.toJson(),
      'redFlagsFound': redFlagsFound.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AnalysisResultImpl extends AnalysisResult {
  _AnalysisResultImpl({
    required int score,
    required String grade,
    required String summary,
    required List<String> goodChoices,
    required List<String> mistakes,
    required List<String> redFlagsFound,
  }) : super._(
         score: score,
         grade: grade,
         summary: summary,
         goodChoices: goodChoices,
         mistakes: mistakes,
         redFlagsFound: redFlagsFound,
       );

  /// Returns a shallow copy of this [AnalysisResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AnalysisResult copyWith({
    int? score,
    String? grade,
    String? summary,
    List<String>? goodChoices,
    List<String>? mistakes,
    List<String>? redFlagsFound,
  }) {
    return AnalysisResult(
      score: score ?? this.score,
      grade: grade ?? this.grade,
      summary: summary ?? this.summary,
      goodChoices: goodChoices ?? this.goodChoices.map((e0) => e0).toList(),
      mistakes: mistakes ?? this.mistakes.map((e0) => e0).toList(),
      redFlagsFound:
          redFlagsFound ?? this.redFlagsFound.map((e0) => e0).toList(),
    );
  }
}
