import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../../dashboard/domain/dashboard_social_data.dart';
import '../../../dashboard/presentation/widgets/activity_snackbar.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, this.initialChapterId});

  final String? initialChapterId;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizBankRepository _bankRepository = QuizBankRepository();

  QuizChapter? _selectedChapter;
  List<QuizQuestion> _sessionQuestions = <QuizQuestion>[];
  Map<String, QuizBankProgress> _bankProgressByChapter =
      <String, QuizBankProgress>{};
  final Map<int, int> _selectedAnswers = <int, int>{};

  int _questionIndex = 0;
  bool _showResults = false;
  bool _loadingBank = true;
  bool _savingResults = false;

  QuizBankProgress get _selectedChapterProgress {
    final chapter = _selectedChapter;
    if (chapter == null) {
      return const QuizBankProgress(
        chapterId: '',
        attempts: 0,
        seenQuestionIds: <String>{},
        lastSessionQuestionIds: <String>{},
        presentedCounts: <String, int>{},
        correctCounts: <String, int>{},
      );
    }

    return _bankProgressByChapter[chapter.id] ??
        QuizBankProgress.empty(chapterId: chapter.id);
  }

  @override
  void initState() {
    super.initState();
    _loadBankProgress();
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
                    onTap: () {
                      if (_selectedChapter != null && !_showResults) {
                        _exitChapter();
                        return;
                      }
                      context.go('/dashboard');
                    },
                  ),
                  const Spacer(),
                  const ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _showResults
                    ? 'Quiz Results'
                    : _selectedChapter == null
                    ? 'Adaptive Topic Banks'
                    : _selectedChapter!.title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _showResults
                    ? 'Review this run, inspect your bank progress, and generate a fresh set of questions.'
                    : _selectedChapter == null
                    ? 'Each topic has its own question bank. Every time someone opens a quiz, the app assembles 10 questions with unseen items first and rotates the bank on future attempts.'
                    : _selectedChapter!.description,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _loadingBank
                      ? const _LoadingView(key: ValueKey('loading'))
                      : _showResults
                      ? _ResultsView(
                          key: const ValueKey('results'),
                          chapter: _selectedChapter!,
                          questions: _sessionQuestions,
                          selectedAnswers: _selectedAnswers,
                          bankProgress: _selectedChapterProgress,
                          onRetry: _restartChapter,
                          onChooseAnother: _exitChapter,
                        )
                      : _selectedChapter == null
                      ? _ChapterSelectionView(
                          key: const ValueKey('selection'),
                          chapters: _chapters,
                          progressByChapter: _bankProgressByChapter,
                          onSelect: _startChapter,
                          onViewBank: _showBankSheet,
                        )
                      : _QuestionView(
                          key: ValueKey(
                            '${_selectedChapter!.id}-${_sessionQuestions.first.id}',
                          ),
                          chapter: _selectedChapter!,
                          questions: _sessionQuestions,
                          questionIndex: _questionIndex,
                          selectedAnswerIndex: _selectedAnswers[_questionIndex],
                          bankProgress: _selectedChapterProgress,
                          isSavingResults: _savingResults,
                          onSelectAnswer: (index) {
                            setState(() {
                              _selectedAnswers[_questionIndex] = index;
                            });
                          },
                          onNext: _goNext,
                          onBackToChapters: _exitChapter,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadBankProgress() async {
    final progress = await _bankRepository.loadProgress(_chapters);
    if (!mounted) {
      return;
    }

    setState(() {
      _bankProgressByChapter = progress;
      _loadingBank = false;
    });

    final initialChapterId = widget.initialChapterId;
    if (initialChapterId != null && _selectedChapter == null) {
      QuizChapter? chapter;
      for (final item in _chapters) {
        if (item.id == initialChapterId) {
          chapter = item;
          break;
        }
      }
      if (chapter != null) {
        await _startChapter(chapter);
      }
    }
  }

  Future<void> _startChapter(QuizChapter chapter) async {
    final progress =
        _bankProgressByChapter[chapter.id] ??
        QuizBankProgress.empty(chapterId: chapter.id);
    final sessionQuestions = _buildAdaptiveSession(
      chapter: chapter,
      progress: progress,
    );
    final updatedProgress = await _bankRepository.recordGeneratedSession(
      chapterId: chapter.id,
      current: progress,
      questions: sessionQuestions,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedChapter = chapter;
      _sessionQuestions = sessionQuestions;
      _bankProgressByChapter[chapter.id] = updatedProgress;
      _questionIndex = 0;
      _selectedAnswers.clear();
      _showResults = false;
      _savingResults = false;
    });
  }

  Future<void> _goNext() async {
    if (_selectedAnswers[_questionIndex] == null || _savingResults) {
      return;
    }

    if (_questionIndex == _sessionQuestions.length - 1) {
      await _completeQuiz();
      return;
    }

    setState(() => _questionIndex += 1);
  }

  Future<void> _completeQuiz() async {
    final chapter = _selectedChapter;
    if (chapter == null) {
      return;
    }

    setState(() => _savingResults = true);

    final updatedProgress = await _bankRepository.recordSessionResult(
      chapter: chapter,
      questions: _sessionQuestions,
      selectedAnswers: _selectedAnswers,
    );
    final correctAnswers = _sessionQuestions.asMap().entries.where((entry) {
      final selectedAnswer = _selectedAnswers[entry.key];
      return selectedAnswer == entry.value.correctIndex;
    }).length;
    final accuracy = _sessionQuestions.isEmpty
        ? 0
        : correctAnswers / _sessionQuestions.length;
    final xpEarned = 40 + (accuracy * 35).round();
    final award = await DashboardSocialActivity.recordCurrentUserActivity(
      type: UserActivityType.quizCompletion,
      activityId: 'quiz:${chapter.id}',
      xp: xpEarned,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _bankProgressByChapter[chapter.id] = updatedProgress;
      _showResults = true;
      _savingResults = false;
    });
    showActivityCelebration(context, award);
  }

  Future<void> _restartChapter() async {
    final chapter = _selectedChapter;
    if (chapter == null) {
      return;
    }

    final progress =
        _bankProgressByChapter[chapter.id] ??
        QuizBankProgress.empty(chapterId: chapter.id);
    final sessionQuestions = _buildAdaptiveSession(
      chapter: chapter,
      progress: progress,
    );
    final updatedProgress = await _bankRepository.recordGeneratedSession(
      chapterId: chapter.id,
      current: progress,
      questions: sessionQuestions,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _sessionQuestions = sessionQuestions;
      _bankProgressByChapter[chapter.id] = updatedProgress;
      _questionIndex = 0;
      _selectedAnswers.clear();
      _showResults = false;
      _savingResults = false;
    });
  }

  void _exitChapter() {
    setState(() {
      _selectedChapter = null;
      _sessionQuestions = <QuizQuestion>[];
      _questionIndex = 0;
      _selectedAnswers.clear();
      _showResults = false;
      _savingResults = false;
    });
  }

  void _showBankSheet(QuizChapter chapter) {
    final progress =
        _bankProgressByChapter[chapter.id] ??
        QuizBankProgress.empty(chapterId: chapter.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TopicBankSheet(chapter: chapter, progress: progress);
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ChapterSelectionView extends StatelessWidget {
  const _ChapterSelectionView({
    super.key,
    required this.chapters,
    required this.progressByChapter,
    required this.onSelect,
    required this.onViewBank,
  });

  final List<QuizChapter> chapters;
  final Map<String, QuizBankProgress> progressByChapter;
  final ValueChanged<QuizChapter> onSelect;
  final ValueChanged<QuizChapter> onViewBank;

  @override
  Widget build(BuildContext context) {
    final totalQuestions = chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.questions.length,
    );
    final exploredQuestions = chapters.fold<int>(
      0,
      (sum, chapter) =>
          sum +
          (progressByChapter[chapter.id] ??
                  QuizBankProgress.empty(chapterId: chapter.id))
              .seenCount,
    );
    final masteredQuestions = chapters.fold<int>(
      0,
      (sum, chapter) =>
          sum +
          (progressByChapter[chapter.id] ??
                  QuizBankProgress.empty(chapterId: chapter.id))
              .masteredCount,
    );
    final totalAttempts = chapters.fold<int>(
      0,
      (sum, chapter) =>
          sum +
          (progressByChapter[chapter.id] ??
                  QuizBankProgress.empty(chapterId: chapter.id))
              .attempts,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return Column(
          children: [
            _BankOverviewCard(
              totalQuestions: totalQuestions,
              exploredQuestions: exploredQuestions,
              masteredQuestions: masteredQuestions,
              totalAttempts: totalAttempts,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 1.18 : 1.02,
                ),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final progress =
                      progressByChapter[chapter.id] ??
                      QuizBankProgress.empty(chapterId: chapter.id);

                  return _ChapterCard(
                    chapter: chapter,
                    progress: progress,
                    onTap: () => onSelect(chapter),
                    onViewBank: () => onViewBank(chapter),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    super.key,
    required this.chapter,
    required this.questions,
    required this.questionIndex,
    required this.selectedAnswerIndex,
    required this.bankProgress,
    required this.isSavingResults,
    required this.onSelectAnswer,
    required this.onNext,
    required this.onBackToChapters,
  });

  final QuizChapter chapter;
  final List<QuizQuestion> questions;
  final int questionIndex;
  final int? selectedAnswerIndex;
  final QuizBankProgress bankProgress;
  final bool isSavingResults;
  final ValueChanged<int> onSelectAnswer;
  final Future<void> Function() onNext;
  final VoidCallback onBackToChapters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final question = questions[questionIndex];
    final sessionProgress = (questionIndex + 1) / questions.length;
    final bankProgressValue = chapter.questions.isEmpty
        ? 0.0
        : bankProgress.seenCount / chapter.questions.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${chapter.shortLabel}  ${questionIndex + 1}/${questions.length}',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.74)
                        : const Color(0xFF365D9E),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onBackToChapters,
                child: const Text('Change Topic'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: sessionProgress,
              minHeight: 11,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : const Color(0xFFD7E6FF),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(
                label: 'Bank Seen',
                value: '${bankProgress.seenCount}/${chapter.questions.length}',
              ),
              _StatPill(
                label: 'Unseen Left',
                value: '${chapter.questions.length - bankProgress.seenCount}',
              ),
              _StatPill(label: 'Attempts', value: '${bankProgress.attempts}'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Topic bank progress',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.74)
                  : const Color(0xFF365D9E),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: bankProgressValue,
              minHeight: 9,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE3EEFF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7FD5A5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF66AFFF).withValues(alpha: 0.78)
                  : const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              question.prompt,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF163A6D)
                    : const Color(0xFF183A72),
                fontSize: 21,
                fontWeight: FontWeight.w800,
                height: 1.18,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final selected = selectedAnswerIndex == index;
                return _OptionTile(
                  optionIndex: index,
                  label: question.options[index],
                  selected: selected,
                  onTap: () => onSelectAnswer(index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedAnswerIndex == null || isSavingResults
                  ? null
                  : () => onNext(),
              child: Text(
                isSavingResults
                    ? 'Saving Result...'
                    : questionIndex == questions.length - 1
                    ? 'Finish Quiz'
                    : 'Next Question',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    super.key,
    required this.chapter,
    required this.questions,
    required this.selectedAnswers,
    required this.bankProgress,
    required this.onRetry,
    required this.onChooseAnother,
  });

  final QuizChapter chapter;
  final List<QuizQuestion> questions;
  final Map<int, int> selectedAnswers;
  final QuizBankProgress bankProgress;
  final VoidCallback onRetry;
  final VoidCallback onChooseAnother;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final correctAnswers = questions
        .asMap()
        .entries
        .where(
          (entry) => selectedAnswers[entry.key] == entry.value.correctIndex,
        )
        .length;
    final incorrectAnswers = questions.length - correctAnswers;
    final percent = ((correctAnswers / questions.length) * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(22),
      child: ListView(
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _StatPill(
                label: 'Score',
                value: '$correctAnswers/${questions.length}',
              ),
              _StatPill(label: 'Percent', value: '$percent%'),
              _StatPill(label: 'Missed', value: '$incorrectAnswers'),
              _StatPill(
                label: 'Bank Seen',
                value: '${bankProgress.seenCount}/${chapter.questions.length}',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            chapter.title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF163A6D),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percent >= 80
                ? 'Strong result. The next run will pull a fresh mix from the same topic bank.'
                : percent >= 60
                ? 'Decent progress. The bank will keep rotating and surface gaps you missed.'
                : 'Worth another pass. The adaptive selector will bring back weaker areas plus new unseen questions.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF365D9E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF3F8FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topic bank progress',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF163A6D),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatPill(
                      label: 'Attempts',
                      value: '${bankProgress.attempts}',
                    ),
                    _StatPill(
                      label: 'Mastered',
                      value:
                          '${bankProgress.masteredCount}/${chapter.questions.length}',
                    ),
                    _StatPill(
                      label: 'Unseen Left',
                      value:
                          '${chapter.questions.length - bankProgress.seenCount}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ...questions.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value;
            final selectedIndex = selectedAnswers[questionIndex];
            final correct = selectedIndex == question.correctIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: correct
                    ? const Color(0xFFBFEFD1)
                    : const Color(0xFFFFD7D7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.prompt,
                    style: const TextStyle(
                      color: Color(0xFF163A6D),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct answer: ${question.options[question.correctIndex]}',
                    style: const TextStyle(
                      color: Color(0xFF215E34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!correct) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Your answer: ${selectedIndex == null ? 'No answer selected' : question.options[selectedIndex]}',
                      style: const TextStyle(
                        color: Color(0xFF8A2D2D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Generate New 10'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onChooseAnother,
                  child: const Text('Choose Another'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankOverviewCard extends StatelessWidget {
  const _BankOverviewCard({
    required this.totalQuestions,
    required this.exploredQuestions,
    required this.masteredQuestions,
    required this.totalAttempts,
  });

  final int totalQuestions;
  final int exploredQuestions;
  final int masteredQuestions;
  final int totalAttempts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverage = totalQuestions == 0
        ? 0.0
        : exploredQuestions / totalQuestions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Bank Overview',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF173C73),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The adaptive selector prioritizes unseen questions first, then rotates older or weaker ones back in.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : const Color(0xFF365D9E),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(
                label: 'Explored',
                value: '$exploredQuestions/$totalQuestions',
              ),
              _StatPill(label: 'Mastered', value: '$masteredQuestions'),
              _StatPill(label: 'Attempts', value: '$totalAttempts'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: coverage,
              minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE2ECFF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7FD5A5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.progress,
    required this.onTap,
    required this.onViewBank,
  });

  final QuizChapter chapter;
  final QuizBankProgress progress;
  final VoidCallback onTap;
  final VoidCallback onViewBank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coverage = chapter.questions.isEmpty
        ? 0.0
        : progress.seenCount / chapter.questions.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A3C86) : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.shortLabel,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.52)
                    : const Color(0xFF5D82B5),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF66AFFF).withValues(alpha: 0.78)
                    : const Color(0xFFE7F1FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                chapter.title,
                style: const TextStyle(
                  color: Color(0xFF173C73),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              chapter.description,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.72)
                    : const Color(0xFF355C9C),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatPill(label: 'Bank', value: '${chapter.questions.length}'),
                _StatPill(label: 'Seen', value: '${progress.seenCount}'),
                _StatPill(
                  label: 'Mastered',
                  value: '${progress.masteredCount}',
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: coverage,
                minHeight: 9,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE2ECFF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7FD5A5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Each launch generates 10 questions from this topic bank.',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.62)
                    : const Color(0xFF5677AA),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                TextButton(
                  onPressed: onViewBank,
                  child: const Text('View Bank'),
                ),
                const Spacer(),
                Text(
                  'Start',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicBankSheet extends StatelessWidget {
  const _TopicBankSheet({required this.chapter, required this.progress});

  final QuizChapter chapter;
  final QuizBankProgress progress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unseenCount = chapter.questions.length - progress.seenCount;
    final reviewCount = progress.inReviewCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${chapter.title} Bank',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF163A6D),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This bank keeps track of what has been seen, what still feels new, and what likely needs more review.',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.72)
                      : const Color(0xFF365D9E),
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatPill(
                    label: 'Total',
                    value: '${chapter.questions.length}',
                  ),
                  _StatPill(label: 'Seen', value: '${progress.seenCount}'),
                  _StatPill(label: 'Unseen', value: '$unseenCount'),
                  _StatPill(
                    label: 'Mastered',
                    value: '${progress.masteredCount}',
                  ),
                  _StatPill(label: 'Review', value: '$reviewCount'),
                  _StatPill(label: 'Attempts', value: '${progress.attempts}'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Question status',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF163A6D),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ...chapter.questions.map((question) {
                final presented = progress.presentedCounts[question.id] ?? 0;
                final correct = progress.correctCounts[question.id] ?? 0;
                final seen = progress.seenQuestionIds.contains(question.id);
                final mastered = correct >= 2;
                final statusLabel = mastered
                    ? 'Mastered'
                    : seen
                    ? 'In Review'
                    : 'New';
                final statusColor = mastered
                    ? const Color(0xFF2E9A59)
                    : seen
                    ? const Color(0xFFC48720)
                    : const Color(0xFF2B6DDB);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF3F8FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question.prompt,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF163A6D),
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Shown: $presented   Correct: $correct',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : const Color(0xFF4C6EA2),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.optionIndex,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int optionIndex;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: isDark ? 0.3 : 0.16)
              : isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFF1F6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? selectedColor
                : isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFD0DDF2),
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? selectedColor
                    : isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(
                String.fromCharCode(65 + optionIndex),
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : isDark
                      ? Colors.white
                      : const Color(0xFF18407D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF173A71),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
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

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF66AFFF).withValues(alpha: 0.78)
            : const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF173C73).withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF173C73),
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizBankRepository {
  static const String _attemptsPrefix = 'quiz_bank_attempts';
  static const String _seenPrefix = 'quiz_bank_seen';
  static const String _lastSessionPrefix = 'quiz_bank_last_session';
  static const String _presentedPrefix = 'quiz_bank_presented';
  static const String _correctPrefix = 'quiz_bank_correct';

  Future<Map<String, QuizBankProgress>> loadProgress(
    List<QuizChapter> chapters,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, QuizBankProgress>{};

    for (final chapter in chapters) {
      result[chapter.id] = _readProgress(prefs: prefs, chapterId: chapter.id);
    }

    return result;
  }

  Future<QuizBankProgress> recordSessionResult({
    required QuizChapter chapter,
    required List<QuizQuestion> questions,
    required Map<int, int> selectedAnswers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _readProgress(prefs: prefs, chapterId: chapter.id);

    final seenQuestionIds = <String>{...current.seenQuestionIds};
    final lastSessionQuestionIds = questions
        .map((question) => question.id)
        .toSet();
    final presentedCounts = <String, int>{...current.presentedCounts};
    final correctCounts = <String, int>{...current.correctCounts};

    for (final entry in questions.asMap().entries) {
      final question = entry.value;
      seenQuestionIds.add(question.id);
      presentedCounts[question.id] = (presentedCounts[question.id] ?? 0) + 1;

      if (selectedAnswers[entry.key] == question.correctIndex) {
        correctCounts[question.id] = (correctCounts[question.id] ?? 0) + 1;
      }
    }

    final updated = QuizBankProgress(
      chapterId: chapter.id,
      attempts: current.attempts + 1,
      seenQuestionIds: seenQuestionIds,
      lastSessionQuestionIds: lastSessionQuestionIds,
      presentedCounts: presentedCounts,
      correctCounts: correctCounts,
    );

    await prefs.setInt(
      _scopedKey(_attemptsPrefix, chapter.id),
      updated.attempts,
    );
    await prefs.setString(
      _scopedKey(_seenPrefix, chapter.id),
      jsonEncode(updated.seenQuestionIds.toList()),
    );
    await prefs.setString(
      _scopedKey(_lastSessionPrefix, chapter.id),
      jsonEncode(updated.lastSessionQuestionIds.toList()),
    );
    await prefs.setString(
      _scopedKey(_presentedPrefix, chapter.id),
      jsonEncode(updated.presentedCounts),
    );
    await prefs.setString(
      _scopedKey(_correctPrefix, chapter.id),
      jsonEncode(updated.correctCounts),
    );

    return updated;
  }

  Future<QuizBankProgress> recordGeneratedSession({
    required String chapterId,
    required QuizBankProgress current,
    required List<QuizQuestion> questions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = QuizBankProgress(
      chapterId: chapterId,
      attempts: current.attempts,
      seenQuestionIds: <String>{
        ...current.seenQuestionIds,
        ...questions.map((question) => question.id),
      },
      lastSessionQuestionIds: questions.map((question) => question.id).toSet(),
      presentedCounts: current.presentedCounts,
      correctCounts: current.correctCounts,
    );

    await prefs.setString(
      _scopedKey(_seenPrefix, chapterId),
      jsonEncode(updated.seenQuestionIds.toList()),
    );
    await prefs.setString(
      _scopedKey(_lastSessionPrefix, chapterId),
      jsonEncode(updated.lastSessionQuestionIds.toList()),
    );

    return updated;
  }

  QuizBankProgress _readProgress({
    required SharedPreferences prefs,
    required String chapterId,
  }) {
    return QuizBankProgress(
      chapterId: chapterId,
      attempts: prefs.getInt(_scopedKey(_attemptsPrefix, chapterId)) ?? 0,
      seenQuestionIds: _decodeStringSet(
        prefs.getString(_scopedKey(_seenPrefix, chapterId)),
      ),
      lastSessionQuestionIds: _decodeStringSet(
        prefs.getString(_scopedKey(_lastSessionPrefix, chapterId)),
      ),
      presentedCounts: _decodeIntMap(
        prefs.getString(_scopedKey(_presentedPrefix, chapterId)),
      ),
      correctCounts: _decodeIntMap(
        prefs.getString(_scopedKey(_correctPrefix, chapterId)),
      ),
    );
  }

  String _scopedKey(String prefix, String chapterId) => '$prefix.$chapterId';

  Set<String> _decodeStringSet(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((value) => value.toString()).toSet();
  }

  Map<String, int> _decodeIntMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, int>{};
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
  }
}

class QuizBankProgress {
  const QuizBankProgress({
    required this.chapterId,
    required this.attempts,
    required this.seenQuestionIds,
    required this.lastSessionQuestionIds,
    required this.presentedCounts,
    required this.correctCounts,
  });

  const QuizBankProgress.empty({required this.chapterId})
    : attempts = 0,
      seenQuestionIds = const <String>{},
      lastSessionQuestionIds = const <String>{},
      presentedCounts = const <String, int>{},
      correctCounts = const <String, int>{};

  final String chapterId;
  final int attempts;
  final Set<String> seenQuestionIds;
  final Set<String> lastSessionQuestionIds;
  final Map<String, int> presentedCounts;
  final Map<String, int> correctCounts;

  int get seenCount => seenQuestionIds.length;

  int get masteredCount =>
      correctCounts.values.where((count) => count >= 2).length;

  int get inReviewCount => seenCount - masteredCount;
}

class QuizChapter {
  const QuizChapter({
    required this.id,
    required this.shortLabel,
    required this.title,
    required this.description,
    required this.questions,
  });

  final String id;
  final String shortLabel;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

List<QuizQuestion> _buildAdaptiveSession({
  required QuizChapter chapter,
  required QuizBankProgress progress,
}) {
  final random = Random();
  final scoredQuestions =
      chapter.questions
          .map(
            (question) => (
              question: question,
              score: _scoreQuestion(
                question: question,
                progress: progress,
                random: random,
              ),
            ),
          )
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));

  final sessionSize = min(10, chapter.questions.length);
  return scoredQuestions
      .take(sessionSize)
      .map((entry) => entry.question)
      .toList();
}

double _scoreQuestion({
  required QuizQuestion question,
  required QuizBankProgress progress,
  required Random random,
}) {
  final presented = progress.presentedCounts[question.id] ?? 0;
  final correct = progress.correctCounts[question.id] ?? 0;
  final incorrect = presented - correct;
  final seen = progress.seenQuestionIds.contains(question.id);
  final inLastSession = progress.lastSessionQuestionIds.contains(question.id);
  final mastered = correct >= 2;

  var score = 0.0;

  if (!seen) {
    score += 1000;
  }

  if (!inLastSession) {
    score += 220;
  } else {
    score -= 520;
  }

  score += incorrect * 140;
  score += presented == 0 ? 120 : 0;
  score += mastered ? -80 : 60;
  score -= presented * 24;
  score += random.nextDouble() * 10;

  return score;
}

const List<QuizChapter> _chapters = <QuizChapter>[
  QuizChapter(
    id: 'basics',
    shortLabel: 'Chapter 1',
    title: 'Basics',
    description:
        'Core security foundations like the CIA triad, authentication, and least privilege.',
    questions: [
      QuizQuestion(
        id: 'basics_01',
        prompt: 'What does the CIA triad stand for in cybersecurity?',
        options: [
          'Control, Identity, Access',
          'Confidentiality, Integrity, Availability',
          'Code, Internet, Antivirus',
          'Confidentiality, Inspection, Authorization',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_02',
        prompt:
            'Which part of the CIA triad is about making sure data is accurate and not tampered with?',
        options: ['Availability', 'Integrity', 'Confidentiality', 'Redundancy'],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_03',
        prompt: 'Which security control best protects confidentiality?',
        options: [
          'Encryption',
          'Cooling fan',
          'Battery backup',
          'Screen brightness',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'basics_04',
        prompt: 'What is multi-factor authentication?',
        options: [
          'Using two passwords',
          'Using more than one type of verification',
          'Logging in twice a day',
          'Changing your username often',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_05',
        prompt: 'What is the principle of least privilege?',
        options: [
          'Give every user admin rights',
          'Give only the minimum access needed',
          'Block all employees from the network',
          'Use the shortest possible password',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_06',
        prompt: 'Which is an example of authentication?',
        options: [
          'Granting read-only access after login',
          'Checking whether a file was changed',
          'Proving you are the account owner with a password',
          'Backing up data to the cloud',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'basics_07',
        prompt: 'What is authorization?',
        options: [
          'Proving identity',
          'Deciding what an authenticated user can access',
          'Encrypting web traffic',
          'Repairing malware infections',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_08',
        prompt: 'Why are software updates important for security?',
        options: [
          'They increase screen size',
          'They patch known vulnerabilities',
          'They remove passwords',
          'They make Wi-Fi faster',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_09',
        prompt: 'What is a vulnerability?',
        options: [
          'A hidden weakness attackers can exploit',
          'A backup copy of data',
          'A strong password standard',
          'A legal warning',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'basics_10',
        prompt: 'What does availability mean in the CIA triad?',
        options: [
          'Data is secret',
          'Data is correct',
          'Systems and data are accessible when needed',
          'Files are compressed',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'basics_11',
        prompt: 'What is the main goal of access control?',
        options: [
          'To speed up devices',
          'To decide who can use which resources',
          'To replace backups',
          'To remove all user accounts',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_12',
        prompt: 'Which example best shows defense in depth?',
        options: [
          'Relying on one long password only',
          'Using layers like MFA, updates, and backups together',
          'Turning off alerts',
          'Using a guest account as admin',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_13',
        prompt: 'What does a strong backup strategy mainly protect against?',
        options: [
          'All phishing forever',
          'Data loss and recovery failure',
          'Browser history',
          'Weak Wi-Fi signals',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_14',
        prompt: 'Which action best supports integrity?',
        options: [
          'Verifying file hashes after transfer',
          'Sharing accounts',
          'Disabling logs',
          'Leaving software outdated',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'basics_15',
        prompt: 'Which password habit is most secure?',
        options: [
          'Reusing one memorable password',
          'Writing every password on a sticky note',
          'Using unique passwords stored in a password manager',
          'Sharing passwords with classmates',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'basics_16',
        prompt: 'What does risk mean in cybersecurity?',
        options: [
          'Any website with ads',
          'The chance and impact of a threat exploiting a weakness',
          'A type of operating system',
          'A security patch',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_17',
        prompt: 'Why are logs useful in security?',
        options: [
          'They make files smaller',
          'They help detect and investigate suspicious activity',
          'They replace passwords',
          'They automatically fix malware',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'basics_18',
        prompt: 'What is a threat actor?',
        options: [
          'A person or group that may cause harm',
          'A broken hard drive',
          'A security standard only',
          'A password manager extension',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'basics_19',
        prompt: 'Which action best improves account security quickly?',
        options: [
          'Turning on MFA',
          'Using public Wi-Fi more often',
          'Disabling notifications',
          'Saving passwords in plain text',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'basics_20',
        prompt: 'What is the safest assumption about unexpected attachments?',
        options: [
          'They are always safe if labeled urgent',
          'They should be treated cautiously until verified',
          'They must be opened on mobile first',
          'They cannot contain malware if from a company',
        ],
        correctIndex: 1,
      ),
    ],
  ),
  QuizChapter(
    id: 'social_engineering',
    shortLabel: 'Chapter 2',
    title: 'Social Engineering',
    description:
        'Spot phishing, smishing, vishing, pretexting, baiting, and AI-enhanced scams.',
    questions: [
      QuizQuestion(
        id: 'social_01',
        prompt: 'Phishing usually tries to trick you through which channel?',
        options: [
          'Email or fake websites',
          'Bluetooth speakers',
          'Printer cables',
          'PDF formatting only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_02',
        prompt: 'What is smishing?',
        options: [
          'A scam through SMS or text messages',
          'A scam through smart TVs only',
          'Deleting spam automatically',
          'Encrypting email traffic',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_03',
        prompt: 'What is vishing?',
        options: [
          'Phishing by voice call',
          'Phishing with video games',
          'A secure VPN standard',
          'Email archiving',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_04',
        prompt: 'What is pretexting?',
        options: [
          'Making up a believable story to gain trust or information',
          'Sending many texts at once',
          'Scanning ports on a network',
          'Removing browser cookies',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_05',
        prompt: 'What is baiting in social engineering?',
        options: [
          'Offering something tempting to trick a victim',
          'Adding strong passwords to accounts',
          'Blocking USB ports permanently',
          'Reviewing privacy settings',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_06',
        prompt: 'Which is a common sign of a phishing email?',
        options: [
          'Unexpected urgency and suspicious links',
          'A familiar company logo',
          'A greeting with your name',
          'Normal spelling and domain',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_07',
        prompt:
            'Why do AI-generated scams make social engineering harder to detect?',
        options: [
          'They always include malware',
          'They can sound more convincing and personalized',
          'They remove the need for money',
          'They only target businesses',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'social_08',
        prompt:
            'If someone claims to be IT and asks for your password, what should you do?',
        options: [
          'Share it if they sound urgent',
          'Ask a coworker first',
          'Refuse and verify using an official channel',
          'Text it instead of emailing it',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'social_09',
        prompt:
            'A message says your account will be closed in 10 minutes unless you click now. What tactic is being used?',
        options: [
          'Urgency and fear',
          'Encryption',
          'Network segmentation',
          'Data hashing',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_10',
        prompt:
            'What is the safest response to an unexpected login alert with a link?',
        options: [
          'Click quickly before it expires',
          'Forward it to friends',
          'Go directly to the official site or app yourself',
          'Reply with your username',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'social_11',
        prompt: 'Why do scammers like using authority in messages?',
        options: [
          'It lowers urgency',
          'It pressures people to comply without thinking',
          'It increases encryption strength',
          'It blocks spam filters',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'social_12',
        prompt: 'What should you verify first in a suspicious email?',
        options: [
          'The sender address and destination link',
          'The font size',
          'The wallpaper on your device',
          'The file type of your notes',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_13',
        prompt: 'What makes a fake invoice scam effective?',
        options: [
          'It uses realistic business context and pressure to pay',
          'It always includes antivirus software',
          'It only affects social media accounts',
          'It relies on public Wi-Fi only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_14',
        prompt: 'What is the safest response to a surprise prize message?',
        options: [
          'Give details to claim it quickly',
          'Verify independently because unexpected rewards are common bait',
          'Reply with your password',
          'Install the attached app first',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'social_15',
        prompt: 'Why are shortened links risky in scam messages?',
        options: [
          'They make files larger',
          'They hide the real destination until clicked',
          'They disable MFA automatically',
          'They work only on desktop browsers',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'social_16',
        prompt:
            'What is a strong habit before responding to urgent requests for money?',
        options: [
          'Trust the sender if their wording feels professional',
          'Verify the request through a separate known channel',
          'Reply from a personal account',
          'Send partial payment first',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'social_17',
        prompt: 'Why can impersonation messages look legitimate?',
        options: [
          'They borrow names, logos, tone, and timing from real organizations',
          'They are protected by law',
          'They always come from secure domains',
          'They are generated only inside schools',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_18',
        prompt:
            'Which response is safest if a caller pressures you to reveal a code?',
        options: [
          'Read it out if they know your name',
          'Hang up and contact the organization yourself',
          'Text the code instead',
          'Give only half the code',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'social_19',
        prompt: 'What is the main goal of many phishing pages?',
        options: [
          'To collect credentials or payment details',
          'To improve your browser speed',
          'To store backups',
          'To update your phone wallpaper',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'social_20',
        prompt:
            'What should you do after reporting a phishing attempt on a work account?',
        options: [
          'Ignore it and keep the same password if you clicked',
          'Follow incident guidance and change credentials if exposure is possible',
          'Forward it to everyone in your contacts',
          'Delete all your files immediately',
        ],
        correctIndex: 1,
      ),
    ],
  ),
  QuizChapter(
    id: 'everyday_threats',
    shortLabel: 'Chapter 3',
    title: 'Everyday Threats',
    description:
        'Daily digital risks including password reuse, bad websites, malware, adware, and ransomware.',
    questions: [
      QuizQuestion(
        id: 'everyday_01',
        prompt: 'Why is password reuse dangerous?',
        options: [
          'It helps attackers access multiple accounts after one breach',
          'It makes passwords shorter',
          'It disables MFA',
          'It deletes backups',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_02',
        prompt: 'Which password is strongest?',
        options: ['password123', 'Hamid2024', 'Tr!ckY-Cloud-92', 'qwertyui'],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'everyday_03',
        prompt: 'What is malware?',
        options: [
          'Any software designed to harm, spy on, or exploit systems',
          'Only ransomware',
          'Only pop-up ads',
          'A legal software license',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_04',
        prompt: 'What is adware?',
        options: [
          'Software that aggressively shows ads and may track activity',
          'A backup tool',
          'A type of password manager',
          'An encrypted browser',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_05',
        prompt: 'What does ransomware do?',
        options: [
          'Speeds up your device',
          'Encrypts files and demands payment',
          'Improves Wi-Fi security',
          'Blocks ads permanently',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_06',
        prompt:
            'A website address is slightly misspelled but looks similar to a real brand. This is likely:',
        options: [
          'A trusted mirror',
          'A typo-squatted or fake site',
          'A browser update page',
          'A CDN',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_07',
        prompt: 'What should you check before downloading software?',
        options: [
          'Whether the site looks colorful',
          'If it came from an official or trusted source',
          'If it has many ads',
          'If it loads very quickly',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_08',
        prompt: 'Why is clicking random browser pop-ups risky?',
        options: [
          'They can trigger fake alerts or malicious downloads',
          'They update the browser',
          'They store more cookies',
          'They improve privacy',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_09',
        prompt: 'What is a safer habit for handling passwords?',
        options: [
          'Save them in open notes',
          'Use a password manager',
          'Use one password everywhere',
          'Share them with a friend',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_10',
        prompt: 'What is the best recovery protection against ransomware?',
        options: [
          'Turning brightness down',
          'Paying immediately',
          'Maintaining secure backups',
          'Using public Wi-Fi',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'everyday_11',
        prompt: 'Why is pirated software especially risky?',
        options: [
          'It often includes hidden malware or tampered installers',
          'It automatically enables MFA',
          'It improves update speed',
          'It comes with official support',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_12',
        prompt: 'What is a sign a browser alert may be fake?',
        options: [
          'It tells you to call a number immediately to fix a virus',
          'It comes from your browser settings page',
          'It appears after visiting your bank app',
          'It mentions a known bookmark',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_13',
        prompt:
            'What is the safest response to an unexpected software installer?',
        options: [
          'Run it to see what it does',
          'Verify the source and signature first',
          'Disable antivirus for better speed',
          'Share it with friends',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_14',
        prompt: 'What does a password manager mainly help with?',
        options: [
          'Creating and storing unique passwords',
          'Improving battery life',
          'Removing all phishing emails',
          'Stopping all Wi-Fi risks',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_15',
        prompt: 'Why should browser extensions be chosen carefully?',
        options: [
          'Some can read page contents or collect data',
          'They all come from the device manufacturer',
          'They cannot affect privacy',
          'They only change wallpaper',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_16',
        prompt:
            'What is the safest habit when a site asks to enable macros in a file?',
        options: [
          'Enable them immediately if the document looks important',
          'Treat it as suspicious and verify the file first',
          'Send the file to random friends',
          'Ignore all future updates',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_17',
        prompt: 'How can attackers benefit from old unused accounts?',
        options: [
          'They may still hold personal data or reused credentials',
          'They strengthen your privacy',
          'They delete breach records',
          'They block phishing automatically',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_18',
        prompt: 'What does HTTPS help protect?',
        options: [
          'Data in transit between your browser and the site',
          'All account passwords everywhere',
          'Physical device theft',
          'Deleted backups',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_19',
        prompt: 'Why are app permissions worth reviewing?',
        options: [
          'Apps may request more access than they truly need',
          'Permissions make apps faster only',
          'Permissions cannot affect privacy',
          'Only laptops use permissions',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_20',
        prompt: 'What should you do if you suspect malware on your device?',
        options: [
          'Keep entering passwords as normal',
          'Disconnect if needed and follow a trusted cleanup process',
          'Post about it publicly first',
          'Install random tools from ads',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_21',
        prompt: 'Why are browser extensions a security concern?',
        options: [
          'Some can read page data and collect more information than expected',
          'They always improve privacy by default',
          'They cannot affect websites after install',
          'They work only when the browser is offline',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'everyday_22',
        prompt:
            'What is the safest reaction to a fake virus pop-up with a phone number?',
        options: [
          'Call immediately because it might be a real warning',
          'Close the page safely and avoid engaging with the number',
          'Give remote access so support can inspect the device',
          'Type your passwords to prove ownership',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'everyday_23',
        prompt: 'Why should backups be tested instead of just created?',
        options: [
          'Because a backup that cannot be restored is less useful in a crisis',
          'Because testing makes malware impossible',
          'Because cloud storage requires weekly deletion',
          'Because testing increases download speed',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  QuizChapter(
    id: 'account_recovery',
    shortLabel: 'Chapter 4',
    title: 'Account Recovery And Identity Protection',
    description:
        'Protect reset flows, handle MFA prompts safely, and respond properly when account access looks suspicious.',
    questions: [
      QuizQuestion(
        id: 'recovery_01',
        prompt: 'Why are account recovery options important for security?',
        options: [
          'They can become another path attackers use to take over an account',
          'They only affect app colors',
          'They disable passwords',
          'They replace MFA automatically',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_02',
        prompt: 'What is MFA fatigue?',
        options: [
          'A battery issue caused by security apps',
          'Repeated approval prompts meant to pressure a user into accepting one',
          'Logging in too often on one device',
          'Using a password manager for too long',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'recovery_03',
        prompt:
            'What should you do if you receive an MFA prompt you did not initiate?',
        options: [
          'Approve it once in case it is a delayed login',
          'Deny it and investigate the account immediately',
          'Ignore it and hope it stops',
          'Share the prompt with friends',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'recovery_04',
        prompt: 'Why is a recovery email account so important?',
        options: [
          'It can help regain access to your primary account',
          'It removes the need for passwords',
          'It blocks all phishing attempts',
          'It prevents software updates',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_05',
        prompt: 'Which recovery method is weakest if based on public facts?',
        options: [
          'Hardware security keys',
          'Security questions answerable from social media or public data',
          'Authenticator apps',
          'Trusted device passcodes',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'recovery_06',
        prompt: 'What is a session token?',
        options: [
          'A physical code printed by your bank',
          'A temporary credential that keeps you signed in after login',
          'A Wi-Fi password',
          'A browser theme file',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'recovery_07',
        prompt:
            'After changing a compromised password, what else is often important?',
        options: [
          'Revoking active sessions and checking recovery settings',
          'Increasing screen brightness',
          'Deleting all browser tabs',
          'Turning off MFA',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_08',
        prompt:
            'What is the safest response to a surprise password reset email?',
        options: [
          'Ignore it completely even if you suspect compromise',
          'Use the email link immediately without checking',
          'Check whether the request was real and review account activity',
          'Forward the reset link to a friend',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'recovery_09',
        prompt: 'Why are carrier account PINs useful?',
        options: [
          'They can make SIM-swap attacks harder',
          'They replace encryption everywhere',
          'They speed up Wi-Fi logins',
          'They stop all malware',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_10',
        prompt:
            'Which backup factor is usually stronger than SMS when available?',
        options: [
          'Authenticator app or hardware key',
          'Public forum answers',
          'Shared email inboxes',
          'A shorter password',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_11',
        prompt: 'What is the main danger of approving a random login push?',
        options: [
          'It may grant an attacker access to your account',
          'It weakens your Wi-Fi signal',
          'It clears browser cookies only',
          'It reduces photo quality',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_12',
        prompt: 'What should you review after suspected account takeover?',
        options: [
          'Recovery phone, email, trusted devices, and sign-in history',
          'Wallpaper settings only',
          'Bluetooth name only',
          'Printer defaults only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_13',
        prompt: 'Why are reused recovery answers risky?',
        options: [
          'Attackers can reuse what they learn across multiple services',
          'They automatically expire every day',
          'They increase encryption strength',
          'They block session revocation',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_14',
        prompt:
            'What is the safest reaction to repeated login failures on an important account?',
        options: [
          'Ignore them if the password still works',
          'Treat them as a sign to review security and monitor the account',
          'Post your login page online for advice',
          'Disable all notifications',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'recovery_15',
        prompt:
            'Why should old phone numbers be removed from account recovery options?',
        options: [
          'They may route recovery attempts to numbers you no longer control',
          'They improve phishing quality',
          'They create better passwords',
          'They increase app storage',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_16',
        prompt:
            'What is the safest attitude toward unexpected approval prompts?',
        options: [
          'Treat them as suspicious unless you initiated the login yourself',
          'Assume every prompt is delayed but legitimate',
          'Approve all prompts from familiar apps',
          'Ignore MFA completely',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_17',
        prompt:
            'Which action best reduces damage after a stolen session token?',
        options: [
          'Revoking sessions and re-authenticating trusted devices',
          'Changing wallpaper',
          'Leaving the browser open longer',
          'Switching Wi-Fi networks',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_18',
        prompt:
            'Why are public birthdays and pet names relevant to account recovery?',
        options: [
          'They may help answer weak recovery questions',
          'They disable authenticator apps',
          'They break HTTPS',
          'They turn off file sharing',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_19',
        prompt: 'Which support message is most suspicious?',
        options: [
          'A message asking you to share a one-time code to prove ownership',
          'A reminder to review your security settings',
          'A note saying updates are available in the official app',
          'A warning to verify links before clicking',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'recovery_20',
        prompt: 'What is the best summary of strong account recovery security?',
        options: [
          'Protect the recovery path as carefully as the main login',
          'Use one recovery email for everyone in the family',
          'Disable all alerts to avoid stress',
          'Approve prompts quickly so you do not get locked out',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  QuizChapter(
    id: 'public_wifi',
    shortLabel: 'Chapter 5',
    title: 'Public Wi-Fi Safety',
    description:
        'Reduce risk on open or fake hotspots and avoid exposing accounts on untrusted networks.',
    questions: [
      QuizQuestion(
        id: 'wifi_01',
        prompt: 'Why can public Wi-Fi be risky?',
        options: [
          'Attackers may monitor or imitate the network',
          'It always has weak signal',
          'It prevents app updates',
          'It blocks all websites',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_02',
        prompt: 'What is an evil twin hotspot?',
        options: [
          'A stronger router at home',
          'A fake Wi-Fi network made to look legitimate',
          'A blocked hotspot',
          'A private VPN server',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_03',
        prompt: 'What should you do before joining cafe Wi-Fi?',
        options: [
          'Ask staff for the exact network name',
          'Use the first open network you see',
          'Disable your firewall',
          'Share the password online',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_04',
        prompt: 'What is safer on public Wi-Fi?',
        options: [
          'Online banking without MFA',
          'A VPN and HTTPS websites',
          'Turning off device lock',
          'Leaving file sharing on',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_05',
        prompt: 'Why should file sharing be turned off on public networks?',
        options: [
          'It drains battery only',
          'It can expose your device to others nearby',
          'It boosts Wi-Fi speed',
          'It blocks malware automatically',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_06',
        prompt: 'What should you avoid doing on random public Wi-Fi?',
        options: [
          'Checking the weather',
          'Reading downloaded notes',
          'Entering sensitive passwords or payment details',
          'Using airplane mode later',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'wifi_07',
        prompt: 'What helps confirm a website is encrypted?',
        options: [
          'Lots of animations',
          'https and a valid padlock indicator',
          'The site uses blue text',
          'The site has ads removed',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_08',
        prompt: 'What device setting reduces automatic public Wi-Fi risk?',
        options: [
          'Auto-join enabled for all networks',
          'Bluetooth discoverable at all times',
          'Disabling automatic connection to open networks',
          'Maximum brightness',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'wifi_09',
        prompt:
            'If you accidentally joined a suspicious Wi-Fi network, what is a good next step?',
        options: [
          'Stay connected and monitor',
          'Disconnect and forget the network',
          'Post the password online',
          'Restart only the browser',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_10',
        prompt:
            'Which is usually safer than unknown public Wi-Fi for sensitive tasks?',
        options: [
          'Mobile hotspot or cellular data',
          'A random hidden SSID',
          'An expired certificate warning page',
          'USB charging stations',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_11',
        prompt: 'Why can captive portal login pages be abused?',
        options: [
          'Fake portals can collect credentials or trick users into downloads',
          'They always improve encryption',
          'They disable ads permanently',
          'They install official updates only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_12',
        prompt: 'What is a safer habit after using public Wi-Fi?',
        options: [
          'Leave the network saved forever',
          'Forget the network when you no longer need it',
          'Share the SSID publicly',
          'Turn off screen lock',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_13',
        prompt: 'Which traffic is easiest to inspect on unsafe open Wi-Fi?',
        options: [
          'Unencrypted traffic',
          'All traffic inside a VPN',
          'Files stored offline',
          'Your paper notes',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_14',
        prompt:
            'Why is auto-sharing AirDrop or nearby sharing risky in public places?',
        options: [
          'It can expose your device to unexpected content or contacts',
          'It speeds up malware scans',
          'It hides your IP address',
          'It creates stronger passwords',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_15',
        prompt:
            'What should you do if a browser warns about a certificate issue on public Wi-Fi?',
        options: [
          'Proceed because public Wi-Fi is expected to be noisy',
          'Treat it seriously and avoid entering sensitive data',
          'Disable all updates',
          'Type your password twice',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'wifi_16',
        prompt: 'What is a benefit of using your phone as a hotspot?',
        options: [
          'It can be more trustworthy than an unknown open network',
          'It removes the need for passwords everywhere',
          'It disables phishing links',
          'It keeps batteries full',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_17',
        prompt:
            'Why should you avoid logging into admin dashboards on open Wi-Fi?',
        options: [
          'Sensitive sessions deserve stronger network trust',
          'Admin dashboards only work at home',
          'They break VPNs automatically',
          'They delete browser cookies',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_18',
        prompt: 'What should you check before connecting to airport Wi-Fi?',
        options: [
          'Whether the official airport instructions match the SSID',
          'Whether the signal is the strongest',
          'Whether other people are already using it',
          'Whether it has a fun network name',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_19',
        prompt: 'Why is disabling network discovery useful on public networks?',
        options: [
          'It reduces how visible your device is to nearby systems',
          'It makes websites load faster',
          'It increases screen brightness',
          'It removes the need for HTTPS',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_20',
        prompt: 'What is the safest payment choice on a questionable network?',
        options: [
          'Avoid payment tasks until you are on a trusted connection',
          'Enter card details quickly before the network changes',
          'Use any link sent over chat',
          'Turn off MFA first',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_21',
        prompt:
            'Which detail might a hotspot operator still learn even when you browse mostly over HTTPS?',
        options: [
          'Visited domains and connection Metadata',
          'Every encrypted password in plain text',
          'Offline files stored in airplane mode',
          'Your device battery percentage only',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_22',
        prompt: 'Why are DNS lookups relevant on a hostile Wi-Fi network?',
        options: [
          'They can reveal which sites you are trying to reach',
          'They disable certificate checks',
          'They make cellular data faster',
          'They only affect printer setup',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_23',
        prompt: 'What is a fake captive portal trying to do?',
        options: [
          'Collect credentials or push malicious downloads before internet access',
          'Increase the legitimacy of the network',
          'Improve browser privacy automatically',
          'Back up your files to the cloud',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'wifi_24',
        prompt: 'Which task belongs in a high-risk category on public Wi-Fi?',
        options: [
          'Reading a cached article',
          'Opening a campus map',
          'Resetting a password for your main email account',
          'Checking the weather forecast',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'wifi_25',
        prompt:
            'What should you do after using a public network that felt suspicious?',
        options: [
          'Forget the network and monitor important accounts for unusual activity',
          'Save the network permanently for convenience',
          'Disable browser warnings because they are noisy',
          'Reuse the same network for banking later',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  QuizChapter(
    id: 'emerging_threats',
    shortLabel: 'Chapter 6',
    title: 'Emerging Threats',
    description:
        'Modern risks like deepfakes, SIM swapping, crypto fraud, and overshared public information.',
    questions: [
      QuizQuestion(
        id: 'emerging_01',
        prompt: 'What is a deepfake?',
        options: [
          'A damaged hard drive',
          'AI-generated fake audio, video, or images',
          'A secure storage standard',
          'An antivirus feature',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_02',
        prompt: 'Why are deepfakes dangerous?',
        options: [
          'They can convincingly impersonate real people',
          'They block Wi-Fi',
          'They only affect video games',
          'They delete browser history',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_03',
        prompt: 'What is SIM swapping?',
        options: [
          'Changing phone wallpaper',
          'Moving a number to a SIM controlled by an attacker',
          'Upgrading a phone battery',
          'Adding two SIM cards for travel',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_04',
        prompt: 'Why is SIM swapping serious?',
        options: [
          'It can let attackers intercept verification codes',
          'It improves call quality',
          'It disables your camera',
          'It deletes your contacts permanently',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_05',
        prompt: 'Which is a common sign of a crypto scam?',
        options: [
          'Guaranteed returns with no risk',
          'Independent audits and caution',
          'Clear regulation details',
          'Slow, boring marketing',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_06',
        prompt: 'What does OSINT refer to?',
        options: [
          'Online secure identity network traffic',
          'Open-source intelligence from publicly available information',
          'Only secure internal tools',
          'Operating system integration tests',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_07',
        prompt: 'Why should you care about OSINT awareness?',
        options: [
          'Public posts can help attackers profile or target you',
          'It removes your passwords automatically',
          'It only matters to celebrities',
          'It makes phishing impossible',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_08',
        prompt:
            'What is a safer way to verify a voice request that sounds urgent?',
        options: [
          'Trust the voice if it sounds familiar',
          'Hang up and call the person back using a known number',
          'Ask for their email password',
          'Reply with bank details',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_09',
        prompt: 'Which protection reduces SIM-swap damage?',
        options: [
          'Using SMS as the only MFA option',
          'Carrier account PINs and stronger authenticator-based MFA',
          'Posting your number publicly',
          'Reusing passwords',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_10',
        prompt:
            'If an investment post says “act now before this doubles tonight,” what should you assume first?',
        options: [
          'It is probably a pressure tactic and needs verification',
          'It is safe because it is urgent',
          'It came from a friend so it is guaranteed',
          'It is regulated by default',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_11',
        prompt: 'Why are voice clones risky in fraud?',
        options: [
          'They can mimic familiar people to pressure victims',
          'They only affect music players',
          'They remove caller ID',
          'They disable SIM cards physically',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_12',
        prompt:
            'What is the safest reaction to a sudden request to move crypto fast?',
        options: [
          'Send first and verify later',
          'Pause and verify through trusted independent channels',
          'Post the wallet publicly',
          'Ignore transaction addresses',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_13',
        prompt:
            'What makes recovery scams dangerous after someone loses money?',
        options: [
          'They pretend they can recover funds for another fee',
          'They return all stolen money automatically',
          'They only target banks',
          'They require no personal data',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_14',
        prompt: 'What is a safer habit with personal data posted online?',
        options: [
          'Assume strangers cannot connect scattered details',
          'Review what attackers could learn from combined public posts',
          'Post more to dilute the data',
          'Share account recovery answers openly',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_15',
        prompt: 'Why are fake investment communities effective?',
        options: [
          'They create social proof and urgency around risky decisions',
          'They are regulated automatically',
          'They reduce all crypto volatility',
          'They only attract security experts',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_16',
        prompt: 'What is a better MFA choice than SMS when possible?',
        options: [
          'Authenticator app or hardware key',
          'Shared group email',
          'Security questions posted online',
          'A shorter password',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_17',
        prompt:
            'What is the main risk of oversharing birthdays, schools, or pet names?',
        options: [
          'That data can help answer recovery questions or build scams',
          'It breaks encryption',
          'It disables backups',
          'It blocks VPNs',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_18',
        prompt:
            'How should you treat a video of a public figure making an extreme urgent claim?',
        options: [
          'Assume it is real if the image quality is high',
          'Verify through multiple reliable sources because deepfakes exist',
          'Share it immediately before it gets removed',
          'Trust it if someone you know reposted it',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'emerging_19',
        prompt: 'What is a key warning sign in many AI-assisted scams?',
        options: [
          'They feel unusually personalized and emotionally targeted',
          'They always contain obvious spelling mistakes',
          'They never use urgency',
          'They only happen on desktop computers',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'emerging_20',
        prompt:
            'What is the safest reaction if your phone suddenly loses signal and MFA codes stop arriving?',
        options: [
          'Ignore it until tomorrow',
          'Consider possible SIM-swap activity and contact your carrier fast',
          'Post the issue on social media with your number',
          'Turn off all passwords',
        ],
        correctIndex: 1,
      ),
    ],
  ),
  QuizChapter(
    id: 'social_media_safety',
    shortLabel: 'Chapter 7',
    title: 'Social Media Safety',
    description:
        'Protect your identity online by avoiding oversharing, fake profiles, and doxxing exposure.',
    questions: [
      QuizQuestion(
        id: 'socialmedia_01',
        prompt: 'What is oversharing on social media?',
        options: [
          'Posting useful updates',
          'Revealing too much personal or sensitive information',
          'Using hashtags often',
          'Sending direct messages',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_02',
        prompt: 'Why can oversharing be dangerous?',
        options: [
          'It helps attackers guess passwords or security answers',
          'It improves account security',
          'It blocks fake profiles',
          'It hides your location',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_03',
        prompt: 'What is doxxing?',
        options: [
          'Encrypting your messages',
          'Publishing private information about someone without consent',
          'Deleting a social account',
          'Backing up profile photos',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_04',
        prompt: 'Which profile is most suspicious?',
        options: [
          'A real friend with shared history',
          'A brand-new account with almost no activity that immediately asks for personal info',
          'A verified university account',
          'A coworker you know offline',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_05',
        prompt: 'Why should location sharing be used carefully?',
        options: [
          'It can reveal routines, whereabouts, or when you are away from home',
          'It improves encryption strength',
          'It prevents phishing',
          'It blocks screenshots',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_06',
        prompt:
            'What is a safer response to a stranger asking for personal details in DMs?',
        options: [
          'Answer politely with full details',
          'Send your phone number first',
          'Avoid sharing and verify who they are',
          'Share once if they have many followers',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        id: 'socialmedia_07',
        prompt: 'Which privacy step is most helpful on social media?',
        options: [
          'Making every post public',
          'Reviewing audience and profile visibility settings',
          'Using the same password everywhere',
          'Accepting every follow request',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_08',
        prompt: 'How can fake profiles be used against people?',
        options: [
          'To build trust, gather data, or run scams',
          'To improve platform security',
          'To patch software bugs',
          'To increase password length',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_09',
        prompt:
            'What kind of post could help someone answer your password reset questions?',
        options: [
          'A generic sunset photo',
          'A post revealing your pet name, birthday, or school mascot',
          'A shared news link',
          'A weather screenshot',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_10',
        prompt:
            'If a profile impersonates a friend or brand, what should you do?',
        options: [
          'Send them your details to test them',
          'Report the account and verify through official channels',
          'Ignore all brand accounts forever',
          'Post your password publicly',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_11',
        prompt: 'Why is posting travel plans before leaving risky?',
        options: [
          'It can signal when you are away from home',
          'It improves map accuracy',
          'It prevents doxxing',
          'It disables private messages',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_12',
        prompt: 'What is a warning sign in a fake giveaway account?',
        options: [
          'It asks for fees or credentials to claim a prize',
          'It links to official support pages',
          'It is run by verified staff',
          'It warns users not to share data',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_13',
        prompt: 'How can public friend lists create risk?',
        options: [
          'Attackers can map relationships for impersonation or targeting',
          'They automatically encrypt your profile',
          'They prevent phishing',
          'They block all fake messages',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_14',
        prompt:
            'What is the safest response to a quiz app asking for broad profile access?',
        options: [
          'Grant access because it looks fun',
          'Review permissions carefully and deny unnecessary access',
          'Log in with the same password everywhere',
          'Share the app with strangers first',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_15',
        prompt: 'Why is reused content from old posts risky?',
        options: [
          'It can reveal long-term habits and personal clues over time',
          'It boosts all privacy settings',
          'It deletes metadata',
          'It hides your name from search',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_16',
        prompt:
            'What should you do if a friend account suddenly asks for money?',
        options: [
          'Send it because you know them',
          'Verify with the real person through another channel',
          'Post your bank details in chat',
          'Ignore all future messages forever',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        id: 'socialmedia_17',
        prompt: 'Why are “Which character are you?” quizzes sometimes risky?',
        options: [
          'They may collect personal details or profile permissions',
          'They always install hardware malware',
          'They disable MFA immediately',
          'They only affect celebrities',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_18',
        prompt: 'What is a safer rule for posting photos?',
        options: [
          'Check whether they reveal IDs, addresses, or screens in the background',
          'Assume background details never matter',
          'Always tag your exact location',
          'Post every boarding pass publicly',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_19',
        prompt: 'How can attackers use comment sections?',
        options: [
          'To gather opinions, routines, and personal details for targeting',
          'To reset your password directly',
          'To force software updates',
          'To remove your account lock',
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'socialmedia_20',
        prompt: 'What is the best default mindset for new connection requests?',
        options: [
          'Accept quickly to grow your network',
          'Verify identity before sharing anything personal',
          'Send them private photos first',
          'Use your birth date as a password for chat',
        ],
        correctIndex: 1,
      ),
    ],
  ),
];
