import 'email_sim_models.dart';

const List<String> _emailProtectiveReplyKeywords = <String>[
  'scam',
  'phishing',
  'suspicious',
  'verify',
  'official',
  'report',
  'delete',
  'call',
  'bookmark',
  'not interested',
  'won\'t',
  'no',
];

const List<String> _emailCooperativeReplyKeywords = <String>[
  'yes',
  'okay',
  'ok',
  'sure',
  'i will',
  'i can',
  'here are',
  'my details',
  'my password',
  'my bank',
  'sending now',
  'attached',
  'clicking',
  'paid',
];

class EmailActionScore {
  const EmailActionScore(this.actionId, this.points, this.rationale);

  final String actionId;
  final int points;
  final String rationale;
}

class EmailScenarioScoringRule {
  const EmailScenarioScoringRule({
    required this.type,
    required this.actionScores,
    required this.redFlagKeywords,
    required this.safeKeywords,
    required this.dangerSummary,
    required this.atRiskSummary,
    required this.goodSummary,
    required this.excellentSummary,
  });

  final EmailScenarioType type;
  final List<EmailActionScore> actionScores;
  final List<String> redFlagKeywords;
  final List<String> safeKeywords;
  final String dangerSummary;
  final String atRiskSummary;
  final String goodSummary;
  final String excellentSummary;
}

