import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../../dashboard/domain/dashboard_social_data.dart';
import '../../../dashboard/presentation/widgets/activity_snackbar.dart';
import '../../domain/sms_response_engine.dart';
import '../../domain/sms_sim_data.dart';
import '../../domain/sms_sim_models.dart';

/*
 * this file contains the full ui for the sms simulator.
 * it shows a thread list on the left or on mobile first, keeps per-thread
 * reply drafts and selected actions in memory, and runs the sms response
 * engine to score the learner's choices and typed reply.
 */

class SmsSimPage extends StatefulWidget {
  const SmsSimPage({super.key});

  @override
  State<SmsSimPage> createState() => _SmsSimPageState();
}

class _SmsSimPageState extends State<SmsSimPage> {
  int _selectedIndex = 0;
  bool _showMobileDetail = false;
  // each thread keeps its own draft, selected action, and evaluation so the
  // learner can switch between conversations without losing work.
  final Map<String, TextEditingController> _replyControllers =
      <String, TextEditingController>{};
  final Map<String, Set<String>> _selectedActionIds = <String, Set<String>>{};
  final Map<String, SmsResponseEvaluation> _evaluations =
      <String, SmsResponseEvaluation>{};

  SmsThread get _selectedThread => smsThreads[_selectedIndex];

  TextEditingController _controllerFor(String threadId) {
    return _replyControllers.putIfAbsent(threadId, TextEditingController.new);
  }

  Set<String> _actionsFor(String threadId) {
    return _selectedActionIds.putIfAbsent(threadId, () => <String>{});
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
                  'Act inside a realistic texting interface. Pick what to do, write your reply, and let the response engine judge how safely you handled the scenario.',
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
                                threads: smsThreads,
                                selectedIndex: _selectedIndex,
                                onSelect: (index) {
                                  setState(() => _selectedIndex = index);
                                },
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _ThreadDetailPanel(
                                thread: _selectedThread,
                                controller: _controllerFor(_selectedThread.id),
                                selectedActionIds: _actionsFor(
                                  _selectedThread.id,
                                ),
                                evaluation: _evaluations[_selectedThread.id],
                                onToggleAction: (actionId) {
                                  setState(() {
                                    final actions = _actionsFor(
                                      _selectedThread.id,
                                    );
                                    if (actions.contains(actionId)) {
                                      actions.clear();
                                    } else {
                                      actions
                                        ..clear()
                                        ..add(actionId);
                                    }
                                  });
                                },
                                onAnalyze: () =>
                                    _analyzeThread(_selectedThread),
                                onReset: () => _resetThread(_selectedThread.id),
                              ),
                            ),
                          ],
                        );
                      }

                      if (!_showMobileDetail) {
                        return _ThreadListPanel(
                          threads: smsThreads,
                          selectedIndex: _selectedIndex,
                          onSelect: (index) {
                            setState(() {
                              _selectedIndex = index;
                              _showMobileDetail = true;
                            });
                          },
                        );
                      }

                      return _ThreadDetailPanel(
                        thread: _selectedThread,
                        controller: _controllerFor(_selectedThread.id),
                        selectedActionIds: _actionsFor(_selectedThread.id),
                        evaluation: _evaluations[_selectedThread.id],
                        onToggleAction: (actionId) {
                          setState(() {
                            final actions = _actionsFor(_selectedThread.id);
                            if (actions.contains(actionId)) {
                              actions.clear();
                            } else {
                              actions
                                ..clear()
                                ..add(actionId);
                            }
                          });
                        },
                        onAnalyze: () => _analyzeThread(_selectedThread),
                        onReset: () => _resetThread(_selectedThread.id),
                        showMobileBack: true,
                        onBackToList: () {
                          setState(() => _showMobileDetail = false);
                        },
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

  Future<void> _analyzeThread(SmsThread thread) async {
    final evaluation = SmsResponseEngine.evaluate(
      thread: thread,
      reply: _controllerFor(thread.id).text,
      selectedActionIds: _actionsFor(thread.id),
    );

    setState(() {
      _evaluations[thread.id] = evaluation;
    });

    // xp scales with the score so stronger decisions feel more rewarding while
    // still giving progress credit for completing a scenario.
    final award = await DashboardSocialActivity.recordCurrentUserActivity(
      type: UserActivityType.simulatorDecision,
      activityId: 'sms:${thread.id}',
      xp: 24 + (evaluation.score * 0.32).round(),
    );
    if (!mounted) {
      return;
    }
    showActivityCelebration(context, award);
  }

  void _resetThread(String threadId) {
    setState(() {
      _controllerFor(threadId).clear();
      _actionsFor(threadId).clear();
      _evaluations.remove(threadId);
    });
  }
}

