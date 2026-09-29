import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mk_ui/src/tokens.dart';

/// Design tokens that Material's [ColorScheme] has no slot for. Read them with
/// `MkTokens.of(context)`.
@immutable
class MkTokens extends ThemeExtension<MkTokens> {
  const MkTokens({
    required this.jama,
    required this.jamaTint,
    required this.udhaar,
    required this.udhaarTint,
    required this.gold,
    required this.goldText,
    required this.goldTint,
    required this.textBody,
    required this.textMuted,
    required this.textFaint,
    required this.border,
    required this.border2,
    required this.borderStrong,
    required this.divider,
    required this.rowHover,
    required this.field,
    required this.background2,
    required this.surfaceAlt,
    required this.sidebar,
    required this.sidebarText,
    required this.sidebarMuted,
    required this.sidebarHover,
    required this.sidebarDivider,
  });

  static const light = MkTokens(
    jama: MkColors.jama,
    jamaTint: MkColors.jamaTint,
    udhaar: MkColors.udhaar,
    udhaarTint: MkColors.udhaarTint,
    gold: MkColors.gold,
    goldText: MkColors.goldText,
    goldTint: MkColors.goldTint,
    textBody: MkColors.textBody,
    textMuted: MkColors.textMuted,
    textFaint: MkColors.textFaint,
    border: MkColors.border,
    border2: MkColors.border2,
    borderStrong: MkColors.borderStrong,
    divider: MkColors.divider,
    rowHover: MkColors.rowHover,
    field: MkColors.field,
    background2: MkColors.background2,
    surfaceAlt: MkColors.surfaceAlt,
    sidebar: MkColors.brandDark,
    sidebarText: MkColors.sidebarText,
    sidebarMuted: MkColors.sidebarMuted,
    sidebarHover: MkColors.brand2,
    sidebarDivider: MkColors.sidebarDivider,
  );

  /// Placeholder until the dark palette is designed.
  static const dark = MkTokens(
    jama: Color(0xFF6BBF93),
    jamaTint: Color(0xFF1E3A2D),
    udhaar: Color(0xFFE88E81),
    udhaarTint: Color(0xFF45241F),
    gold: MkColors.gold,
    goldText: MkColors.goldSoft,
    goldTint: Color(0xFF3A3020),
    textBody: Color(0xFFCBD3CC),
    textMuted: Color(0xFF9DA69C),
    textFaint: Color(0xFF7D857C),
    border: Color(0xFF2E3A33),
    border2: Color(0xFF28332D),
    borderStrong: Color(0xFF4A5A50),
    divider: Color(0xFF26302A),
    rowHover: Color(0xFF1C2621),
    field: Color(0xFF1A2420),
    background2: Color(0xFF151D19),
    surfaceAlt: Color(0xFF18211D),
    sidebar: Color(0xFF0E211A),
    sidebarText: MkColors.sidebarText,
    sidebarMuted: MkColors.sidebarMuted,
    sidebarHover: MkColors.brand2,
    sidebarDivider: MkColors.sidebarDivider,
  );

  final Color jama;
  final Color jamaTint;
  final Color udhaar;
  final Color udhaarTint;
  final Color gold;
  final Color goldText;
  final Color goldTint;
  final Color textBody;
  final Color textMuted;
  final Color textFaint;
  final Color border;
  final Color border2;
  final Color borderStrong;
  final Color divider;
  final Color rowHover;
  final Color field;
  final Color background2;
  final Color surfaceAlt;
  final Color sidebar;
  final Color sidebarText;
  final Color sidebarMuted;
  final Color sidebarHover;
  final Color sidebarDivider;

  static MkTokens of(BuildContext context) =>
      Theme.of(context).extension<MkTokens>() ?? light;

  @override
  MkTokens copyWith({
    Color? jama,
    Color? jamaTint,
    Color? udhaar,
    Color? udhaarTint,
    Color? gold,
    Color? goldText,
    Color? goldTint,
    Color? textBody,
    Color? textMuted,
    Color? textFaint,
    Color? border,
    Color? border2,
    Color? borderStrong,
    Color? divider,
    Color? rowHover,
    Color? field,
    Color? background2,
    Color? surfaceAlt,
    Color? sidebar,
    Color? sidebarText,
    Color? sidebarMuted,
    Color? sidebarHover,
    Color? sidebarDivider,
  }) {
    return MkTokens(
      jama: jama ?? this.jama,
      jamaTint: jamaTint ?? this.jamaTint,
      udhaar: udhaar ?? this.udhaar,
      udhaarTint: udhaarTint ?? this.udhaarTint,
      gold: gold ?? this.gold,
      goldText: goldText ?? this.goldText,
      goldTint: goldTint ?? this.goldTint,
      textBody: textBody ?? this.textBody,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      border: border ?? this.border,
      border2: border2 ?? this.border2,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      rowHover: rowHover ?? this.rowHover,
      field: field ?? this.field,
      background2: background2 ?? this.background2,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      sidebar: sidebar ?? this.sidebar,
      sidebarText: sidebarText ?? this.sidebarText,
      sidebarMuted: sidebarMuted ?? this.sidebarMuted,
      sidebarHover: sidebarHover ?? this.sidebarHover,
      sidebarDivider: sidebarDivider ?? this.sidebarDivider,
    );
  }

