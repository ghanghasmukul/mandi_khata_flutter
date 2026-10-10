import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:mandi_khata_app/features/documents/presentation/documents_labels.dart';
import 'package:mandi_khata_app/features/documents/presentation/documents_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// One document: the picture (or a link for a PDF) and delete.
class DocumentViewerDialog extends ConsumerWidget {
  const DocumentViewerDialog({required this.doc, super.key});

  final PartyDocument doc;

  static Future<void> show(BuildContext context, PartyDocument doc) =>
      showDialog<void>(
        context: context,
        builder: (_) => DocumentViewerDialog(doc: doc),
      );

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.docDelete),
        content: Text(l10n.docDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('doc-delete-confirm'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(l10n.docDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await ref.read(documentWriterProvider).delete(doc.id);
    if (!context.mounted) return;
    if (done) {
      Navigator.of(context).pop();
    } else {
      MkToast.show(context, l10n.docRefusedNotAllowed, tone: MkToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canDelete = ref.watch(canProvider(Permission.masterDelete));
    final image = ref.watch(documentImageProvider(doc.bucket, doc.filePath));
    return AlertDialog(
      title: Text(doc.title ?? l10n.documentType(doc.type)),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text([l10n.documentType(doc.type), ?doc.idMasked].join(' · ')),
              if (doc.notes != null) Text(doc.notes!),
              const SizedBox(height: MkSpacing.md),
              image.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => Text(l10n.docOffline),
                data: (img) {
                  if (img == null) return Text(l10n.docOffline);
                  if (doc.isPdf) {
                    final url = img.url;
                    return url == null
                        ? Text(l10n.docOffline)
                        : MkButton(
                            label: l10n.docOpenPdf,
                            icon: Icons.picture_as_pdf_outlined,
                            onPressed: () => launchUrl(Uri.parse(url)),
                          );
                  }
                  if (img.bytes != null) {
                    return Image.memory(img.bytes!, height: 360);
                  }
                  return Image.network(
                    img.url!,
                    height: 360,
                    errorBuilder: (_, _, _) => Text(l10n.docOffline),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (canDelete)
          TextButton.icon(
            key: const ValueKey('doc-delete'),
            onPressed: () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.docDelete),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
