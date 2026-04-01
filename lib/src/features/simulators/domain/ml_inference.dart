import 'generated_ml_models.dart';

class MlClassificationResult {
  const MlClassificationResult({required this.label, required this.score});

  final String label;
  final int score;
}

class MlNaiveBayesClassifier {
  const MlNaiveBayesClassifier._();

  static MlClassificationResult classifySms({
    required String scenario,
    required Set<String> actions,
    required String reply,
  }) {
    return _classify(
      model: generatedSmsMlModel,
      scenario: scenario,
      actions: actions,
      reply: reply,
    );
  }

  static MlClassificationResult classifyEmail({
    required String scenario,
    required Set<String> actions,
    required String reply,
  }) {
    return _classify(
      model: generatedEmailMlModel,
      scenario: scenario,
      actions: actions,
      reply: reply,
    );
  }

  static MlClassificationResult _classify({
    required Map<String, dynamic> model,
    required String scenario,
    required Set<String> actions,
    required String reply,
  }) {
    final labels = List<String>.from(model['labels'] as List);
    final priors = Map<String, dynamic>.from(model['priors'] as Map);
    final likelihoods = Map<String, dynamic>.from(model['likelihoods'] as Map);
    final unknownLogProb = Map<String, dynamic>.from(
      model['unknownLogProb'] as Map,
    );

    final tokens = _tokenize(reply, scenario: scenario, actions: actions);
    var bestLabel = labels.first;
    double? bestScore;

    for (final label in labels) {
      var logScore = (priors[label] as num).toDouble();
      final tokenMap = Map<String, dynamic>.from(likelihoods[label] as Map);
      final unknown = (unknownLogProb[label] as num).toDouble();
      for (final token in tokens) {
        logScore += ((tokenMap[token] as num?)?.toDouble() ?? unknown);
      }
      if (bestScore == null || logScore > bestScore) {
        bestScore = logScore;
        bestLabel = label;
      }
    }

    final mappedScore = switch (bestLabel) {
      'excellent' => 92,
      'good' => 72,
      'at_risk' => 45,
      _ => 20,
    };

    return MlClassificationResult(label: bestLabel, score: mappedScore);
  }

  static List<String> _tokenize(
    String reply, {
    required String scenario,
    required Set<String> actions,
  }) {
    final normalized = reply.toLowerCase();
    final tokens = <String>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
    }

    for (final rune in normalized.runes) {
      final char = String.fromCharCode(rune);
      final isWord = RegExp(r"[a-z0-9']").hasMatch(char) || char == "'";
      if (isWord) {
        buffer.write(char);
      } else {
        flush();
      }
    }
    flush();

    tokens.add('scenario_${scenario.toLowerCase()}');
    tokens.addAll(actions.map((action) => 'action_${action.toLowerCase()}'));
    return tokens;
  }
}
