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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:cs310_server/src/generated/protocol.dart' as _i2;

abstract class ScenarioResponse
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ScenarioResponseTable();

  static const db = ScenarioResponseRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ScenarioResponseInclude include() {
    return ScenarioResponseInclude._();
  }

  static ScenarioResponseIncludeList includeList({
    _i1.WhereExpressionBuilder<ScenarioResponseTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ScenarioResponseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ScenarioResponseTable>? orderByList,
    ScenarioResponseInclude? include,
  }) {
    return ScenarioResponseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ScenarioResponse.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ScenarioResponse.t),
      include: include,
    );
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

class ScenarioResponseUpdateTable
    extends _i1.UpdateTable<ScenarioResponseTable> {
  ScenarioResponseUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> simulator(String value) => _i1.ColumnValue(
    table.simulator,
    value,
  );

  _i1.ColumnValue<String, String> scenarioId(String value) => _i1.ColumnValue(
    table.scenarioId,
    value,
  );

  _i1.ColumnValue<String, String> scenarioType(String? value) =>
      _i1.ColumnValue(
        table.scenarioType,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> actionsSelected(
    List<String> value,
  ) => _i1.ColumnValue(
    table.actionsSelected,
    value,
  );

  _i1.ColumnValue<String, String> replyText(String value) => _i1.ColumnValue(
    table.replyText,
    value,
  );

  _i1.ColumnValue<int, int> score(int value) => _i1.ColumnValue(
    table.score,
    value,
  );

  _i1.ColumnValue<String, String> grade(String value) => _i1.ColumnValue(
    table.grade,
    value,
  );

  _i1.ColumnValue<String, String> summary(String value) => _i1.ColumnValue(
    table.summary,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ScenarioResponseTable extends _i1.Table<int?> {
  ScenarioResponseTable({super.tableRelation})
    : super(tableName: 'scenario_response') {
    updateTable = ScenarioResponseUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    simulator = _i1.ColumnString(
      'simulator',
      this,
    );
    scenarioId = _i1.ColumnString(
      'scenarioId',
      this,
    );
    scenarioType = _i1.ColumnString(
      'scenarioType',
      this,
    );
    actionsSelected = _i1.ColumnSerializable<List<String>>(
      'actionsSelected',
      this,
    );
    replyText = _i1.ColumnString(
      'replyText',
      this,
    );
    score = _i1.ColumnInt(
      'score',
      this,
    );
    grade = _i1.ColumnString(
      'grade',
      this,
    );
    summary = _i1.ColumnString(
      'summary',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ScenarioResponseUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnString simulator;

  late final _i1.ColumnString scenarioId;

  late final _i1.ColumnString scenarioType;

  late final _i1.ColumnSerializable<List<String>> actionsSelected;

  late final _i1.ColumnString replyText;

  late final _i1.ColumnInt score;

  late final _i1.ColumnString grade;

  late final _i1.ColumnString summary;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    simulator,
    scenarioId,
    scenarioType,
    actionsSelected,
    replyText,
    score,
    grade,
    summary,
    createdAt,
  ];
}

class ScenarioResponseInclude extends _i1.IncludeObject {
  ScenarioResponseInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ScenarioResponse.t;
}

class ScenarioResponseIncludeList extends _i1.IncludeList {
  ScenarioResponseIncludeList._({
    _i1.WhereExpressionBuilder<ScenarioResponseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ScenarioResponse.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ScenarioResponse.t;
}

class ScenarioResponseRepository {
  const ScenarioResponseRepository._();

  /// Returns a list of [ScenarioResponse]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ScenarioResponse>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ScenarioResponseTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ScenarioResponseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ScenarioResponseTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ScenarioResponse>(
      where: where?.call(ScenarioResponse.t),
      orderBy: orderBy?.call(ScenarioResponse.t),
      orderByList: orderByList?.call(ScenarioResponse.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ScenarioResponse] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ScenarioResponse?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ScenarioResponseTable>? where,
    int? offset,
    _i1.OrderByBuilder<ScenarioResponseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ScenarioResponseTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ScenarioResponse>(
      where: where?.call(ScenarioResponse.t),
      orderBy: orderBy?.call(ScenarioResponse.t),
      orderByList: orderByList?.call(ScenarioResponse.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ScenarioResponse] by its [id] or null if no such row exists.
  Future<ScenarioResponse?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ScenarioResponse>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ScenarioResponse]s in the list and returns the inserted rows.
  ///
  /// The returned [ScenarioResponse]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ScenarioResponse>> insert(
    _i1.Session session,
    List<ScenarioResponse> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ScenarioResponse>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ScenarioResponse] and returns the inserted row.
  ///
  /// The returned [ScenarioResponse] will have its `id` field set.
  Future<ScenarioResponse> insertRow(
    _i1.Session session,
    ScenarioResponse row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ScenarioResponse>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ScenarioResponse]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ScenarioResponse>> update(
    _i1.Session session,
    List<ScenarioResponse> rows, {
    _i1.ColumnSelections<ScenarioResponseTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ScenarioResponse>(
      rows,
      columns: columns?.call(ScenarioResponse.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ScenarioResponse]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ScenarioResponse> updateRow(
    _i1.Session session,
    ScenarioResponse row, {
    _i1.ColumnSelections<ScenarioResponseTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ScenarioResponse>(
      row,
      columns: columns?.call(ScenarioResponse.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ScenarioResponse] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ScenarioResponse?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ScenarioResponseUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ScenarioResponse>(
      id,
      columnValues: columnValues(ScenarioResponse.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ScenarioResponse]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ScenarioResponse>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ScenarioResponseUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ScenarioResponseTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ScenarioResponseTable>? orderBy,
    _i1.OrderByListBuilder<ScenarioResponseTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ScenarioResponse>(
      columnValues: columnValues(ScenarioResponse.t.updateTable),
      where: where(ScenarioResponse.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ScenarioResponse.t),
      orderByList: orderByList?.call(ScenarioResponse.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ScenarioResponse]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ScenarioResponse>> delete(
    _i1.Session session,
    List<ScenarioResponse> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ScenarioResponse>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ScenarioResponse].
  Future<ScenarioResponse> deleteRow(
    _i1.Session session,
    ScenarioResponse row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ScenarioResponse>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ScenarioResponse>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ScenarioResponseTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ScenarioResponse>(
      where: where(ScenarioResponse.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ScenarioResponseTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ScenarioResponse>(
      where: where?.call(ScenarioResponse.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
