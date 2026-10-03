import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/team/data/invite_service.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension TeamLabels on AppLocalizations {
  String permissionName(Permission p) => switch (p) {
    Permission.partiesManage => permission_partiesManage,
    Permission.arrivalsManage => permission_arrivalsManage,
    Permission.paymentsCreate => permission_paymentsCreate,
    Permission.entriesReverse => permission_entriesReverse,
    Permission.loansManage => permission_loansManage,
    Permission.financeView => permission_financeView,
    Permission.adminManage => permission_adminManage,
    Permission.masterDelete => permission_masterDelete,
    Permission.settingsManage => permission_settingsManage,
    Permission.auditView => permission_auditView,
  };

  /// Message for a failed team change, or null when it saved.
  String? teamError(TeamResult r) => switch (r) {
    TeamSaved() => null,
    TeamNotPermitted() => settingsNoPermission,
    TeamNotFound() => teamErrNotFound,
    TeamLastOwner() => teamErrLastOwner,
    TeamProtected() => teamErrProtected,
  };

  String inviteError(InviteFailure f) => switch (f) {
    InviteFailure.invalidPhone => inviteErrPhone,
    InviteFailure.invalidRole => inviteErrRole,
    InviteFailure.alreadyMember => inviteErrAlreadyMember,
    InviteFailure.alreadyInvited => inviteErrAlreadyInvited,
    InviteFailure.notAllowed => inviteErrNotAllowed,
    InviteFailure.offline => inviteErrOffline,
    InviteFailure.failed => inviteErrFailed,
  };
}

/// Platform names are proper nouns, shown as is.
String platformName(String platform) => switch (platform) {
  'android' => 'Android',
  'windows' => 'Windows',
  'macos' => 'Mac',
  'web' => 'Web',
  _ => platform,
};
