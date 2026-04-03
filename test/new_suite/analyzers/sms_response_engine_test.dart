import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_app/src/features/simulators/domain/sms_response_engine.dart';
import 'package:cs310_app/src/features/simulators/domain/sms_sim_data.dart';
import 'package:cs310_app/src/features/simulators/domain/sms_sim_models.dart';

void main() {
  group('SmsResponseEngine', () {
    SmsThread findThread(String id) =>
        smsThreads.firstWhere((thread) => thread.id == id);

    test('rewards cautious handling of a delivery smishing text', () {
      final thread = findThread('delivery_fee');

      final result = SmsResponseEngine.evaluate(
        thread: thread,
        reply: 'This looks suspicious. I will report it and verify in the official app.',
        selectedActionIds: {'report_block', 'verify_official'},
      );

      expect(result.score, greaterThanOrEqualTo(70));
      expect(
        result.verdict,
        anyOf(equals('Excellent judgment'), equals('Good response')),
      );
      expect(result.goodChoices, isNotEmpty);
      expect(result.mistakes, isEmpty);
    });

    test('heavily penalizes clicking and paying in a smishing scenario', () {
      final thread = findThread('delivery_fee');

      final result = SmsResponseEngine.evaluate(
        thread: thread,
        reply: 'I will click the link and pay the urgent fee now.',
        selectedActionIds: {'click_link', 'pay_fee'},
      );

      expect(result.score, lessThan(45));
      expect(result.verdict, equals('Dangerous response'));
      expect(result.redFlagsFound, containsAll(<String>['click', 'pay', 'fee']));
      expect(result.mistakes, isNotEmpty);
    });

    test('treats safe routine campus messages as low risk', () {
      final thread = findThread('campus_safe');

      final result = SmsResponseEngine.evaluate(
        thread: thread,
        reply: 'Thanks, I will check the official app later.',
        selectedActionIds: {'check_app'},
      );

      expect(result.score, greaterThanOrEqualTo(60));
      expect(
        result.verdict,
        anyOf(equals('Excellent judgment'), equals('Good response')),
      );
    });

    test('doing nothing scores worse than choosing a verification plan', () {
      final thread = findThread('bank_verify');

      final noPlan = SmsResponseEngine.evaluate(
        thread: thread,
        reply: '',
        selectedActionIds: <String>{},
      );
      final safePlan = SmsResponseEngine.evaluate(
        thread: thread,
        reply: 'I will call the bank using the number on my card.',
        selectedActionIds: {'contact_known_channel', 'report_block'},
      );

      expect(noPlan.score, lessThan(safePlan.score));
      expect(noPlan.mistakes, isNotEmpty);
    });
  });
}
