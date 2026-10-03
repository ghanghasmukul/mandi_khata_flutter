// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_acceptor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inviteAcceptor)
final inviteAcceptorProvider = InviteAcceptorProvider._();

final class InviteAcceptorProvider
    extends $FunctionalProvider<InviteAcceptor, InviteAcceptor, InviteAcceptor>
    with $Provider<InviteAcceptor> {
  InviteAcceptorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteAcceptorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteAcceptorHash();

  @$internal
  @override
  $ProviderElement<InviteAcceptor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InviteAcceptor create(Ref ref) {
    return inviteAcceptor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteAcceptor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteAcceptor>(value),
    );
  }
}

String _$inviteAcceptorHash() => r'7308bd918a25ba514d781bdc3468a145601ba129';

/// Accepts invitations right after sign-in (once per sign-in, best effort:
/// offline simply tries again at the next sign-in or when the person taps
/// "Check again" on the empty business picker).

@ProviderFor(InviteSync)
final inviteSyncProvider = InviteSyncProvider._();

/// Accepts invitations right after sign-in (once per sign-in, best effort:
/// offline simply tries again at the next sign-in or when the person taps
/// "Check again" on the empty business picker).
final class InviteSyncProvider extends $NotifierProvider<InviteSync, void> {
  /// Accepts invitations right after sign-in (once per sign-in, best effort:
  /// offline simply tries again at the next sign-in or when the person taps
  /// "Check again" on the empty business picker).
  InviteSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteSyncHash();

  @$internal
  @override
  InviteSync create() => InviteSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$inviteSyncHash() => r'f68586bbe136987ed9454f12e2c35690157e5e59';

/// Accepts invitations right after sign-in (once per sign-in, best effort:
/// offline simply tries again at the next sign-in or when the person taps
/// "Check again" on the empty business picker).

abstract class _$InviteSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
