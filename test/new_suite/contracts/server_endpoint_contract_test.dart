import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Server endpoint contract', () {
    test('scenario endpoint persists responses and updates progress', () async {
      final source = File('server/lib/src/endpoints/scenario_endpoint.dart');
      expect(await source.exists(), isTrue);

      final content = await source.readAsString();
      expect(content, contains('class ScenarioEndpoint extends Endpoint'));
      expect(content, contains('ScenarioResponse.db.insertRow'));
      expect(content, contains('UserProgress.db.findFirstRow'));
      expect(content, contains('UserProgress.db.updateRow'));
      expect(content, contains('Future<List<ScenarioResponse>> listRecentResponses'));
    });

    test('generated client exposes the scenario endpoint', () async {
      final client = File('client/lib/src/protocol/client.dart');
      expect(await client.exists(), isTrue);

      final content = await client.readAsString();
      expect(content, contains('class EndpointScenario'));
      expect(content, contains("String get name => 'scenario';"));
      expect(content, contains('Future<_i5.AnalysisResult> analyzeResponse'));
      expect(content, contains('Future<_i6.UserProgress?> getUserProgress()'));
      expect(
        content,
        contains('Future<List<_i7.ScenarioResponse>> listRecentResponses'),
      );
    });
  });
}
