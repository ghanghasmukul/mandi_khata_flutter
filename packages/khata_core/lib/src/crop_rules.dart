/// Rules for the crops master (`crops` table).
///
/// A crop's code is also the suffix of its per-crop settings
/// (`mandi.commission_pct.<code>`), so it must be a settings identifier and
/// can never change once the crop exists.
abstract final class CropRules {
  static const maxCodeLength = 24;

  static final _code = RegExp(r'^[a-z][a-z0-9_]*$');

  /// Units a crop can be weighed in. Quintal only for now.
  static const units = ['qtl'];

  static bool isValidCode(String code) =>
      code.length <= maxCodeLength && _code.hasMatch(code);

  /// A code made from an English name: "Paddy PR-126" → `paddy_pr_126`.
  /// Empty if the name has no usable letters (the user must type one).
  static String suggestCode(String nameEn) {
    final words = nameEn
        .toLowerCase()
        .split(RegExp('[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    // Must start with a letter.
    while (words.isNotEmpty && !RegExp('^[a-z]').hasMatch(words.first)) {
      words.removeAt(0);
    }
    var code = words.join('_');
    if (code.length > maxCodeLength) {
      code = code.substring(0, maxCodeLength).replaceAll(RegExp(r'_+$'), '');
    }
    return code;
  }
}
