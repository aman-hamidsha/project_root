import 'package:cs310_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Server protocol models', () {
    test('analysis result serializes and deserializes cleanly', () {
      final original = AnalysisResult(
        score: 88,
        grade: 'good',
        summary: 'Handled safely.',
        goodChoices: <String>['Reported the scam'],
        mistakes: <String>[],
        redFlagsFound: <String>['urgent'],
      );

      final json = original.toJson();
      final decoded = AnalysisResult.fromJson(json);

      expect(decoded.score, 88);
      expect(decoded.grade, 'good');
      expect(decoded.summary, 'Handled safely.');
      expect(decoded.goodChoices, contains('Reported the scam'));
      expect(decoded.redFlagsFound, contains('urgent'));
    });

    test('protocol knows about the custom application models', () {
      expect(Protocol.getClassNameForType(AnalysisResult), 'AnalysisResult');
      expect(Protocol.getClassNameForType(KeywordBriefing), 'KeywordBriefing');
      expect(
          Protocol.getClassNameForType(ScenarioResponse), 'ScenarioResponse');
      expect(Protocol.getClassNameForType(UserProgress), 'UserProgress');
    });
  });
}
