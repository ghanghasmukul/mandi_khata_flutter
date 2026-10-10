import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension DocumentLabels on AppLocalizations {
  String documentType(PartyDocumentType t) => switch (t) {
    PartyDocumentType.aadhaar => docTypeAadhaar,
    PartyDocumentType.pan => docTypePan,
    PartyDocumentType.passbook => docTypePassbook,
    PartyDocumentType.cheque => docTypeCheque,
    PartyDocumentType.jForm => docTypeJForm,
    PartyDocumentType.loanAgreement => docTypeLoanAgreement,
    PartyDocumentType.other => docTypeOther,
  };

  /// A message for a refused add; null when [result] is a success.
  String? documentResult(DocumentResult result) => switch (result) {
    DocumentAdded() => null,
    DocumentRefused(:final reason) => switch (reason) {
      DocumentRefusal.notAllowed => docRefusedNotAllowed,
      DocumentRefusal.tooLarge => docTooLarge,
      DocumentRefusal.unsupportedType => docUnsupported,
      DocumentRefusal.badIdNumber => docBadIdNumber,
    },
  };
}
