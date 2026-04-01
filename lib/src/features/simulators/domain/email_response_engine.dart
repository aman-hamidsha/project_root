import 'email_response_analyzer.dart';
import 'email_sim_models.dart';

class EmailResponseEngine {
  const EmailResponseEngine._();

  static EmailResponseEvaluation evaluate({
    required SimEmail email,
    required String reply,
    required Set<String> selectedActionIds,
  }) {
    return EmailResponseAnalyzer.analyze(
      email: email,
      actionsSelected: selectedActionIds,
      replyText: reply,
    );
  }
}