// list panel that previews all sms threads in the simulator inbox.
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
            'Tap a thread to inspect it and decide what to do.',
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

// one thread preview row inside the sms inbox panel.
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

// detail panel for a single thread, including transcript and analysis ui.
class _ThreadDetailPanel extends StatelessWidget {
  const _ThreadDetailPanel({
    required this.thread,
    required this.controller,
    required this.selectedActionIds,
    required this.evaluation,
    required this.onToggleAction,
    required this.onAnalyze,
    required this.onReset,
    this.showMobileBack = false,
    this.onBackToList,
  });

  final SmsThread thread;
  final TextEditingController controller;
  final Set<String> selectedActionIds;
  final SmsResponseEvaluation? evaluation;
  final ValueChanged<String> onToggleAction;
  final VoidCallback onAnalyze;
  final VoidCallback onReset;
  final bool showMobileBack;
  final VoidCallback? onBackToList;

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
          if (showMobileBack) ...[
            Row(
              children: [
                TextButton.icon(
                  onPressed: onBackToList,
                  icon: const AppSvgIcon(
                    AppIcons.arrowLeft,
                    color: Color(0xFF2A74EE),
                    size: 18,
                    semanticLabel: 'Back to threads',
                  ),
                  label: const Text('Back To Threads'),
                ),
                const Spacer(),
                Text(
                  thread.contact,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF17376C),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
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
          _ChatTranscript(thread: thread, draftReply: controller.text.trim()),
          const SizedBox(height: 18),
          _DecisionLab(
            thread: thread,
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
        ],
      ),
    );
  }
}

// top metadata card for the selected text-message scenario.
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

// transcript card that shows incoming messages plus the current draft reply.
class _ChatTranscript extends StatelessWidget {
  const _ChatTranscript({required this.thread, required this.draftReply});

  final SmsThread thread;
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
        children: [
          ...thread.messages.map((message) => _SmsBubble(message: message)),
          if (draftReply.isNotEmpty)
            _SmsBubble(
              message: SmsMessage(
                text: draftReply,
                timestamp: 'Draft reply',
                incoming: false,
              ),
            ),
        ],
      ),
    );
  }
}

// one message bubble in the fake texting conversation.
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

// interaction area where the learner picks an action and types a reply.
class _DecisionLab extends StatefulWidget {
  const _DecisionLab({
    required this.thread,
    required this.controller,
    required this.selectedActionIds,
    required this.onToggleAction,
    required this.onAnalyze,
    required this.onReset,
  });

  final SmsThread thread;
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

  // rebuilding here keeps the live draft bubble in sync as the user types.
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
            'Choose one action, write a reply if you want, then run the response engine.',
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
            children: widget.thread.decisionOptions
                .map(
                  (option) => FilterChip(
                    label: Text(option.label),
                    selected: widget.selectedActionIds.contains(option.id),
                    onSelected: (_) => widget.onToggleAction(option.id),
                    tooltip: option.description,
                    showCheckmark: true,
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
                  'Type the reply you would send, or leave this blank if your action is not to reply.',
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

  final SmsResponseEvaluation evaluation;

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
