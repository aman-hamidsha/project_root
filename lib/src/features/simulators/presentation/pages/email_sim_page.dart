import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../domain/email_response_engine.dart';
import '../../domain/email_sim_data.dart';
import '../../domain/email_sim_models.dart';

class EmailSimPage extends StatefulWidget {
  const EmailSimPage({super.key});

  @override
  State<EmailSimPage> createState() => _EmailSimPageState();
}

class _EmailSimPageState extends State<EmailSimPage> {
  int _selectedIndex = 0;
  final Map<String, TextEditingController> _replyControllers =
      <String, TextEditingController>{};
  final Map<String, Set<String>> _selectedActionIds = <String, Set<String>>{};
  final Map<String, EmailResponseEvaluation> _evaluations =
      <String, EmailResponseEvaluation>{};

  SimEmail get _selectedEmail => simEmails[_selectedIndex];

  TextEditingController _controllerFor(String emailId) {
    return _replyControllers.putIfAbsent(emailId, TextEditingController.new);
  }

  Set<String> _actionsFor(String emailId) {
    return _selectedActionIds.putIfAbsent(emailId, () => <String>{});
  }

  @override
  void dispose() {
    for (final controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                  'Inspect realistic email scenarios, choose your actions, write the reply you would send, and let the response engine judge how safely you handled it.',
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
                                emails: simEmails,
                                selectedIndex: _selectedIndex,
                                onSelect: (index) {
                                  setState(() => _selectedIndex = index);
                                },
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _EmailDetailPanel(
                                email: _selectedEmail,
                                controller: _controllerFor(_selectedEmail.id),
                                selectedActionIds: _actionsFor(
                                  _selectedEmail.id,
                                ),
                                evaluation: _evaluations[_selectedEmail.id],
                                onToggleAction: (actionId) {
                                  setState(() {
                                    final actions = _actionsFor(
                                      _selectedEmail.id,
                                    );
                                    if (!actions.add(actionId)) {
                                      actions.remove(actionId);
                                    }
                                  });
                                },
                                onAnalyze: () => _analyzeEmail(_selectedEmail),
                                onReset: () => _resetEmail(_selectedEmail.id),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          SizedBox(
                            height: 280,
                            child: _InboxPanel(
                              emails: simEmails,
                              selectedIndex: _selectedIndex,
                              onSelect: (index) {
                                setState(() => _selectedIndex = index);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _EmailDetailPanel(
                              email: _selectedEmail,
                              controller: _controllerFor(_selectedEmail.id),
                              selectedActionIds: _actionsFor(_selectedEmail.id),
                              evaluation: _evaluations[_selectedEmail.id],
                              onToggleAction: (actionId) {
                                setState(() {
                                  final actions = _actionsFor(
                                    _selectedEmail.id,
                                  );
                                  if (!actions.add(actionId)) {
                                    actions.remove(actionId);
                                  }
                                });
                              },
                              onAnalyze: () => _analyzeEmail(_selectedEmail),
                              onReset: () => _resetEmail(_selectedEmail.id),
                            ),
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

  void _analyzeEmail(SimEmail email) {
    final evaluation = EmailResponseEngine.evaluate(
      email: email,
      reply: _controllerFor(email.id).text,
      selectedActionIds: _actionsFor(email.id),
    );

    setState(() {
      _evaluations[email.id] = evaluation;
    });
  }

  void _resetEmail(String emailId) {
    setState(() {
      _controllerFor(emailId).clear();
      _actionsFor(emailId).clear();
      _evaluations.remove(emailId);
    });
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
        boxShadow: appShadows(isDark),
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
            'Tap a message to inspect it and decide what to do.',
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
  const _EmailDetailPanel({
    required this.email,
    required this.controller,
    required this.selectedActionIds,
    required this.evaluation,
    required this.onToggleAction,
    required this.onAnalyze,
    required this.onReset,
  });

  final SimEmail email;
  final TextEditingController controller;
  final Set<String> selectedActionIds;
  final EmailResponseEvaluation? evaluation;
  final ValueChanged<String> onToggleAction;
  final VoidCallback onAnalyze;
  final VoidCallback onReset;

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
              _InfoPill(label: email.kind.label, highlight: email.kind.color),
              _InfoPill(label: email.technique),
              _InfoPill(label: email.riskLevel),
            ],
          ),
          const SizedBox(height: 18),
          _MailHeader(email: email),
          const SizedBox(height: 18),
          _MailBody(email: email, draftReply: controller.text.trim()),
          const SizedBox(height: 18),
          _DecisionLab(
            email: email,
            controller: controller,
            selectedActionIds: selectedActionIds,
            onToggleAction: onToggleAction,
            onAnalyze: onAnalyze,
            onReset: onReset,
          ),
          if (evaluation != null) ...[
            const SizedBox(height: 18),
            _EvaluationCard(evaluation: evaluation!),
          ],
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
  const _MailBody({required this.email, required this.draftReply});

  final SimEmail email;
  final String draftReply;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            email.body,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          if (draftReply.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2F73EA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Draft reply:\n$draftReply',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionLab extends StatefulWidget {
  const _DecisionLab({
    required this.email,
    required this.controller,
    required this.selectedActionIds,
    required this.onToggleAction,
    required this.onAnalyze,
    required this.onReset,
  });

  final SimEmail email;
  final TextEditingController controller;
  final Set<String> selectedActionIds;
  final ValueChanged<String> onToggleAction;
  final VoidCallback onAnalyze;
  final VoidCallback onReset;

  @override
  State<_DecisionLab> createState() => _DecisionLabState();
}

class _DecisionLabState extends State<_DecisionLab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant _DecisionLab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _SectionCard(
      title: 'Your Turn',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose actions, write the reply you would send, and analyze your email judgment.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF4B6694),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.email.decisionOptions
                .map(
                  (option) => FilterChip(
                    label: Text(option.label),
                    selected: widget.selectedActionIds.contains(option.id),
                    onSelected: (_) => widget.onToggleAction(option.id),
                    tooltip: option.description,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: widget.controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Type the reply you would send, or leave this blank if you would not respond directly.',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton(
                onPressed: widget.onAnalyze,
                child: const Text('Analyze Response'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: widget.onReset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvaluationCard extends StatelessWidget {
  const _EvaluationCard({required this.evaluation});

  final EmailResponseEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = switch (evaluation.score) {
      >= 85 => const Color(0xFF2E9A59),
      >= 70 => const Color(0xFF2F73EA),
      >= 50 => const Color(0xFFC48720),
      _ => const Color(0xFFBF3D3D),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scoreColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Score ${evaluation.score}/100',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  evaluation.verdict,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF17376C),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            evaluation.summary,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.84)
                  : const Color(0xFF17376C),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...evaluation.feedback.map(
            (line) => _BulletLine(text: line, color: scoreColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Recommended next steps',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...evaluation.recommendedNextSteps.map(
            (line) => _BulletLine(text: line, color: const Color(0xFF245FBC)),
          ),
        ],
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
        child: Center(
          child: AppSvgIcon(
            AppIcons.arrowLeft,
            color: colorScheme.primary,
            size: 20,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}
