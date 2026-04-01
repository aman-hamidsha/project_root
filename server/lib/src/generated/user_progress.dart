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

abstract class UserProgress
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = UserProgressTable();

  static const db = UserProgressRepository._();

  @override
  int? id;

  String userId;

  int totalPlayed;

  int totalScore;

  double averageScore;

  int currentStreakDays;

  int bestStreakDays;

  DateTime? lastPlayedAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static UserProgressInclude include() {
    return UserProgressInclude._();
  }

  static UserProgressIncludeList includeList({
    _i1.WhereExpressionBuilder<UserProgressTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserProgressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserProgressTable>? orderByList,
    UserProgressInclude? include,
  }) {
    return UserProgressIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserProgress.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserProgress.t),
      include: include,
    );
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

class UserProgressUpdateTable extends _i1.UpdateTable<UserProgressTable> {
  UserProgressUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<int, int> totalPlayed(int value) => _i1.ColumnValue(
    table.totalPlayed,
    value,
  );

  _i1.ColumnValue<int, int> totalScore(int value) => _i1.ColumnValue(
    table.totalScore,
    value,
  );

  _i1.ColumnValue<double, double> averageScore(double value) => _i1.ColumnValue(
    table.averageScore,
    value,
  );

  _i1.ColumnValue<int, int> currentStreakDays(int value) => _i1.ColumnValue(
    table.currentStreakDays,
    value,
  );

  _i1.ColumnValue<int, int> bestStreakDays(int value) => _i1.ColumnValue(
    table.bestStreakDays,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastPlayedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastPlayedAt,
        value,
      );
}

class UserProgressTable extends _i1.Table<int?> {
  UserProgressTable({super.tableRelation}) : super(tableName: 'user_progress') {
    updateTable = UserProgressUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    totalPlayed = _i1.ColumnInt(
      'totalPlayed',
      this,
    );
    totalScore = _i1.ColumnInt(
      'totalScore',
      this,
    );
    averageScore = _i1.ColumnDouble(
      'averageScore',
      this,
    );
    currentStreakDays = _i1.ColumnInt(
      'currentStreakDays',
      this,
    );
    bestStreakDays = _i1.ColumnInt(
      'bestStreakDays',
      this,
    );
    lastPlayedAt = _i1.ColumnDateTime(
      'lastPlayedAt',
      this,
    );
  }

  late final UserProgressUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnInt totalPlayed;

  late final _i1.ColumnInt totalScore;

  late final _i1.ColumnDouble averageScore;

  late final _i1.ColumnInt currentStreakDays;

  late final _i1.ColumnInt bestStreakDays;

  late final _i1.ColumnDateTime lastPlayedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    totalPlayed,
    totalScore,
    averageScore,
    currentStreakDays,
    bestStreakDays,
    lastPlayedAt,
  ];
}

class UserProgressInclude extends _i1.IncludeObject {
  UserProgressInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserProgress.t;
}

class UserProgressIncludeList extends _i1.IncludeList {
  UserProgressIncludeList._({
    _i1.WhereExpressionBuilder<UserProgressTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserProgress.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserProgress.t;
}

class UserProgressRepository {
  const UserProgressRepository._();

  /// Returns a list of [UserProgress]s matching the given query parameters.
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
  Future<List<UserProgress>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserProgressTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserProgressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserProgressTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserProgress>(
      where: where?.call(UserProgress.t),
      orderBy: orderBy?.call(UserProgress.t),
      orderByList: orderByList?.call(UserProgress.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserProgress] matching the given query parameters.
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
  Future<UserProgress?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserProgressTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserProgressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserProgressTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserProgress>(
      where: where?.call(UserProgress.t),
      orderBy: orderBy?.call(UserProgress.t),
      orderByList: orderByList?.call(UserProgress.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserProgress] by its [id] or null if no such row exists.
  Future<UserProgress?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserProgress>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserProgress]s in the list and returns the inserted rows.
  ///
  /// The returned [UserProgress]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserProgress>> insert(
    _i1.Session session,
    List<UserProgress> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserProgress>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserProgress] and returns the inserted row.
  ///
  /// The returned [UserProgress] will have its `id` field set.
  Future<UserProgress> insertRow(
    _i1.Session session,
    UserProgress row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserProgress>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserProgress]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserProgress>> update(
    _i1.Session session,
    List<UserProgress> rows, {
    _i1.ColumnSelections<UserProgressTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserProgress>(
      rows,
      columns: columns?.call(UserProgress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserProgress]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserProgress> updateRow(
    _i1.Session session,
    UserProgress row, {
    _i1.ColumnSelections<UserProgressTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserProgress>(
      row,
      columns: columns?.call(UserProgress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserProgress] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserProgress?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserProgressUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserProgress>(
      id,
      columnValues: columnValues(UserProgress.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserProgress]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserProgress>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserProgressUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserProgressTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserProgressTable>? orderBy,
    _i1.OrderByListBuilder<UserProgressTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserProgress>(
      columnValues: columnValues(UserProgress.t.updateTable),
      where: where(UserProgress.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserProgress.t),
      orderByList: orderByList?.call(UserProgress.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserProgress]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserProgress>> delete(
    _i1.Session session,
    List<UserProgress> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserProgress>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserProgress].
  Future<UserProgress> deleteRow(
    _i1.Session session,
    UserProgress row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserProgress>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserProgress>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserProgressTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserProgress>(
      where: where(UserProgress.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserProgressTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserProgress>(
      where: where?.call(UserProgress.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
