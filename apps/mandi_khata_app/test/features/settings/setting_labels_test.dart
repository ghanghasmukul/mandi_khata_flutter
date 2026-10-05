import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/features/settings/presentation/settings_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

/// A new key in khata_core's schema must come with en / hi / pa labels
/// (CLAUDE.md rule 12); the label helpers fall back to the raw key, which
/// this catches.
void main() {
  for (final lang in ['en', 'hi', 'pa']) {
    group(lang, () {
      final l10n = lookupAppLocalizations(Locale(lang));

      test('every key has a label', () {
        for (final def in SettingsSchema.visible) {
          expect(l10n.settingLabel(def.key), isNot(def.key), reason: def.key);
        }
      });

      test('every choice has a label', () {
        for (final def in SettingsSchema.visible) {
          for (final o in def.options ?? const <String>[]) {
            expect(
              l10n.settingOption(def.key, o),
              isNot('${def.key}=$o'),
              reason: '${def.key}=$o',
            );
          }
        }
      });

      test('every fixed suffix has a label', () {
        for (final def in SettingsSchema.visible) {
          for (final s in def.suffixValues ?? const <String>[]) {
            expect(
              l10n.settingSuffix(def.suffixName!, s),
              isNot('${def.suffixName}=$s'),
              reason: '${def.key}.$s',
            );
          }
        }
      });

      test('every group has a title', () {
        for (final scope in [SettingScope.tenant, SettingScope.party]) {
          for (final g in settingEntriesFor(scope).keys) {
            expect(l10n.settingGroup(g), isNot(g), reason: g);
          }
        }
      });
    });
  }

  test('party level offers interest, mandi and the credit limit only', () {
    final groups = settingEntriesFor(SettingScope.party);
    expect(groups.keys.toSet(), {'interest', 'mandi', 'business'});
    expect(groups['business']!.map((e) => e.def.key), [
      'business.credit_limit',
    ]);
  });
}
