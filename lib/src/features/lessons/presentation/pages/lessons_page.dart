import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../../dashboard/domain/dashboard_social_data.dart';
import '../../../dashboard/presentation/widgets/activity_snackbar.dart';
import '../../domain/lesson_progress_store.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  String _selectedLessonId = _lessons.first.id;
  final Map<String, String?> _fillBlankSelections = <String, String?>{};
  final Map<String, bool> _fillBlankChecked = <String, bool>{};
  final Map<String, String?> _scenarioSelections = <String, String?>{};
  final Map<String, bool> _scenarioChecked = <String, bool>{};
  final Map<String, Map<String, String?>> _matchSelections =
      <String, Map<String, String?>>{};
  final Map<String, bool> _matchChecked = <String, bool>{};
  LessonProgressSnapshot _progress = const LessonProgressSnapshot.empty();

  LessonModule get _selectedLesson =>
      _lessons.firstWhere((lesson) => lesson.id == _selectedLessonId);

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
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
                  'Lessons',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Study the theory behind each quiz topic, then practice with quick interactive checks before jumping into the bank.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _LessonProgressHeader(progress: _progress),
                const SizedBox(height: 18),
                SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      final isSelected = lesson.id == _selectedLessonId;
                      return ChoiceChip(
                        label: Text('${lesson.shortLabel}  ${lesson.title}'),
                        selected: isSelected,
                        onSelected: (_) => _selectLesson(lesson.id),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF17376C)),
                          fontWeight: FontWeight.w800,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.14)
                                    : const Color(0xFFD6E0F1)),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF11172A)
                            : Colors.white,
                        selectedColor: const Color(0xFF296EE8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _lessons.length,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: ListView(
                      key: ValueKey<String>(_selectedLesson.id),
                      children: [
                        _LessonHeroCard(
                          lesson: _selectedLesson,
                          progress: _progress.progressForLesson(
                            _selectedLesson.id,
                          ),
                          nextStep: _progress.nextStepForLesson(
                            _selectedLesson.id,
                          ),
                          onOpenQuiz: () =>
                              context.go('/quiz?chapter=${_selectedLesson.id}'),
                        ),
                        const SizedBox(height: 18),
                        ..._selectedLesson.sections.map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _TheorySectionCard(
                              lesson: _selectedLesson,
                              section: section,
                            ),
                          ),
                        ),
                        _ScenarioCheckCard(
                          lesson: _selectedLesson,
                          selectedOption:
                              _scenarioSelections[_selectedLesson.id],
                          isChecked:
                              _scenarioChecked[_selectedLesson.id] ?? false,
                          onSelect: (option) {
                            setState(() {
                              _scenarioSelections[_selectedLesson.id] = option;
                              _scenarioChecked[_selectedLesson.id] = false;
                            });
                          },
                          onCheck: () async {
                            final isCorrect =
                                _scenarioSelections[_selectedLesson.id] ==
                                _selectedLesson.scenarioCheck.correctAnswer;
                            setState(() {
                              _scenarioChecked[_selectedLesson.id] = true;
                            });
                            if (isCorrect) {
                              final award =
                                  await DashboardSocialActivity.recordCurrentUserActivity(
                                    type: UserActivityType.lessonCheck,
                                    activityId:
                                        'lesson-scenario:${_selectedLesson.id}',
                                  );
                              if (!mounted) {
                                return;
                              }
                              showActivityCelebration(context, award);
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        _FillBlankCard(
                          lesson: _selectedLesson,
                          selectedOption:
                              _fillBlankSelections[_selectedLesson.id],
                          isChecked:
                              _fillBlankChecked[_selectedLesson.id] ?? false,
                          onSelect: (option) {
                            setState(() {
                              _fillBlankSelections[_selectedLesson.id] = option;
                              _fillBlankChecked[_selectedLesson.id] = false;
                            });
                          },
                          onCheck: () {
                            final isCorrect =
                                _fillBlankSelections[_selectedLesson.id] ==
                                _selectedLesson.fillBlank.correctAnswer;
                            setState(() {
                              _fillBlankChecked[_selectedLesson.id] = true;
                            });
                            _saveFillBlankProgress(
                              _selectedLesson.id,
                              mastered: isCorrect,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _MatchGameCard(
                          lesson: _selectedLesson,
                          selections:
                              _matchSelections[_selectedLesson.id] ??
                              <String, String?>{},
                          isChecked: _matchChecked[_selectedLesson.id] ?? false,
                          onSelect: (term, definition) {
                            setState(() {
                              final existing = Map<String, String?>.from(
                                _matchSelections[_selectedLesson.id] ??
                                    <String, String?>{},
                              );
                              existing[term] = definition;
                              _matchSelections[_selectedLesson.id] = existing;
                              _matchChecked[_selectedLesson.id] = false;
                            });
                          },
                          onCheck: () {
                            final allCorrect = _selectedLesson.matchPairs.every(
                              (pair) =>
                                  (_matchSelections[_selectedLesson.id] ??
                                      <String, String?>{})[pair.term] ==
                                  pair.definition,
                            );
                            setState(() {
                              _matchChecked[_selectedLesson.id] = true;
                            });
                            _saveMatchProgress(
                              _selectedLesson.id,
                              mastered: allCorrect,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _LessonChecklistCard(lesson: _selectedLesson),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadProgress() async {
    final progress = await LessonProgressStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _progress = progress;
      _selectedLessonId =
          _lessons.any((lesson) => lesson.id == progress.lastLessonId)
          ? progress.lastLessonId
          : _lessons.first.id;
    });
  }

  Future<void> _selectLesson(String lessonId) async {
    setState(() => _selectedLessonId = lessonId);
    final progress = await LessonProgressStore.updateSelection(lessonId);
    final award = await DashboardSocialActivity.recordCurrentUserActivity(
      type: UserActivityType.lessonStudy,
      activityId: 'lesson:$lessonId',
    );
    if (!mounted) {
      return;
    }
    setState(() => _progress = progress);
    showActivityCelebration(context, award);
  }

  Future<void> _saveFillBlankProgress(
    String lessonId, {
    required bool mastered,
  }) async {
    final progress = await LessonProgressStore.setFillBlankMastered(
      lessonId,
      mastered,
    );
    final award = mastered
        ? await DashboardSocialActivity.recordCurrentUserActivity(
            type: UserActivityType.lessonCheck,
            activityId: 'lesson-fill:$lessonId',
          )
        : null;
    if (!mounted) {
      return;
    }
    setState(() => _progress = progress);
    showActivityCelebration(context, award);
  }

  Future<void> _saveMatchProgress(
    String lessonId, {
    required bool mastered,
  }) async {
    final progress = await LessonProgressStore.setMatchMastered(
      lessonId,
      mastered,
    );
    final award = mastered
        ? await DashboardSocialActivity.recordCurrentUserActivity(
            type: UserActivityType.lessonCheck,
            activityId: 'lesson-match:$lessonId',
          )
        : null;
    if (!mounted) {
      return;
    }
    setState(() => _progress = progress);
    showActivityCelebration(context, award);
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 72,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF11172A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFD5DFF0),
          ),
        ),
        child: Center(
          child: AppSvgIcon(
            AppIcons.arrowLeft,
            color: isDark ? Colors.white : const Color(0xFF17376C),
            size: 20,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

class _LessonHeroCard extends StatelessWidget {
  const _LessonHeroCard({
    required this.lesson,
    required this.progress,
    required this.nextStep,
    required this.onOpenQuiz,
  });

  final LessonModule lesson;
  final double progress;
  final String nextStep;
  final VoidCallback onOpenQuiz;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _lessonPaletteFor(lesson.id, isDark: isDark);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: appShadows(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.shortLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.summary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nextStep,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Hover or press the highlighted concept chips for quick definitions.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: lesson.keyTerms
                .map((term) => _GlossaryChip(term: term, inverse: true))
                .toList(),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onOpenQuiz,
            child: const Text('Take Topic Quiz'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF17407A),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonProgressHeader extends StatelessWidget {
  const _LessonProgressHeader({required this.progress});

  final LessonProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE5F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson Progress',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.overallProgress,
              minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE3EEFF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7FD5A5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${progress.completedLessonCount}/${lessonCatalog.length} lessons completed • Last visited: ${progress.lastLesson.shortLabel} ${progress.lastLesson.title}',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.74)
                  : const Color(0xFF4B6694),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TheorySectionCard extends StatelessWidget {
  const _TheorySectionCard({required this.lesson, required this.section});

  final LessonModule lesson;
  final LessonTheorySection section;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final palette = _lessonPaletteFor(lesson.id, isDark: isDark);
    final accent = palette.first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[const Color(0xFF11172A), accent.withValues(alpha: 0.14)]
              : <Color>[Colors.white, accent.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE5F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSvgIcon(
                _iconForSection(section.title),
                color: accent,
                size: 20,
                semanticLabel: section.title,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hover or tap the underlined terms for quick definitions.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.62)
                  : const Color(0xFF6584B3),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...section.points.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InsightTile(
                accentColor: accent,
                iconAsset: _iconForPoint(entry.key),
                text: entry.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FillBlankCard extends StatelessWidget {
  const _FillBlankCard({
    required this.lesson,
    required this.selectedOption,
    required this.isChecked,
    required this.onSelect,
    required this.onCheck,
  });

  final LessonModule lesson;
  final String? selectedOption;
  final bool isChecked;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF11172A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFDCE5F3);
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF4B6694);
    final isCorrect = selectedOption == lesson.fillBlank.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fill In The Blank',
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.fillBlank.prompt.replaceFirst(
              '_____',
              selectedOption ?? '_____',
            ),
            style: TextStyle(
              color: bodyColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: lesson.fillBlank.options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option),
                    selected: option == selectedOption,
                    onSelected: (_) => onSelect(option),
                    labelStyle: TextStyle(
                      color: option == selectedOption
                          ? Colors.white
                          : titleColor,
                      fontWeight: FontWeight.w800,
                    ),
                    selectedColor: const Color(0xFF2F73EA),
                    backgroundColor: isDark
                        ? const Color(0xFF182138)
                        : const Color(0xFFF3F7FE),
                    side: BorderSide(
                      color: option == selectedOption
                          ? Colors.transparent
                          : borderColor,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: selectedOption == null ? null : onCheck,
            child: const Text('Check Answer'),
          ),
          if (isChecked) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFFDCF8E6)
                    : const Color(0xFFFFE4E0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                isCorrect
                    ? 'Correct. ${lesson.fillBlank.explanation}'
                    : 'Not quite. The best answer is "${lesson.fillBlank.correctAnswer}". ${lesson.fillBlank.explanation}',
                style: const TextStyle(
                  color: Color(0xFF17376C),
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

class _ScenarioCheckCard extends StatelessWidget {
  const _ScenarioCheckCard({
    required this.lesson,
    required this.selectedOption,
    required this.isChecked,
    required this.onSelect,
    required this.onCheck,
  });

  final LessonModule lesson;
  final String? selectedOption;
  final bool isChecked;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.74)
        : const Color(0xFF4B6694);
    final palette = _lessonPaletteFor(lesson.id, isDark: isDark);
    final accent = palette.first;
    final isCorrect = selectedOption == lesson.scenarioCheck.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[const Color(0xFF11172A), accent.withValues(alpha: 0.16)]
              : <Color>[Colors.white, accent.withValues(alpha: 0.09)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE5F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppSvgIcon(
                    AppIcons.eye,
                    color: accent,
                    size: 18,
                    semanticLabel: 'Scenario check',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Scenario Check',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lesson.scenarioCheck.prompt,
            style: TextStyle(
              color: bodyColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ...lesson.scenarioCheck.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(option),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: option == selectedOption
                        ? accent.withValues(alpha: 0.18)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF7FAFF)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: option == selectedOption
                          ? accent
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFDCE5F3)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: option == selectedOption
                                ? accent
                                : bodyColor.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          color: option == selectedOption
                              ? accent
                              : Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: selectedOption == null ? null : onCheck,
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: const Text('Check Scenario'),
          ),
          if (isChecked) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFFDCF8E6)
                    : const Color(0xFFFFE4E0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                isCorrect
                    ? 'Strong choice. ${lesson.scenarioCheck.explanation}'
                    : 'Not the safest move. The best answer is "${lesson.scenarioCheck.correctAnswer}". ${lesson.scenarioCheck.explanation}',
                style: const TextStyle(
                  color: Color(0xFF17376C),
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

class _MatchGameCard extends StatelessWidget {
  const _MatchGameCard({
    required this.lesson,
    required this.selections,
    required this.isChecked,
    required this.onSelect,
    required this.onCheck,
  });

  final LessonModule lesson;
  final Map<String, String?> selections;
  final bool isChecked;
  final void Function(String term, String definition) onSelect;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF11172A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFDCE5F3);
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF4B6694);
    final definitions = lesson.matchPairs
        .map((pair) => pair.definition)
        .toList(growable: false);
    final allChosen = lesson.matchPairs.every(
      (pair) => (selections[pair.term] ?? '').isNotEmpty,
    );
    final score = lesson.matchPairs
        .where((pair) => selections[pair.term] == pair.definition)
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mix And Match',
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Match each term with the correct description.',
            style: TextStyle(
              color: bodyColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...lesson.matchPairs.map(
            (pair) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF182138)
                            : const Color(0xFFF3F7FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        pair.term,
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: definitions.contains(selections[pair.term])
                          ? selections[pair.term]
                          : null,
                      items: definitions
                          .map(
                            (definition) => DropdownMenuItem<String>(
                              value: definition,
                              child: Text(
                                definition,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onSelect(pair.term, value);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF182138)
                            : const Color(0xFFF3F7FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FilledButton(
            onPressed: allChosen ? onCheck : null,
            child: const Text('Check Matches'),
          ),
          if (isChecked) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'You matched $score out of ${lesson.matchPairs.length} correctly. Review the theory cards above if a few concepts still feel fuzzy.',
                style: const TextStyle(
                  color: Color(0xFF17376C),
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

class _LessonChecklistCard extends StatelessWidget {
  const _LessonChecklistCard({required this.lesson});

  final LessonModule lesson;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF4B6694);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE5F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remember This',
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...lesson.rememberPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF4F8FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSvgIcon(
                      AppIcons.sparkles,
                      color: Color(0xFF2F73EA),
                      size: 18,
                      semanticLabel: 'Remember',
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonModule {
  const LessonModule({
    required this.id,
    required this.shortLabel,
    required this.title,
    required this.summary,
    required this.keyTerms,
    required this.sections,
    required this.scenarioCheck,
    required this.fillBlank,
    required this.matchPairs,
    required this.rememberPoints,
  });

  final String id;
  final String shortLabel;
  final String title;
  final String summary;
  final List<String> keyTerms;
  final List<LessonTheorySection> sections;
  final LessonScenarioCheck scenarioCheck;
  final LessonFillBlank fillBlank;
  final List<LessonMatchPair> matchPairs;
  final List<String> rememberPoints;
}

class LessonTheorySection {
  const LessonTheorySection({required this.title, required this.points});

  final String title;
  final List<String> points;
}

class LessonFillBlank {
  const LessonFillBlank({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
}

class LessonScenarioCheck {
  const LessonScenarioCheck({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
}

class LessonMatchPair {
  const LessonMatchPair({required this.term, required this.definition});

  final String term;
  final String definition;
}

class _GlossaryChip extends StatelessWidget {
  const _GlossaryChip({required this.term, this.inverse = false});

  final String term;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final definition = _glossary[term];
    final bgColor = inverse
        ? Colors.white.withValues(alpha: 0.12)
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    final fgColor = inverse
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: definition ?? 'Definition coming soon.',
      waitDuration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: inverse
                ? Colors.white.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              AppIcons.info,
              color: fgColor,
              size: 14,
              semanticLabel: term,
            ),
            const SizedBox(width: 8),
            Text(
              term,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w700,
                decoration: definition == null
                    ? TextDecoration.none
                    : TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.iconAsset,
    required this.text,
    required this.accentColor,
  });

  final String iconAsset;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppSvgIcon(
                iconAsset,
                color: accentColor,
                size: 18,
                semanticLabel: 'Insight',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _GlossaryRichText(text: text)),
        ],
      ),
    );
  }
}

class _GlossaryRichText extends StatelessWidget {
  const _GlossaryRichText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.74)
        : const Color(0xFF4B6694);
    final accentColor = isDark
        ? const Color(0xFF8BC4FF)
        : const Color(0xFF1E67DF);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: baseColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
        children: _buildGlossarySpans(
          context,
          text,
          baseColor: baseColor,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

List<InlineSpan> _buildGlossarySpans(
  BuildContext context,
  String text, {
  required Color baseColor,
  required Color accentColor,
}) {
  final spans = <InlineSpan>[];
  final lower = text.toLowerCase();
  final glossaryTerms = _glossary.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  var cursor = 0;
  while (cursor < text.length) {
    String? matchedTerm;
    var matchedIndex = text.length;

    for (final term in glossaryTerms) {
      final index = lower.indexOf(term.toLowerCase(), cursor);
      if (index != -1 && index < matchedIndex) {
        matchedIndex = index;
        matchedTerm = term;
      }
    }

    if (matchedTerm == null) {
      spans.add(TextSpan(text: text.substring(cursor)));
      break;
    }

    if (matchedIndex > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, matchedIndex)));
    }

    final end = matchedIndex + matchedTerm.length;
    final visible = text.substring(matchedIndex, end);
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Tooltip(
          message: _glossary[matchedTerm]!,
          waitDuration: const Duration(milliseconds: 250),
          child: Text(
            visible,
            style: TextStyle(
              color: accentColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: accentColor,
            ),
          ),
        ),
      ),
    );
    cursor = end;
  }

  return spans;
}

String _iconForSection(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('response') || lower.contains('habit')) {
    return AppIcons.sparkles;
  }
  if (lower.contains('identity') || lower.contains('access')) {
    return AppIcons.shieldAlert;
  }
  if (lower.contains('risk') || lower.contains('danger')) {
    return AppIcons.eye;
  }
  return AppIcons.info;
}

String _iconForPoint(int index) {
  const icons = <String>[
    AppIcons.info,
    AppIcons.sparkles,
    AppIcons.shieldAlert,
    AppIcons.eye,
  ];
  return icons[index % icons.length];
}

const Map<String, String> _glossary = <String, String>{
  'CIA triad':
      'Confidentiality, integrity, and availability: three core security goals.',
  'Authentication': 'Proving who you are with evidence like a password or MFA.',
  'Authorization': 'Determining what an authenticated user is allowed to do.',
  'Least privilege': 'Giving only the minimum access needed for a task.',
  'Backups': 'Copies of important data used for recovery after loss or attack.',
  'Phishing': 'A scam that imitates a trusted source to steal data or money.',
  'Smishing': 'Phishing delivered through SMS or text messages.',
  'Vishing': 'Phishing delivered through voice calls.',
  'Pretexting': 'Using a made-up story to gain trust and extract information.',
  'Baiting': 'Using curiosity or reward to lure someone into unsafe action.',
  'Malware': 'Software designed to harm, spy on, or exploit a device.',
  'Adware': 'Software that pushes ads and may track user behaviour.',
  'Ransomware':
      'Malware that locks files or systems until payment is demanded.',
  'Password manager':
      'A tool that stores and generates strong unique passwords.',
  'HTTPS': 'Encrypted web traffic between your browser and a site.',
  'Evil twin': 'A fake Wi-Fi hotspot made to look like a legitimate one.',
  'VPN':
      'A tool that encrypts traffic between your device and a trusted endpoint.',
  'Hotspot': 'A network shared from a device, often a phone.',
  'Deepfakes': 'AI-generated fake media that imitates real people.',
  'SIM swapping': 'When an attacker moves your number to a SIM they control.',
  'OSINT': 'Open-source intelligence gathered from public information.',
  'Voice clone': 'AI-generated speech that mimics a real person’s voice.',
  'Recovery scams':
      'Scams that target victims by promising to recover lost money.',
  'Oversharing': 'Posting more personal information than is safe online.',
  'Doxxing': 'Publishing someone’s private information without consent.',
  'Impersonation': 'Pretending to be a trusted person or brand.',
  'Permissions': 'The access an app or service is allowed to use.',
  'Captive portal':
      'A login or acceptance page shown before internet access is allowed on a network.',
  'Certificate warning':
      'A browser warning that encrypted identity checks failed or look suspicious.',
  'Metadata':
      'Context about communication, such as time, sender, destination, or device details.',
  'MFA fatigue':
      'Repeated approval prompts sent to pressure a user into accepting one by mistake.',
  'Session token':
      'A temporary credential that keeps you signed in after authentication.',
};

List<Color> _lessonPaletteFor(String lessonId, {required bool isDark}) {
  switch (lessonId) {
    case 'basics':
      return isDark
          ? const <Color>[Color(0xFF0B3B84), Color(0xFF2A74EE)]
          : const <Color>[Color(0xFF2A74EE), Color(0xFF7CB4FF)];
    case 'social_engineering':
      return isDark
          ? const <Color>[Color(0xFF5C225A), Color(0xFFE05FA6)]
          : const <Color>[Color(0xFFD94A91), Color(0xFFFFA2C8)];
    case 'everyday_threats':
      return isDark
          ? const <Color>[Color(0xFF7A3B00), Color(0xFFF38B2A)]
          : const <Color>[Color(0xFFF38B2A), Color(0xFFFFCB76)];
    case 'account_recovery':
      return isDark
          ? const <Color>[Color(0xFF0E5E53), Color(0xFF27B89B)]
          : const <Color>[Color(0xFF1FA98B), Color(0xFF8FE1CB)];
    case 'public_wifi':
      return isDark
          ? const <Color>[Color(0xFF005666), Color(0xFF26B6D8)]
          : const <Color>[Color(0xFF18A8CF), Color(0xFF8FE7FF)];
    case 'emerging_threats':
      return isDark
          ? const <Color>[Color(0xFF493083), Color(0xFF8C6FF7)]
          : const <Color>[Color(0xFF7A61E8), Color(0xFFC2B6FF)];
    case 'social_media_safety':
      return isDark
          ? const <Color>[Color(0xFF7A203A), Color(0xFFFF6F8D)]
          : const <Color>[Color(0xFFFF6289), Color(0xFFFFB5C9)];
  }
  return isDark
      ? const <Color>[Color(0xFF0B3B84), Color(0xFF2A74EE)]
      : const <Color>[Color(0xFF2A74EE), Color(0xFF7CB4FF)];
}

const List<LessonModule> _lessons = <LessonModule>[
  LessonModule(
    id: 'basics',
    shortLabel: 'Chapter 1',
    title: 'Basics',
    summary:
        'Learn the core building blocks of cybersecurity: the CIA triad, strong authentication, least privilege, updates, backups, and defense in depth.',
    keyTerms: [
      'CIA triad',
      'Authentication',
      'Authorization',
      'Least privilege',
      'Backups',
    ],
    sections: [
      LessonTheorySection(
        title: 'Security Foundations',
        points: [
          'The CIA triad stands for confidentiality, integrity, and availability. Confidentiality keeps information secret from unauthorized people, integrity protects accuracy and trustworthiness, and availability keeps systems usable when people need them.',
          'Security is about reducing risk, not eliminating all danger forever. Risk combines the chance that something bad happens with the damage it could cause.',
          'Threat actors are the people or groups who might exploit a weakness. Vulnerabilities are the weaknesses they look for.',
        ],
      ),
      LessonTheorySection(
        title: 'Identity And Access',
        points: [
          'Authentication answers "who are you?" with evidence such as a password, authenticator app, hardware key, or biometric factor.',
          'Authorization answers "what are you allowed to do?" after identity has already been verified.',
          'Least privilege means each user, app, or service should get only the minimum access needed to do its job. That limits damage if an account is abused.',
        ],
      ),
      LessonTheorySection(
        title: 'Healthy Security Habits',
        points: [
          'Updates matter because they patch known vulnerabilities before attackers can keep abusing them.',
          'Backups protect availability and recovery. If files are lost, damaged, or encrypted by ransomware, a clean backup can restore operations.',
          'Defense in depth means using multiple layers together, such as unique passwords, MFA, updates, logging, backups, and access controls.',
        ],
      ),
      LessonTheorySection(
        title: 'Common Beginner Mistakes',
        points: [
          'People often focus only on passwords and forget the rest of the system. A strong password helps, but if software is outdated or accounts have broad access, risk is still high.',
          'Security controls work best when they are routine. Logging, patching, reviewing permissions, and testing Backups should feel normal instead of only happening after an incident.',
          'When something unusual happens, slow down and ask which part of the CIA triad could be harmed. That habit makes security decisions more concrete and less abstract.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'A student helper account only needs to upload course slides, but it currently has permission to edit staff payroll records too. What is the safest improvement?',
      options: [
        'Keep the wide access so the helper never gets blocked',
        'Apply Least privilege and remove everything unrelated to the helper task',
        'Share the staff account password so access can be monitored together',
      ],
      correctAnswer:
          'Apply Least privilege and remove everything unrelated to the helper task',
      explanation:
          'Limiting permissions lowers the impact if the account is compromised or misused.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'The principle of _____ means giving people only the minimum access they need.',
      options: ['availability', 'least privilege', 'obfuscation'],
      correctAnswer: 'least privilege',
      explanation:
          'Least privilege limits exposure by reducing what an attacker can do with a compromised account.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Confidentiality',
        definition: 'Keeping data secret from unauthorized access',
      ),
      LessonMatchPair(
        term: 'Integrity',
        definition: 'Keeping data accurate and untampered with',
      ),
      LessonMatchPair(
        term: 'Availability',
        definition: 'Keeping systems and data accessible when needed',
      ),
    ],
    rememberPoints: [
      'Use MFA wherever possible, especially on email and important accounts.',
      'Store unique passwords in a password manager instead of reusing them.',
      'Treat unexpected files, links, and urgent prompts cautiously until verified.',
      'When reviewing a security problem, ask whether confidentiality, integrity, or availability is at risk first.',
    ],
  ),
  LessonModule(
    id: 'social_engineering',
    shortLabel: 'Chapter 2',
    title: 'Social Engineering',
    summary:
        'Study how attackers manipulate trust, fear, urgency, authority, curiosity, and emotion through phishing, smishing, vishing, baiting, and pretexting.',
    keyTerms: ['Phishing', 'Smishing', 'Vishing', 'Pretexting', 'Baiting'],
    sections: [
      LessonTheorySection(
        title: 'How Manipulation Works',
        points: [
          'Social engineering attacks target people instead of software first. The attacker wants you to click, disclose, transfer, install, or trust before you think.',
          'Common emotional triggers include urgency, fear, authority, curiosity, and reward. Messages often try to rush you into skipping verification.',
          'Modern scams can be AI-assisted, which makes language, tone, and personalization more believable.',
        ],
      ),
      LessonTheorySection(
        title: 'Main Attack Types',
        points: [
          'Phishing usually arrives by email or a fake website and tries to steal credentials, money, or approval for malware.',
          'Smishing is phishing through text messages, while vishing uses voice calls. Pretexting uses a believable invented story to gain trust, and baiting uses something tempting such as a free reward or urgent attachment.',
          'Shortened links, spoofed branding, fake invoices, and surprise prizes all work by hiding the attacker intent behind familiar-looking context.',
        ],
      ),
      LessonTheorySection(
        title: 'Best Response',
        points: [
          'Do not trust a request just because it sounds official. Verify the sender, the destination link, and the reason for the request.',
          'Never share passwords or one-time codes with callers or messages claiming to be support staff.',
          'For money, account changes, or urgent requests, switch to a separate known channel such as the official app, website, or phone number.',
        ],
      ),
      LessonTheorySection(
        title: 'Pressure Tactics To Notice',
        points: [
          'Attackers often stack pressure signals together: urgency, secrecy, authority, fear of punishment, and reward. The more pressure a message applies, the more calmly you should verify it.',
          'A believable tone does not prove legitimacy. AI tools can remove spelling errors and mimic familiar writing styles, which is why process matters more than appearance.',
          'The safest response pattern is pause, inspect, verify separately, then act. That breaks the emotional tempo the attacker wants.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'You get a message from “IT Support” saying your account will be disabled in 15 minutes unless you confirm your password at a link. What is the safest move?',
      options: [
        'Use the link quickly because the deadline is short',
        'Reply asking if the message is real, then wait',
        'Ignore the link and verify through the official IT portal or phone number',
      ],
      correctAnswer:
          'Ignore the link and verify through the official IT portal or phone number',
      explanation:
          'Separate verification removes the attacker’s control over the channel and the urgency tactic.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'A phishing message often uses _____ to pressure you into acting before thinking.',
      options: ['urgency', 'encryption', 'compression'],
      correctAnswer: 'urgency',
      explanation:
          'Attackers want fast reactions because slowing down gives you time to verify the claim.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Smishing',
        definition: 'A scam delivered through SMS or text messages',
      ),
      LessonMatchPair(
        term: 'Vishing',
        definition: 'A scam delivered through a voice call',
      ),
      LessonMatchPair(
        term: 'Pretexting',
        definition: 'Using a believable invented story to gain trust',
      ),
    ],
    rememberPoints: [
      'Inspect sender addresses and links before clicking.',
      'Hang up and call back using a number you already trust.',
      'Report suspicious messages, especially if you already clicked or replied.',
      'The more a message pushes secrecy or speed, the more likely it is trying to bypass your normal checks.',
    ],
  ),
  LessonModule(
    id: 'everyday_threats',
    shortLabel: 'Chapter 3',
    title: 'Everyday Threats',
    summary:
        'Cover the risks people see daily: password reuse, fake websites, malware, adware, ransomware, dangerous installers, and risky browser behavior.',
    keyTerms: ['Malware', 'Adware', 'Ransomware', 'Password manager', 'HTTPS'],
    sections: [
      LessonTheorySection(
        title: 'Account And Software Risks',
        points: [
          'Password reuse is dangerous because a single breach can unlock many of your accounts. Unique passwords limit that blast radius.',
          'Password managers help by generating and storing long unique passwords so you do not need to memorize every one.',
          'Old, unused accounts can still expose personal data or reused credentials, so retiring and reviewing them is part of good hygiene.',
        ],
      ),
      LessonTheorySection(
        title: 'Malware And Fake Content',
        points: [
          'Malware is any software designed to harm, spy on, or exploit systems. Adware aggressively pushes ads and may track behavior. Ransomware encrypts files and demands payment.',
          'Pirated software, fake update prompts, suspicious pop-ups, and unknown installers are common malware delivery methods.',
          'A slightly misspelled website can be a typo-squatted fake site built to steal logins or trick users into downloads.',
        ],
      ),
      LessonTheorySection(
        title: 'Safer Defaults',
        points: [
          'Download apps and software only from official or trusted sources, and verify signatures when possible.',
          'HTTPS helps protect data in transit, but it does not automatically mean the site is trustworthy in every other way.',
          'Secure backups are one of the strongest protections against ransomware because they help you recover without depending on the attacker.',
        ],
      ),
      LessonTheorySection(
        title: 'Damage Control',
        points: [
          'If you suspect Malware, stop normal activity, disconnect if appropriate, and follow a trusted cleanup or reporting process. Continuing to log in everywhere can spread the damage.',
          'Ransomware recovery is strongest when Backups are offline, tested, and separated from the main system so the attacker cannot encrypt them too.',
          'A suspicious extension, pop-up, or installer should be treated like a possible intrusion path, not just an annoyance.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'A download site offers a “free premium” app installer and asks you to disable antivirus before running it. What is the safest response?',
      options: [
        'Disable antivirus only temporarily and test it',
        'Avoid it and download software only from official or trusted sources',
        'Run it in full-screen mode so pop-ups are easier to see',
      ],
      correctAnswer:
          'Avoid it and download software only from official or trusted sources',
      explanation:
          'Disabling protections and using unofficial installers are classic malware delivery patterns.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'A password _____ helps create and store strong unique passwords for different accounts.',
      options: ['manager', 'shortcut', 'mirror'],
      correctAnswer: 'manager',
      explanation:
          'Password managers reduce reuse and make stronger passwords practical at scale.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Malware',
        definition: 'Software built to harm, spy on, or exploit systems',
      ),
      LessonMatchPair(
        term: 'Adware',
        definition: 'Software that pushes ads and may track activity',
      ),
      LessonMatchPair(
        term: 'Ransomware',
        definition: 'Malware that encrypts files and demands payment',
      ),
    ],
    rememberPoints: [
      'Treat unexpected installers and browser pop-ups as suspicious.',
      'Keep backups separate and tested, not just created once and forgotten.',
      'Review app permissions and browser extensions because they may collect more data than expected.',
      'HTTPS is useful, but it does not make every site trustworthy by itself.',
    ],
  ),
  LessonModule(
    id: 'account_recovery',
    shortLabel: 'Chapter 4',
    title: 'Account Recovery And Identity Protection',
    summary:
        'Learn how password resets, MFA prompts, breach response, recovery channels, and identity proofing can either protect accounts or become the next attack path.',
    keyTerms: [
      'Authentication',
      'MFA fatigue',
      'Session token',
      'Permissions',
      'Certificate warning',
    ],
    sections: [
      LessonTheorySection(
        title: 'Why Recovery Flows Matter',
        points: [
          'Attackers do not always break into an account by guessing the password directly. They often target the recovery path instead, because reset links, support calls, backup emails, or one-time codes may be easier to exploit.',
          'Every recovery method is effectively a second front door. If a backup email, phone number, or device is weakly protected, the main account becomes easier to take over.',
          'Identity proofing questions based on public facts are often weak because attackers can gather those details through OSINT, social profiles, or previous breaches.',
        ],
      ),
      LessonTheorySection(
        title: 'Approval Prompt Attacks',
        points: [
          'MFA fatigue happens when an attacker repeatedly triggers approval prompts until the victim accepts one out of confusion or frustration.',
          'A push notification is not proof that a login is legitimate. If you did not initiate it, deny it and investigate why it happened.',
          'Session tokens matter too. Even if a password changes later, a stolen Session token may keep an attacker signed in until sessions are revoked.',
        ],
      ),
      LessonTheorySection(
        title: 'Safer Recovery Habits',
        points: [
          'Use strong MFA, keep recovery email addresses secure, set carrier and account PINs where available, and review which devices are trusted on important services.',
          'After a suspected compromise, change the password, revoke active sessions, inspect recovery settings, review sign-in history, and rotate any exposed codes or secrets.',
          'Treat unexpected reset emails, login approvals, and Certificate warning pages as signals to verify your account state rather than as prompts to react blindly.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'You receive five MFA approval prompts in a row even though you are not logging in anywhere. What is the safest response?',
      options: [
        'Approve one prompt to stop the notifications',
        'Deny the prompts, change the password if needed, and review account activity',
        'Ignore them because they will probably time out',
      ],
      correctAnswer:
          'Deny the prompts, change the password if needed, and review account activity',
      explanation:
          'Unexpected prompts can indicate a live attack, so the safest move is to deny access and inspect the account immediately.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'Repeated login approval prompts designed to wear a user down are known as MFA _____.',
      options: ['fatigue', 'mirroring', 'compression'],
      correctAnswer: 'fatigue',
      explanation:
          'MFA fatigue attacks rely on repetition and confusion, not on proving legitimacy.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Recovery email',
        definition: 'A secondary account that can help reset access',
      ),
      LessonMatchPair(
        term: 'Session token',
        definition: 'A temporary credential that keeps a user signed in',
      ),
      LessonMatchPair(
        term: 'MFA fatigue',
        definition: 'Repeated approval prompts used to pressure a victim',
      ),
    ],
    rememberPoints: [
      'Protect recovery channels as carefully as the main password.',
      'Unexpected approval prompts should be denied and investigated, not ignored.',
      'After compromise, revoke sessions and check recovery settings, not just the password.',
    ],
  ),
  LessonModule(
    id: 'public_wifi',
    shortLabel: 'Chapter 5',
    title: 'Public Wi-Fi Safety',
    summary:
        'Understand why open or fake hotspots are risky and how to reduce exposure with trusted SSIDs, VPNs, HTTPS, and better device settings.',
    keyTerms: ['Evil twin', 'VPN', 'HTTPS', 'Network discovery', 'Hotspot'],
    sections: [
      LessonTheorySection(
        title: 'Why Public Networks Can Be Dangerous',
        points: [
          'Attackers may observe unencrypted traffic, imitate a real hotspot, or use a fake captive portal to collect credentials or push downloads.',
          'An evil twin hotspot is a malicious network that looks like a legitimate one, such as a fake airport or cafe Wi-Fi name.',
          'Open networks increase the importance of checking warnings carefully because certificate issues or login prompts may signal tampering.',
        ],
      ),
      LessonTheorySection(
        title: 'Safer Network Choices',
        points: [
          'Ask staff or trusted signage for the exact network name before connecting. Do not pick a network just because it has the strongest signal.',
          'For sensitive tasks such as banking, admin dashboards, or payments, cellular data or your own hotspot is often safer than unknown public Wi-Fi.',
          'A VPN and HTTPS can improve privacy in transit, but they do not replace basic caution about where you log in and what you approve.',
        ],
      ),
      LessonTheorySection(
        title: 'Device Settings That Help',
        points: [
          'Disable automatic connection to open networks so your device does not silently join risky hotspots.',
          'Turn off file sharing, nearby sharing, and network discovery to reduce how visible your device is to strangers nearby.',
          'Forget public networks after use so your device does not reconnect to them later without you noticing.',
        ],
      ),
      LessonTheorySection(
        title: 'What A Risky Hotspot Can Still Learn',
        points: [
          'Even when sites use HTTPS, a network operator may still observe Metadata such as which domains you visit, when you connect, how much data you transfer, and what device identifiers or browser fingerprints appear.',
          'A malicious operator can try to push fake Captive portal pages, tamper with DNS lookups, trigger downgrade or certificate tricks, or present malware prompts disguised as updates or login requirements.',
          'If a site or app sends anything unencrypted, the hotspot owner may read or alter that traffic directly. Sensitive logins, search queries, and Session token leaks become much more dangerous on those networks.',
        ],
      ),
      LessonTheorySection(
        title: 'Safer Workflow On Public Wi-Fi',
        points: [
          'Classify tasks before you connect. Low-risk browsing is different from entering payroll details, resetting a password, or accessing an admin dashboard.',
          'If you must use public Wi-Fi, prefer staff-confirmed networks, turn on a VPN, verify HTTPS and Certificate warning prompts, and save high-value actions for a safer connection.',
          'After leaving, forget the network, review what you logged into, and watch for suspicious alerts, especially if anything unusual happened while connected.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'At an airport you see “Airport Free WiFi”, “Airport_Guest”, and a staff sign that says the official SSID is “Airport-Official” with a splash page but no password. What is the safest choice?',
      options: [
        'Join the strongest signal because speed usually means legitimacy',
        'Join Airport-Official because it matches trusted signage, then avoid sensitive tasks',
        'Join every open network once to compare which login page looks best',
      ],
      correctAnswer:
          'Join Airport-Official because it matches trusted signage, then avoid sensitive tasks',
      explanation:
          'Trusted confirmation of the exact SSID matters more than signal strength or a familiar-sounding name.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'A fake hotspot designed to imitate a real network is called an _____ twin.',
      options: ['evil', 'offline', 'encrypted'],
      correctAnswer: 'evil',
      explanation:
          'Evil twin networks rely on confusion and trust in a familiar-looking SSID.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Evil twin hotspot',
        definition: 'A fake Wi-Fi network made to look legitimate',
      ),
      LessonMatchPair(
        term: 'VPN',
        definition:
            'A tool that encrypts traffic between your device and a trusted endpoint',
      ),
      LessonMatchPair(
        term: 'Hotspot',
        definition:
            'A network shared from a trusted personal device such as a phone',
      ),
    ],
    rememberPoints: [
      'Avoid entering sensitive passwords or card details on questionable networks.',
      'Treat certificate warnings seriously instead of clicking through them.',
      'Disconnect and forget the network if you accidentally joined the wrong one.',
      'A VPN improves privacy in transit, but it does not make a risky task magically safe on an untrusted network.',
    ],
  ),
  LessonModule(
    id: 'emerging_threats',
    shortLabel: 'Chapter 6',
    title: 'Emerging Threats',
    summary:
        'Explore newer scam patterns involving deepfakes, voice clones, SIM swapping, crypto fraud, recovery scams, and OSINT-based targeting.',
    keyTerms: [
      'Deepfake',
      'SIM swapping',
      'OSINT',
      'Voice clone',
      'Recovery scam',
    ],
    sections: [
      LessonTheorySection(
        title: 'AI-Enhanced Deception',
        points: [
          'Deepfakes are AI-generated fake audio, video, or images that can imitate real people convincingly.',
          'Voice clones let attackers imitate familiar people in urgent situations, which is why trusted call-back verification matters.',
          'High production quality is no longer enough proof that something is authentic. Cross-check extreme or urgent claims with multiple reliable sources.',
        ],
      ),
      LessonTheorySection(
        title: 'Identity And Financial Threats',
        points: [
          'SIM swapping happens when an attacker convinces a carrier to move your number to their SIM. That can let them intercept SMS codes and recovery flows.',
          'Crypto scams often promise guaranteed returns, urgent investment windows, or fake insider access. Real investing always includes uncertainty and verification.',
          'Recovery scams target people after a loss by promising to get money back for another fee or for more personal information.',
        ],
      ),
      LessonTheorySection(
        title: 'Public Data As A Weapon',
        points: [
          'OSINT means open-source intelligence from public information. Attackers combine posts, profiles, birthdays, schools, and routines to build targeted scams.',
          'Overshared public details can strengthen impersonation attempts or help with account recovery attacks.',
          'Authenticator apps and hardware keys are generally safer MFA choices than SMS when available because they are less exposed to SIM-swap abuse.',
        ],
      ),
      LessonTheorySection(
        title: 'How To Slow Emerging Scams Down',
        points: [
          'Build verification routines that do not depend on the suspicious content itself. If a clip, call, or crypto offer creates pressure, step away from that channel and confirm through another source.',
          'AI can improve appearance, but it does not remove the need for the attacker to push for trust, urgency, money, codes, or access. Those motives still show up.',
          'Use layered defenses for modern threats: carrier PINs, stronger MFA, private-by-default profiles, and skeptical handling of investment or recovery promises.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'A familiar voice message says your cousin needs you to urgently buy crypto and send it within the hour. What is the safest response?',
      options: [
        'Trust the familiar voice and send a small amount first',
        'Call your cousin back using a known number and verify before doing anything',
        'Reply asking for the wallet address again so you can check it later',
      ],
      correctAnswer:
          'Call your cousin back using a known number and verify before doing anything',
      explanation:
          'Voice familiarity alone is no longer enough because voice clones and urgent pretexts are both common scam tools.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'When possible, an authenticator app is a stronger MFA choice than _____.',
      options: ['SMS', 'Wi-Fi', 'Bluetooth'],
      correctAnswer: 'SMS',
      explanation:
          'SMS codes can be intercepted through SIM-swap attacks, while authenticator-based MFA is usually more resilient.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Deepfake',
        definition: 'AI-generated fake audio, video, or images',
      ),
      LessonMatchPair(
        term: 'SIM swapping',
        definition: 'Moving a victim number to a SIM controlled by an attacker',
      ),
      LessonMatchPair(
        term: 'OSINT',
        definition:
            'Publicly available information used for profiling or research',
      ),
    ],
    rememberPoints: [
      'Pause on sudden urgent financial requests, especially around crypto.',
      'Set a carrier PIN and watch for unexplained signal loss or MFA failures.',
      'Think about what strangers can learn when public posts are combined together.',
      'Treat high-quality media as something to verify, not as automatic proof that it is real.',
    ],
  ),
  LessonModule(
    id: 'social_media_safety',
    shortLabel: 'Chapter 7',
    title: 'Social Media Safety',
    summary:
        'Learn how oversharing, fake profiles, doxxing, location clues, quiz apps, and impersonation can turn social platforms into security risks.',
    keyTerms: [
      'Oversharing',
      'Doxxing',
      'Fake profiles',
      'Permissions',
      'Impersonation',
    ],
    sections: [
      LessonTheorySection(
        title: 'Why Social Data Matters',
        points: [
          'Oversharing happens when personal or sensitive information is posted more broadly than intended. Small details such as birthdays, pet names, schools, and routines can be weaponized.',
          'Attackers use that information to guess security answers, impersonate you, or build very believable targeted messages.',
          'Posting travel plans, home clues, or real-time location can expose routines and show when a home or dorm is unattended.',
        ],
      ),
      LessonTheorySection(
        title: 'Fake Accounts And Social Pressure',
        points: [
          'Fake profiles can gather trust, collect information, or run financial and romance scams. A new account that immediately asks for details is a warning sign.',
          'Impersonation can target both individuals and brands. Attackers may copy photos, names, friend lists, and writing style to seem real.',
          'Comment sections and public friend lists can reveal relationships and habits that make future scams more convincing.',
        ],
      ),
      LessonTheorySection(
        title: 'Safer Use Of Platforms And Apps',
        points: [
          'Review audience settings, profile visibility, tagging rules, and app permissions regularly. Fun quiz apps can request broader access than they really need.',
          'Be careful with photos because IDs, addresses, tickets, whiteboards, or screens in the background can leak sensitive information.',
          'If a friend account suddenly asks for money or codes, verify with the real person through another channel before responding.',
        ],
      ),
      LessonTheorySection(
        title: 'Long-Term Exposure',
        points: [
          'Attackers do not need one dramatic post to learn about you. They can combine months or years of small details into a surprisingly accurate profile.',
          'Old posts, tagged events, public comments, and reused usernames can link identities across platforms and make impersonation feel more convincing.',
          'Safer social media use is less about disappearing entirely and more about choosing what should stay private, delayed, or audience-limited.',
        ],
      ),
    ],
    scenarioCheck: LessonScenarioCheck(
      prompt:
          'A new account with your friend’s photos asks for money in DMs and says they are too embarrassed to answer calls. What is the safest response?',
      options: [
        'Help quickly because the situation sounds emotional',
        'Verify with your real friend through another known channel before doing anything',
        'Ask the account for banking details so you can compare them later',
      ],
      correctAnswer:
          'Verify with your real friend through another known channel before doing anything',
      explanation:
          'Emotional pressure and refusal to verify are both common signs of impersonation fraud.',
    ),
    fillBlank: LessonFillBlank(
      prompt:
          'Publishing someone’s private information without consent is known as _____.',
      options: ['doxxing', 'mirroring', 'hashing'],
      correctAnswer: 'doxxing',
      explanation:
          'Doxxing exposes personal details publicly and can create both safety and harassment risks.',
    ),
    matchPairs: [
      LessonMatchPair(
        term: 'Oversharing',
        definition:
            'Revealing too much personal or sensitive information online',
      ),
      LessonMatchPair(
        term: 'Doxxing',
        definition:
            'Publishing private information about someone without consent',
      ),
      LessonMatchPair(
        term: 'Impersonation',
        definition: 'Pretending to be a real person or brand to gain trust',
      ),
    ],
    rememberPoints: [
      'Verify new connection requests before sharing anything personal.',
      'Review third-party app permissions instead of granting broad profile access automatically.',
      'Check the background of photos for addresses, IDs, passes, and screen content.',
      'Post with the mindset that many small clues can be combined into one strong attack profile.',
    ],
  ),
];
