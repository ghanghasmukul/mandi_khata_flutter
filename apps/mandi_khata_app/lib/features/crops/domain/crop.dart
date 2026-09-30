import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// A crop of the business's crops master.
@immutable
class Crop {
  const Crop({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.unit,
    required this.sortOrder,
    required this.isActive,
    this.nameHi,
    this.namePa,
    this.stdRate,
  });

  factory Crop.fromRow(Map<String, Object?> r) => Crop(
    id: r['id']! as String,
    code: r['code']! as String,
    nameEn: r['name_en']! as String,
    nameHi: r['name_hi'] as String?,
    namePa: r['name_pa'] as String?,
    unit: (r['unit'] as String?) ?? 'qtl',
    stdRate: switch (r['msp_or_std_rate']) {
      final int p => Money(p),
      _ => null,
    },
    sortOrder: (r['sort_order'] as int?) ?? 0,
    // Synced booleans are 0/1 locally.
    isActive: r['is_active'] != 0 && r['is_active'] != false,
  );

  final String id;

  /// Also the suffix of per-crop settings (`mandi.commission_pct.<code>`).
  final String code;
  final String nameEn;
  final String? nameHi;
  final String? namePa;
  final String unit;

  /// MSP or usual rate per [unit]; a reference, not a lot's rate.
  final Money? stdRate;
  final int sortOrder;
  final bool isActive;

  /// The name in [languageCode], falling back to English.
  String nameIn(String languageCode) {
    final local = switch (languageCode) {
      'hi' => nameHi,
      'pa' => namePa,
      _ => null,
    };
    return local == null || local.trim().isEmpty ? nameEn : local;
  }

  CropInput toInput() => CropInput(
    code: code,
    nameEn: nameEn,
    nameHi: nameHi,
    namePa: namePa,
    stdRate: stdRate,
    isActive: isActive,
  );
}

/// What the add / edit form submits.
@immutable
class CropInput {
  const CropInput({
    required this.code,
    required this.nameEn,
    this.nameHi,
    this.namePa,
    this.stdRate,
    this.isActive = true,
  });

  final String code;
  final String nameEn;
  final String? nameHi;
  final String? namePa;
  final Money? stdRate;
  final bool isActive;

  static String? _clean(String? s) {
    final t = s?.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t == null || t.isEmpty ? null : t;
  }

  CropInput normalised() => CropInput(
    code: code.trim(),
    nameEn: _clean(nameEn) ?? '',
    nameHi: _clean(nameHi),
    namePa: _clean(namePa),
    stdRate: stdRate,
    isActive: isActive,
  );

  /// Problems with the (normalised) input; empty when valid.
  Set<CropFieldError> validate() {
    final n = normalised();
    return {
      if (!CropRules.isValidCode(n.code)) CropFieldError.code,
      if (n.nameEn.isEmpty) CropFieldError.nameEn,
      if (n.stdRate != null && n.stdRate!.isNegative) CropFieldError.stdRate,
    };
  }

  /// Columns written to `crops` (besides id, tenant, sort, audit columns).
  Map<String, Object?> columns() {
    final n = normalised();
    return {
      'code': n.code,
      'name_en': n.nameEn,
      'name_hi': n.nameHi,
      'name_pa': n.namePa,
      'msp_or_std_rate': n.stdRate?.paise,
      'is_active': n.isActive ? 1 : 0,
    };
  }
}

enum CropFieldError { code, nameEn, stdRate }

/// Result of a crop write.
sealed class CropSaveResult {
  const CropSaveResult();
}

final class CropSaved extends CropSaveResult {
  const CropSaved(this.id);

  final String id;
}

final class CropInvalid extends CropSaveResult {
  const CropInvalid(this.errors);

  final Set<CropFieldError> errors;
}

final class CropCodeTaken extends CropSaveResult {
  const CropCodeTaken();
}

final class CropNotFound extends CropSaveResult {
  const CropNotFound();
}

final class CropNotPermitted extends CropSaveResult {
  const CropNotPermitted();
}
