import 'sms_sim_models.dart';

/*
 * this file contains the scoring and analysis logic for the sms simulator.
 * it defines the keyword lists, per-scenario score rules, and the analyzer
 * that combines selected actions plus typed reply text into a final coaching
 * result with a score, summary, feedback, and next steps.
 */

// cautious reply wording that usually signals healthier skepticism.
const List<String> _smsProtectiveReplyKeywords = <String>[
  'scam',
  'suspicious',
  'verify',
  'official',
  'call',
  'bank app',
  'old number',
  'report',
  'block',
  'ignore',
  'not interested',
  'stop',
  'leave me alone',
  'won\'t',
];

// cooperative wording that suggests the learner is complying with the scam.
const List<String> _smsCooperativeReplyKeywords = <String>[
  'yes',
  'okay',
  'ok',
  'sure',
  'i can',
  'i will',
  'send',
  'here are',
  'my details',
  'my code',
  'my number',
  'my email',
  'clicking',
  'paid',
];

// maps one decision option id to a score change and explanation.
class SmsActionScore {
  const SmsActionScore(this.actionId, this.points, this.rationale);

  final String actionId;
  final int points;
  final String rationale;
}

// scoring rule bundle for one sms scenario family.
class SmsScenarioScoringRule {
  const SmsScenarioScoringRule({
    required this.type,
    required this.actionScores,
    required this.redFlagKeywords,
    required this.safeKeywords,
    required this.dangerSummary,
    required this.atRiskSummary,
    required this.goodSummary,
    required this.excellentSummary,
  });

  final SmsScenarioType type;
  final List<SmsActionScore> actionScores;
  final List<String> redFlagKeywords;
  final List<String> safeKeywords;
  final String dangerSummary;
  final String atRiskSummary;
  final String goodSummary;
  final String excellentSummary;
}

