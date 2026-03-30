import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

class SmsSimPage extends StatefulWidget {
  const SmsSimPage({super.key});

  @override
  State<SmsSimPage> createState() => _SmsSimPageState();
}

class _SmsSimPageState extends State<SmsSimPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedThread = _threads[_selectedIndex];
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF365D9E);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const <Color>[Color(0xFF04153E), Color(0xFF0B2B66)]
                : const <Color>[Color(0xFFF8FBFF), Color(0xFFEAF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TopButton(
                      label: 'Back',
                      onTap: () => context.go('/dashboard'),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'SMS Simulator',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review realistic text-message scams and safe messages. Practice spotting smishing, delivery fraud, fake bank alerts, job bait, and account verification traps.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;

                      if (wide) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 350,
                              child: _ThreadListPanel(
                                threads: _threads,
                                selectedIndex: _selectedIndex,
                                onSelect: (index) {
                                  setState(() => _selectedIndex = index);
                                },
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _ThreadDetailPanel(thread: selectedThread),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          SizedBox(
                            height: 290,
                            child: _ThreadListPanel(
                              threads: _threads,
                              selectedIndex: _selectedIndex,
                              onSelect: (index) {
                                setState(() => _selectedIndex = index);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _ThreadDetailPanel(thread: selectedThread),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadListPanel extends StatelessWidget {
  const _ThreadListPanel({
    required this.threads,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<SmsThread> threads;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message Threads',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap a thread to inspect the conversation.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : const Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final thread = threads[index];
                final selected = index == selectedIndex;
                return _ThreadPreviewCard(
                  thread: thread,
                  selected: selected,
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadPreviewCard extends StatelessWidget {
  const _ThreadPreviewCard({
    required this.thread,
    required this.selected,
    required this.onTap,
  });

  final SmsThread thread;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(
                  alpha: isDark ? 0.28 : 0.14,
                )
              : isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFF2F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFD7E4F8),
            width: 3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    thread.contact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF17376C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _RiskPill(kind: thread.kind),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              thread.preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.88)
                    : const Color(0xFF365D9E),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${thread.phoneNumber}  •  ${thread.timeLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.56)
                    : const Color(0xFF6384B6),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadDetailPanel extends StatelessWidget {
  const _ThreadDetailPanel({required this.thread});

  final SmsThread thread;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoPill(label: thread.kind.label, highlight: thread.kind.color),
              _InfoPill(label: thread.scamType),
              _InfoPill(label: thread.riskLevel),
            ],
          ),
          const SizedBox(height: 18),
          _ConversationHeader(thread: thread),
          const SizedBox(height: 18),
          _ChatTranscript(thread: thread),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Red Flags / Legitimacy Checks',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: thread.flags
                  .map(
                    (flag) => _BulletLine(
                      text: flag,
                      color: thread.kind == SmsKind.safe
                          ? const Color(0xFF2C8A51)
                          : const Color(0xFFAE3131),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'How To Respond',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: thread.actions
                  .map(
                    (action) => _BulletLine(
                      text: action,
                      color: const Color(0xFF245FBC),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Smishing Checklist',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletLine(
                  text:
                      'Unexpected urgency, delivery issues, bank warnings, and prize claims are common SMS scam hooks.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Shortened links and lookalike domains are designed to hide the real destination.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Real organizations rarely ask you to confirm passwords, MFA codes, or payment details by text.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Use the official app, website, or phone number you already trust instead of the one in the message.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'If the message mentions legal trouble, package fees, or frozen access, slow down and verify first.',
                  color: Color(0xFF245FBC),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.thread});

  final SmsThread thread;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF66AFFF).withValues(alpha: 0.78)
            : const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thread.contact,
            style: const TextStyle(
              color: Color(0xFF173C73),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          _HeaderRow(label: 'Number', value: thread.phoneNumber),
          _HeaderRow(label: 'Scenario', value: thread.scenario),
          _HeaderRow(label: 'Technique', value: thread.scamType),
          _HeaderRow(label: 'Risk', value: thread.riskLevel),
        ],
      ),
    );
  }
}

class _ChatTranscript extends StatelessWidget {
  const _ChatTranscript({required this.thread});

  final SmsThread thread;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD6E2F6),
        ),
      ),
      child: Column(
        children: thread.messages
            .map((message) => _SmsBubble(message: message))
            .toList(),
      ),
    );
  }
}

class _SmsBubble extends StatelessWidget {
  const _SmsBubble({required this.message});

  final SmsMessage message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = message.incoming
        ? (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE8F0FF))
        : const Color(0xFF2F73EA);
    final textColor = message.incoming
        ? (isDark ? Colors.white : const Color(0xFF17376C))
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: message.incoming
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.timestamp,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.86)
                    : const Color(0xFF17376C),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskPill extends StatelessWidget {
  const _RiskPill({required this.kind});

  final SmsKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kind.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: kind.color, width: 2),
      ),
      child: Text(
        kind.label,
        style: TextStyle(
          color: kind.color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, this.highlight});

  final String label;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = highlight ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ?? (isDark ? Colors.white : const Color(0xFF17376C)),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF173C73),
            fontSize: 14,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary, width: 3),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

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
  });

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

