import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Add a crop ([crop] null) or edit one. Returns the saved crop id, or null
/// when cancelled. Enter saves; the code follows the English name until it
/// is typed by hand, and is fixed once the crop exists.
class CropFormDialog extends ConsumerStatefulWidget {
  const CropFormDialog({this.crop, super.key});

  final Crop? crop;

  static Future<String?> show(BuildContext context, {Crop? crop}) =>
      showDialog<String>(
        context: context,
        barrierColor: MkColors.scrim,
        builder: (_) => CropFormDialog(crop: crop),
      );

  @override
  ConsumerState<CropFormDialog> createState() => _CropFormDialogState();
}

class _CropFormDialogState extends ConsumerState<CropFormDialog> {
  late final Crop? _crop = widget.crop;
  late final _nameEn = TextEditingController(text: _crop?.nameEn);
  late final _nameHi = TextEditingController(text: _crop?.nameHi);
  late final _namePa = TextEditingController(text: _crop?.namePa);
  late final _code = TextEditingController(text: _crop?.code);
  late Money? _rate = _crop?.stdRate;
  late bool _active = _crop?.isActive ?? true;

  /// The code was typed by hand, so the name no longer fills it.
  bool _codeTouched = false;
  Set<CropFieldError> _errors = const {};
  String? _formError;
  bool _saving = false;

  bool get _isNew => _crop == null;

  @override
  void dispose() {
    _nameEn.dispose();
    _nameHi.dispose();
    _namePa.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final input = CropInput(
      code: _code.text,
      nameEn: _nameEn.text,
      nameHi: _nameHi.text,
      namePa: _namePa.text,
      stdRate: _rate,
      isActive: _active,
    );
    final errors = input.validate();
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() {
      _saving = true;
      _errors = const {};
      _formError = null;
    });
    final writer = ref.read(cropWriterProvider);
    final result = _isNew
        ? await writer.create(input)
        : await writer.update(_crop!.id, input);
    if (!mounted) return;
    switch (result) {
      case CropSaved(:final id):
        Navigator.of(context).pop(id);
      case CropInvalid(:final errors):
        setState(() => _errors = errors);
      case CropCodeTaken():
        setState(() => _formError = l10n.cropErrorCodeTaken);
      case CropNotFound():
        setState(() => _formError = l10n.cropNotFound);
      case CropNotPermitted():
        setState(() => _formError = l10n.settingsNoPermission);
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const gap = SizedBox(height: MkSpacing.md);
    return MkDialog(
      title: _isNew ? l10n.cropsAdd : l10n.cropEditTitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkTextField(
            key: const ValueKey('crop-name-en'),
            controller: _nameEn,
            label: l10n.cropFieldNameEn,
            autofocus: true,
            errorText: l10n.cropFieldError(
              _errors.contains(CropFieldError.nameEn)
                  ? CropFieldError.nameEn
                  : null,
            ),
            textInputAction: TextInputAction.next,
            onChanged: (v) {
              if (_isNew && !_codeTouched) {
                _code.text = CropRules.suggestCode(v);
              }
            },
          ),
          gap,
          MkTextField(
            key: const ValueKey('crop-name-hi'),
            controller: _nameHi,
            label: l10n.cropFieldNameHi,
            textInputAction: TextInputAction.next,
          ),
          gap,
          MkTextField(
            key: const ValueKey('crop-name-pa'),
            controller: _namePa,
            label: l10n.cropFieldNamePa,
            textInputAction: TextInputAction.next,
          ),
          gap,
          MkTextField(
            key: const ValueKey('crop-code'),
            controller: _code,
            label: l10n.cropFieldCode,
            enabled: _isNew,
            errorText: l10n.cropFieldError(
              _errors.contains(CropFieldError.code)
                  ? CropFieldError.code
                  : null,
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => _codeTouched = true,
          ),
          if (_isNew)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.cropCodeHint,
                style: TextStyle(
                  fontSize: 12,
                  color: MkTokens.of(context).textMuted,
                ),
              ),
            ),
          gap,
          MkNumberField(
            key: const ValueKey('crop-rate'),
            label: l10n.cropFieldStdRate,
            initialValue: _rate?.paise,
            errorText: l10n.cropFieldError(
              _errors.contains(CropFieldError.stdRate)
                  ? CropFieldError.stdRate
                  : null,
            ),
            onChanged: (p) => _rate = p == null ? null : Money(p),
            onSubmitted: _save,
          ),
          if (!_isNew) ...[
            gap,
            SwitchListTile(
              key: const ValueKey('crop-active'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.cropFieldActive),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
          ],
          if (_formError != null) ...[
            gap,
            Text(
              _formError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        MkButton(
          label: MaterialLocalizations.of(context).cancelButtonLabel,
          variant: MkButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('crop-save'),
          label: l10n.settingsSave,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
