import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

class EmailSimPage extends StatefulWidget {
  const EmailSimPage({super.key});

  @override
  State<EmailSimPage> createState() => _EmailSimPageState();
}

class _EmailSimPageState extends State<EmailSimPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedEmail = _emails[_selectedIndex];
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF365D9E);

    return Scaffold(
      body: SafeArea(
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
                'Email Simulator',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore legit and scam emails, inspect the warning signs, and practice spotting phishing, pharming, bait, fake invoices, and impersonation.',
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
                            width: 340,
                            child: _InboxPanel(
                              emails: _emails,
                              selectedIndex: _selectedIndex,
                              onSelect: (index) {
                                setState(() => _selectedIndex = index);
                              },
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _EmailDetailPanel(email: selectedEmail),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 280,
                          child: _InboxPanel(
                            emails: _emails,
                            selectedIndex: _selectedIndex,
                            onSelect: (index) {
                              setState(() => _selectedIndex = index);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _EmailDetailPanel(email: selectedEmail),
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
    );
  }
}

class _InboxPanel extends StatelessWidget {
  const _InboxPanel({
    required this.emails,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<SimEmail> emails;
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
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inbox Samples',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap a message to inspect it.',
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
              itemCount: emails.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final email = emails[index];
                final selected = index == selectedIndex;
                return _InboxItem(
                  email: email,
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

class _InboxItem extends StatelessWidget {
  const _InboxItem({
    required this.email,
    required this.selected,
    required this.onTap,
  });

  final SimEmail email;
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
                    email.sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF17376C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _SeverityPill(kind: email.kind),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              email.subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.88)
                    : const Color(0xFF365D9E),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email.preview,
              maxLines: 2,
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

class _EmailDetailPanel extends StatelessWidget {
  const _EmailDetailPanel({required this.email});

  final SimEmail email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoPill(label: email.kind.label, highlight: email.kind.color),
              _InfoPill(label: email.technique),
              _InfoPill(label: email.riskLevel),
            ],
          ),
          const SizedBox(height: 18),
          _MailHeader(email: email),
          const SizedBox(height: 18),
          _MailBody(email: email),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Red Flags / Legitimacy Checks',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: email.flags
                  .map(
                    (flag) => _BulletLine(
                      text: flag,
                      color: email.kind == EmailKind.safe
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
              children: email.actions
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
            title: 'Quick Spotting Checklist',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletLine(
                  text: 'Check the sender domain, not just the display name.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Hover over links before clicking. Watch for lookalike URLs.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Be suspicious of urgency, fear, secrecy, or reward bait.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Verify invoices, gift-card requests, and account warnings through official channels.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'A clean logo does not make an email real. Attackers copy branding all the time.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'If the message pushes you to log in, type the real site yourself instead of using the email link.',
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

class _MailHeader extends StatelessWidget {
  const _MailHeader({required this.email});

  final SimEmail email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            email.subject,
            style: const TextStyle(
              color: Color(0xFF173C73),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          _HeaderRow(
            label: 'From',
            value: '${email.sender}  <${email.fromAddress}>',
          ),
          _HeaderRow(label: 'To', value: email.toAddress),
          _HeaderRow(label: 'Reply-To', value: email.replyTo),
          _HeaderRow(label: 'Theme', value: email.theme),
        ],
      ),
    );
  }
}

class _MailBody extends StatelessWidget {
  const _MailBody({required this.email});

  final SimEmail email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      child: SelectableText(
        email.body,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF17376C),
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.55,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.kind});

  final EmailKind kind;

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
        // TODO(hamidsha): Replace this text with a back icon after your icon pass.
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
  });

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
}

const List<SimEmail> _emails = [
  SimEmail(
    sender: 'Campus IT Support',
    fromAddress: 'support@cs310-university.edu',
    replyTo: 'support@cs310-university.edu',
    toAddress: 'student@uni.edu',
    subject: 'Scheduled Password Reset Reminder',
    preview:
        'This is your normal semester reminder to review your password and MFA settings.',
    body:
        'Hello,\n\nAs part of our routine semester security review, please check that your account recovery email and MFA settings are up to date.\n\nDo not use links from unexpected messages. Instead, open the student portal directly from your usual bookmark.\n\nRegards,\nCampus IT Support',
    kind: EmailKind.safe,
    technique: 'Legit security notice',
    theme: 'Routine account hygiene',
    riskLevel: 'Low risk',
    flags: [
      'The domain matches the institution and the reply-to also matches.',
      'There is no panic language, threat, or unrealistic deadline.',
      'The message tells you to go to the portal directly instead of pushing a shortcut link.',
      'The wording is consistent and does not ask for passwords or codes.',
    ],
    actions: [
      'You can still verify it in the normal portal if you want.',
      'Use your saved bookmark rather than any email link.',
      'Treat even real emails as prompts, not as login pathways.',
    ],
  ),
  SimEmail(
    sender: 'Microsoft Account Team',
    fromAddress: 'security-alert@micr0softverify-login.com',
    replyTo: 'resetforms@micr0softverify-login.com',
    toAddress: 'student@uni.edu',
    subject: 'URGENT: Your Microsoft 365 mailbox will be disabled today',
    preview:
        'Your account has triggered abnormal activity. Verify immediately to avoid permanent shutdown.',
    body:
        'Dear User,\n\nWe detected malicious sign in activity from Russia and your Microsoft 365 mailbox will be disabled in 45 minutes unless you verify ownership.\n\nClick below immediately:\nhttps://microsoft-check-session-security.com/recover\n\nFailure to comply will result in message deletion and access suspension.\n\nMicrosoft Account Security Team',
    kind: EmailKind.phishing,
    technique: 'Credential harvesting',
    theme: 'Urgent account warning',
    riskLevel: 'High risk',
    flags: [
      'The sender domain is not Microsoft. It uses a lookalike word and extra login-themed wording.',
      'The message creates urgency, fear, and a fake countdown to pressure a rushed click.',
      'Generic greeting like “Dear User” is common in mass phishing.',
      'The link domain does not match the brand being claimed.',
    ],
    actions: [
      'Do not click the link or enter credentials.',
      'Open the real Microsoft account page manually if you want to confirm.',
      'Report and delete the email.',
    ],
  ),
  SimEmail(
    sender: 'HR Payroll Office',
    fromAddress: 'payroll@company-payroll-help.net',
    replyTo: 'forms@company-payroll-help.net',
    toAddress: 'employee@company.com',
    subject: 'Updated direct deposit form required before payroll close',
    preview: 'Please submit your banking details by 3 PM to avoid salary hold.',
    body:
        'Hi,\n\nWe are migrating salary processing. Every staff member must complete the attached bank verification form today before 3 PM. Employees who fail to respond may see delayed wages.\n\nOpen Attachment: Payroll_Update_Form.html\n\nPayroll Desk',
    kind: EmailKind.scam,
    technique: 'Fake payroll update / attachment lure',
    theme: 'Sensitive data theft',
    riskLevel: 'High risk',
    flags: [
      'It asks for banking information under deadline pressure.',
      'The sender domain is not the organization domain.',
      'An HTML attachment can open a fake sign-in or data collection page.',
      'Threatening salary delay is a classic compliance pressure tactic.',
    ],
    actions: [
      'Verify with payroll using the known phone number or company chat.',
      'Do not open the attachment.',
      'Report it internally as a payroll phishing attempt.',
    ],
  ),
  SimEmail(
    sender: 'Delivery Notifications',
    fromAddress: 'tracking@parcel-redelivery-center.com',
    replyTo: 'tracking@parcel-redelivery-center.com',
    toAddress: 'student@uni.edu',
    subject: 'Package delivery failed - small redelivery fee required',
    preview:
        'A £1.79 fee is needed to release your parcel. Update details now.',
    body:
        'Customer,\n\nYour package could not be delivered due to missing address validation. To schedule redelivery, pay the small processing fee below.\n\nPay Fee Now\n\nIf you do not confirm today, your package will be returned.\n\nParcel Dispatch Team',
    kind: EmailKind.scam,
    technique: 'Micro-payment bait',
    theme: 'Fake parcel redelivery',
    riskLevel: 'Medium to high risk',
    flags: [
      'Unexpected package alerts are often used to lure card details.',
      'The sender is vague and not linked to a known delivery provider.',
      'A tiny fee is meant to feel harmless while capturing card data.',
      'No shipment reference or official order context is provided.',
    ],
    actions: [
      'Check your real order history in the retailer or courier app.',
      'Never pay through the email shortcut.',
      'Delete or report the message if no shipment is expected.',
    ],
  ),
  SimEmail(
    sender: 'Bank Fraud Prevention',
    fromAddress: 'alerts@mysecure-bank-alerts.net',
    replyTo: 'alerts@mysecure-bank-alerts.net',
    toAddress: 'customer@bankmail.com',
    subject: 'Suspicious transfer blocked - confirm device now',
    preview:
        'Unrecognized sign-in attempt detected. Failure to confirm may freeze your account.',
    body:
        'Customer,\n\nA suspicious transfer was blocked from a new device. Use the secure confirmation link to validate your banking profile.\n\nSecure Banking Portal\n\nFor your safety, do not ignore this alert.\n\nFraud Team',
    kind: EmailKind.phishing,
    technique: 'Financial login phish',
    theme: 'Fake fraud alert',
    riskLevel: 'High risk',
    flags: [
      'The display name sounds official but the domain is not the bank domain.',
      'Attackers often abuse “fraud prevention” language because users react quickly.',
      'The email wants immediate account interaction through its own path.',
      'There is no proper personalization or official case number.',
    ],
    actions: [
      'Do not use the provided link.',
      'Open the official banking app directly to review account activity.',
      'If worried, call the number from the back of your card or official site.',
    ],
  ),
  SimEmail(
    sender: 'Streaming Support',
    fromAddress: 'support@netf1ix-billing-check.com',
    replyTo: 'billing@netf1ix-billing-check.com',
    toAddress: 'viewer@mail.com',
    subject: 'Your subscription has been paused due to billing error',
    preview:
        'We were unable to process your payment. Update card details to continue watching.',
    body:
        'Hello,\n\nYour subscription could not be renewed. To restore service, update payment details through the account form below.\n\nRestore My Account\n\nThank you,\nCustomer Billing Support',
    kind: EmailKind.phishing,
    technique: 'Brand impersonation',
    theme: 'Fake billing problem',
    riskLevel: 'High risk',
    flags: [
      'The brand name is misspelled in the domain with a number replacing a letter.',
      'Billing-problem emails are common because users expect subscriptions to renew.',
      'The message funnels you straight to a card-update page.',
      'Real services usually address you by account name and reference their own domain.',
    ],
    actions: [
      'Check your subscription inside the real app or website.',
      'Never update payment details from a suspicious email.',
      'Mark the message as phishing.',
    ],
  ),
  SimEmail(
    sender: 'Travel Booking Desk',
    fromAddress: 'offers@flysmart-discounts.co',
    replyTo: 'offers@flysmart-discounts.co',
    toAddress: 'user@mail.com',
    subject: 'Free business class upgrade for the first 200 responders',
    preview:
        'Claim your upgrade and luggage bonus by confirming your travel account today.',
    body:
        'Congratulations!\n\nYou have been selected for a premium travel loyalty upgrade. To activate, sign in through the portal below and confirm your passport details.\n\nActivate Upgrade Now\n\nOffer ends in 2 hours.',
    kind: EmailKind.scam,
    technique: 'Reward bait / personal data theft',
    theme: 'Too-good-to-be-true offer',
    riskLevel: 'High risk',
    flags: [
      'Unexpected freebies and scarcity are classic bait tactics.',
      'The message asks for passport details, which is highly sensitive.',
      'There is no real booking reference or traveler context.',
      '“First 200 responders” is designed to override caution.',
    ],
    actions: [
      'Do not provide identity details from marketing emails.',
      'Verify offers only in your official airline account.',
      'Treat sudden reward claims with heavy suspicion.',
    ],
  ),
  SimEmail(
    sender: 'University Library',
    fromAddress: 'library@cs310-university.edu',
    replyTo: 'library@cs310-university.edu',
    toAddress: 'student@uni.edu',
    subject: 'Reserved book is ready for collection',
    preview: 'Your requested book is available at the main desk until Friday.',
    body:
        'Hi Hamid,\n\nYour reserved copy of “Digital Security Fundamentals” is now available for pickup at the main library desk until Friday at 5 PM.\n\nYou do not need to log in from this email. Bring your student ID when collecting.\n\nLibrary Services',
    kind: EmailKind.safe,
    technique: 'Legit service update',
    theme: 'Normal campus notification',
    riskLevel: 'Low risk',
    flags: [
      'The sender and reply-to match the institution.',
      'It does not ask for credentials, payment, or urgent action.',
      'The message includes a sensible real-world next step instead of a login shortcut.',
      'The tone is specific, calm, and context-based.',
    ],
    actions: [
      'This looks reasonable, but you can still verify in the library portal if needed.',
      'Good legitimate emails usually do not force secretive or rushed behavior.',
    ],
  ),
  SimEmail(
    sender: 'Secure DNS Warning Center',
    fromAddress: 'notice@dns-traffic-protect.info',
    replyTo: 'notice@dns-traffic-protect.info',
    toAddress: 'user@mail.com',
    subject: 'Important: your home router may redirect banking pages',
    preview:
        'We detected your device may be using unsafe DNS. Install the router fix file immediately.',
    body:
        'User,\n\nYour internet route may have been changed and financial websites can be silently redirected. Install the router protection utility attached below and sign in to verify your network.\n\nAttachment: RouterFix.zip\n\nSecurity Notice Center',
    kind: EmailKind.pharming,
    technique: 'Pharming-themed malware lure',
    theme: 'Fake router / DNS fix',
    riskLevel: 'High risk',
    flags: [
      'It references a real fear, pharming, but uses that fear to push an unsafe attachment.',
      'A ZIP attachment claiming to fix your router is a major warning sign.',
      'Unknown “security centers” are often fabricated to sound technical.',
      'Real router or ISP guidance would point you to official support pages, not random compressed tools.',
    ],
    actions: [
      'Do not open the ZIP file.',
      'If you are worried about router compromise, log in to the router using your known local address or official vendor guide.',
      'Reset DNS settings only through trusted device or router settings.',
    ],
  ),
  SimEmail(
    sender: 'CEO Office',
    fromAddress: 'ceo.office@corp-executive-mail.com',
    replyTo: 'ceo.office@corp-executive-mail.com',
    toAddress: 'assistant@company.com',
    subject: 'Need 6 gift cards for client appreciation before 2 PM',
    preview:
        'I am in meetings. Buy them now and send the codes by reply email.',
    body:
        'Hi,\n\nI am tied up in back-to-back meetings and need six gift cards for a client appreciation package. Buy them now and email me the codes before 2 PM. I will reimburse you later.\n\nPlease keep this between us so we can handle it quickly.\n\nCEO',
    kind: EmailKind.scam,
    technique: 'Executive impersonation / BEC',
    theme: 'Gift card fraud',
    riskLevel: 'High risk',
    flags: [
      'Gift card requests plus secrecy are a major business email compromise sign.',
      'The sender domain is not the corporate domain.',
      'Attackers often impersonate executives to bypass normal approval processes.',
      '“Keep this between us” is meant to stop verification.',
    ],
    actions: [
      'Verify any unusual request with the executive using a known contact method.',
      'Never send gift card codes or financial details only by email instruction.',
      'Escalate it internally as an impersonation attempt.',
    ],
  ),
];
