import 'package:khata_core/src/party_rules.dart';
import 'package:khata_core/src/permissions.dart';

/// Why an invite cannot be created.
enum InviteError {
  /// Not a valid Indian mobile number.
  phone,

  /// Owners are not created by invite (a business keeps its owner).
  role,
}

/// A valid invite: the phone as stored (`91` + 10 digits, the form Supabase
/// Auth keeps in `auth.users.phone`) and the role it grants.
class InviteDraft {
  const InviteDraft(this.phone, this.role);

  final String phone;
  final MemberRole role;
}

/// Rules for the team: invites, the permission grid, owner safety.
/// Mirrors the SQL in the users migration (`create_member_invite`,
/// `guard_tenant_members`).
abstract final class TeamRules {
  /// Roles that can be invited.
  static const List<MemberRole> invitableRoles = [
    MemberRole.accountant,
    MemberRole.munshi,
    MemberRole.custom,
  ];

  /// Normalises an invite. Returns the draft, or the first [InviteError].
  static (InviteDraft?, InviteError?) validateInvite({
    required String phone,
    required MemberRole role,
  }) {
    final digits = IndianMobile.normalise(phone);
    if (digits == null) return (null, InviteError.phone);
    if (!invitableRoles.contains(role)) return (null, InviteError.role);
    return (InviteDraft('91$digits', role), null);
  }

  /// `919814022110` → `98140 22110`; anything else unchanged.
  static String displayPhone(String stored) {
    final m = RegExp(r'^\+?91(\d{5})(\d{5})$').firstMatch(stored);
    return m == null ? stored : '${m[1]} ${m[2]}';
  }

  /// Permissions [role] holds with [overrides] applied (the grid's state).
  static Set<Permission> effective(
    MemberRole role,
    Map<String, Object?> overrides,
  ) => {
    for (final p in Permission.values)
      if (hasPermission(role, overrides, p)) p,
  };

  /// The `custom_permissions` to store so that [role] ends up holding exactly
  /// [granted]: only keys that differ from the role default are written, so
  /// changing a role later keeps the intent clean. Owners store nothing.
  static Map<String, bool> overridesFor(
    MemberRole role,
    Set<Permission> granted,
  ) {
    if (role == MemberRole.owner) return const {};
    return {
      for (final p in Permission.values)
        if (granted.contains(p) != role.allows(p)) p.key: granted.contains(p),
    };
  }

  /// Whether a member row may be switched off or demoted without leaving the
  /// business without an active owner. [activeOwnerIds] are the member ids
  /// of every active owner; [memberId] is the one being changed.
  static bool keepsAnOwner(Iterable<String> activeOwnerIds, String memberId) =>
      activeOwnerIds.any((id) => id != memberId);

  /// Permissions that can lock people out or hand out power. Changing these
  /// in the grid asks for confirmation.
  static const Set<Permission> sensitive = {
    Permission.adminManage,
    Permission.entriesReverse,
    Permission.financeView,
    Permission.auditView,
  };
}
