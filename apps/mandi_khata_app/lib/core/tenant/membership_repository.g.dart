// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(membershipRepository)
final membershipRepositoryProvider = MembershipRepositoryProvider._();

final class MembershipRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MembershipRepository>,
          MembershipRepository,
          FutureOr<MembershipRepository>
        >
    with
        $FutureModifier<MembershipRepository>,
        $FutureProvider<MembershipRepository> {
  MembershipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<MembershipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MembershipRepository> create(Ref ref) {
    return membershipRepository(ref);
  }
}

String _$membershipRepositoryHash() =>
    r'12a8e891410ccbf00ce9f04b01f9ed5856e5a389';

/// Active memberships of the signed-in user (empty when signed out).

@ProviderFor(myMemberships)
final myMembershipsProvider = MyMembershipsProvider._();

/// Active memberships of the signed-in user (empty when signed out).

final class MyMembershipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Membership>>,
          List<Membership>,
          Stream<List<Membership>>
        >
    with $FutureModifier<List<Membership>>, $StreamProvider<List<Membership>> {
  /// Active memberships of the signed-in user (empty when signed out).
  MyMembershipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myMembershipsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myMembershipsHash();

  @$internal
  @override
  $StreamProviderElement<List<Membership>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Membership>> create(Ref ref) {
    return myMemberships(ref);
  }
}

String _$myMembershipsHash() => r'49a029cbdde1fb7071c4158d45cd86a4208ad5bb';
