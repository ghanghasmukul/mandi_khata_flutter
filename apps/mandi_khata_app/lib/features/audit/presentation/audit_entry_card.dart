import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_labels.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One audit entry: what happened to which record, who did it (role,
/// device) and, for changes, each field as before → after. Money edits and
/// reversals get a coloured edge and a badge.
class AuditEntryCard extends StatelessWidget {
  const AuditEntryCard({required this.entry, super.key});

  final AuditEntry entry;

  static const _maxFields = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final theme = Theme.of(context);
    final e = entry;

    final (edge, tint) = switch (e.kind) {
      AuditKind.reversal => (tokens.udhaar, tokens.udhaarTint),
      AuditKind.moneyEdit => (tokens.gold, tokens.goldTint),
      _ => (tokens.border, theme.colorScheme.surface),
    };
    final badge = switch (e.kind) {
      AuditKind.reversal => l10n.auditBadgeReversal,
      AuditKind.moneyEdit => l10n.auditBadgeMoneyEdit,
      _ => null,
    };
    final uid = e.userId;
    final who = e.userName?.trim().isNotEmpty ?? false
        ? e.userName!
        : uid == null
        ? l10n.auditSystem
        : uid.substring(0, uid.length < 8 ? uid.length : 8);
    final role = e.role == null
        ? null
        : l10n.roleName(MemberRole.parse(e.role!));
    final keys = e.changedKeys;
    final shown = keys.take(_maxFields).toList();
    final subject = e.subject;

    return Padding(
      padding: const EdgeInsets.only(bottom: MkSpacing.sm),
      child: DecoratedBox(
        key: ValueKey('audit-${e.id}'),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(MkRadius.md),
          border: Border.all(color: edge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MkSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: MkSpacing.sm,
                      runSpacing: MkSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (badge != null)
                          MkRoleChip(label: badge, warning: true),
                        Text(
                          '${l10n.auditAction(e.action)} · '
                          '${l10n.auditTable(e.table)}'
                          '${subject == null ? '' : ' · $subject'}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: MkSpacing.sm),
                  Text(
                    AppFormat.dateTime(context, e.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: MkSpacing.xs),
              Text(
                [
                  if (role == null) who else l10n.auditByUser(who, role),
                  if (e.deviceCode != null) l10n.auditOnDevice(e.deviceCode!),
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
              if (shown.isNotEmpty) ...[
                const SizedBox(height: MkSpacing.sm),
                for (final k in shown) _FieldRow(entry: e, fieldKey: k),
                if (keys.length > shown.length)
                  Text(
                    l10n.auditMoreFields(keys.length - shown.length),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.entry, required this.fieldKey});

  final AuditEntry entry;
  final String fieldKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final before = entry.before;
    final after = entry.after;
    // Only a value that changed has a "was".
    final hasBefore =
        before != null &&
        before.containsKey(fieldKey) &&
        before[fieldKey].toString() != after?[fieldKey].toString();
    final money = AuditRules.moneyColumns.contains(fieldKey);
    String text(Object? v) {
      // Timestamps (revoked_at…) read as dates, not ISO text.
      if (fieldKey.endsWith('_at') && v is String) {
        final t = DateTime.tryParse(v);
        if (t != null) return AppFormat.dateTime(context, t);
      }
      return l10n.auditValue(fieldKey, v);
    }

    final newText = text(after?[fieldKey]);
    final style = TextStyle(
      fontSize: 12.5,
      fontWeight: money ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: MkSpacing.sm,
        children: [
          Text(
            '${l10n.auditField(fieldKey)}:',
            style: TextStyle(fontSize: 12.5, color: tokens.textMuted),
          ),
          if (hasBefore) ...[
            Text(
              text(before[fieldKey]),
              style: style.copyWith(
                decoration: TextDecoration.lineThrough,
                color: tokens.textMuted,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 14),
          ],
          Text(newText, style: style),
        ],
      ),
    );
  }
}