const List<SmsThread> _threads = [
  SmsThread(
    contact: 'Campus Safety',
    phoneNumber: '+44 7700 900111',
    preview:
        'Routine campus weather update and timetable reminder for tomorrow morning.',
    kind: SmsKind.safe,
    scamType: 'Legitimate service alert',
    scenario: 'General campus information',
    riskLevel: 'Low risk',
    timeLabel: '09:14',
    messages: [
      SmsMessage(
        text:
            'Campus Safety: Light snow expected after 7AM. Please leave extra time for travel and check your timetable in the official student app if needed.',
        timestamp: '09:12',
        incoming: true,
      ),
      SmsMessage(
        text: 'Thanks, I will check the app before leaving.',
        timestamp: '09:14',
        incoming: false,
      ),
    ],
    flags: [
      'The message is informational and does not create panic or demand immediate action.',
      'It points you toward the normal student app rather than a random login link.',
      'No passwords, codes, or payment requests are involved.',
    ],
    actions: [
      'Open the official app yourself if you want to verify the update.',
      'Treat even real texts as prompts, not direct login pathways.',
      'Keep using your known official channels for timetable or safety information.',
    ],
  ),
  SmsThread(
    contact: 'Royal Mail Parcel',
    phoneNumber: '+44 7412 113580',
    preview:
        'Your parcel is held due to an unpaid redelivery fee. Pay now to avoid return.',
    kind: SmsKind.smishing,
    scamType: 'Delivery fee scam',
    scenario: 'Package redelivery bait',
    riskLevel: 'High risk',
    timeLabel: '11:03',
    messages: [
      SmsMessage(
        text:
            'RoyalMail: We could not deliver your parcel today. A £1.45 redelivery fee is due. Pay now at rm-fees-track-parcel.com to avoid return.',
        timestamp: '11:01',
        incoming: true,
      ),
      SmsMessage(
        text: 'What parcel is this for?',
        timestamp: '11:03',
        incoming: false,
      ),
      SmsMessage(
        text:
            'Final notice: your parcel will be destroyed if you do not complete payment in the next 20 minutes.',
        timestamp: '11:04',
        incoming: true,
      ),
    ],
    flags: [
      'The domain does not match the official organization and uses fee-themed wording to look believable.',
      'Tiny payment amounts are common because they make people drop their guard.',
      'The message creates urgency and consequences to force a quick click.',
      'Scammers often send follow-up texts when you reply, which confirms your number is active.',
    ],
    actions: [
      'Do not open the link or enter payment details.',
      'Check your real delivery account or app manually if you are expecting a parcel.',
      'Report the message as spam or smishing and block the sender.',
    ],
  ),
  SmsThread(
    contact: 'SecureBank Alerts',
    phoneNumber: '+44 7920 445812',
    preview:
        'Suspicious transfer detected. Verify your identity immediately to stop account suspension.',
    kind: SmsKind.fraud,
    scamType: 'Fake bank verification',
    scenario: 'Account freeze threat',
    riskLevel: 'High risk',
    timeLabel: '18:27',
    messages: [
      SmsMessage(
        text:
            'SecureBank: We detected a transfer attempt for £846.31. If this was not you, verify now at securebank-check-transfer.net or your account will be frozen.',
        timestamp: '18:24',
        incoming: true,
      ),
      SmsMessage(
        text: 'Is this really from my bank?',
        timestamp: '18:26',
        incoming: false,
      ),
      SmsMessage(
        text:
            'Yes. Confirm your date of birth and online banking code now so we can cancel it.',
        timestamp: '18:27',
        incoming: true,
      ),
    ],
    flags: [
      'Banks do not ask for full login codes or personal secrets through text.',
      'The link domain is unrelated to the real bank brand.',
      'The attacker escalates from a fake alert into direct credential collection.',
      'Replying with concern is used to keep the conversation moving.',
    ],
    actions: [
      'Do not share credentials, PINs, or recovery information.',
      'Open the official banking app or call the number on your card yourself.',
      'If you clicked or responded, change credentials and contact the real bank immediately.',
    ],
  ),
  SmsThread(
    contact: 'Part-Time Jobs UK',
    phoneNumber: '+44 7555 882301',
    preview:
        'Earn £300 a day from home with no interview. Training starts tonight if you join now.',
    kind: SmsKind.scam,
    scamType: 'Job bait / task scam',
    scenario: 'Too-good-to-be-true job offer',
    riskLevel: 'Medium-high risk',
    timeLabel: '14:42',
    messages: [
      SmsMessage(
        text:
            'Hello! We found your CV online. Earn £300/day from home rating products. No interview. Reply YES for instant onboarding.',
        timestamp: '14:39',
        incoming: true,
      ),
      SmsMessage(
        text: 'What company is this?',
        timestamp: '14:40',
        incoming: false,
      ),
      SmsMessage(
        text:
            'We explain after registration. Limited places. Send your full name and WhatsApp number to secure your slot.',
        timestamp: '14:42',
        incoming: true,
      ),
    ],
    flags: [
      'Vague employer identity is a common warning sign in scam recruiting.',
      'Unrealistic pay and urgency are designed to override skepticism.',
      'The attacker avoids specifics and pushes you to move channels quickly.',
      'These scams often lead to fake task platforms, upfront fees, or identity harvesting.',
    ],
    actions: [
      'Avoid sharing personal details before you verify the employer independently.',
      'Search the company through trusted sources, not through the number that contacted you.',
      'Assume secrecy plus easy money is a red flag until proven otherwise.',
    ],
  ),
  SmsThread(
    contact: 'Friend? New Number',
    phoneNumber: '+44 7401 225901',
    preview:
        'Hey, this is me on a new number. Can you urgently help me buy a gift card?',
    kind: SmsKind.suspicious,
    scamType: 'Impersonation / urgency',
    scenario: 'Friend-in-need text',
    riskLevel: 'Medium-high risk',
    timeLabel: '20:11',
    messages: [
      SmsMessage(
        text:
            'Hey, it’s me. I lost access to my old phone. Save this new number. Are you free right now?',
        timestamp: '20:08',
        incoming: true,
      ),
      SmsMessage(text: 'Who is this?', timestamp: '20:09', incoming: false),
      SmsMessage(
        text:
            'I’m in a meeting and can’t talk. Need a quick favor. Can you buy a £100 gift card and send me the code?',
        timestamp: '20:11',
        incoming: true,
      ),
    ],
    flags: [
      'The message tries to build urgency before proving identity.',
      'Refusing to speak on the phone is common when the attacker is impersonating someone.',
      'Gift card requests are a classic scam payment method because they are fast and irreversible.',
    ],
    actions: [
      'Verify through the real person’s old number or another channel you already trust.',
      'Do not send money, gift cards, or codes based only on text messages.',
      'Assume identity needs proof first, especially from a “new number.”',
    ],
  ),
];
