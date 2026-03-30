import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _darkBg = Color(0xFF02123D);
const _darkCard = Color(0xFF0A3C86);
const _darkCardSoft = Color(0xFF0B4AA3);
const _darkAccent = Color(0xFF6FA8FF);

const _lightBg = Color(0xFFF4F8FF);
const _lightCard = Color(0xFFFFFFFF);
const _lightCardSoft = Color(0xFFDDEBFF);
const _lightAccent = Color(0xFF2B6DDB);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBg,
  colorScheme: const ColorScheme.dark(
    surface: _darkCard,
    primary: _darkAccent,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkCardSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkAccent,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    ),
  ),
);

final appLightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightBg,
  colorScheme: const ColorScheme.light(
    surface: _lightCard,
    primary: _lightAccent,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightCardSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    ),
  ),
);

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode != ThemeMode.light;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).state =
            isDark ? ThemeMode.light : ThemeMode.dark;
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary,
            width: 3,
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
