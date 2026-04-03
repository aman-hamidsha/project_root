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
import 'keyword_article.dart' as _i2;
import 'package:cs310_client/src/protocol/protocol.dart' as _i3;

abstract class KeywordBriefing implements _i1.SerializableModel {
  KeywordBriefing._({
    required this.keyword,
    required this.overview,
    required this.vulnerabilities,
    required this.news,
    required this.fetchedAt,
  });

  factory KeywordBriefing({
    required String keyword,
    required String overview,
    required List<_i2.KeywordArticle> vulnerabilities,
    required List<_i2.KeywordArticle> news,
    required DateTime fetchedAt,
  }) = _KeywordBriefingImpl;

  factory KeywordBriefing.fromJson(Map<String, dynamic> jsonSerialization) {
    return KeywordBriefing(
      keyword: jsonSerialization['keyword'] as String,
      overview: jsonSerialization['overview'] as String,
      vulnerabilities: _i3.Protocol().deserialize<List<_i2.KeywordArticle>>(
        jsonSerialization['vulnerabilities'],
      ),
      news: _i3.Protocol().deserialize<List<_i2.KeywordArticle>>(
        jsonSerialization['news'],
      ),
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  String keyword;

  String overview;

  List<_i2.KeywordArticle> vulnerabilities;

  List<_i2.KeywordArticle> news;

  DateTime fetchedAt;

  /// Returns a shallow copy of this [KeywordBriefing]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  KeywordBriefing copyWith({
    String? keyword,
    String? overview,
    List<_i2.KeywordArticle>? vulnerabilities,
    List<_i2.KeywordArticle>? news,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'KeywordBriefing',
      'keyword': keyword,
      'overview': overview,
      'vulnerabilities': vulnerabilities.toJson(valueToJson: (v) => v.toJson()),
      'news': news.toJson(valueToJson: (v) => v.toJson()),
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _KeywordBriefingImpl extends KeywordBriefing {
  _KeywordBriefingImpl({
    required String keyword,
    required String overview,
    required List<_i2.KeywordArticle> vulnerabilities,
    required List<_i2.KeywordArticle> news,
    required DateTime fetchedAt,
  }) : super._(
         keyword: keyword,
         overview: overview,
         vulnerabilities: vulnerabilities,
         news: news,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [KeywordBriefing]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  KeywordBriefing copyWith({
    String? keyword,
    String? overview,
    List<_i2.KeywordArticle>? vulnerabilities,
    List<_i2.KeywordArticle>? news,
    DateTime? fetchedAt,
  }) {
    return KeywordBriefing(
      keyword: keyword ?? this.keyword,
      overview: overview ?? this.overview,
      vulnerabilities:
          vulnerabilities ??
          this.vulnerabilities.map((e0) => e0.copyWith()).toList(),
      news: news ?? this.news.map((e0) => e0.copyWith()).toList(),
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
