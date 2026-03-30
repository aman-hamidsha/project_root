import 'package:flutter/material.dart';

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

class SmsThread {
  const SmsThread({
    required this.id,
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

class SmsResponseEvaluation {
  const SmsResponseEvaluation({
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
