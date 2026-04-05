import 'sms_response_analyzer.dart';
import 'sms_sim_models.dart';

/*
 * this file provides the small public entry point for the sms simulator's
 * scoring flow. the ui calls this engine, and the engine forwards into the
 * analyzer that actually applies the scenario rules and reply checks.
 */

class SmsResponseEngine {
  const SmsResponseEngine._();

  static SmsResponseEvaluation evaluate({
    required SmsThread thread,
    required String reply,
    required Set<String> selectedActionIds,
  }) {
    // keeping this wrapper in front of the analyzer gives the ui one simple
    // method to call even if the scoring internals change later.
    return SmsResponseAnalyzer.analyze(
      thread: thread,
      actionsSelected: selectedActionIds,
      replyText: reply,
    );
  }
}
