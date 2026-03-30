import 'sms_sim_models.dart';

class SmsResponseEngine {
  const SmsResponseEngine._();

  static SmsResponseEvaluation evaluate({
    required SmsThread thread,
    required String reply,
    required Set<String> selectedActionIds,
  }) {
    final normalizedReply = reply.trim().toLowerCase();
    var score = thread.kind == SmsKind.safe ? 65 : 50;
    final feedback = <String>[];
    final nextSteps = <String>{};

    if (selectedActionIds.isEmpty && normalizedReply.isEmpty) {
      score -= 12;
      feedback.add(
        'No action was chosen. In a real conversation, you still need to decide how to respond safely.',
      );
    }

    for (final actionId in selectedActionIds) {
      switch (actionId) {
        case 'verify_official':
        case 'check_app':
        case 'contact_known_channel':
          score += 24;
          feedback.add(
            'Verifying through an official app, website, or trusted number is a strong defensive move.',
          );
          nextSteps.add(
            'Use the official service directly instead of the text link.',
          );
        case 'report_block':
          score += 20;
          feedback.add(
            'Reporting and blocking suspicious numbers reduces future risk and helps stop repeat attempts.',
          );
          nextSteps.add('Report the message as spam or smishing.');
        case 'ignore_delete':
          score += thread.kind == SmsKind.safe ? -4 : 10;
          feedback.add(
            thread.kind == SmsKind.safe
                ? 'Ignoring a legitimate message is not dangerous, but it may not be the most useful response.'
                : 'Ignoring the lure instead of engaging protects you from being pushed deeper into the scam.',
          );
        case 'ask_for_identity':
          score += thread.kind == SmsKind.safe ? 2 : 8;
          feedback.add(
            'Questioning the sender shows caution, but it should still be followed by out-of-band verification.',
          );
        case 'click_link':
          score -= 34;
          feedback.add(
            'Clicking a link from a suspicious text is one of the most dangerous choices because it can lead to credential theft or payment fraud.',
          );
          nextSteps.add(
            'If you clicked, stop entering data and verify the service through a known safe channel.',
          );
        case 'pay_fee':
          score -= 32;
          feedback.add(
            'Paying a fee directly from an unverified text is exactly what delivery and toll scams rely on.',
          );
          nextSteps.add('Do not enter payment details from SMS links.');
        case 'share_personal_info':
          score -= 36;
          feedback.add(
            'Sharing personal details through text can fuel identity theft and account recovery attacks.',
          );
          nextSteps.add(
            'Never share DOB, address, or banking details by text.',
          );
        case 'share_code':
          score -= 42;
          feedback.add(
            'One-time codes and banking codes should never be given to someone who contacted you first.',
          );
          nextSteps.add('Keep MFA codes and banking codes private.');
        case 'buy_gift_card':
          score -= 40;
          feedback.add(
            'Gift card requests are a classic impersonation scam because they are fast and hard to reverse.',
          );
          nextSteps.add('Verify identity before sending any money or codes.');
        case 'reply_yes':
          score -= 14;
          feedback.add(
            'Replying positively to a suspicious text confirms your number is active and can encourage more scam attempts.',
          );
      }
    }

    if (normalizedReply.isNotEmpty) {
      final safeSignals = <String, int>{
        'official': 8,
        'verify': 10,
        'check the app': 12,
        'check my app': 12,
        'trusted number': 12,
        'known number': 12,
        'report': 10,
        'block': 10,
        'spam': 10,
        'not clicking': 15,
        'will not click': 15,
        'ignore': 6,
        'call the bank': 14,
        'student app': 10,
        'portal': 8,
      };
      final riskySignals = <String, int>{
        'click': -18,
        'clicked': -22,
        'pay': -18,
        'paid': -22,
        'card': -16,
        'code': -24,
        'otp': -28,
        'password': -28,
        'banking code': -32,
        'gift card': -32,
        'dob': -22,
        'date of birth': -22,
        'whatsapp': -10,
        'full name': -14,
        'my address': -22,
        'my details': -18,
      };

      var safeMatches = 0;
      var riskyMatches = 0;

      for (final entry in safeSignals.entries) {
        if (normalizedReply.contains(entry.key)) {
          score += entry.value;
          safeMatches += 1;
        }
      }

      for (final entry in riskySignals.entries) {
        if (normalizedReply.contains(entry.key)) {
          score += entry.value;
          riskyMatches += 1;
        }
      }

      if (normalizedReply.contains('who is this') ||
          normalizedReply.contains('what company') ||
          normalizedReply.contains('is this really')) {
        score += 6;
        feedback.add(
          'Asking a challenging question is better than trusting the message immediately, but verification still matters.',
        );
      }

      if (thread.kind == SmsKind.safe &&
          (normalizedReply.contains('thanks') ||
              normalizedReply.contains('i will check'))) {
        score += 8;
        feedback.add(
          'That is a reasonable response for a low-risk informational text.',
        );
      }

      if (thread.kind != SmsKind.safe && safeMatches > 0) {
        feedback.add(
          'Your reply shows you were thinking about verification and safer channels instead of trusting the text directly.',
        );
      }

      if (thread.kind != SmsKind.safe && riskyMatches > 0) {
        feedback.add(
          'Parts of your reply would expose you to the scam if this were a real attack.',
        );
      }
    }

    score = score.clamp(0, 100);

    final verdict = switch (score) {
      >= 85 => 'Excellent judgment',
      >= 70 => 'Mostly safe',
      >= 50 => 'Mixed response',
      _ => 'High-risk response',
    };

    final summary = switch (score) {
      >= 85 =>
        'You handled the text with strong caution and used the right verification mindset.',
      >= 70 =>
        'Your response was mostly solid, but there are still small ways to reduce exposure even further.',
      >= 50 =>
        'You noticed some warning signs, but parts of the response could still put you at risk.',
      _ =>
        'This response would be dangerous in a real smishing scenario because it gives the scammer leverage or access.',
    };

    if (nextSteps.isEmpty) {
      nextSteps.addAll(thread.actions.take(3));
    }

    return SmsResponseEvaluation(
      score: score,
      verdict: verdict,
      summary: summary,
      feedback: feedback.isEmpty
          ? <String>[
              'Your decision was reviewed, but the safest habit is still to verify suspicious texts through official channels.',
            ]
          : feedback,
      recommendedNextSteps: nextSteps.toList(growable: false),
    );
  }
}
