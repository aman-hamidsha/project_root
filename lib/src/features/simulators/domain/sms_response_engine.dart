import 'sms_response_analyzer.dart';
import 'sms_sim_models.dart';

class SmsResponseEngine {
  const SmsResponseEngine._();

  static SmsResponseEvaluation evaluate({
    required SmsThread thread,
    required String reply,
    required Set<String> selectedActionIds,
  }) {
    return SmsResponseAnalyzer.analyze(
      thread: thread,
      actionsSelected: selectedActionIds,
      replyText: reply,
    );
  }
}
