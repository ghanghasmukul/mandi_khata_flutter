// Developer-only gallery content; sample text is not localised on purpose.
import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_ui/mk_ui.dart';

class InputSamples extends StatefulWidget {
  const InputSamples({super.key});

  @override
  State<InputSamples> createState() => _InputSamplesState();
}

class _InputSamplesState extends State<InputSamples> {
  int? _paise = 110959;
  int? _bags;

  @override
  Widget build(BuildContext context) {
    return MkCard(
      child: Wrap(
        spacing: MkSpacing.lg,
        runSpacing: MkSpacing.lg,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          const SizedBox(
            width: 260,
            child: MkTextField(
              label: 'Farmer name',
              hint: 'Search name, village, mobile…',
            ),
          ),
          SizedBox(
            width: 180,
            child: MkNumberField(
              label: 'Amount',
              initialValue: _paise,
              onChanged: (v) => setState(() => _paise = v),
            ),
          ),
          SizedBox(
            width: 140,
            child: MkNumberField(
              label: 'Bags',
              kind: MkNumberKind.integer,
              suffixText: 'bags',
              onChanged: (v) => setState(() => _bags = v),
            ),
          ),
          const SizedBox(
            width: 180,
            child: MkTextField(label: 'Mobile', errorText: 'Enter 10 digits'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Parsed: ${_paise == null ? '—' : '$_paise paise'}'
              ' · bags: ${_bags ?? '—'}',
              style: MkText.mono(size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _PartyRow = ({
  String name,
  String father,
  String village,
  String mobile,
  Money balance,
});

const List<_PartyRow> _parties = [
  (
    name: 'Gurpreet Singh',
    father: 'Harbans Singh',
    village: 'Bhikhi',
    mobile: '98140 22110',
    balance: Money(15558000),
  ),
  (
    name: 'Balwinder Kaur',
    father: 'Jagtar Singh',
    village: 'Budhlada',
    mobile: '98723 41876',
    balance: Money(-9820000),
  ),
  (
    name: 'Ramesh Kumar',
    father: 'Sita Ram',
    village: 'Jhunir',
    mobile: '94170 55321',
    balance: Money(240000),
  ),
  (
    name: 'Amrik Singh',
    father: 'Kartar Singh',
    village: 'Sardulgarh',
    mobile: '99155 10432',
    balance: Money(-132800000),
  ),
  (
    name: 'Harjit Kaur',
    father: 'Mohan Singh',
    village: 'Mansa',
    mobile: '98152 77009',
    balance: Money.zero,
  ),
];

class TableSample extends StatelessWidget {
  const TableSample({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return MkDataTable<_PartyRow>(
      rows: _parties,
      minWidth: 640,
      onRowTap: (row) => MkToast.show(context, 'Open ${row.name}'),
      columns: [
        MkColumn(
          label: 'Farmer',
          flex: 3,
          sortKey: (r) => r.name,
          cell: (r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                's/o ${r.father}',
                style: TextStyle(fontSize: 11.5, color: tokens.textFaint),
              ),
            ],
          ),
        ),
        MkColumn(
          label: 'Village',
          flex: 2,
          sortKey: (r) => r.village,
          cell: (r) => Text(r.village),
        ),
        MkColumn(
          label: 'Mobile',
          flex: 2,
          cell: (r) => Text(r.mobile, style: MkText.mono(size: 12)),
        ),
        MkColumn(
          label: 'Baki · balance',
          flex: 2,
          numeric: true,
          sortKey: (r) => r.balance,
          cell: (r) => MkMoneyText.balance(r.balance),
        ),
      ],
    );
  }
}

class FeedbackSamples extends StatelessWidget {
  const FeedbackSamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MkSpacing.lg,
      children: [
        Wrap(
          spacing: MkSpacing.md,
          runSpacing: MkSpacing.md,
          children: [
            MkButton(
              label: 'Show toast',
              variant: MkButtonVariant.secondary,
              onPressed: () => MkToast.show(
                context,
                'Receipt R-W1-3008 saved',
                tone: MkToastTone.success,
              ),
            ),
            MkButton(
              label: 'Show dialog',
              variant: MkButtonVariant.secondary,
              onPressed: () => MkDialog.show<void>(
                context,
                title: 'Reverse this entry?',
                content: const Text(
                  'A reversal entry will be posted and linked. The original '
                  'stays in the khata, struck through.',
                ),
                actions: [
                  MkButton(
                    label: 'Cancel',
                    variant: MkButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  MkButton(
                    label: 'Reverse',
                    variant: MkButtonVariant.danger,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
        MkCard(
          child: MkEmptyState(
            icon: Icons.groups_outlined,
            title: 'No farmers yet',
            message: 'Add your first farmer to start their khata.',
            action: MkButton(
              label: 'Add farmer',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