  @override
  MkTokens lerp(covariant MkTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return MkTokens(
      jama: l(jama, other.jama),
      jamaTint: l(jamaTint, other.jamaTint),
      udhaar: l(udhaar, other.udhaar),
      udhaarTint: l(udhaarTint, other.udhaarTint),
      gold: l(gold, other.gold),
      goldText: l(goldText, other.goldText),
      goldTint: l(goldTint, other.goldTint),
      textBody: l(textBody, other.textBody),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      border: l(border, other.border),
      border2: l(border2, other.border2),
      borderStrong: l(borderStrong, other.borderStrong),
      divider: l(divider, other.divider),
      rowHover: l(rowHover, other.rowHover),
      field: l(field, other.field),
      background2: l(background2, other.background2),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      sidebar: l(sidebar, other.sidebar),
      sidebarText: l(sidebarText, other.sidebarText),
      sidebarMuted: l(sidebarMuted, other.sidebarMuted),
      sidebarHover: l(sidebarHover, other.sidebarHover),
      sidebarDivider: l(sidebarDivider, other.sidebarDivider),
    );
  }
}

/// Text styles that sit outside Material's [TextTheme].
abstract final class MkText {
  /// Monospaced digits for every number and money value.
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: MkFonts.mono,
      fontFamilyFallback: MkFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: size >= 20 ? -0.5 : 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Small uppercase label above a stat or table column.
  static TextStyle caps(Color color) => TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    color: color,
  );
}

/// Whether the current platform is touch-first, where every tap target must be
/// at least 48 px.
bool mkIsTouch(BuildContext context) {
  return switch (Theme.of(context).platform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => true,
    TargetPlatform.windows ||
    TargetPlatform.macOS ||
    TargetPlatform.linux => false,
  };
}

/// Builds the app's [ThemeData].
abstract final class MkTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    tokens: MkTokens.light,
    background: MkColors.background,
    surface: MkColors.surface,
    onSurface: MkColors.textPrimary,
  );

  /// Stub: usable, but not yet designed. Only light is shipped for now.
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    tokens: MkTokens.dark,
    background: const Color(0xFF111814),
    surface: const Color(0xFF18211D),
    onSurface: const Color(0xFFE8EFE9),
  );

  static ThemeData _build({
    required Brightness brightness,
    required MkTokens tokens,
    required Color background,
    required Color surface,
    required Color onSurface,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: MkColors.brand,
          brightness: brightness,
        ).copyWith(
          primary: MkColors.brand,
          onPrimary: Colors.white,
          secondary: MkColors.gold,
          onSecondary: MkColors.brandDark,
          error: tokens.udhaar,
          surface: surface,
          onSurface: onSurface,
          outline: tokens.border,
          outlineVariant: tokens.border2,
        );

    final text = _textTheme(onSurface, tokens);
    final radius = BorderRadius.circular(MkRadius.md);
    final isTouch = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: MkFonts.sans,
      fontFamilyFallback: MkFonts.fallback,
      textTheme: text,
      materialTapTargetSize: isTouch
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap,
      visualDensity: isTouch ? VisualDensity.standard : VisualDensity.compact,
      dividerTheme: DividerThemeData(
        color: tokens.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: !isTouch,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        hintStyle: TextStyle(color: tokens.textFaint, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: MkColors.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.udhaar),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: tokens.udhaar, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MkColors.brandDark,
        contentTextStyle: const TextStyle(
          color: MkColors.sidebarText,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MkRadius.lg),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: MkColors.brandDark,
          borderRadius: BorderRadius.circular(MkRadius.sm),
        ),
        textStyle: const TextStyle(color: MkColors.sidebarText, fontSize: 12),
      ),
      extensions: [tokens],
    );
  }

  static TextTheme _textTheme(Color primary, MkTokens tokens) {
    TextStyle s(double size, FontWeight weight, {Color? color, double? ls}) =>
        TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color ?? primary,
          letterSpacing: ls,
          height: 1.3,
        );
    return TextTheme(
      displaySmall: s(27, FontWeight.w600, ls: -0.6),
      headlineSmall: s(20, FontWeight.w600, ls: -0.3),
      titleLarge: s(15, FontWeight.w600, ls: -0.15),
      titleMedium: s(13.5, FontWeight.w600),
      titleSmall: s(12.5, FontWeight.w600),
      bodyLarge: s(14, FontWeight.w400),
      bodyMedium: s(13, FontWeight.w400),
      bodySmall: s(11.5, FontWeight.w400, color: tokens.textMuted),
      labelLarge: s(12.5, FontWeight.w600),
      labelMedium: s(12, FontWeight.w500),
      labelSmall: s(10.5, FontWeight.w600, color: tokens.textFaint, ls: 0.7),
    );
  }
}
