import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Scenario endpoint contract', () {
    test('endpoint persists responses and updates aggregates', () async {
      final source = File('lib/src/endpoints/scenario_endpoint.dart');
      expect(await source.exists(), isTrue);

      final content = await source.readAsString();
      expect(content, contains('class ScenarioEndpoint extends Endpoint'));
      expect(content, contains('ScenarioResponse.db.insertRow'));
      expect(content, contains('UserProgress.db.findFirstRow'));
      expect(content, contains('UserProgress.db.updateRow'));
      expect(content,
          contains('Future<List<ScenarioResponse>> listRecentResponses'));
    });

    test('dispatch registry exposes the scenario endpoint methods', () async {
      final dispatch = File('lib/src/endpoints.dart');
      expect(await dispatch.exists(), isTrue);

      final content = await dispatch.readAsString();
      expect(content, contains("'scenario': _i4.ScenarioEndpoint()"));
      expect(content, contains("'getKeywordBriefing'"));
      expect(content, contains("'analyzeResponse'"));
      expect(content, contains("'getUserProgress'"));
      expect(content, contains("'listRecentResponses'"));
    });
  });
}
