import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:mandi_khata_app/features/documents/presentation/add_document_dialog.dart';
import 'package:mandi_khata_app/features/documents/presentation/document_viewer_dialog.dart';
import 'package:mandi_khata_app/features/documents/presentation/documents_labels.dart';
import 'package:mandi_khata_app/features/documents/presentation/documents_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The Documents tab of a party (step 6.3).
class PartyDocumentsTab extends ConsumerWidget {
  const PartyDocumentsTab({required this.partyId, super.key});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final docs = ref.watch(partyDocumentsProvider(partyId));
    final canAdd = ref.watch(canProvider(Permission.partiesManage));
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
    final pending = ref.watch(pendingDocumentsProvider).value ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(MkSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  [
                    if (isOwner) l10n.docOwnerNote,
                    if (pending > 0) l10n.docPendingUploads(pending),
                  ].join('  ·  '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (canAdd)
                MkButton(
                  label: l10n.docAdd,
                  icon: Icons.add_a_photo_outlined,
                  onPressed: () => AddDocumentDialog.show(context, partyId),
                ),
            ],
          ),
        ),
        Expanded(
          child: switch (docs) {
            AsyncData(:final value) when value.isEmpty => MkEmptyState(
              icon: Icons.folder_open_outlined,
              title: l10n.docEmpty,
            ),
            AsyncData(:final value) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: MkSpacing.lg),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: MkSpacing.sm),
              itemBuilder: (_, i) => _DocTile(doc: value[i]),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}

class _DocTile extends ConsumerWidget {
  const _DocTile({required this.doc});

  final PartyDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final created = doc.createdAt;
    return MkCard(
      child: InkWell(
        key: ValueKey('doc-${doc.id}'),
        onTap: () => DocumentViewerDialog.show(context, doc),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              _Thumb(doc: doc),
              const SizedBox(width: MkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title ?? l10n.documentType(doc.type),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      [
                        if (doc.title != null) l10n.documentType(doc.type),
                        ?doc.idMasked,
                        '${(doc.sizeBytes / 1024).round()} KB',
                        if (created != null)
                          AppFormat.date(context, created.toLocal()),
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb({required this.doc});

  final PartyDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const size = 48.0;
    final thumb = doc.thumbPath;
    Widget icon(IconData i) =>
        SizedBox(width: size, height: size, child: Icon(i, size: 28));
    if (thumb == null) {
      return icon(
        doc.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
      );
    }
    final image = ref.watch(documentImageProvider(doc.bucket, thumb));
    return switch (image) {
      AsyncData(value: (bytes: final b?, url: _)) => Image.memory(
        b,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
      AsyncData(value: (bytes: _, url: final u?)) => Image.network(
        u,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => icon(Icons.image_not_supported_outlined),
      ),
      AsyncLoading() => const SizedBox(width: size, height: size),
      _ => icon(Icons.cloud_off_outlined),
    };
  }
}
