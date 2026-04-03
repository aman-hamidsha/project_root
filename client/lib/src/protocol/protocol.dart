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
import 'analysis_result.dart' as _i2;
import 'keyword_article.dart' as _i3;
import 'keyword_briefing.dart' as _i4;
import 'scenario_response.dart' as _i5;
import 'user_progress.dart' as _i6;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i7;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i8;
export 'analysis_result.dart';
export 'keyword_article.dart';
export 'keyword_briefing.dart';
export 'scenario_response.dart';
export 'user_progress.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AnalysisResult) {
      return _i2.AnalysisResult.fromJson(data) as T;
    }
    if (t == _i3.KeywordArticle) {
      return _i3.KeywordArticle.fromJson(data) as T;
    }
    if (t == _i4.KeywordBriefing) {
      return _i4.KeywordBriefing.fromJson(data) as T;
    }
    if (t == _i5.ScenarioResponse) {
      return _i5.ScenarioResponse.fromJson(data) as T;
    }
    if (t == _i6.UserProgress) {
      return _i6.UserProgress.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AnalysisResult?>()) {
      return (data != null ? _i2.AnalysisResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.KeywordArticle?>()) {
      return (data != null ? _i3.KeywordArticle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.KeywordBriefing?>()) {
      return (data != null ? _i4.KeywordBriefing.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ScenarioResponse?>()) {
      return (data != null ? _i5.ScenarioResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.UserProgress?>()) {
      return (data != null ? _i6.UserProgress.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i3.KeywordArticle>) {
      return (data as List)
              .map((e) => deserialize<_i3.KeywordArticle>(e))
              .toList()
          as T;
    }
    try {
      return _i7.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i8.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AnalysisResult => 'AnalysisResult',
      _i3.KeywordArticle => 'KeywordArticle',
      _i4.KeywordBriefing => 'KeywordBriefing',
      _i5.ScenarioResponse => 'ScenarioResponse',
      _i6.UserProgress => 'UserProgress',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('cs310.', '');
    }

    switch (data) {
      case _i2.AnalysisResult():
        return 'AnalysisResult';
      case _i3.KeywordArticle():
        return 'KeywordArticle';
      case _i4.KeywordBriefing():
        return 'KeywordBriefing';
      case _i5.ScenarioResponse():
        return 'ScenarioResponse';
      case _i6.UserProgress():
        return 'UserProgress';
    }
    className = _i7.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    className = _i8.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnalysisResult') {
      return deserialize<_i2.AnalysisResult>(data['data']);
    }
    if (dataClassName == 'KeywordArticle') {
      return deserialize<_i3.KeywordArticle>(data['data']);
    }
    if (dataClassName == 'KeywordBriefing') {
      return deserialize<_i4.KeywordBriefing>(data['data']);
    }
    if (dataClassName == 'ScenarioResponse') {
      return deserialize<_i5.ScenarioResponse>(data['data']);
    }
    if (dataClassName == 'UserProgress') {
      return deserialize<_i6.UserProgress>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i7.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i8.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i7.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i8.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
