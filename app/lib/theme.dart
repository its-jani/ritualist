import 'package:flutter/material.dart';

/// Ritualist design tokens.
///
/// Canonical Duolingo parity palette (`replica-design` token extraction of
/// https://www.duolingo.com public layout patterns). Variable names are the
/// house style; the values are the reference brand ramp so every widget in
/// the app inherits the same surface hierarchy, ink weights and reward
/// accents. See docs/rea-duolingo-findings.md §5 for the mapping.
class RitualColors {
  const RitualColors._();

  // Brand: Owl Green. Primary CTA, correct states, active path nodes.
  static const Color jade = Color(0xFF58CC02);
  static const Color jadeLip = Color(0xFF58A700);
  static const Color jadeTint = Color(0xFFD7FFB8);
  static const Color jadeDeep = Color(0xFF45A402);

  // Info: Humpback Blue. Secondary action, links, sky accents.
  static const Color sky = Color(0xFF1CB0F6);
  static const Color skyLip = Color(0xFF1899D6);
  static const Color skyTint = Color(0xFFDDF4FF);

  // Reward: Streak Orange. Day streaks, XP, combo badges.
  static const Color amber = Color(0xFFFF9600);
  static const Color amberLip = Color(0xFFE08600);
  static const Color amberTint = Color(0xFFFFE7C4);

  // Violet: Gem Pink. Premium/currency accents.
  static const Color violet = Color(0xFFCE82FF);
  static const Color violetLip = Color(0xFFB05FDF);
  static const Color violetTint = Color(0xFFF6E5FF);

  // Rose / Cardinal Red: incorrect answers, hearts lost, destructive actions.
  static const Color rose = Color(0xFFFF4B4B);
  static const Color roseLip = Color(0xFFD33131);
  static const Color roseTint = Color(0xFFFFE0E0);
  static const Color roseInk = Color(0xFFB3261E);

  // Teal (unit band).
  static const Color teal = Color(0xFF00C4CC);
  static const Color tealLip = Color(0xFF00A2A9);
  static const Color tealTint = Color(0xFFDDF7F9);

  // Sun Orange (unit band).
  static const Color sun = Color(0xFFFFC800);
  static const Color sunLip = Color(0xFFE0A800);
  static const Color sunTint = Color(0xFFFFF3CC);

  // Neutrals — the reference app's Swan/Eel/Bea ramp.
  //
  // `ink` is the primary body text tone (Eel #4B4B4B). `bea` is the deep
  // display heading tone (Bea #042C60). `subInk` is muted body copy,
  // `faint` is UI-only. Contrast floors follow WCAG AA on the pure-white
  // canvas this theme now uses.
  static const Color ink = Color(0xFF4B4B4B);
  static const Color subInk = Color(0xFF777777);
  static const Color faint = Color(0xFFAFAFAF);

  /// Swan Border: the canonical hairline for cards, dividers and inactive
  /// chips. Always used with a solid 2px width via [BorderSide].
  static const Color line = Color(0xFFE5E5E5);

  /// Slightly heavier hairline for surfaces that need to hold their edge
  /// against a tinted background (feedback panel, selected chips).
  static const Color lineStrong = Color(0xFFD9D9D9);

  /// Canvas / Surface: pure white. Reference-app parity for the app scaffold
  /// and every interactive card face.
  static const Color bg = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  /// Deep display heading ink (Bea). Reserved for hero titles and screen
  /// headings; body copy keeps [ink].
  static const Color bea = Color(0xFF042C60);

  // Correct-answer feedback. `correctInk` is dark enough for AA body text
  // on `correctTint`; the brighter `correct` is for fills and borders.
  static const Color correct = Color(0xFF58CC02);
  static const Color correctLip = Color(0xFF58A700);
  static const Color correctTint = Color(0xFFD7FFB8);
  static const Color correctInk = Color(0xFF5A8213);

  /// Paper tint used behind a "why" callout inside feedback panels.
  static const Color paper = Color(0xFFFFFDF7);

  /// Flat grey surface used for locked path nodes. Combined with the 0.4
  /// opacity floor declared in [RitualShape.lockedOpacity].
  static const Color swanMuted = Color(0xFFE0E0E0);
  static const Color swanMutedLip = Color(0xFFC7C7C7);
}

/// Canonical geometry tokens. Every button, tile, card, chip and path node
/// in the app resolves its radii, border widths and lip depth through this
/// class so a shape change is a one-line edit.
class RitualShape {
  const RitualShape._();

  /// Radius for primary CTAs, secondary buttons, exercise tiles, cards and
  /// the results-screen shells (16px canonical).
  static const double radius = 16;

  /// Radius for compact chips, badges and key-caps.
  static const double radiusChip = 12;

  /// Solid border width on cards, exercise tiles and buttons.
  static const double borderWidth = 2;

  /// Depth of the 3D "lip" shadow under every chunky button, tile and card.
  /// Press states translate the surface down by exactly this many pixels and
  /// collapse the lip to zero, producing the gamepad-button feel.
  static const double lipDepth = 4;

  /// Deeper lip used on path nodes (they float higher than the cards).
  static const double nodeLipDepth = 6;

  /// Flat opacity applied to locked path nodes and disabled chrome.
  static const double lockedOpacity = 0.4;
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

/// Shared text styles. Duolingo-style shapes: heavy rounded headings, calm
/// body text, wide-tracked uppercase micro-labels. Display uses the deep
/// Bea ink; body uses the Eel ink.
class AppText {
  const AppText._();

  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: RitualColors.bea,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: RitualColors.bea,
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
      onSecondary: Colors.white,
      error: RitualColors.rose,
      onError: Colors.white,
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
    dividerTheme: const DividerThemeData(
      color: RitualColors.line,
      thickness: RitualShape.borderWidth,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: RitualColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(RitualShape.radius)),
        side: BorderSide(color: RitualColors.line, width: RitualShape.borderWidth),
      ),
    ),
  );
}

/// The signature 3-D "lip" shadow used on buttons, path nodes and cards:
/// a zero-blur drop of [lip] color under a [base]-colored rounded surface.
/// Defaults to the canonical 4px depth ([RitualShape.lipDepth]).
List<BoxShadow> lipShadow(Color lip, {double depth = RitualShape.lipDepth}) =>
    <BoxShadow>[
      BoxShadow(color: lip, offset: Offset(0, depth), blurRadius: 0),
    ];
