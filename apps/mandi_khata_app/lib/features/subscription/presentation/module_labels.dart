import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension ModuleLabels on AppLocalizations {
  /// Name of a plan module (`khata`, `arrivals`, `karza`, `accounting`,
  /// `shop`); unknown keys show as typed.
  String moduleName(String module) => switch (module) {
    'khata' => modKhata,
    'arrivals' => modArrivals,
    'karza' => modKarza,
    'accounting' => modAccounting,
    'shop' => modShop,
    _ => module,
  };

  /// Name of a counted limit.
  String billLimitName(String key) => switch (key) {
    'users' => billUsers,
    'devices' => billDevices,
    'parties' => billParties,
    _ => key,
  };

  String billStatus(String status) => switch (status) {
    'trial' => billStatusTrial,
    'active' => billStatusActive,
    'grace' => billStatusGrace,
    'past_due' => billStatusGrace,
    'locked' => billStatusLocked,
    'cancelled' => billStatusCancelled,
    _ => status,
  };

  String billRequestStatus(String status) => switch (status) {
    'pending' => billReqPending,
    'done' => billReqDone,
    'rejected' => billReqRejected,
    _ => status,
  };
}
