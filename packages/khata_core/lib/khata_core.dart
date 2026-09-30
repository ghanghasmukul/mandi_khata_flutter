/// Pure Dart business logic for Mandi Khata.
///
/// Money, interest, mandi charges and ledger maths live here. This package must
/// never depend on Flutter or on a database — it is the one place those rules
/// are implemented, and it is unit tested in full.
library;

export 'src/document_number.dart';
export 'src/khata_core_base.dart';
export 'src/ledger.dart';
export 'src/money.dart';
export 'src/party_rules.dart';
export 'src/permissions.dart';
export 'src/settings/interest_rate.dart';
export 'src/settings/setting_scope.dart';
export 'src/settings/settings_resolver.dart';
export 'src/settings/settings_schema.dart';
