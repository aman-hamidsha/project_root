import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizChapter? _selectedChapter;
  int _questionIndex = 0;
  final Map<int, int> _selectedAnswers = <int, int>{};
  bool _showResults = false;

  QuizQuestion get _currentQuestion => _selectedChapter!.questions[_questionIndex];

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
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      if (_selectedChapter != null && !_showResults) {
                        setState(() {
                          _selectedChapter = null;
                          _questionIndex = 0;
                          _selectedAnswers.clear();
                        });
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
                        ? 'Cybersecurity Quizzes'
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
                    ? 'Review your score and jump into another chapter.'
                    : _selectedChapter == null
                        ? 'Choose a chapter and work through 10 multiple-choice questions.'
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
                  child: _showResults
                      ? _ResultsView(
                          key: const ValueKey('results'),
                          chapter: _selectedChapter!,
                          selectedAnswers: _selectedAnswers,
                          onRetry: _restartChapter,
                          onChooseAnother: _exitChapter,
                        )
                      : _selectedChapter == null
                          ? _ChapterSelectionView(
                              key: const ValueKey('selection'),
                              chapters: _chapters,
                              onSelect: _startChapter,
                            )
                          : _QuestionView(
                              key: ValueKey(_selectedChapter!.title),
                              chapter: _selectedChapter!,
                              questionIndex: _questionIndex,
                              selectedAnswerIndex:
                                  _selectedAnswers[_questionIndex],
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

  void _startChapter(QuizChapter chapter) {
    setState(() {
      _selectedChapter = chapter;
      _questionIndex = 0;
      _selectedAnswers.clear();
      _showResults = false;
    });
  }

  void _goNext() {
    if (_selectedAnswers[_questionIndex] == null) {
      return;
    }

    if (_questionIndex == _selectedChapter!.questions.length - 1) {
      setState(() => _showResults = true);
      return;
    }

    setState(() => _questionIndex += 1);
  }

  void _restartChapter() {
    setState(() {
      _questionIndex = 0;
      _selectedAnswers.clear();
      _showResults = false;
    });
  }

  void _exitChapter() {
    setState(() {
      _selectedChapter = null;
      _questionIndex = 0;
      _selectedAnswers.clear();
      _showResults = false;
    });
  }
}

class _ChapterSelectionView extends StatelessWidget {
  const _ChapterSelectionView({
    super.key,
    required this.chapters,
    required this.onSelect,
  });

  final List<QuizChapter> chapters;
  final ValueChanged<QuizChapter> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
                ? 2
                : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 1.8 : 1.05,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return _ChapterCard(
              chapter: chapter,
              onTap: () => onSelect(chapter),
            );
          },
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    super.key,
    required this.chapter,
    required this.questionIndex,
    required this.selectedAnswerIndex,
    required this.onSelectAnswer,
    required this.onNext,
    required this.onBackToChapters,
  });

  final QuizChapter chapter;
  final int questionIndex;
  final int? selectedAnswerIndex;
  final ValueChanged<int> onSelectAnswer;
  final VoidCallback onNext;
  final VoidCallback onBackToChapters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final question = chapter.questions[questionIndex];
    final progress = (questionIndex + 1) / chapter.questions.length;

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
                  '${chapter.shortLabel}  ${questionIndex + 1}/${chapter.questions.length}',
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
                child: const Text('Change Chapter'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : const Color(0xFFD7E6FF),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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
                color: isDark ? const Color(0xFF163A6D) : const Color(0xFF183A72),
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
              onPressed: selectedAnswerIndex == null ? null : onNext,
              child: Text(
                questionIndex == chapter.questions.length - 1
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
    required this.selectedAnswers,
    required this.onRetry,
    required this.onChooseAnother,
  });

  final QuizChapter chapter;
  final Map<int, int> selectedAnswers;
  final VoidCallback onRetry;
  final VoidCallback onChooseAnother;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final correctAnswers = chapter.questions
        .asMap()
        .entries
        .where((entry) => selectedAnswers[entry.key] == entry.value.correctIndex)
        .length;
    final incorrectAnswers = chapter.questions.length - correctAnswers;
    final percent = ((correctAnswers / chapter.questions.length) * 100).round();

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
              _StatPill(label: 'Score', value: '$correctAnswers/${chapter.questions.length}'),
              _StatPill(label: 'Percent', value: '$percent%'),
              _StatPill(label: 'Missed', value: '$incorrectAnswers'),
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
                ? 'Strong result. You have a solid handle on this chapter.'
                : percent >= 60
                    ? 'Decent progress. A quick review will tighten things up.'
                    : 'Worth another pass. This chapter covers common real-world mistakes.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF365D9E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          ...chapter.questions.asMap().entries.map((entry) {
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
                  child: const Text('Retry Chapter'),
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

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.onTap,
  });

  final QuizChapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            Expanded(
              child: Text(
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
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${chapter.questions.length} questions',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.58)
                        : const Color(0xFF5677AA),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Start',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
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
  const _TopButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary, width: 3),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF66AFFF).withValues(alpha: 0.78) : const Color(0xFFE7F1FF),
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

