import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_app/src/features/simulators/domain/generated_ml_models.dart';
import 'package:cs310_app/src/features/simulators/domain/ml_inference.dart';

void main() {
  group('MlNaiveBayesClassifier', () {
    test('generated SMS model has expected top-level keys', () {
      expect(generatedSmsMlModel, contains('labels'));
      expect(generatedSmsMlModel, contains('priors'));
      expect(generatedSmsMlModel, contains('likelihoods'));
      expect(generatedSmsMlModel, contains('unknownLogProb'));
    });

    test('generated email model has expected top-level keys', () {
      expect(generatedEmailMlModel, contains('labels'));
      expect(generatedEmailMlModel, contains('priors'));
      expect(generatedEmailMlModel, contains('likelihoods'));
      expect(generatedEmailMlModel, contains('unknownLogProb'));
    });

    test('classifySms returns a stable result object', () {
      final result = MlNaiveBayesClassifier.classifySms(
        scenario: 'smishing',
        actions: {'report_block', 'verify_official'},
        reply: 'This is suspicious and I will verify through the official courier app.',
      );

      expect(
        result.label,
        isIn(<String>['excellent', 'good', 'at_risk', 'dangerous']),
      );
      expect(result.score, isIn(<int>[20, 45, 72, 92]));
    });

    test('safe SMS pattern scores higher than risky SMS pattern', () {
      final safeResult = MlNaiveBayesClassifier.classifySms(
        scenario: 'fraudAlert',
        actions: {'contact_known_channel', 'report_block'},
        reply: 'This looks suspicious. I will call the bank myself and report it.',
      );
      final riskyResult = MlNaiveBayesClassifier.classifySms(
        scenario: 'fraudAlert',
        actions: {'share_code', 'share_personal_info'},
        reply: 'I will confirm my code and birthday now.',
      );

      expect(safeResult.score, greaterThan(riskyResult.score));
    });

    test('safe email pattern scores higher than risky email pattern', () {
      final safeResult = MlNaiveBayesClassifier.classifyEmail(
        scenario: 'accountPhishing',
        actions: {'open_real_site', 'report_delete'},
        reply: 'This is suspicious. I will report it and use the official site.',
      );
      final riskyResult = MlNaiveBayesClassifier.classifyEmail(
        scenario: 'accountPhishing',
        actions: {'click_link', 'send_credentials'},
        reply: 'I clicked the link and entered my password.',
      );

      expect(safeResult.score, greaterThan(riskyResult.score));
    });
  });
}
