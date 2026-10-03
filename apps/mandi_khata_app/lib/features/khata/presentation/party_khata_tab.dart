import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/khata/presentation/entry_actions.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_entry_dialog.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_line.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/khata/presentation/statement_labels.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/payments/presentation/record_payment_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:printing/printing.dart';

/// A party's khata inside the party page: opening balance, entries with
/// running baki, closing balance, for a date range. Print / share as PDF.
class PartyKhataTab extends ConsumerStatefulWidget {
  const PartyKhataTab({required this.party, super.key});

  final Party party;

  @override
  ConsumerState<PartyKhataTab> createState() => _PartyKhataTabState();
}

class _PartyKhataTabState extends ConsumerState<PartyKhataTab> {
  LedgerDate? _from;
  LedgerDate? _to;

  Future<Uint8List> _pdf(Statement s) async {
    final l10n = AppLocalizations.of(context);
    final membership = ref.read(activeMembershipProvider);
    final fonts = await StatementFonts.load();
    if (!mounted) return Uint8List(0);
    final p = widget.party;
    final period = _from == null && _to == null
        ? l10n.rangeAll
        : '${_from == null ? '…' : AppFormat.ledgerDate(context, _from!)} – '
              '${_to == null ? '…' : AppFormat.ledgerDate(context, _to!)}';
    return await StatementPdf.build(
      statement: s,
      fonts: fonts,
      header: StatementHeader(
        businessName: membership?.tenantName ?? '',
        partyName: p.name,
        partyCode: p.code,
        partyPlace: p.village,
        mobile: p.mobile,
      ),
      labels: statementLabels(
        l10n,
        period: period,
        formatDate: (d) => AppFormat.ledgerDate(context, d),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.entriesReverse));
    final canPay = ref.watch(canProvider(Permission.paymentsCreate));
    final async = ref.watch(
      partyStatementProvider(widget.party.id, from: _from, to: _to),
    );
    final statement = async.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(MkSpacing.lg),
          child: Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DateRangeChips(
                  from: _from,
                  to: _to,
                  keyPrefix: 'statement',
                  onChanged: (f, t) => setState(() {
                    _from = f;
                    _to = t;
                  }),
                ),
              ),
              if (canPay) ...[
                MkButton(
                  key: const ValueKey('statement-pay'),
                  label: l10n.paymentPay,
                  icon: Icons.north_east,
                  variant: MkButtonVariant.secondary,
                  onPressed: () =>
                      showRecordPaymentDialog(context, party: widget.party),
                ),
                MkButton(
                  key: const ValueKey('statement-receive'),
                  label: l10n.paymentReceive,
                  icon: Icons.south_west,
                  variant: MkButtonVariant.secondary,
                  onPressed: () => showRecordPaymentDialog(
                    context,
                    party: widget.party,
                    direction: PaymentDirection.fromParty,
                  ),
                ),
              ],
              if (canAdd)
                MkButton(
                  key: const ValueKey('statement-add'),
                  label: l10n.khataEntryTitle,
                  icon: Icons.add,
                  variant: MkButtonVariant.secondary,
                  onPressed: () =>
                      showKhataEntryDialog(context, party: widget.party),
                ),
              if (statement != null) ...[
                MkButton(
                  key: const ValueKey('statement-print'),
                  label: l10n.statementPrint,
                  icon: Icons.print_outlined,
                  variant: MkButtonVariant.secondary,
                  onPressed: () async {
                    final bytes = await _pdf(statement);
                    await Printing.layoutPdf(
                      name: '${l10n.statementTitle} ${widget.party.code}',
                      onLayout: (_) async => bytes,
                    );
                  },
                ),
                MkButton(
                  key: const ValueKey('statement-share'),
                  label: l10n.statementShare,
                  icon: Icons.share_outlined,
                  variant: MkButtonVariant.secondary,
                  onPressed: () async {
                    final bytes = await _pdf(statement);
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: 'khata-${widget.party.code}.pdf',
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (statement == null)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else ...[
          _Totals(statement: statement),
          const KhataHeader(),
          const Divider(height: 1),
          Expanded(
            child: statement.rows.isEmpty
                ? MkEmptyState(
                    icon: Icons.menu_book_outlined,
                    title: l10n.khataStatementEmpty,
                  )
                : ListView.builder(
                    itemCount: statement.rows.length,
                    itemExtent: khataLineHeight,
                    itemBuilder: (context, i) {
                      final r = statement.rows[i];
                      return KhataLine(
                        entry: r.entry,
                        balance: r.balance,
                        struck: r.isStruck,
                        trailing: EntryActionsMenu(
                          entry: r.entry,
                          reversed: r.reversedById != null,
                          party: widget.party,
                        ),
                      );
                    },
                  ),
          ),
          _Closing(statement: statement),
        ],
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.statement});

  final Statement statement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget item(String label, Widget value) => Padding(
      padding: const EdgeInsets.only(right: MkSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          value,
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MkSpacing.lg),
      child: Wrap(
        runSpacing: MkSpacing.sm,
        children: [
          item(l10n.statementOpening, MkMoneyText.balance(statement.opening)),
          item(
            l10n.khataColUdhaar,
            MkMoneyText(statement.totalUdhaar, tone: MkMoneyTone.udhaar),
          ),
          item(
            l10n.khataColJama,
            MkMoneyText(statement.totalJama, tone: MkMoneyTone.jama),
          ),
        ],
      ),
    );
  }
}

class _Closing extends StatelessWidget {
  const _Closing({required this.statement});

  final Statement statement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: MkTokens.of(context).field,
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.statementClosing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: MkSpacing.sm),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: KhataBalanceChip(balance: statement.closing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
