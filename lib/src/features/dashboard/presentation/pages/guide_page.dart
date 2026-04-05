import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';

/**
 * This page is meant to be a quick-start guide for how the app is designed to be used. 
 * It is not a comprehensive manual, but rather a high-level overview of the intended study
 *  flow and how the different features fit together.
 *
 * The main goal is to help users understand the best way to use the app to learn effectively
 * , rather than just listing out features or instructions. 
 * It should set expectations for how the lessons, quizzes, and simulators
 *  work together as a training loop.
 *
 * The content is organized into sections that walk through 
 * the ideal study path, with tips on how to get the most out of
 *  each part of the app. The tone is encouraging and focused on learning, 
 * rather than just technical instructions.
 */
class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

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
                ? const <Color>[Color(0xFF04153E), Color(0xFF08255E)]
                : const <Color>[Color(0xFFF7FAFF), Color(0xFFEAF2FF)],
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
                  'Instructional Guide',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This page walks through how the app is designed to be used: learn the theory, practice the topic, test yourself, and then apply that thinking in the simulators.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    children: const [
                      _GuideHeroCard(),
                      SizedBox(height: 16),
                      _GuideSectionCard(
                        title: '1. Start On The Dashboard',
                        points: [
                          'The dashboard is the home base. It should help you resume the last lesson you touched, check your overall lesson progress, and jump into a simulator quickly.',
                          'Use the larger lesson card first if you want structured study, or use the simulator cards when you want scenario practice.',
                          'The Settings page controls appearance and local learning data, while the Guide page explains the intended study flow.',
                        ],
                      ),
                      SizedBox(height: 14),
                      _GuideSectionCard(
                        title: '2. Work Through Lessons First',
                        points: [
                          'Each lesson teaches the theory behind one topic area such as phishing, public Wi-Fi safety, or emerging scams.',
                          'A lesson is not just reading material. It also includes a fill-in-the-blank activity and a mix-and-match check to help reinforce the ideas.',
                          'Your lesson progress bar should move when you read, complete the checks, and continue across modules.',
                        ],
                      ),
                      SizedBox(height: 14),
                      _GuideSectionCard(
                        title: '3. Use Quizzes To Measure Recall',
                        points: [
                          'Topic quizzes pull from question banks so each run can reinforce what you have seen and surface weaker areas again later.',
                          'Quiz scores tell you how well you remembered the topic, but they are most useful when paired with the lesson content and simulator feedback.',
                          'If a topic still feels shaky after a quiz, return to the related lesson instead of guessing repeatedly.',
                        ],
                      ),
                      SizedBox(height: 14),
                      _GuideSectionCard(
                        title: '4. Practice In The Simulators',
                        points: [
                          'The simulators are where the theory becomes practical judgment. They are designed to slow you down and make you think through realistic choices.',
                          'SMS and Email ask you to choose actions and write what you would say. Crypto and Wi-Fi train you to spot warning signs before committing to a risky choice.',
                          'When a simulator shows a bad outcome, focus on the reasoning it gives you. The goal is to learn the pattern, not just chase the right answer.',
                        ],
                      ),
                      SizedBox(height: 14),
                      _GuideSectionCard(
                        title: '5. Best Study Path',
                        points: [
                          'A strong default path is Lesson -> Quiz -> Simulator. That order builds theory first, then tests memory, then applies the skill.',
                          'If you are short on time, finish one complete topic rather than skimming everything at once.',
                          'Revisit the guide and settings occasionally so the app still matches how you want to study.',
                        ],
                      ),
                      SizedBox(height: 14),
                      _GuideSectionCard(
                        title: '6. Security Habits The App Keeps Reinforcing',
                        points: [
                          'Verify through trusted channels instead of trusting urgency.',
                          'Treat open Wi-Fi, fake support requests, and guaranteed returns as situations that deserve extra caution.',
                          'Prefer boring, verifiable signals over hype, pressure, and convenience when a decision affects money or account access.',
                        ],
                      ),
                    ],
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

class _GuideHeroCard extends StatelessWidget {
  const _GuideHeroCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const <Color>[Color(0xFF0B3B84), Color(0xFF2A74EE)]
              : const <Color>[Color(0xFF2A74EE), Color(0xFF7CB4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: appShadows(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              AppSvgIcon(
                AppIcons.bookOpen,
                color: Colors.white,
                size: 22,
                semanticLabel: 'Guide',
              ),
              SizedBox(width: 10),
              Text(
                'How This App Is Meant To Be Used',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Think of the app as a training loop: read the lesson, test the topic bank, then practice the same ideas in a realistic simulator.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  const _GuideSectionCard({required this.title, required this.points});

  final String title;
  final List<String> points;

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
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F73EA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.76)
                            : const Color(0xFF4B6694),
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
        ],
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
