import 'package:flutter/material.dart';

/*
 * this file defines the core data models for the email simulator.
 * it holds the enums for email classification and scenario type, the main
 * simulated email model used by the ui, the selectable decision options, and
 * the evaluation model returned after the analyzer scores a response.
 */

// the high level classification shown to the learner in the inbox and detail ui.
enum EmailKind {
  safe('Safe Example', Color(0xFF2E9A59)),
  suspicious('Suspicious', Color(0xFFC48720)),
  scam('Scam', Color(0xFFBF3D3D)),
  phishing('Phishing', Color(0xFFB13232)),
  pharming('Pharming / Redirect Risk', Color(0xFF7A3FC7));

  const EmailKind(this.label, this.color);

  final String label;
  final Color color;
}

// the five scenario families used to pick scoring rules and example content.
enum EmailScenarioType {
  campusSafe,
  accountPhishing,
  payrollScam,
  parcelFee,
  ceoImpersonation,
}

// one full email scenario with message content, learning notes, and choices.
class SimEmail {
  const SimEmail({
    required this.id,
    required this.scenarioType,
    required this.sender,
    required this.fromAddress,
    required this.replyTo,
    required this.toAddress,
    required this.subject,
    required this.preview,
    required this.body,
    required this.kind,
    required this.technique,
    required this.theme,
    required this.riskLevel,
    required this.flags,
    required this.actions,
    required this.decisionOptions,
  });

  final String id;
  final EmailScenarioType scenarioType;
  final String sender;
  final String fromAddress;
  final String replyTo;
  final String toAddress;
  final String subject;
  final String preview;
  final String body;
  final EmailKind kind;
  final String technique;
  final String theme;
  final String riskLevel;
  final List<String> flags;
  final List<String> actions;
  final List<EmailDecisionOption> decisionOptions;
}

// a single action chip the learner can select while handling an email.
class EmailDecisionOption {
  const EmailDecisionOption({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

// the final analyzer output that powers the score card and coaching ui.
class EmailResponseEvaluation {
  const EmailResponseEvaluation({
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
