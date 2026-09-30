import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions.g.dart';

/// Whether the signed-in member may do [permission] in the active business:
/// role default + `custom_permissions` (same rule as SQL `has_permission`).
///
/// This only hides / disables UI. The server enforces the same rule in RLS,
/// so a stale local copy can never grant real access (CLAUDE.md rule 9).
@riverpod
bool can(Ref ref, Permission permission) =>
    ref.watch(activeMembershipProvider)?.can(permission) ?? false;

/// Shows [child] only when the member has [permission]; otherwise
/// [fallback] (nothing by default). For a control that should stay visible
/// but disabled, use [builder].
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    required this.permission,
    super.key,
    this.child,
    this.fallback = const SizedBox.shrink(),
    this.builder,
  }) : assert(
         (child == null) != (builder == null),
         'Pass either child or builder',
       );

  final Permission permission;
  final Widget? child;
  final Widget fallback;

  /// Always built, with whether the permission is granted.
  final Widget Function(BuildContext context, {required bool allowed})? builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(canProvider(permission));
    final build = builder;
    if (build != null) return build(context, allowed: allowed);
    return allowed ? child! : fallback;
  }
}
