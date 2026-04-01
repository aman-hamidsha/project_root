import 'package:flutter/material.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';
import '../../domain/dashboard_social_data.dart';

void showActivityCelebration(BuildContext context, ActivityAward? award) {
  if (award == null || !award.shouldCelebrate) {
    return;
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final iconAsset = award.unlockedStreakDay ? AppIcons.fire : AppIcons.sparkles;
  final accentColor = award.unlockedStreakDay
      ? const Color(0xFFFF8A3D)
      : const Color(0xFF2A74EE);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1A32) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.42),
              width: 2,
            ),
            boxShadow: appShadows(isDark),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AppSvgIcon(
                    iconAsset,
                    color: accentColor,
                    size: 22,
                    semanticLabel: award.headline,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      award.headline,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF17376C),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      award.message,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.74)
                            : const Color(0xFF4D6EA2),
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '+${award.xpEarned} XP',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
