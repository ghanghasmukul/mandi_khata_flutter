import 'package:flutter/widgets.dart';

/// Colour tokens from the prototype in `design/Mandi_Khata.html`.
abstract final class MkColors {
  // Brand
  static const brandDark = Color(0xFF173B2C);
  static const brand = Color(0xFF2F7A56);
  static const brand2 = Color(0xFF245440);
  static const brandHover = Color(0xFF256546);
  static const gold = Color(0xFFD4A140);
  static const goldSoft = Color(0xFFE9C46A);
  static const goldText = Color(0xFF9C7425);
  static const goldTint = Color(0xFFFBF3E0);

  // Surfaces
  static const background = Color(0xFFF4F2EA);
  static const background2 = Color(0xFFF7F5EC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFFCFBF6);
  static const field = Color(0xFFF5F3EA);
  static const border = Color(0xFFE7E4D6);
  static const border2 = Color(0xFFEDEADF);
  static const borderStrong = Color(0xFFC4BFA8);
  static const divider = Color(0xFFEFEDE2);
  static const rowHover = Color(0xFFFAF8F1);

  // Text
  static const textPrimary = Color(0xFF1A231D);
  static const textBody = Color(0xFF424A40);
  static const textMuted = Color(0xFF6A6F62);
  static const textFaint = Color(0xFF8C8F80);

  /// Credit to the party — we owe them. Positive balance.
  static const jama = Color(0xFF2F7A56);
  static const jamaTint = Color(0xFFE6F1EA);

  /// Debit to the party — they owe us. Negative balance.
  static const udhaar = Color(0xFFCF6A5C);
  static const udhaarTint = Color(0xFFFDEFED);

  // Sidebar (on brandDark)
  static const sidebarText = Color(0xFFE8EFE9);
  static const sidebarMuted = Color(0xFF9DB8A8);
  static const sidebarItem = Color(0xFFC4D6C9);
  static const sidebarDivider = Color(0xFF1D4534);
  static const sidebarAvatar = Color(0xFF275743);

  // Sync status dot
  static const synced = Color(0xFF44A06F);
  static const Color pending = gold;

  /// Modal barrier behind dialogs and drawers.
  static const scrim = Color(0x6B0F281E);
}

/// Spacing scale in logical pixels.
abstract final class MkSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

/// Corner radius scale.
abstract final class MkRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;

  /// Fully rounded pills (chips, badges).
  static const pill = 999.0;
}

/// Shadow presets.
abstract final class MkShadows {
  static const card = [
    BoxShadow(color: Color(0x0A173B2C), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x24173B2C),
      offset: Offset(0, 14),
      blurRadius: 34,
      spreadRadius: -14,
    ),
  ];

  static const overlay = [
    BoxShadow(color: Color(0x4D0F281E), offset: Offset(0, 24), blurRadius: 60),
  ];

  static const toast = [
    BoxShadow(color: Color(0x470F281E), offset: Offset(0, 12), blurRadius: 30),
  ];
}

/// Bundled font families. Everything works offline — no runtime downloads.
abstract final class MkFonts {
  static const _package = 'packages/mk_ui';

  /// UI text.
  static const sans = '$_package/IBMPlexSans';

  /// All numbers and money.
  static const mono = '$_package/IBMPlexMono';

  /// Hindi and Punjabi glyphs, picked up automatically through fallback.
  static const fallback = [
    '$_package/NotoSansDevanagari',
    '$_package/NotoSansGurmukhi',
  ];
}

/// Layout breakpoints for `MkAppShell`.
abstract final class MkBreakpoints {
  /// At or above this width the full sidebar is shown.
  static const sidebar = 1000.0;

  /// At or above this width (and below [sidebar]) a navigation rail is shown;
  /// below it, a bottom navigation bar.
  static const rail = 600.0;
}
