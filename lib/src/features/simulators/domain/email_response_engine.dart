import 'email_response_analyzer.dart';
import 'email_sim_models.dart';

/*
 * this file provides the thin public entry point for scoring a learner's
 * response in the email simulator. the page layer calls this engine rather
 * than talking to the analyzer directly, which keeps the ui code simpler and
 * gives the domain layer one obvious place to expose evaluation behavior.
 */

// this class acts as the small facade the presentation layer talks to.
class EmailResponseEngine {
  const EmailResponseEngine._();

  static EmailResponseEvaluation evaluate({
    required SimEmail email,
    required String reply,
    required Set<String> selectedActionIds,
  }) {
    // the engine currently forwards straight into the analyzer, but keeping
    // this wrapper makes it easier to extend later without touching the ui.
    return EmailResponseAnalyzer.analyze(
      email: email,
      actionsSelected: selectedActionIds,
      replyText: reply,
    );
  }
}
