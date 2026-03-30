import 'email_sim_models.dart';

class EmailResponseEngine {
  const EmailResponseEngine._();

  static EmailResponseEvaluation evaluate({
    required SimEmail email,
    required String reply,
    required Set<String> selectedActionIds,
  }) {
    final normalizedReply = reply.trim().toLowerCase();
    var score = email.kind == EmailKind.safe ? 65 : 48;
    final feedback = <String>[];
    final nextSteps = <String>{};

    if (selectedActionIds.isEmpty && normalizedReply.isEmpty) {
      score -= 12;
      feedback.add(
        'No action was chosen. In practice, you still need a deliberate response plan for suspicious email.',
      );
    }

    for (final actionId in selectedActionIds) {
      switch (actionId) {
        case 'verify_official':
        case 'open_real_site':
        case 'call_known_contact':
          score += 24;
          feedback.add(
            'Verifying through an official site, portal, or known contact path is a strong defensive response.',
          );
          nextSteps.add(
            'Use the real organization site or known contact details instead of the email path.',
          );
        case 'report_delete':
        case 'report_internal':
          score += 20;
          feedback.add(
            'Reporting suspicious email helps protect other users and reduces the chance of repeat clicks.',
          );
          nextSteps.add('Report the message and remove it from your inbox.');
        case 'ignore':
          score += email.kind == EmailKind.safe ? -4 : 10;
          feedback.add(
            email.kind == EmailKind.safe
                ? 'Ignoring a legitimate message is not dangerous, but it may not help you complete the intended task.'
                : 'Not engaging with the lure is safer than replying or clicking.',
          );
        case 'reply_question':
          score += email.kind == EmailKind.safe ? 2 : 8;
          feedback.add(
            'Questioning the sender is better than trusting immediately, but direct verification is still stronger.',
          );
        case 'click_link':
          score -= 34;
          feedback.add(
            'Clicking a suspicious email link is one of the most common ways users are led to credential theft or malware.',
          );
          nextSteps.add(
            'If you clicked, stop interacting and verify the service through a known safe route.',
          );
        case 'open_attachment':
          score -= 36;
          feedback.add(
            'Opening an unknown attachment can lead to fake sign-in pages, malware, or data theft.',
          );
          nextSteps.add(
            'Do not open unexpected attachments until they are independently verified.',
          );
        case 'send_credentials':
          score -= 42;
          feedback.add(
            'Email should never be used to send passwords, codes, or secret account data.',
          );
          nextSteps.add('Keep credentials and MFA codes private.');
        case 'send_bank_info':
          score -= 40;
          feedback.add(
            'Sending banking or identity details in response to an email is a major exposure risk.',
          );
          nextSteps.add(
            'Never send payment or identity data from an unverified email request.',
          );
        case 'buy_gift_cards':
          score -= 40;
          feedback.add(
            'Gift-card requests are a classic business email compromise tactic because the payment is hard to reverse.',
          );
          nextSteps.add(
            'Verify unusual requests using a trusted channel before spending or sending money.',
          );
      }
    }

    if (normalizedReply.isNotEmpty) {
      final safeSignals = <String, int>{
        'verify': 10,
        'official site': 12,
        'real portal': 12,
        'bookmark': 12,
        'call': 10,
        'report': 10,
        'delete': 8,
        'not clicking': 15,
        'will not click': 15,
        'suspicious': 8,
        'confirm separately': 14,
      };
      final riskySignals = <String, int>{
        'click': -18,
        'clicked': -22,
        'password': -28,
        'code': -24,
        'otp': -28,
        'bank details': -30,
        'account details': -24,
        'credit card': -26,
        'card details': -26,
        'dob': -22,
        'gift card': -32,
        'attached': -12,
        'attachment': -12,
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

      if (normalizedReply.contains('who are you') ||
          normalizedReply.contains('what company') ||
          normalizedReply.contains('is this legitimate')) {
        score += 6;
        feedback.add(
          'Challenging the email is better than trusting it, though a separate verification route is still safer.',
        );
      }

      if (email.kind == EmailKind.safe &&
          (normalizedReply.contains('thanks') ||
              normalizedReply.contains('i will check'))) {
        score += 8;
        feedback.add(
          'That is a reasonable low-risk response for a routine legitimate email.',
        );
      }

      if (email.kind != EmailKind.safe && safeMatches > 0) {
        feedback.add(
          'Your reply shows healthy skepticism and a stronger verification mindset.',
        );
      }

      if (email.kind != EmailKind.safe && riskyMatches > 0) {
        feedback.add(
          'Parts of your reply would give the attacker leverage if this were a real phishing attempt.',
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
        'You handled the email with strong caution and used the right verification habits.',
      >= 70 =>
        'Your response was mostly safe, though a few choices could still be tightened.',
      >= 50 =>
        'You noticed some warning signs, but part of the response would still create exposure.',
      _ =>
        'This response would be dangerous in a real phishing or scam scenario because it gives away trust, access, or sensitive data.',
    };

    if (nextSteps.isEmpty) {
      nextSteps.addAll(email.actions.take(3));
    }

    return EmailResponseEvaluation(
      score: score,
      verdict: verdict,
      summary: summary,
      feedback: feedback.isEmpty
          ? <String>[
              'The email was reviewed, but the safest habit is still to verify through official channels instead of trusting the message itself.',
            ]
          : feedback,
      recommendedNextSteps: nextSteps.toList(growable: false),
    );
  }
}
