import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_icons.dart';

const _darkBg = Color(0xFF02123D);
const _darkCard = Color(0xFF0A3C86);
const _darkCardSoft = Color(0xFF0B4AA3);
const _darkAccent = Color(0xFF6FA8FF);
const _darkSurfaceAlt = Color(0xFF10214A);

const _lightBg = Color(0xFFF4F8FF);
const _lightCard = Color(0xFFFFFFFF);
const _lightCardSoft = Color(0xFFDDEBFF);
const _lightAccent = Color(0xFF2B6DDB);
const _lightSurfaceAlt = Color(0xFFE7F0FF);

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.dark) {
    _load();
  }

  static const String _storageKey = 'app_theme_mode_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    state = switch (stored) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_storageKey, value);
  }
}

List<BoxShadow> appShadows(bool isDark) => <BoxShadow>[
  BoxShadow(
    color: isDark
        ? Colors.black.withValues(alpha: 0.24)
        : const Color(0xFF8CA7D1).withValues(alpha: 0.22),
    blurRadius: isDark ? 34 : 26,
    offset: const Offset(0, 16),
  ),
];

final appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBg,
  colorScheme: const ColorScheme.dark(
    surface: _darkCard,
    primary: _darkAccent,
    secondary: Color(0xFF8BC4FF),
    onPrimary: Color(0xFF041938),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontSize: 16, height: 1.45),
  ),
  cardTheme: CardThemeData(
    color: _darkSurfaceAlt,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkCardSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _darkAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkAccent,
      foregroundColor: const Color(0xFF041938),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      backgroundColor: Colors.white.withValues(alpha: 0.04),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _darkSurfaceAlt,
    selectedColor: _darkAccent,
    secondarySelectedColor: _darkAccent,
    disabledColor: Colors.white.withValues(alpha: 0.06),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    },
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: _darkSurfaceAlt,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    contentTextStyle: const TextStyle(color: Colors.white),
  ),
  dividerColor: Colors.white.withValues(alpha: 0.08),
  splashFactory: InkRipple.splashFactory,
);

final appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightBg,
  colorScheme: const ColorScheme.light(
    surface: _lightCard,
    primary: _lightAccent,
    secondary: Color(0xFF68A7FF),
    onPrimary: Colors.white,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontSize: 16, height: 1.45),
  ),
  cardTheme: CardThemeData(
    color: _lightCard,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightCardSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD4E0F3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _lightAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF17376C),
      side: const BorderSide(color: Color(0xFFD0DCF0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      backgroundColor: _lightSurfaceAlt,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _lightSurfaceAlt,
    selectedColor: _lightAccent,
    secondarySelectedColor: _lightAccent,
    disabledColor: const Color(0xFFF1F5FC),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    side: const BorderSide(color: Color(0xFFD8E2F4)),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    },
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    contentTextStyle: const TextStyle(color: Color(0xFF17376C)),
  ),
  dividerColor: const Color(0xFFDCE5F3),
  splashFactory: InkRipple.splashFactory,
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
        ref
            .read(themeModeProvider.notifier)
            .setMode(isDark ? ThemeMode.light : ThemeMode.dark);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 64,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary, width: 2),
          boxShadow: appShadows(isDark),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: AppSvgIcon(
              isDark ? AppIcons.sun : AppIcons.moon,
              key: ValueKey<bool>(isDark),
              color: colorScheme.primary,
              size: 20,
              semanticLabel: isDark
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
            ),
          ),
        ),
      ),
    );
  }
}
