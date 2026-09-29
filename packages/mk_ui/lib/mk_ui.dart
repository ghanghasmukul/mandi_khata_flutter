/// Mandi Khata design system: colour and spacing tokens, theme and the shared
/// widgets every screen is built from. Built out in step 0.2.
library;

import 'package:flutter/material.dart';

/// Brand colours taken from the prototype in `design/Mandi_Khata.html`.
abstract final class MkColors {
  static const brandDark = Color(0xFF173B2C);
  static const brand = Color(0xFF2F7A56);
  static const gold = Color(0xFFD4A140);
  static const background = Color(0xFFF4F2EA);
  static const surface = Color(0xFFFFFFFF);

  /// Money owed to us by the party.
  static const udhaar = Color(0xFFCF6A5C);

  /// Money we owe the party.
  static const jama = Color(0xFF2F7A56);
}
