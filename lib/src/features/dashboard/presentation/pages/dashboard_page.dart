import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../auth/application/auth_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 900;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aman Hamidsha © 2025',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/sim/email'),
                        child: Ink(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F73F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mail_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const ThemeToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Welcome back.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(child: wide ? const _WideLayout() : const _NarrowLayout()),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                          },
                          icon: const Icon(Icons.logout, size: 34),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.settings_outlined, size: 38),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _SectionTitle('Lessons  📖'),
        const SizedBox(height: 10),
        _LessonCard(onQuizTap: () => context.go('/quiz')),
        const SizedBox(height: 18),
        const _SectionTitle('Streak  🔥'),
        const SizedBox(height: 10),
        const _SquareStatCard(title: '12 days'),
        const SizedBox(height: 18),
        const _SectionTitle('Simulators'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SimButton(
                label: 'E-Mail',
                icon: Icons.mail_outline,
                onTap: () => context.go('/sim/email'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SimButton(
                label: 'SMS',
                icon: Icons.chat_bubble_outline,
                onTap: () => context.go('/sim/sms'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Lessons  📖'),
              const SizedBox(height: 10),
              Expanded(child: _LessonCard(onQuizTap: () => context.go('/quiz'))),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Streak  🔥'),
              const SizedBox(height: 10),
              const _SquareStatCard(title: '12 days'),
              const SizedBox(height: 18),
              const _SectionTitle('Simulators'),
              const SizedBox(height: 10),
              _SimButton(
                label: 'E-Mail',
                icon: Icons.mail_outline,
                onTap: () => context.go('/sim/email'),
              ),
              const SizedBox(height: 12),
              _SimButton(
                label: 'SMS',
                icon: Icons.chat_bubble_outline,
                onTap: () => context.go('/sim/sms'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white.withOpacity(0.48),
        height: 1,
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.onQuizTap});

  final VoidCallback onQuizTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3C86),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Last Lesson',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.45),
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF66AFFF).withOpacity(0.78),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Text(
                      'Common Themes\nin Phishing\nEmails',
                      style: TextStyle(
                        color: Color(0xFF2D588F),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onQuizTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 165,
                    decoration: BoxDecoration(
                      color: const Color(0xFF679FDC),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Text(
                      'Quiz\n✏️',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.53),
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Lessons Completed: 26/60',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: 26 / 60,
              minHeight: 12,
              backgroundColor: const Color(0xFFB4CCE6),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF337FDB)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareStatCard extends StatelessWidget {
  const _SquareStatCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF0A3C86),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.48),
          ),
        ),
      ),
    );
  }
}

class _SimButton extends StatelessWidget {
  const _SimButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF0A3C86),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.48),
                height: 1,
              ),
            ),
            Icon(icon, size: 36, color: const Color(0xFF0A1A30)),
          ],
        ),
      ),
    );
  }
}
