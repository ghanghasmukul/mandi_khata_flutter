import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:mandi_khata_app/features/documents/presentation/documents_labels.dart';
import 'package:mandi_khata_app/features/documents/presentation/documents_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Adds a document to a party: type, optional title / number, then a photo
/// (camera on Android) or a file.
class AddDocumentDialog extends ConsumerStatefulWidget {
  const AddDocumentDialog({required this.partyId, super.key});

  final String partyId;

  static Future<void> show(BuildContext context, String partyId) =>
      showDialog<void>(
        context: context,
        builder: (_) => AddDocumentDialog(partyId: partyId),
      );

  @override
  ConsumerState<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends ConsumerState<AddDocumentDialog> {
  PartyDocumentType _type = PartyDocumentType.passbook;
  final _title = TextEditingController();
  final _number = TextEditingController();
  DocumentFile? _file;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _number.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool camera}) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await ref.read(documentPickerProvider)(camera: camera);
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (file != null) _file = file;
      });
    } on DocumentPickFailed catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.documentResult(DocumentRefused(e.reason));
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final file = _file;
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(documentWriterProvider)
        .add(
          DocumentDraft(
            partyId: widget.partyId,
            type: _type,
            file: file,
            title: _title.text,
            idNumber: _number.text,
          ),
        );
    if (!mounted) return;
    final error = l10n.documentResult(result);
    if (error == null) {
      MkToast.show(context, l10n.docAdded, tone: MkToastTone.success);
      Navigator.of(context).pop();
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
    final canManage = ref.watch(canProvider(Permission.partiesManage));
    final types = [
      for (final t in PartyDocumentType.values)
        if (t.isIdentity ? isOwner : canManage) t,
    ];
    if (!types.contains(_type) && types.isNotEmpty) _type = types.first;

    return AlertDialog(
      title: Text(l10n.docAdd),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<PartyDocumentType>(
                key: const ValueKey('doc-type'),
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.docFieldType),
                items: [
                  for (final t in types)
                    DropdownMenuItem(
                      value: t,
                      child: Text(l10n.documentType(t)),
                    ),
                ],
                onChanged: _busy
                    ? null
                    : (t) => setState(() => _type = t ?? _type),
              ),
              const SizedBox(height: MkSpacing.md),
              TextField(
                key: const ValueKey('doc-title'),
                controller: _title,
                decoration: InputDecoration(labelText: l10n.docFieldTitle),
              ),
              if (_type.isIdentity) ...[
                const SizedBox(height: MkSpacing.md),
                TextField(
                  key: const ValueKey('doc-number'),
                  controller: _number,
                  decoration: InputDecoration(
                    labelText: l10n.docFieldIdNumber,
                    helperText: l10n.docIdNumberHelp,
                    helperMaxLines: 3,
                  ),
                ),
              ],
              const SizedBox(height: MkSpacing.lg),
              Wrap(
                spacing: MkSpacing.sm,
                runSpacing: MkSpacing.sm,
                children: [
                  if (cameraAvailable)
                    MkButton(
                      label: l10n.docTakePhoto,
                      icon: Icons.photo_camera_outlined,
                      variant: MkButtonVariant.secondary,
                      onPressed: _busy ? null : () => _pick(camera: true),
                    ),
                  MkButton(
                    label: l10n.docPickFile,
                    icon: Icons.attach_file,
                    variant: MkButtonVariant.secondary,
                    onPressed: _busy ? null : () => _pick(camera: false),
                  ),
                ],
              ),
              if (_file != null) ...[
                const SizedBox(height: MkSpacing.sm),
                Row(
                  children: [
                    if (_file!.thumb != null)
                      Padding(
                        padding: const EdgeInsets.only(right: MkSpacing.sm),
                        child: Image.memory(_file!.thumb!, height: 56),
                      ),
                    Expanded(
                      child: Text(
                        l10n.docChosen(
                          _file!.fileName,
                          (_file!.bytes.length / 1024).round(),
                        ),
                        key: const ValueKey('doc-chosen'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.sm),
                  child: Text(
                    _error!,
                    key: const ValueKey('doc-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('doc-save'),
          onPressed: _busy || _file == null || types.isEmpty ? null : _save,
          child: Text(l10n.docSave),
        ),
      ],
    );
  }
}
