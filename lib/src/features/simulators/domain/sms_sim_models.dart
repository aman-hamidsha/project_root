import 'package:flutter/material.dart';

/*
 * this file defines the core data models for the sms simulator.
 * it includes the thread and message models, the scenario and risk enums,
 * the decision-option model used by the ui, and the final evaluation object
 * returned after a learner's response is scored.
 */

// top-level classification shown to the learner for each text scenario.
enum SmsKind {
  safe('Safe Example', Color(0xFF2E9A59)),
  suspicious('Suspicious', Color(0xFFC48720)),
  scam('Scam', Color(0xFFBF3D3D)),
  smishing('Smishing', Color(0xFFB13232)),
  fraud('Fraud Alert', Color(0xFF7A3FC7));

  const SmsKind(this.label, this.color);

  final String label;
  final Color color;
}

// the five scenario families used by the sms analyzer and sample data.
enum SmsScenarioType { campusSafe, smishing, fraudAlert, jobScam, friendInNeed }

// complete sms thread used by the simulator page and analyzer.
class SmsThread {
  const SmsThread({
    required this.id,
    required this.scenarioType,
    required this.contact,
    required this.phoneNumber,
    required this.preview,
    required this.kind,
    required this.scamType,
    required this.scenario,
    required this.riskLevel,
    required this.timeLabel,
    required this.messages,
    required this.flags,
    required this.actions,
    required this.decisionOptions,
  });

  final String id;
  final SmsScenarioType scenarioType;
  final String contact;
  final String phoneNumber;
  final String preview;
  final SmsKind kind;
  final String scamType;
  final String scenario;
  final String riskLevel;
  final String timeLabel;
  final List<SmsMessage> messages;
  final List<String> flags;
  final List<String> actions;
  final List<SmsDecisionOption> decisionOptions;
}

// one visible bubble in a simulated message thread.
class SmsMessage {
  const SmsMessage({
    required this.text,
    required this.timestamp,
    required this.incoming,
  });

  final String text;
  final String timestamp;
  final bool incoming;
}

// one action chip the learner can select for a text scenario.
class SmsDecisionOption {
  const SmsDecisionOption({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

// final scoring output used by the sms feedback card.
class SmsResponseEvaluation {
  const SmsResponseEvaluation({
    required this.score,
    required this.verdict,
    required this.summary,
    required this.feedback,
    required this.recommendedNextSteps,
    this.goodChoices = const <String>[],
    this.mistakes = const <String>[],
    this.redFlagsFound = const <String>[],
  });

  final int score;
  final String verdict;
  final String summary;
  final List<String> feedback;
  final List<String> recommendedNextSteps;
  final List<String> goodChoices;
  final List<String> mistakes;
  final List<String> redFlagsFound;
}
