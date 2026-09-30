// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in member may do [permission] in the active business:
/// role default + `custom_permissions` (same rule as SQL `has_permission`).
///
/// This only hides / disables UI. The server enforces the same rule in RLS,
/// so a stale local copy can never grant real access (CLAUDE.md rule 9).

@ProviderFor(can)
final canProvider = CanFamily._();

/// Whether the signed-in member may do [permission] in the active business:
/// role default + `custom_permissions` (same rule as SQL `has_permission`).
///
/// This only hides / disables UI. The server enforces the same rule in RLS,
/// so a stale local copy can never grant real access (CLAUDE.md rule 9).

final class CanProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in member may do [permission] in the active business:
  /// role default + `custom_permissions` (same rule as SQL `has_permission`).
  ///
  /// This only hides / disables UI. The server enforces the same rule in RLS,
  /// so a stale local copy can never grant real access (CLAUDE.md rule 9).
  CanProvider._({
    required CanFamily super.from,
    required Permission super.argument,
  }) : super(
         retry: null,
         name: r'canProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canHash();

  @override
  String toString() {
    return r'canProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as Permission;
    return can(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canHash() => r'0a4c0e860b2e17623fc37d111a596d49d04567c7';

/// Whether the signed-in member may do [permission] in the active business:
/// role default + `custom_permissions` (same rule as SQL `has_permission`).
///
/// This only hides / disables UI. The server enforces the same rule in RLS,
/// so a stale local copy can never grant real access (CLAUDE.md rule 9).

final class CanFamily extends $Family
    with $FunctionalFamilyOverride<bool, Permission> {
  CanFamily._()
    : super(
        retry: null,
        name: r'canProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the signed-in member may do [permission] in the active business:
  /// role default + `custom_permissions` (same rule as SQL `has_permission`).
  ///
  /// This only hides / disables UI. The server enforces the same rule in RLS,
  /// so a stale local copy can never grant real access (CLAUDE.md rule 9).

  CanProvider call(Permission permission) =>
      CanProvider._(argument: permission, from: this);

  @override
  String toString() => r'canProvider';
}
