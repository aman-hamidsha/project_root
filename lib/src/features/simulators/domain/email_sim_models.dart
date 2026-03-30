import 'package:flutter/material.dart';

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

class SimEmail {
  const SimEmail({
    required this.id,
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

class EmailResponseEvaluation {
  const EmailResponseEvaluation({
    required this.score,
    required this.verdict,
    required this.summary,
    required this.feedback,
    required this.recommendedNextSteps,
  });

  final int score;
  final String verdict;
  final String summary;
  final List<String> feedback;
  final List<String> recommendedNextSteps;
}