class QuizChapter {
  const QuizChapter({
    required this.shortLabel,
    required this.title,
    required this.description,
    required this.questions,
  });

  final String shortLabel;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
}

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

const List<QuizChapter> _chapters = <QuizChapter>[
  QuizChapter(
    shortLabel: 'Chapter 1',
    title: 'Basics',
    description: 'Core security foundations like the CIA triad, authentication, and least privilege.',
    questions: [
      QuizQuestion(
        prompt: 'What does the CIA triad stand for in cybersecurity?',
        options: ['Control, Identity, Access', 'Confidentiality, Integrity, Availability', 'Code, Internet, Antivirus', 'Confidentiality, Inspection, Authorization'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Which part of the CIA triad is about making sure data is accurate and not tampered with?',
        options: ['Availability', 'Integrity', 'Confidentiality', 'Redundancy'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Which security control best protects confidentiality?',
        options: ['Encryption', 'Cooling fan', 'Battery backup', 'Screen brightness'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is multi-factor authentication?',
        options: ['Using two passwords', 'Using more than one type of verification', 'Logging in twice a day', 'Changing your username often'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What is the principle of least privilege?',
        options: ['Give every user admin rights', 'Give only the minimum access needed', 'Block all employees from the network', 'Use the shortest possible password'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Which is an example of authentication?',
        options: ['Granting read-only access after login', 'Checking whether a file was changed', 'Proving you are the account owner with a password', 'Backing up data to the cloud'],
        correctIndex: 2,
      ),
      QuizQuestion(
        prompt: 'What is authorization?',
        options: ['Proving identity', 'Deciding what an authenticated user can access', 'Encrypting web traffic', 'Repairing malware infections'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why are software updates important for security?',
        options: ['They increase screen size', 'They patch known vulnerabilities', 'They remove passwords', 'They make Wi-Fi faster'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What is a vulnerability?',
        options: ['A hidden weakness attackers can exploit', 'A backup copy of data', 'A strong password standard', 'A legal warning'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What does availability mean in the CIA triad?',
        options: ['Data is secret', 'Data is correct', 'Systems and data are accessible when needed', 'Files are compressed'],
        correctIndex: 2,
      ),
    ],
  ),
  QuizChapter(
    shortLabel: 'Chapter 2',
    title: 'Social Engineering',
    description: 'Spot phishing, smishing, vishing, pretexting, baiting, and AI-enhanced scams.',
    questions: [
      QuizQuestion(
        prompt: 'Phishing usually tries to trick you through which channel?',
        options: ['Email or fake websites', 'Bluetooth speakers', 'Printer cables', 'PDF formatting only'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is smishing?',
        options: ['A scam through SMS or text messages', 'A scam through smart TVs only', 'Deleting spam automatically', 'Encrypting email traffic'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is vishing?',
        options: ['Phishing by voice call', 'Phishing with video games', 'A secure VPN standard', 'Email archiving'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is pretexting?',
        options: ['Making up a believable story to gain trust or information', 'Sending many texts at once', 'Scanning ports on a network', 'Removing browser cookies'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is baiting in social engineering?',
        options: ['Offering something tempting to trick a victim', 'Adding strong passwords to accounts', 'Blocking USB ports permanently', 'Reviewing privacy settings'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which is a common sign of a phishing email?',
        options: ['Unexpected urgency and suspicious links', 'A familiar company logo', 'A greeting with your name', 'Normal spelling and domain'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Why do AI-generated scams make social engineering harder to detect?',
        options: ['They always include malware', 'They can sound more convincing and personalized', 'They remove the need for money', 'They only target businesses'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'If someone claims to be IT and asks for your password, what should you do?',
        options: ['Share it if they sound urgent', 'Ask a coworker first', 'Refuse and verify using an official channel', 'Text it instead of emailing it'],
        correctIndex: 2,
      ),
      QuizQuestion(
        prompt: 'A message says your account will be closed in 10 minutes unless you click now. What tactic is being used?',
        options: ['Urgency and fear', 'Encryption', 'Network segmentation', 'Data hashing'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is the safest response to an unexpected login alert with a link?',
        options: ['Click quickly before it expires', 'Forward it to friends', 'Go directly to the official site or app yourself', 'Reply with your username'],
        correctIndex: 2,
      ),
    ],
  ),
  QuizChapter(
    shortLabel: 'Chapter 3',
    title: 'Everyday Threats',
    description: 'Daily digital risks including password reuse, bad websites, malware, adware, and ransomware.',
    questions: [
      QuizQuestion(
        prompt: 'Why is password reuse dangerous?',
        options: ['It helps attackers access multiple accounts after one breach', 'It makes passwords shorter', 'It disables MFA', 'It deletes backups'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which password is strongest?',
        options: ['password123', 'Hamid2024', 'Tr!ckY-Cloud-92', 'qwertyui'],
        correctIndex: 2,
      ),
      QuizQuestion(
        prompt: 'What is malware?',
        options: ['Any software designed to harm, spy on, or exploit systems', 'Only ransomware', 'Only pop-up ads', 'A legal software license'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is adware?',
        options: ['Software that aggressively shows ads and may track activity', 'A backup tool', 'A type of password manager', 'An encrypted browser'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What does ransomware do?',
        options: ['Speeds up your device', 'Encrypts files and demands payment', 'Improves Wi-Fi security', 'Blocks ads permanently'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'A website address is slightly misspelled but looks similar to a real brand. This is likely:',
        options: ['A trusted mirror', 'A typo-squatted or fake site', 'A browser update page', 'A CDN'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What should you check before downloading software?',
        options: ['Whether the site looks colorful', 'If it came from an official or trusted source', 'If it has many ads', 'If it loads very quickly'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why is clicking random browser pop-ups risky?',
        options: ['They can trigger fake alerts or malicious downloads', 'They update the browser', 'They store more cookies', 'They improve privacy'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is a safer habit for handling passwords?',
        options: ['Save them in open notes', 'Use a password manager', 'Use one password everywhere', 'Share them with a friend'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What is the best recovery protection against ransomware?',
        options: ['Turning brightness down', 'Paying immediately', 'Maintaining secure backups', 'Using public Wi-Fi'],
        correctIndex: 2,
      ),
    ],
  ),
  QuizChapter(
    shortLabel: 'Chapter 5',
    title: 'Public Wi-Fi Safety',
    description: 'Reduce risk on open or fake hotspots and avoid exposing accounts on untrusted networks.',
    questions: [
      QuizQuestion(
        prompt: 'Why can public Wi-Fi be risky?',
        options: ['Attackers may monitor or imitate the network', 'It always has weak signal', 'It prevents app updates', 'It blocks all websites'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is an evil twin hotspot?',
        options: ['A stronger router at home', 'A fake Wi-Fi network made to look legitimate', 'A blocked hotspot', 'A private VPN server'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What should you do before joining café Wi-Fi?',
        options: ['Ask staff for the exact network name', 'Use the first open network you see', 'Disable your firewall', 'Share the password online'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is safer on public Wi-Fi?',
        options: ['Online banking without MFA', 'A VPN and HTTPS websites', 'Turning off device lock', 'Leaving file sharing on'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why should file sharing be turned off on public networks?',
        options: ['It drains battery only', 'It can expose your device to others nearby', 'It boosts Wi-Fi speed', 'It blocks malware automatically'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What should you avoid doing on random public Wi-Fi?',
        options: ['Checking the weather', 'Reading downloaded notes', 'Entering sensitive passwords or payment details', 'Using airplane mode later'],
        correctIndex: 2,
      ),
      QuizQuestion(
        prompt: 'What helps confirm a website is encrypted?',
        options: ['Lots of animations', 'https and a valid padlock indicator', 'The site uses blue text', 'The site has ads removed'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'What device setting reduces automatic public Wi-Fi risk?',
        options: ['Auto-join enabled for all networks', 'Bluetooth discoverable at all times', 'Disabling automatic connection to open networks', 'Maximum brightness'],
        correctIndex: 2,
      ),
      QuizQuestion(
        prompt: 'If you accidentally joined a suspicious Wi-Fi network, what is a good next step?',
        options: ['Stay connected and monitor', 'Disconnect and forget the network', 'Post the password online', 'Restart only the browser'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Which is usually safer than unknown public Wi-Fi for sensitive tasks?',
        options: ['Mobile hotspot or cellular data', 'A random hidden SSID', 'An expired certificate warning page', 'USB charging stations'],
        correctIndex: 0,
      ),
    ],
  ),
  QuizChapter(
    shortLabel: 'Chapter 6',
    title: 'Emerging Threats',
    description: 'Modern risks like deepfakes, SIM swapping, crypto fraud, and overshared public information.',
    questions: [
      QuizQuestion(
        prompt: 'What is a deepfake?',
        options: ['A damaged hard drive', 'AI-generated fake audio, video, or images', 'A secure storage standard', 'An antivirus feature'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why are deepfakes dangerous?',
        options: ['They can convincingly impersonate real people', 'They block Wi-Fi', 'They only affect video games', 'They delete browser history'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is SIM swapping?',
        options: ['Changing phone wallpaper', 'Moving a number to a SIM controlled by an attacker', 'Upgrading a phone battery', 'Adding two SIM cards for travel'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why is SIM swapping serious?',
        options: ['It can let attackers intercept verification codes', 'It improves call quality', 'It disables your camera', 'It deletes your contacts permanently'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'Which is a common sign of a crypto scam?',
        options: ['Guaranteed returns with no risk', 'Independent audits and caution', 'Clear regulation details', 'Slow, boring marketing'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What does OSINT refer to?',
        options: ['Online secure identity network traffic', 'Open-source intelligence from publicly available information', 'Only secure internal tools', 'Operating system integration tests'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why should you care about OSINT awareness?',
        options: ['Public posts can help attackers profile or target you', 'It removes your passwords automatically', 'It only matters to celebrities', 'It makes phishing impossible'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is a safer way to verify a voice request that sounds urgent?',
        options: ['Trust the voice if it sounds familiar', 'Hang up and call the person back using a known number', 'Ask for their email password', 'Reply with bank details'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Which protection reduces SIM-swap damage?',
        options: ['Using SMS as the only MFA option', 'Carrier account PINs and stronger authenticator-based MFA', 'Posting your number publicly', 'Reusing passwords'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'If an investment post says “act now before this doubles tonight,” what should you assume first?',
        options: ['It is probably a pressure tactic and needs verification', 'It is safe because it is urgent', 'It came from a friend so it is guaranteed', 'It is regulated by default'],
        correctIndex: 0,
      ),
    ],
  ),
  QuizChapter(
    shortLabel: 'Chapter 7',
    title: 'Social Media Safety',
    description: 'Protect your identity online by avoiding oversharing, fake profiles, and doxxing exposure.',
    questions: [
      QuizQuestion(
        prompt: 'What is oversharing on social media?',
        options: ['Posting useful updates', 'Revealing too much personal or sensitive information', 'Using hashtags often', 'Sending direct messages'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why can oversharing be dangerous?',
        options: ['It helps attackers guess passwords or security answers', 'It improves account security', 'It blocks fake profiles', 'It hides your location'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is doxxing?',
        options: ['Encrypting your messages', 'Publishing private information about someone without consent', 'Deleting a social account', 'Backing up profile photos'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Which profile is most suspicious?',
        options: ['A real friend with shared history', 'A brand-new account with almost no activity that immediately asks for personal info', 'A verified university account', 'A coworker you know offline'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'Why should location sharing be used carefully?',
        options: ['It can reveal routines, whereabouts, or when you are away from home', 'It improves encryption strength', 'It prevents phishing', 'It blocks screenshots'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What is a safer response to a stranger asking for personal details in DMs?',
        options: ['Answer politely with full details', 'Send your phone number first', 'Avoid sharing and verify who they are', 'Share once if they have many followers'],
        correctIndex: 2,
      ),
      QuizQuestion(
        prompt: 'Which privacy step is most helpful on social media?',
        options: ['Making every post public', 'Reviewing audience and profile visibility settings', 'Using the same password everywhere', 'Accepting every follow request'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'How can fake profiles be used against people?',
        options: ['To build trust, gather data, or run scams', 'To improve platform security', 'To patch software bugs', 'To increase password length'],
        correctIndex: 0,
      ),
      QuizQuestion(
        prompt: 'What kind of post could help someone answer your password reset questions?',
        options: ['A generic sunset photo', 'A post revealing your pet name, birthday, or school mascot', 'A shared news link', 'A weather screenshot'],
        correctIndex: 1,
      ),
      QuizQuestion(
        prompt: 'If a profile impersonates a friend or brand, what should you do?',
        options: ['Send them your details to test them', 'Report the account and verify through official channels', 'Ignore all brand accounts forever', 'Post your password publicly'],
        correctIndex: 1,
      ),
    ],
  ),
];
