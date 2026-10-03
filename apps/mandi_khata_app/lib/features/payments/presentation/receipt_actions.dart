import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/payments/data/receipt_pdf.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:printing/printing.dart';

/// Builds, prints and shares a payment's receipt in the business's language
/// (`app.default_language`) and on its paper (`print.receipt_size`).
///
/// Printing goes through the platform print dialog (Windows, macOS, Android);
/// sharing opens the share sheet on Android and a save dialog on desktop.
abstract final class PaymentReceipts {
  static ReceiptLayout layoutOf(WidgetRef ref) => ReceiptLayout.fromSetting(
    ref.read(settingProvider('print.receipt_size', businessTarget))?.value,
  );

  static String languageOf(WidgetRef ref) {
    final code = ref
        .read(settingProvider('app.default_language', businessTarget))
        ?.value;
    return code is String ? code : 'en';
  }

  /// The receipt PDF for [payment]. [party] adds code and village;
  /// [balanceAfter] the party's baki once it is in (right after recording).
  static Future<Uint8List> pdf(
    WidgetRef ref,
    Payment payment, {
    Party? party,
    Money? balanceAfter,
    ReceiptLayout? layout,
  }) async {
    final code = languageOf(ref);
    final l10n = lookupAppLocalizations(Locale(code));
    final fonts = await StatementFonts.load();
    final business = ref.read(activeMembershipProvider)?.tenantName ?? '';
    final d = payment.entryDate;
    String dateText(LedgerDate date) =>
        (DateFormat.yMMMd(code)..useNativeDigits = false).format(
          DateTime(date.year, date.month, date.day),
        );
    final isPaid = payment.direction == PaymentDirection.toParty;
    final detail = [
      payment.partyCode,
      party?.village,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return await ReceiptPdf.build(
      layout: layout ?? layoutOf(ref),
      fonts: fonts,
      data: ReceiptData(
        businessName: business,
        receiptNo: payment.receiptNo,
        date: dateText(d),
        partyName: payment.partyName,
        partyDetail: detail.isEmpty ? null : detail,
        amount: payment.amount,
        modeName: l10n.paymentModeName(payment.mode),
        reference: payment.reference,
        chequeNo: payment.chequeNo,
        chequeDate: payment.chequeDate == null
            ? null
            : dateText(payment.chequeDate!),
        narration: payment.narration,
        balanceAfter: balanceAfter,
        isReversed: payment.isReversed,
      ),
      labels: ReceiptLabels(
        title: l10n.paymentDocumentTitle(payment.direction),
        partyLabel: isPaid ? l10n.receiptPaidTo : l10n.receiptReceivedFrom,
        no: l10n.receiptNo,
        date: l10n.receiptDate,
        amount: l10n.receiptAmount,
        mode: l10n.receiptMode,
        reference: l10n.receiptReference,
        chequeNo: l10n.receiptChequeNo,
        chequeDate: l10n.receiptChequeDate,
        balanceAfter: l10n.receiptBalanceAfter,
        signature: l10n.receiptSignature,
        reversed: l10n.receiptReversed,
        balanceSide: (m) => m.isPositive
            ? l10n.khataBalanceJama
            : m.isNegative
            ? l10n.khataBalanceUdhaarParty
            : l10n.khataBalanceSettled,
      ),
    );
  }

  static Future<void> print(
    WidgetRef ref,
    Payment payment, {
    Party? party,
    Money? balanceAfter,
  }) async {
    final layout = layoutOf(ref);
    final bytes = await pdf(
      ref,
      payment,
      party: party,
      balanceAfter: balanceAfter,
      layout: layout,
    );
    await Printing.layoutPdf(
      name: payment.receiptNo,
      format: ReceiptPdf.format(layout),
      onLayout: (_) async => bytes,
    );
  }

  static Future<void> share(
    WidgetRef ref,
    Payment payment, {
    Party? party,
    Money? balanceAfter,
  }) async {
    final bytes = await pdf(
      ref,
      payment,
      party: party,
      balanceAfter: balanceAfter,
    );
    await Printing.sharePdf(bytes: bytes, filename: '${payment.receiptNo}.pdf');
  }
}