const Map<EmailScenarioType, EmailScenarioScoringRule>
_emailScoringRules = <EmailScenarioType, EmailScenarioScoringRule>{
  EmailScenarioType.accountPhishing: EmailScenarioScoringRule(
    type: EmailScenarioType.accountPhishing,
    actionScores: <EmailActionScore>[
      EmailActionScore(
        'open_real_site',
        24,
        'Correct: opening the real Microsoft page yourself avoids the phishing path.',
      ),
      EmailActionScore(
        'report_delete',
        40,
        'Strong call: reporting and deleting is exactly how you should handle a fake account-warning email.',
      ),
      EmailActionScore(
        'click_link',
        -50,
        'Dangerous: the link is the attacker’s credential-harvesting route.',
      ),
      EmailActionScore(
        'send_credentials',
        -60,
        'Very risky: submitting login details would directly compromise the account.',
      ),
    ],
    redFlagKeywords: <String>[
      'click',
      'password',
      'login',
      'code',
      'verify now',
    ],
    safeKeywords: <String>[
      'report',
      'suspicious',
      'official site',
      'bookmark',
      'won\'t',
    ],
    dangerSummary:
        'You took actions that would likely have handed account access to the phishing attacker.',
    atRiskSummary:
        'You noticed some warning signs, but parts of the response still leaned too far toward the fake email path.',
    goodSummary:
        'Mostly safe. You moved toward trusted verification, though a few choices could still be sharper.',
    excellentSummary:
        'Well handled. You recognized the fake account-warning email and stayed on safe channels.',
  ),
  EmailScenarioType.payrollScam: EmailScenarioScoringRule(
    type: EmailScenarioType.payrollScam,
    actionScores: <EmailActionScore>[
      EmailActionScore(
        'call_known_contact',
        38,
        'Correct: payroll changes should be verified through a known internal channel.',
      ),
      EmailActionScore(
        'report_internal',
        30,
        'Good: reporting a fake payroll message protects the wider team.',
      ),
      EmailActionScore(
        'open_attachment',
        -50,
        'Dangerous: opening a suspicious payroll attachment can trigger fake forms or malware.',
      ),
      EmailActionScore(
        'send_bank_info',
        -60,
        'Very risky: sending banking details to an unverified payroll email exposes you to fraud.',
      ),
    ],
    redFlagKeywords: <String>[
      'bank details',
      'attachment',
      'salary',
      'today',
      'account',
    ],
    safeKeywords: <String>['verify', 'payroll', 'report', 'internal', 'call'],
    dangerSummary:
        'This response would likely expose payroll or banking data to a scammer.',
    atRiskSummary:
        'You saw some of the danger, but parts of your response still gave the fake payroll request too much trust.',
    goodSummary:
        'Mostly safe. You treated the payroll email with useful caution and verification thinking.',
    excellentSummary:
        'Excellent judgment. You kept payroll verification on trusted internal channels.',
  ),
  EmailScenarioType.parcelFee: EmailScenarioScoringRule(
    type: EmailScenarioType.parcelFee,
    actionScores: <EmailActionScore>[
      EmailActionScore(
        'verify_official',
        22,
        'Good instinct: checking the courier through a real account is safer than trusting the email.',
      ),
      EmailActionScore(
        'report_delete',
        40,
        'Correct: reporting and deleting is the right move for a fake parcel-fee email.',
      ),
      EmailActionScore(
        'click_link',
        -50,
        'Dangerous: opening the parcel fee link leads toward payment theft.',
      ),
      EmailActionScore(
        'send_bank_info',
        -60,
        'Very risky: entering card data for a fake fee is exactly what the scam wants.',
      ),
    ],
    redFlagKeywords: <String>['pay', 'card', 'fee', 'urgent', 'today'],
    safeKeywords: <String>[
      'report',
      'ignore',
      'courier app',
      'official',
      'scam',
    ],
    dangerSummary:
        'You followed the exact path a parcel-fee scam is built to exploit.',
    atRiskSummary:
        'You spotted some issues, but the response still gave the fake parcel notice too much trust.',
    goodSummary:
        'Mostly safe. You leaned toward trusted courier checks instead of the email path.',
    excellentSummary:
        'Strong call. You recognized the parcel-fee bait and avoided the payment trap.',
  ),
  EmailScenarioType.ceoImpersonation: EmailScenarioScoringRule(
    type: EmailScenarioType.ceoImpersonation,
    actionScores: <EmailActionScore>[
      EmailActionScore(
        'call_known_contact',
        40,
        'Correct: executive requests should be verified through a known real contact path.',
      ),
      EmailActionScore(
        'report_internal',
        30,
        'Good: escalating a suspected impersonation attempt helps protect the organization.',
      ),
      EmailActionScore(
        'buy_gift_cards',
        -60,
        'Scam: gift card purchases under secrecy and urgency are classic business email compromise.',
      ),
      EmailActionScore(
        'reply_question',
        6,
        'Questioning the request is better than obeying it, but verification outside the thread is still stronger.',
      ),
    ],
    redFlagKeywords: <String>[
      'gift card',
      'buy',
      'send code',
      'urgent',
      'keep this between us',
    ],
    safeKeywords: <String>['verify', 'call', 'report', 'impersonation', 'no'],
    dangerSummary:
        'This response would likely have caused direct financial loss in a CEO impersonation scam.',
    atRiskSummary:
        'You had some caution, but parts of the response still left room for business email compromise pressure.',
    goodSummary:
        'Mostly safe. You resisted the authority pressure and moved toward verification.',
    excellentSummary:
        'Excellent judgment. You recognized the executive impersonation pattern and did not follow the payment request.',
  ),
  EmailScenarioType.campusSafe: EmailScenarioScoringRule(
    type: EmailScenarioType.campusSafe,
    actionScores: <EmailActionScore>[
      EmailActionScore(
        'open_real_site',
        24,
        'Good: using your normal bookmark or portal is the right way to handle routine account reminders.',
      ),
      EmailActionScore(
        'ignore',
        6,
        'Ignoring a routine reminder is low risk, even if it is not the most useful choice.',
      ),
      EmailActionScore(
        'reply_question',
        4,
        'A short acknowledgement is low risk here, though not required.',
      ),
    ],
    redFlagKeywords: <String>['password', 'code', 'card', 'bank'],
    safeKeywords: <String>['thanks', 'portal', 'bookmark', 'check', 'app'],
    dangerSummary:
        'The original email was routine, but your reply still introduced avoidable risk.',
    atRiskSummary:
        'This was not a scam, though your response could still have been cleaner.',
    goodSummary:
        'Reasonable response. You handled the legitimate email without adding much risk.',
    excellentSummary:
        'Appropriate judgment. You treated the message as a prompt and stayed with the normal portal route.',
  ),
};

class EmailResponseAnalyzer {
  const EmailResponseAnalyzer._();

