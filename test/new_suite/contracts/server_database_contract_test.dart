import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Server database contract', () {
    test('migration registry references the created migration', () async {
      final registry = File('server/migrations/migration_registry.txt');
      expect(await registry.exists(), isTrue);

      final content = await registry.readAsString();
      expect(content, contains('20260401070615029'));
    });

    test('migration SQL creates expected application tables and indexes', () async {
      final sql = File('server/migrations/20260401070615029/migration.sql');
      expect(await sql.exists(), isTrue);

      final content = await sql.readAsString();
      expect(content, contains('CREATE TABLE "scenario_response"'));
      expect(content, contains('CREATE TABLE "user_progress"'));
      expect(content, contains('"scenario_response_user_created_idx"'));
      expect(content, contains('"scenario_response_simulator_idx"'));
      expect(content, contains('"user_progress_user_idx"'));
    });

    test('database definition file describes response and progress columns', () async {
      final definition = File(
        'server/migrations/20260401070615029/definition.sql',
      );
      expect(await definition.exists(), isTrue);

      final content = await definition.readAsString();
      expect(content, contains('"actionsSelected" json NOT NULL'));
      expect(content, contains('"summary" text NOT NULL'));
      expect(content, contains('"averageScore" double precision NOT NULL'));
      expect(content, contains('"lastPlayedAt" timestamp without time zone'));
    });
  });
}
