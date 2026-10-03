// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamRepository)
final teamRepositoryProvider = TeamRepositoryProvider._();

final class TeamRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamRepository>,
          TeamRepository,
          FutureOr<TeamRepository>
        >
    with $FutureModifier<TeamRepository>, $FutureProvider<TeamRepository> {
  TeamRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<TeamRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TeamRepository> create(Ref ref) {
    return teamRepository(ref);
  }
}

String _$teamRepositoryHash() => r'9886e033c565e47f0c66e65dac8a6b09a8b591e1';

/// People of the active business (active first). Live.

@ProviderFor(teamMembers)
final teamMembersProvider = TeamMembersProvider._();

/// People of the active business (active first). Live.

final class TeamMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamMember>>,
          List<TeamMember>,
          Stream<List<TeamMember>>
        >
    with $FutureModifier<List<TeamMember>>, $StreamProvider<List<TeamMember>> {
  /// People of the active business (active first). Live.
  TeamMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMembersHash();

  @$internal
  @override
  $StreamProviderElement<List<TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TeamMember>> create(Ref ref) {
    return teamMembers(ref);
  }
}

String _$teamMembersHash() => r'89f33d11af178c4e8a7770f0c8a9125c4083a514';

/// Devices of the active business. Live.

@ProviderFor(teamDevices)
final teamDevicesProvider = TeamDevicesProvider._();

/// Devices of the active business. Live.

final class TeamDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamDevice>>,
          List<TeamDevice>,
          Stream<List<TeamDevice>>
        >
    with $FutureModifier<List<TeamDevice>>, $StreamProvider<List<TeamDevice>> {
  /// Devices of the active business. Live.
  TeamDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamDevicesHash();

  @$internal
  @override
  $StreamProviderElement<List<TeamDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TeamDevice>> create(Ref ref) {
    return teamDevices(ref);
  }
}

String _$teamDevicesHash() => r'43b03ebf571b4e2c77b716f5ae6a7f73bcf31de7';

/// Invites waiting to be accepted. Live.

@ProviderFor(pendingInvites)
final pendingInvitesProvider = PendingInvitesProvider._();

/// Invites waiting to be accepted. Live.

final class PendingInvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamInvite>>,
          List<TeamInvite>,
          Stream<List<TeamInvite>>
        >
    with $FutureModifier<List<TeamInvite>>, $StreamProvider<List<TeamInvite>> {
  /// Invites waiting to be accepted. Live.
  PendingInvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingInvitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingInvitesHash();

  @$internal
  @override
  $StreamProviderElement<List<TeamInvite>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TeamInvite>> create(Ref ref) {
    return pendingInvites(ref);
  }
}

String _$pendingInvitesHash() => r'4066af90678781127d70adcced564c4c16a5de6e';

@ProviderFor(teamWriter)
final teamWriterProvider = TeamWriterProvider._();

final class TeamWriterProvider
    extends $FunctionalProvider<TeamWriter, TeamWriter, TeamWriter>
    with $Provider<TeamWriter> {
  TeamWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamWriterHash();

  @$internal
  @override
  $ProviderElement<TeamWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TeamWriter create(Ref ref) {
    return teamWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamWriter>(value),
    );
  }
}

String _$teamWriterHash() => r'83ea966dd5df4a27e18bfe569ff24bd471574769';
