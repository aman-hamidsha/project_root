import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ML artifact contracts', () {
    test('training data contains both simulator domains and all labels', () async {
      final dataFile = File('ml/data/simulator_training_data.jsonl');
      expect(await dataFile.exists(), isTrue);

      final lines = await dataFile.readAsLines();
      expect(lines, isNotEmpty);

      final domains = <String>{};
      final labels = <String>{};

      for (final line in lines.take(200)) {
        final decoded = jsonDecode(line) as Map<String, dynamic>;
        domains.add(decoded['domain'] as String);
        labels.add(decoded['label'] as String);
        expect(decoded['scenario'], isNotEmpty);
        expect(decoded['reply'], isNotEmpty);
        expect(decoded['actions'], isA<List<dynamic>>());
      }

      expect(domains, containsAll(<String>['sms', 'email']));
      expect(
        labels,
        containsAll(<String>['dangerous', 'at_risk', 'good', 'excellent']),
      );
    });

    test('generated ML model file exports both SMS and email models', () async {
      final generated = File(
        'lib/src/features/simulators/domain/generated_ml_models.dart',
      );
      expect(await generated.exists(), isTrue);

      final content = await generated.readAsString();
      expect(content, contains('generatedSmsMlModel'));
      expect(content, contains('generatedEmailMlModel'));
      expect(content, contains('"labels"'));
      expect(content, contains('"priors"'));
      expect(content, contains('"likelihoods"'));
      expect(content, contains('"unknownLogProb"'));
    });

    test('trainer script writes to the generated model file path', () async {
      final trainer = File('tools/ml/train_simulator_model.py');
      expect(await trainer.exists(), isTrue);

      final content = await trainer.readAsString();
      expect(content, contains('MultinomialNB'));
      expect(content, contains('CountVectorizer'));
      expect(
        content,
        contains('"generated_ml_models.dart"'),
      );
    });
  });
}