// lookup table that tells the analyzer how each scenario type should score.
const Map<SmsScenarioType, SmsScenarioScoringRule>
_smsScoringRules = <SmsScenarioType, SmsScenarioScoringRule>{
  SmsScenarioType.smishing: SmsScenarioScoringRule(
    type: SmsScenarioType.smishing,
    actionScores: <SmsActionScore>[
      SmsActionScore(
        'report_block',
        40,
        'Correct: reporting and blocking helps stop the smishing attempt spreading.',
      ),
      SmsActionScore(
        'verify_official',
        22,
        'Good instinct: checking the delivery through the official service is much safer than trusting the text.',
      ),
      SmsActionScore(
        'click_link',
        -50,
        'Dangerous: opening the delivery link exposes you to phishing or card theft.',
      ),
      SmsActionScore(
        'pay_fee',
        -60,
        'Very risky: paying the fee hands money and payment data to the scammer.',
      ),
    ],
    redFlagKeywords: <String>['pay', 'click', 'urgent', 'fee', 'now'],
    safeKeywords: <String>[
      'ignore',
      'report',
      'scam',
      'suspicious',
      'won\'t',
      'official',
    ],
    dangerSummary:
        'You took actions that would likely have led straight into the delivery scam.',
    atRiskSummary:
        'You noticed some warning signs, but parts of the response still left you exposed to the scam.',
    goodSummary:
        'Mostly safe. You showed the right verification habit, but there is still room to tighten the response.',
    excellentSummary:
        'Well handled. You spotted the delivery-fee scam pattern and avoided the trap.',
  ),
  SmsScenarioType.friendInNeed: SmsScenarioScoringRule(
    type: SmsScenarioType.friendInNeed,
    actionScores: <SmsActionScore>[
      SmsActionScore(
        'contact_known_channel',
        40,
        'Smart: always verify a “new number” through the real friend\'s known contact path.',
      ),
      SmsActionScore(
        'ask_for_identity',
        18,
        'Cautious, but it still needs follow-up verification outside the same text thread.',
      ),
      SmsActionScore(
        'buy_gift_card',
        -60,
        'Scam: gift card requests under urgency are a classic impersonation tactic.',
      ),
      SmsActionScore(
        'reply_yes',
        -45,
        'Risky: agreeing before verifying identity gives the scammer momentum.',
      ),
    ],
    redFlagKeywords: <String>['buy', 'gift card', 'code', 'send', 'sure'],
    safeKeywords: <String>[
      'won\'t',
      'call you',
      'verify',
      'suspicious',
      'no',
      'old number',
    ],
    dangerSummary:
        'You responded in a way that could have led to direct financial loss in a friend-impersonation scam.',
    atRiskSummary:
        'Some of your choices were cautious, but the reply still gave the impersonator too much room to keep pressuring you.',
    goodSummary:
        'Mostly safe. You slowed the scam down, though independent verification is still the key move here.',
    excellentSummary:
        'Excellent judgment. You treated the “friend in need” message as untrusted until proven real.',
  ),
  SmsScenarioType.fraudAlert: SmsScenarioScoringRule(
    type: SmsScenarioType.fraudAlert,
    actionScores: <SmsActionScore>[
      SmsActionScore(
        'contact_known_channel',
        40,
        'Correct: calling the bank through a trusted number is the safest next step.',
      ),
      SmsActionScore(
        'report_block',
        30,
        'Good: reporting and blocking reduces the chance of further fraud attempts.',
      ),
      SmsActionScore(
        'share_code',
        -60,
        'Never share banking or verification codes from an SMS prompt.',
      ),
      SmsActionScore(
        'share_personal_info',
        -50,
        'Banks do not ask for DOB or account secrets over a text message.',
      ),
    ],
    redFlagKeywords: <String>['code', 'dob', 'verify', 'confirm', 'birthday'],
    safeKeywords: <String>[
      'ignore',
      'scam',
      'call bank',
      'report',
      'my banking app',
    ],
    dangerSummary:
        'This response would put your bank account and identity details at serious risk.',
    atRiskSummary:
        'You saw that something was off, but parts of your response still trusted the fake alert too much.',
    goodSummary:
        'Mostly safe. You leaned toward trusted bank channels, which is the right instinct.',
    excellentSummary:
        'Well handled. You treated the fraud alert as untrusted and moved to a real bank contact path.',
  ),
  SmsScenarioType.jobScam: SmsScenarioScoringRule(
    type: SmsScenarioType.jobScam,
    actionScores: <SmsActionScore>[
      SmsActionScore(
        'ask_for_identity',
        15,
        'Questioning the sender is better than trusting the job offer immediately.',
      ),
      SmsActionScore(
        'ignore_delete',
        22,
        'Good: not engaging with a vague too-good-to-be-true offer protects you.',
      ),
      SmsActionScore(
        'reply_yes',
        -38,
        'Risky: replying positively helps the scammer move you deeper into onboarding pressure.',
      ),
      SmsActionScore(
        'share_personal_info',
        -55,
        'Very risky: sharing personal details can fuel identity theft or fake task-scam onboarding.',
      ),
    ],
    redFlagKeywords: <String>[
      'yes',
      'register',
      'whatsapp',
      'full name',
      'send',
    ],
    safeKeywords: <String>[
      'ignore',
      'verify',
      'company',
      'suspicious',
      'not interested',
    ],
    dangerSummary:
        'You responded in a way that could have fed identity theft or a fake task-job scam.',
    atRiskSummary:
        'You showed some caution, but the reply still gave the scammer more access than it should.',
    goodSummary:
        'Mostly safe. You treated the unrealistic job offer with useful skepticism.',
    excellentSummary:
        'Strong call. You recognized the job bait warning signs instead of chasing the promise.',
  ),
  SmsScenarioType.campusSafe: SmsScenarioScoringRule(
    type: SmsScenarioType.campusSafe,
    actionScores: <SmsActionScore>[
      SmsActionScore(
        'check_app',
        24,
        'Good: checking the usual app yourself is a safe way to verify routine information.',
      ),
      SmsActionScore(
        'ignore_delete',
        6,
        'Ignoring a low-risk informational message is not harmful, even if it is not very useful.',
      ),
      SmsActionScore(
        'reply_yes',
        4,
        'A short acknowledgement is low risk here, though not necessary.',
      ),
    ],
    redFlagKeywords: <String>['password', 'code', 'bank', 'payment'],
    safeKeywords: <String>['thanks', 'check', 'official', 'app', 'fine'],
    dangerSummary:
        'The message itself was low risk, but your response introduced unnecessary trust or sensitive information.',
    atRiskSummary:
        'This was not a scam, though your reply still could have been more careful.',
    goodSummary:
        'Reasonable response. You handled the routine message without creating extra risk.',
    excellentSummary:
        'Appropriate judgment. You treated the text as a routine notice and kept to normal channels.',
  ),
};

// static-only analyzer that scores the learner's complete sms response.
class SmsResponseAnalyzer {
  const SmsResponseAnalyzer._();

