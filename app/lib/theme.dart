import 'package:flutter/material.dart';

/// Ritualist design tokens.
///
/// Original palette (NOT Duolingo's): the same *relationships* the REA study
/// found in the reference app - a brand base plus a darker "lip" shade for the
/// signature 3-D button edge, a neutral ramp, one alert red, one reward amber -
/// but with our own values and names. See docs/rea-duolingo-findings.md §5.
class RitualColors {
  const RitualColors._();

  // Brand: jade green.
  static const Color jade = Color(0xFF2FB584);
  static const Color jadeLip = Color(0xFF279A70);
  static const Color jadeTint = Color(0xFFE4F8F0);
  static const Color jadeDeep = Color(0xFF1B6B4F);

  // Info: sky blue.
  static const Color sky = Color(0xFF3AA8E0);
  static const Color skyLip = Color(0xFF2E8AB8);
  static const Color skyTint = Color(0xFFE3F4FC);

  // Reward: amber (streak, XP).
  static const Color amber = Color(0xFFFFB300);
  static const Color amberLip = Color(0xFFD99700);
  static const Color amberTint = Color(0xFFFFF3D4);

  // Violet (units).
  static const Color violet = Color(0xFF8C6FE6);
  static const Color violetLip = Color(0xFF7159C4);
  static const Color violetTint = Color(0xFFEFEAFB);

  // Rose / alert red.
  static const Color rose = Color(0xFFE5484D);
  static const Color roseLip = Color(0xFFC93A3F);
  static const Color roseTint = Color(0xFFFFE3E4);
  static const Color roseInk = Color(0xFFB3261E);

  // Teal (units).
  static const Color teal = Color(0xFF2CB9C7);
  static const Color tealLip = Color(0xFF239AA6);
  static const Color tealTint = Color(0xFFE2F7F9);

  // Sun orange (units).
  static const Color sun = Color(0xFFFF8A3D);
  static const Color sunLip = Color(0xFFD97230);
  static const Color sunTint = Color(0xFFFFEFE3);

  // Neutrals.
  //
  // Contrast floor is WCAG AA on the app's own surfaces: `subInk` carries body
  // copy (>= 4.7:1 on bg), `faint` is UI-only (>= 3:1) and never body text.
  static const Color ink = Color(0xFF3C3C3C);
  static const Color subInk = Color(0xFF6E6E6E);
  static const Color faint = Color(0xFF9A9A9A);
  static const Color line = Color(0xFFE5E5E5);

  /// Slightly heavier hairline for surfaces that need to hold their edge
  /// against a tinted background (feedback panel, selected chips).
  static const Color lineStrong = Color(0xFFD6D6D6);
  static const Color bg = Color(0xFFF7F7F9);
  static const Color card = Color(0xFFFFFFFF);

  // Correct-answer feedback. `correctInk` is dark enough for AA body text
  // on `correctTint` (5.8:1); the brighter `correct` is for fills and borders.
  static const Color correct = Color(0xFF4CAF50);
  static const Color correctLip = Color(0xFF3B8C3E);
  static const Color correctTint = Color(0xFFE9F9E5);
  static const Color correctInk = Color(0xFF2E6B31);

  /// Paper tint used behind a "why" callout inside feedback panels.
  static const Color paper = Color(0xFFFFFDF7);
}

/// One unit's band colors, derived from its `colorIndex` (manifest rotation).
class UnitPalette {
  const UnitPalette({
    required this.base,
    required this.lip,
    required this.tint,
  });

  final Color base;
  final Color lip;
  final Color tint;

  static const List<UnitPalette> _rotation = <UnitPalette>[
    UnitPalette(base: RitualColors.jade, lip: RitualColors.jadeLip, tint: RitualColors.jadeTint),
    UnitPalette(base: RitualColors.sky, lip: RitualColors.skyLip, tint: RitualColors.skyTint),
    UnitPalette(base: RitualColors.violet, lip: RitualColors.violetLip, tint: RitualColors.violetTint),
    UnitPalette(base: RitualColors.sun, lip: RitualColors.sunLip, tint: RitualColors.sunTint),
    UnitPalette(base: RitualColors.rose, lip: RitualColors.roseLip, tint: RitualColors.roseTint),
    UnitPalette(base: RitualColors.teal, lip: RitualColors.tealLip, tint: RitualColors.tealTint),
  ];

  static UnitPalette of(int colorIndex) =>
      _rotation[colorIndex.abs() % _rotation.length];
}

/// Shared text styles. Duolingo-style shapes with our own values: heavy
/// rounded headings, calm body text, wide-tracked uppercase micro-labels.
class AppText {
  const AppText._();

  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: RitualColors.ink,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: RitualColors.ink,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: RitualColors.ink,
    height: 1.45,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: RitualColors.subInk,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: RitualColors.subInk,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    color: RitualColors.subInk,
    letterSpacing: 0.9,
  );

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
  );

  static const TextStyle arabic = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: RitualColors.ink,
    height: 1.6,
  );
}

/// Builds the global light theme. Dark mode is deliberately out of scope for
/// V1 (keeps the color-token surface small); see docs/architecture.md.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: RitualColors.bg,
    colorScheme: const ColorScheme.light(
      primary: RitualColors.jade,
      onPrimary: Colors.white,
      secondary: RitualColors.amber,
      onSecondary: RitualColors.ink,
      error: RitualColors.rose,
      surface: RitualColors.card,
      onSurface: RitualColors.ink,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: RitualColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppText.title,
      iconTheme: IconThemeData(color: RitualColors.subInk),
    ),
    dividerTheme: const DividerThemeData(color: RitualColors.line, thickness: 1),
    dialogTheme: const DialogThemeData(
      backgroundColor: RitualColors.card,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

/// The signature 3-D "lip" shadow used on buttons, path nodes and cards:
/// a zero-blur drop of [lip] color under a [base]-colored rounded surface.
List<BoxShadow> lipShadow(Color lip, {double depth = 4}) => <BoxShadow>[
      BoxShadow(color: lip, offset: Offset(0, depth), blurRadius: 0),
    ];
