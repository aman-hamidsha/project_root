import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/*
 * this file centralizes the svg asset paths used across the app and provides
 * a small wrapper widget for rendering them with consistent color and sizing.
 */

class AppIcons {
  const AppIcons._();

  // keeping icon asset paths here avoids hardcoding string paths throughout
  // the ui and makes future asset swaps much simpler.
  static const String arrowLeft = 'assets/icons/arrow-left.svg';
  static const String sun = 'assets/icons/sun.svg';
  static const String moon = 'assets/icons/moon.svg';
  static const String bookOpen = 'assets/icons/book-open.svg';
  static const String envelope = 'assets/icons/envelope.svg';
  static const String chatBubble = 'assets/icons/chat-bubble-left-right.svg';
  static const String banknotes = 'assets/icons/banknotes.svg';
  static const String wifi = 'assets/icons/wifi.svg';
  static const String trophy = 'assets/icons/trophy.svg';
  static const String fire = 'assets/icons/fire.svg';
  static const String info = 'assets/icons/information-circle.svg';
  static const String eye = 'assets/icons/eye.svg';
  static const String shieldAlert = 'assets/icons/shield-exclamation.svg';
  static const String sparkles = 'assets/icons/sparkles.svg';
  static const String settings = 'assets/icons/cog-6-tooth.svg';
  static const String signOut = 'assets/icons/arrow-right-on-rectangle.svg';
}

/**
 * this widget renders one svg icon from the app asset set.
 * it wraps SvgPicture.asset so pages can use the same icon api everywhere.
 */
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.asset, {
    super.key,
    required this.color,
    this.size = 20,
    this.semanticLabel,
  });

  final String asset;
  final Color color;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // a color filter is used so the same svg asset can be tinted differently
    // across dark mode, light mode, and status-specific ui.
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );
  }
}