  static SmsResponseEvaluation analyze({
    required SmsThread thread,
    required Set<String> actionsSelected,
    required String replyText,
  }) {
    // each thread resolves to its scenario rule first so the later checks can
    // score the same reply differently depending on the scam pattern.
    final rule = _smsScoringRules[thread.scenarioType]!;
    final normalizedReply = replyText.trim().toLowerCase();

    // safe examples begin a little higher because the message itself is not
    // hostile, while scam threads start from a more neutral baseline.
    var rawScore = thread.kind == SmsKind.safe ? 60 : 50;
    final goodChoices = <String>[];
    final mistakes = <String>[];
    final feedback = <String>[];

    for (final actionId in actionsSelected) {
      // selected action chips are translated into point changes and mirrored
      // into positive or negative coaching strings.
      final actionScore = rule.actionScores.firstWhere(
        (score) => score.actionId == actionId,
        orElse: () => const SmsActionScore('', 0, ''),
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
        'No response plan was chosen. In a real text scam, doing nothing without thinking it through can still leave you uncertain about the right next step.',
      );
    }

    final redFlagsFound = rule.redFlagKeywords
        .where((keyword) => normalizedReply.contains(keyword))
        .toList(growable: false);
    final safeKeywordCount = rule.safeKeywords
        .where((keyword) => normalizedReply.contains(keyword))
        .length;
    final hasProtectiveReply = _smsProtectiveReplyKeywords.any(
      (keyword) => normalizedReply.contains(keyword),
    );
    final hasCooperativeReply = _smsCooperativeReplyKeywords.any(
      (keyword) => normalizedReply.contains(keyword),
    );
    final leaksSensitiveData = _containsSensitiveData(normalizedReply);

    // typed reply language is scored separately from action choices so the
    // analyzer can catch mixed behavior like safe taps but unsafe wording.
    rawScore += (safeKeywordCount * 5).clamp(0, 15);
    rawScore -= (redFlagsFound.length * 10).clamp(0, 30);

    if (thread.kind != SmsKind.safe && normalizedReply.isNotEmpty) {
      if (hasProtectiveReply) {
        rawScore -= 6;
        feedback.add(
          'You sounded skeptical, but replying to a scam text can still confirm that your number is active.',
        );
      } else {
        rawScore -= 18;
        mistakes.add(
          'Replying directly to a scam text without a firm refusal or separate verification is risky because it keeps the attacker engaged.',
        );
      }
    }

    if (hasCooperativeReply) {
      rawScore -= 14;
      mistakes.add(
        'Your reply sounded cooperative, which is dangerous in a scam scenario because it encourages the attacker to keep pressing you.',
      );
    }

    if (leaksSensitiveData) {
      rawScore -= 22;
      mistakes.add(
        'Your reply appeared to include personal or contact information. Sharing details in scam texts can escalate the damage quickly.',
      );
    }

    final selectedSafeAction = actionsSelected.any(
      (action) =>
          action == 'verify_official' || action == 'contact_known_channel',
    );
    if (selectedSafeAction && (hasCooperativeReply || leaksSensitiveData)) {
      rawScore -= 10;
      mistakes.add(
        'Your chosen action was safer than your typed reply. In practice, the reply would undermine the safer decision.',
      );
    }

    if (safeKeywordCount > 0) {
      feedback.add(
        'Your reply language showed some healthy skepticism and safer intent.',
      );
    }
    if (redFlagsFound.isNotEmpty) {
      feedback.add(
        'Some wording in your reply still matched common scam-compliance language: ${redFlagsFound.join(', ')}.',
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

    // next steps reuse the scenario coaching and add a report reminder when
    // the learner skipped the report action.
    final nextSteps = <String>{
      ...thread.actions.take(3),
      if (actionsSelected.isNotEmpty &&
          !actionsSelected.contains('report_block'))
        'Report the scam attempt if the platform gives you that option.',
    };

    return SmsResponseEvaluation(
      score: score,
      verdict: verdict,
      summary: summary,
      feedback: feedback.isEmpty
          ? <String>[
              'The safest habit is still to verify suspicious texts through official channels instead of trusting the message itself.',
            ]
          : feedback,
      recommendedNextSteps: nextSteps.toList(growable: false),
      goodChoices: goodChoices,
      mistakes: mistakes,
      redFlagsFound: redFlagsFound,
    );
  }

  // checks whether the typed reply looks like it contains personal or account
  // information that should not be shared in a suspicious text exchange.
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
