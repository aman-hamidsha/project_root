import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

class CryptoScamSimPage extends StatefulWidget {
  const CryptoScamSimPage({super.key});

  @override
  State<CryptoScamSimPage> createState() => _CryptoScamSimPageState();
}

class _CryptoScamSimPageState extends State<CryptoScamSimPage> {
  static const int _startingBalance = 1000;

  int _projectIndex = 0;
  int _balance = _startingBalance;
  int _savedLosses = 0;
  final List<InvestmentDecision> _decisions = <InvestmentDecision>[];

  CryptoProject get _currentProject => _projects[_projectIndex];
  bool get _finished => _projectIndex >= _projects.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
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
                _finished ? 'Simulation Results' : 'Crypto Scam Simulator',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _finished
                    ? 'Review how your choices handled rug pulls, pump-and-dumps, fake audits, and influencer hype.'
                    : 'Inspect each project like a cautious trader. Look for liquidity traps, unrealistic promises, fake communities, and exit scams before you “invest.”',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'Balance', value: '\$$_balance'),
                  _StatChip(
                    label: 'Projects',
                    value: _finished
                        ? '${_projects.length}/${_projects.length}'
                        : '${_projectIndex + 1}/${_projects.length}',
                  ),
                  _StatChip(label: 'Losses Avoided', value: '\$$_savedLosses'),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _finished
                    ? _ResultsPanel(
                        decisions: _decisions,
                        endingBalance: _balance,
                        startingBalance: _startingBalance,
                        onRestart: _restart,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 980;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _ProjectPanel(
                                    project: _currentProject,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  flex: 4,
                                  child: _TrainingPanel(
                                    project: _currentProject,
                                    onSkip: () => _handleDecision(false),
                                    onInvest: () => _handleDecision(true),
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView(
                            children: [
                              _ProjectPanel(project: _currentProject),
                              const SizedBox(height: 16),
                              _TrainingPanel(
                                project: _currentProject,
                                onSkip: () => _handleDecision(false),
                                onInvest: () => _handleDecision(true),
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

  void _handleDecision(bool invested) {
    final project = _currentProject;
    final nextBalance = invested
        ? _balance + project.outcomeIfInvested
        : _balance;
    final savedLoss = !invested && project.outcomeIfInvested < 0
        ? -project.outcomeIfInvested
        : 0;

    setState(() {
      _decisions.add(
        InvestmentDecision(
          projectName: project.name,
          invested: invested,
          resultDelta: invested ? project.outcomeIfInvested : 0,
          lesson: project.lesson,
          dangerScore: project.dangerScore,
          wasScam: project.outcomeIfInvested < 0,
        ),
      );
      _balance = nextBalance;
      _savedLosses += savedLoss;
      _projectIndex += 1;
    });
  }

  void _restart() {
    setState(() {
      _projectIndex = 0;
      _balance = _startingBalance;
      _savedLosses = 0;
      _decisions.clear();
    });
  }
}

class _ProjectPanel extends StatelessWidget {
  const _ProjectPanel({required this.project});

  final CryptoProject project;

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
          Text(
            project.name,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.pitch,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoPill(label: project.category),
              _InfoPill(label: 'Risk ${project.dangerScore}/10'),
              _InfoPill(label: project.socialSignal),
            ],
          ),
          const SizedBox(height: 18),
          _ChartCard(project: project),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'What You See',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: project.snapshot
                  .map(
                    (item) =>
                        _BulletLine(text: item, color: const Color(0xFF245FBC)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _MetricsGrid(project: project),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Red Flags',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: project.redFlags
                  .map(
                    (flag) =>
                        _BulletLine(text: flag, color: const Color(0xFFB13232)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Safer Investor Checks',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: project.safeChecks
                  .map(
                    (check) => _BulletLine(
                      text: check,
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.project});

  final CryptoProject project;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Market Snapshot',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF17376C),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                project.chartLabel,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.62)
                      : const Color(0xFF5D82B5),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 2.2,
            child: CustomPaint(
              painter: _CandlesPainter(
                candles: project.candles,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingPanel extends StatelessWidget {
  const _TrainingPanel({
    required this.project,
    required this.onSkip,
    required this.onInvest,
  });

  final CryptoProject project;
  final VoidCallback onSkip;
  final VoidCallback onInvest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final investColor = project.outcomeIfInvested < 0
        ? const Color(0xFFB13232)
        : const Color(0xFF2E9A59);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Decision Lab',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask yourself whether this looks investable or engineered to trap FOMO.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Scam Pattern',
            child: Text(
              project.scamPattern,
              style: const TextStyle(
                color: Color(0xFF17376C),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Why People Fall For It',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: project.psychologyHooks
                  .map(
                    (hook) =>
                        _BulletLine(text: hook, color: const Color(0xFFC48720)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: investColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: investColor, width: 2),
            ),
            child: Text(
              project.outcomeIfInvested < 0
                  ? 'If you invested here, you would lose ${-project.outcomeIfInvested} simulation dollars.'
                  : 'This one is relatively safer in the sim and would return +${project.outcomeIfInvested}.',
              style: TextStyle(
                color: investColor,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip,
                  child: const Text('Skip / Walk Away'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onInvest,
                  child: const Text('Invest'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.decisions,
    required this.endingBalance,
    required this.startingBalance,
    required this.onRestart,
  });

  final List<InvestmentDecision> decisions;
  final int endingBalance;
  final int startingBalance;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scamsAvoided = decisions
        .where((d) => !d.invested && d.wasScam)
        .length;
    final scamsHit = decisions.where((d) => d.invested && d.wasScam).length;
    final safeWins = decisions.where((d) => d.invested && !d.wasScam).length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatChip(label: 'Started', value: '\$$startingBalance'),
              _StatChip(label: 'Ended', value: '\$$endingBalance'),
              _StatChip(label: 'Scams Avoided', value: '$scamsAvoided'),
              _StatChip(label: 'Scams Hit', value: '$scamsHit'),
              _StatChip(label: 'Safer Wins', value: '$safeWins'),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionCard(
            title: 'How To Avoid Rug Pulls And Financial Scams',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletLine(
                  text: 'Check whether liquidity is locked and for how long.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Be wary of anonymous teams, unverifiable audits, and copy-paste whitepapers.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'If insiders hold massive supply, they can dump on everyone else.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Do not trust screenshots of profits, influencer hype, or “guaranteed” returns.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'Use official token contracts and never buy from links dropped in random chats.',
                  color: Color(0xFF245FBC),
                ),
                _BulletLine(
                  text:
                      'If you cannot explain how value is created, step back before sending money.',
                  color: Color(0xFF245FBC),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...decisions.map(
            (decision) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: decision.wasScam
                    ? const Color(0xFFFFD7D7)
                    : const Color(0xFFBFEFD1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    decision.projectName,
                    style: const TextStyle(
                      color: Color(0xFF17376C),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    decision.invested
                        ? 'You invested. Result: ${decision.resultDelta >= 0 ? '+' : ''}${decision.resultDelta}'
                        : 'You walked away.',
                    style: TextStyle(
                      color: decision.resultDelta < 0
                          ? const Color(0xFF9A2F2F)
                          : const Color(0xFF22653B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    decision.lesson,
                    style: const TextStyle(
                      color: Color(0xFF17376C),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRestart,
              child: const Text('Run Simulation Again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.project});

  final CryptoProject project;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(label: 'Liquidity', value: project.liquidity),
        _MetricCard(label: 'Audit', value: project.auditStatus),
        _MetricCard(label: 'Team', value: project.teamTransparency),
        _MetricCard(label: 'Tokenomics', value: project.tokenomics),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5D82B5),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17376C),
              fontWeight: FontWeight.w800,
            ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF17376C),
          fontWeight: FontWeight.w800,
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
        // TODO(hamidsha): Replace this text with a back icon during the icon refresh.
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5D82B5),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17376C),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class CryptoProject {
  const CryptoProject({
    required this.name,
    required this.category,
    required this.pitch,
    required this.socialSignal,
    required this.liquidity,
    required this.auditStatus,
    required this.teamTransparency,
    required this.tokenomics,
    required this.dangerScore,
    required this.scamPattern,
    required this.psychologyHooks,
    required this.redFlags,
    required this.safeChecks,
    required this.lesson,
    required this.outcomeIfInvested,
    required this.snapshot,
    required this.chartLabel,
    required this.candles,
  });

  final String name;
  final String category;
  final String pitch;
  final String socialSignal;
  final String liquidity;
  final String auditStatus;
  final String teamTransparency;
  final String tokenomics;
  final int dangerScore;
  final String scamPattern;
  final List<String> psychologyHooks;
  final List<String> redFlags;
  final List<String> safeChecks;
  final String lesson;
  final int outcomeIfInvested;
  final List<String> snapshot;
  final String chartLabel;
  final List<CandlePoint> candles;
}

class InvestmentDecision {
  const InvestmentDecision({
    required this.projectName,
    required this.invested,
    required this.resultDelta,
    required this.lesson,
    required this.dangerScore,
    required this.wasScam,
  });

  final String projectName;
  final bool invested;
  final int resultDelta;
  final String lesson;
  final int dangerScore;
  final bool wasScam;
}

class CandlePoint {
  const CandlePoint({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final double open;
  final double high;
  final double low;
  final double close;
}

class _CandlesPainter extends CustomPainter {
  const _CandlesPainter({required this.candles, required this.isDark});

  final List<CandlePoint> candles;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final minPrice = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final maxPrice = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final range = (maxPrice - minPrice).abs() < 0.001
        ? 1.0
        : maxPrice - minPrice;

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF7A9BC8)).withValues(
        alpha: 0.12,
      )
      ..strokeWidth = 1;

    for (var i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final candleWidth = size.width / (candles.length * 1.6);
    final spacing = size.width / candles.length;

    double priceToY(double value) {
      final normalized = (value - minPrice) / range;
      return size.height - (normalized * (size.height - 8)) - 4;
    }

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = (i * spacing) + (spacing / 2);
      final openY = priceToY(candle.open);
      final closeY = priceToY(candle.close);
      final highY = priceToY(candle.high);
      final lowY = priceToY(candle.low);
      final bullish = candle.close >= candle.open;
      final color = bullish ? const Color(0xFF2E9A59) : const Color(0xFFB13232);

      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 2;

      final bodyPaint = Paint()..color = color;

      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      final rect = Rect.fromLTRB(
        x - candleWidth / 2,
        openY < closeY ? openY : closeY,
        x + candleWidth / 2,
        (openY - closeY).abs() < 3
            ? (openY > closeY ? openY : closeY) + 3
            : (openY > closeY ? openY : closeY),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlesPainter oldDelegate) {
    return oldDelegate.candles != candles || oldDelegate.isDark != isDark;
  }
}

const List<CryptoProject> _projects = <CryptoProject>[
  CryptoProject(
    name: 'MoonForge AI',
    category: 'AI Meme Token',
    pitch:
        'An “AI-powered” meme coin promising 40x upside before the weekend with celebrity tweets and private alpha groups.',
    socialSignal: 'Influencer hype everywhere',
    liquidity: 'Unlocked, creator-controlled',
    auditStatus: '“Audit pending” badge only',
    teamTransparency: 'Anonymous founders',
    tokenomics: 'Top 5 wallets hold 62%',
    dangerScore: 9,
    scamPattern: 'Classic rug pull setup with hype first, fundamentals never.',
    psychologyHooks: [
      'Fear of missing the next 100x run.',
      'Social proof from loud Telegram and X accounts.',
      'Authority by borrowed AI buzzwords.',
    ],
    redFlags: [
      'Liquidity is not locked, so insiders can pull it fast.',
      'Supply concentration is extremely high.',
      'No verifiable team or real product.',
      'Audit language is vague and not linked to a trusted report.',
    ],
    safeChecks: [
      'Verify whether liquidity lock and token contract are public and real.',
      'Check holder concentration before buying.',
      'Treat anonymous + urgent hype as a major warning.',
    ],
    lesson:
        'Rug pulls often look exciting right before they collapse. If liquidity and insider concentration look bad, hype is not a substitute for safety.',
    outcomeIfInvested: -350,
    snapshot: [
      'Telegram says “dev cannot fail us.”',
      'Website has countdown timer and referral rewards.',
    ],
    chartLabel: 'Violent pump, unstable candles',
    candles: [
      CandlePoint(open: 12, high: 15, low: 11, close: 14),
      CandlePoint(open: 14, high: 19, low: 13, close: 18),
      CandlePoint(open: 18, high: 27, low: 17, close: 25),
      CandlePoint(open: 25, high: 31, low: 24, close: 29),
      CandlePoint(open: 29, high: 30, low: 18, close: 20),
      CandlePoint(open: 20, high: 22, low: 11, close: 13),
      CandlePoint(open: 13, high: 14, low: 7, close: 8),
      CandlePoint(open: 8, high: 9, low: 4, close: 5),
    ],
  ),
  CryptoProject(
    name: 'StableBridge Pro',
    category: 'Yield Platform',
    pitch:
        'A DeFi bridge offering “guaranteed” 18% weekly returns for early users who lock tokens for 30 days.',
    socialSignal: 'Fast-growing Discord',
    liquidity: 'Unknown',
    auditStatus: 'Claims audited, no report link',
    teamTransparency: 'Pseudonyms only',
    tokenomics: 'Rewards funded by new deposits',
    dangerScore: 10,
    scamPattern: 'Ponzi-style yield promise dressed up as DeFi innovation.',
    psychologyHooks: [
      'Greed through impossible returns.',
      'Fear of missing “early access” rewards.',
      'Complex terminology to reduce scrutiny.',
    ],
    redFlags: [
      'Guaranteed returns are not realistic in crypto markets.',
      'No verifiable audit despite claiming one.',
      'Reward model depends on new money flowing in.',
      'Lock-up means your exit is restricted while theirs may not be.',
    ],
    safeChecks: [
      'If returns sound absurd, pause immediately.',
      'Look for real documentation, not screenshots and slogans.',
      'Understand exactly where yield comes from.',
    ],
    lesson:
        'If you cannot explain the revenue model and the platform sells certainty in a volatile market, assume the risk is hidden or the promise is fake.',
    outcomeIfInvested: -420,
    snapshot: [
      'Homepage says “banking is dead.”',
      'Referral ladder pays more for bringing in friends.',
    ],
    chartLabel: 'Steady climb, hidden collapse risk',
    candles: [
      CandlePoint(open: 10, high: 12, low: 9, close: 11),
      CandlePoint(open: 11, high: 14, low: 10, close: 13),
      CandlePoint(open: 13, high: 16, low: 12, close: 15),
      CandlePoint(open: 15, high: 18, low: 14, close: 17),
      CandlePoint(open: 17, high: 21, low: 16, close: 20),
      CandlePoint(open: 20, high: 22, low: 9, close: 11),
      CandlePoint(open: 11, high: 12, low: 5, close: 6),
      CandlePoint(open: 6, high: 7, low: 3, close: 4),
    ],
  ),
  CryptoProject(
    name: 'CivicChain',
    category: 'Payments Network',
    pitch:
        'A boring-looking payments token with public founders, modest growth claims, and a real audit linked from the docs.',
    socialSignal: 'Steady but not viral',
    liquidity: 'Locked for 18 months',
    auditStatus: 'Public report from known auditor',
    teamTransparency: 'Named founders and company registry',
    tokenomics: 'Wide distribution, treasury disclosed',
    dangerScore: 3,
    scamPattern: 'Relatively safer project with fewer classic scam markers.',
    psychologyHooks: [
      'Less emotional pressure because it is not selling urgency.',
    ],
    redFlags: [
      'Even safer projects still carry market risk.',
      'Audit does not remove all technical or price risks.',
    ],
    safeChecks: [
      'Public team, real docs, and locked liquidity are better signs.',
      'Look for realistic language instead of moon promises.',
      'Separate scam risk from ordinary market risk.',
    ],
    lesson:
        'Not every project is a scam, but safer signs are usually boring: transparency, verifiable docs, and no pressure tactics.',
    outcomeIfInvested: 120,
    snapshot: [
      'Roadmap is plain and measurable.',
      'Community mods keep reminding users to avoid fake contract links.',
    ],
    chartLabel: 'Calmer trend with pullbacks',
    candles: [
      CandlePoint(open: 14, high: 16, low: 13, close: 15),
      CandlePoint(open: 15, high: 17, low: 14, close: 16),
      CandlePoint(open: 16, high: 18, low: 15, close: 17),
      CandlePoint(open: 17, high: 18, low: 16, close: 16.5),
      CandlePoint(open: 16.5, high: 19, low: 16, close: 18.2),
      CandlePoint(open: 18.2, high: 20, low: 17.8, close: 19.1),
      CandlePoint(open: 19.1, high: 21, low: 18.9, close: 20.2),
      CandlePoint(open: 20.2, high: 22, low: 19.8, close: 21.3),
    ],
  ),
  CryptoProject(
    name: 'WhaleSignal Premium',
    category: 'Private Trading Group',
    pitch:
        'A paid VIP group that promises insider wallet alerts before every pump and asks users to connect wallets to “sync alpha access.”',
    socialSignal: 'Screenshots of huge wins',
    liquidity: 'Not applicable',
    auditStatus: 'No product audit',
    teamTransparency: 'Admins use stock photos',
    tokenomics: 'Value tied to access subscriptions',
    dangerScore: 8,
    scamPattern:
        'Wallet-drain / paid signal scam built around screenshots and exclusivity.',
    psychologyHooks: [
      'Insider access fantasy.',
      'Exclusive club pressure.',
      'Social proof from cherry-picked wins.',
    ],
    redFlags: [
      'Wallet connection is requested for something that does not need it.',
      'Profit screenshots are easy to fake or selectively show.',
      '“Private alpha” is often used to sell illusion rather than skill.',
      'No credible operator identity.',
    ],
    safeChecks: [
      'Do not connect wallets to random dashboards.',
      'Assume screenshots are marketing, not evidence.',
      'If a service needs secrecy to sound valuable, be careful.',
    ],
    lesson:
        'Scammers frequently sell “exclusive access” instead of real value. Wallet-drain scams often hide inside tools that do not truly need wallet permissions.',
    outcomeIfInvested: -230,
    snapshot: [
      'VIP page says only 17 seats left.',
      'Bot messages celebrate “members who made 9x overnight.”',
    ],
    chartLabel: 'Spiky candles, manufactured pumps',
    candles: [
      CandlePoint(open: 9, high: 13, low: 8, close: 12),
      CandlePoint(open: 12, high: 18, low: 11, close: 16),
      CandlePoint(open: 16, high: 21, low: 14, close: 15),
      CandlePoint(open: 15, high: 19, low: 10, close: 11),
      CandlePoint(open: 11, high: 12, low: 6, close: 7),
      CandlePoint(open: 7, high: 8, low: 4, close: 5),
      CandlePoint(open: 5, high: 6, low: 3.5, close: 4),
      CandlePoint(open: 4, high: 4.5, low: 2.5, close: 3),
    ],
  ),
  CryptoProject(
    name: 'GreenGrid Token',
    category: 'Infrastructure Token',
    pitch:
        'A smaller token tied to a real grid-monitoring startup. Slow roadmap, transparent docs, and no guaranteed returns.',
    socialSignal: 'Moderate niche community',
    liquidity: 'Partially locked, lock address published',
    auditStatus: 'External review linked',
    teamTransparency: 'Founders public on company site',
    tokenomics: 'Treasury visible, vesting schedule posted',
    dangerScore: 4,
    scamPattern: 'Mostly legitimate setup with ordinary market uncertainty.',
    psychologyHooks: ['Less hype means lower emotional manipulation.'],
    redFlags: [
      'There is still execution risk and price volatility.',
      'Partial liquidity lock is better than none, but still needs monitoring.',
    ],
    safeChecks: [
      'Public vesting schedules help reduce surprise dumps.',
      'Look for evidence of a real product beyond token marketing.',
      'Reasonable claims are generally safer than dramatic promises.',
    ],
    lesson:
        'The goal is not to find guaranteed winners. It is to avoid obvious scams and understand that legitimate-looking projects can still be risky investments.',
    outcomeIfInvested: 80,
    snapshot: [
      'Docs explain what the token actually does.',
      'Moderators warn about fake airdrop posts in comments.',
    ],
    chartLabel: 'Slow grind upward',
    candles: [
      CandlePoint(open: 18, high: 19, low: 17.5, close: 18.4),
      CandlePoint(open: 18.4, high: 19.4, low: 18, close: 18.9),
      CandlePoint(open: 18.9, high: 20, low: 18.5, close: 19.6),
      CandlePoint(open: 19.6, high: 20.2, low: 19, close: 19.4),
      CandlePoint(open: 19.4, high: 20.5, low: 19.2, close: 20.1),
      CandlePoint(open: 20.1, high: 21.2, low: 19.9, close: 20.8),
      CandlePoint(open: 20.8, high: 21.8, low: 20.2, close: 21.3),
      CandlePoint(open: 21.3, high: 22.1, low: 20.9, close: 21.7),
    ],
  ),
];