  static EmailResponseEvaluation analyze({
    required SimEmail email,
    required Set<String> actionsSelected,
    required String replyText,
  }) {
    final rule = _emailScoringRules[email.scenarioType]!;
    final normalizedReply = replyText.trim().toLowerCase();

    var rawScore = email.kind == EmailKind.safe ? 60 : 50;
    final goodChoices = <String>[];
    final mistakes = <String>[];
    final feedback = <String>[];

    for (final actionId in actionsSelected) {
      final actionScore = rule.actionScores.firstWhere(
        (score) => score.actionId == actionId,
        orElse: () => const EmailActionScore('', 0, ''),
      );
      rawScore += actionScore.points;
      if (actionScore.points > 0 && actionScore.rationale.isNotEmpty) {
        goodChoices.add(actionScore.rationale);
      }
      if (actionScore.points < 0 && actionScore.rationale.isNotEmpty) {
        mistakes.add(actionScore.rationale);
      }
    }

    if (actionsSelected.isEmpty && normalizedReply.isEmpty) {
      rawScore -= 12;
      mistakes.add(
        'No response plan was chosen. Suspicious email still needs an active safety decision, not just uncertainty.',
      );
    }

    final redFlagsFound = rule.redFlagKeywords
        .where((keyword) => normalizedReply.contains(keyword))
        .toList(growable: false);
    final safeKeywordCount = rule.safeKeywords
        .where((keyword) => normalizedReply.contains(keyword))
        .length;
    final hasProtectiveReply = _emailProtectiveReplyKeywords.any(
      (keyword) => normalizedReply.contains(keyword),
    );
    final hasCooperativeReply = _emailCooperativeReplyKeywords.any(
      (keyword) => normalizedReply.contains(keyword),
    );
    final leaksSensitiveData = _containsSensitiveData(normalizedReply);

    rawScore += (safeKeywordCount * 5).clamp(0, 15);
    rawScore -= (redFlagsFound.length * 10).clamp(0, 30);

    if (email.kind != EmailKind.safe && normalizedReply.isNotEmpty) {
      if (hasProtectiveReply) {
        rawScore -= 6;
        feedback.add(
          'Your reply showed skepticism, but responding to a scam email can still confirm that your address is active.',
        );
      } else {
        rawScore -= 18;
        mistakes.add(
          'Replying directly to a scam email without a firm refusal or separate verification is risky because it keeps the attacker engaged.',
        );
      }
    }

    if (hasCooperativeReply) {
      rawScore -= 14;
      mistakes.add(
        'Your reply sounded cooperative, which is unsafe because it encourages the scammer and can lead to follow-up pressure.',
      );
    }

    if (leaksSensitiveData) {
      rawScore -= 22;
      mistakes.add(
        'Your reply appeared to include personal, account, or contact information. Sending details over a scam email can quickly escalate the damage.',
      );
    }

    final selectedSafeAction = actionsSelected.any(
      (action) =>
          action == 'open_real_site' ||
          action == 'verify_official' ||
          action == 'call_known_contact' ||
          action == 'report_delete' ||
          action == 'report_internal',
    );
    if (selectedSafeAction && (hasCooperativeReply || leaksSensitiveData)) {
      rawScore -= 10;
      mistakes.add(
        'Your chosen action was safer than your typed reply. In practice, the reply would weaken the better decision.',
      );
    }

    if (safeKeywordCount > 0) {
      feedback.add(
        'Your reply language showed useful skepticism and stronger verification thinking.',
      );
    }
    if (redFlagsFound.isNotEmpty) {
      feedback.add(
        'Some wording in your reply still matched risky compliance language: ${redFlagsFound.join(', ')}.',
      );
    }
    final score = rawScore.clamp(0, 100);
    final verdict = switch (score) {
      >= 85 => 'Excellent judgment',
      >= 70 => 'Good response',
      >= 45 => 'At risk',
      _ => 'Dangerous response',
    };

    final summary = switch (verdict) {
      'Excellent judgment' => rule.excellentSummary,
      'Good response' => rule.goodSummary,
      'At risk' => rule.atRiskSummary,
      _ => rule.dangerSummary,
    };

    feedback
      ..addAll(goodChoices)
      ..addAll(mistakes);

    final nextSteps = <String>{
      ...email.actions.take(3),
      if (actionsSelected.isNotEmpty &&
          !actionsSelected.contains('report_delete') &&
          !actionsSelected.contains('report_internal'))
        'Report the email if your mail platform or organization provides a phishing-report flow.',
    };

    return EmailResponseEvaluation(
      score: score,
      verdict: verdict,
      summary: summary,
      feedback: feedback.isEmpty
          ? <String>[
              'The safest habit is still to verify through official channels instead of trusting the email itself.',
            ]
          : feedback,
      recommendedNextSteps: nextSteps.toList(growable: false),
      goodChoices: goodChoices,
      mistakes: mistakes,
      redFlagsFound: redFlagsFound,
    );
  }

  static bool _containsSensitiveData(String replyText) {
    if (replyText.isEmpty) {
      return false;
    }

    final emailPattern = RegExp(r'\b\S+@\S+\.\S+\b');
    final phonePattern = RegExp(r'\b(?:\+?\d[\d -]{6,}\d)\b');
    final codePattern = RegExp(r'\b\d{4,8}\b');
    final dobPattern = RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b');
    return emailPattern.hasMatch(replyText) ||
        phonePattern.hasMatch(replyText) ||
        codePattern.hasMatch(replyText) ||
        dobPattern.hasMatch(replyText);
  }
}
