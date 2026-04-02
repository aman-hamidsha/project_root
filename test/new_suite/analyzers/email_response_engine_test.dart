import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_app/src/features/simulators/domain/email_response_engine.dart';
import 'package:cs310_app/src/features/simulators/domain/email_sim_data.dart';
import 'package:cs310_app/src/features/simulators/domain/email_sim_models.dart';

void main() {
  group('EmailResponseEngine', () {
    SimEmail findEmail(String id) =>
        simEmails.firstWhere((email) => email.id == id);

    test('rewards reporting and separate verification for phishing email', () {
      final email = findEmail('microsoft_phish');

      final result = EmailResponseEngine.evaluate(
        email: email,
        reply: 'This looks suspicious. I will report it and open the real site from my bookmark.',
        selectedActionIds: {'open_real_site', 'report_delete'},
      );

      expect(result.score, greaterThanOrEqualTo(70));
      expect(
        result.verdict,
        anyOf(equals('Excellent judgment'), equals('Good response')),
      );
      expect(result.goodChoices, isNotEmpty);
    });

    test('flags credential submission as dangerous in account phishing', () {
      final email = findEmail('microsoft_phish');

      final result = EmailResponseEngine.evaluate(
        email: email,
        reply: 'I clicked the link and entered my password and login code.',
        selectedActionIds: {'click_link', 'send_credentials'},
      );

      expect(result.score, lessThan(45));
      expect(result.verdict, equals('Dangerous response'));
      expect(result.redFlagsFound, contains('password'));
      expect(result.mistakes, isNotEmpty);
    });

    test('recognizes safe payroll verification behavior', () {
      final email = findEmail('payroll_scam');

      final result = EmailResponseEngine.evaluate(
        email: email,
        reply: 'I will verify this with payroll through the known internal channel.',
        selectedActionIds: {'call_known_contact', 'report_internal'},
      );

      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.verdict, isNot(equals('Dangerous response')));
    });

    test('routine legitimate email stays in a low-risk band', () {
      final email = findEmail('campus_it');

      final result = EmailResponseEngine.evaluate(
        email: email,
        reply: 'Thanks, I will use the student portal bookmark.',
        selectedActionIds: {'open_real_site'},
      );

      expect(result.score, greaterThanOrEqualTo(60));
      expect(
        result.verdict,
        anyOf(equals('Excellent judgment'), equals('Good response')),
      );
    });
  });
}
