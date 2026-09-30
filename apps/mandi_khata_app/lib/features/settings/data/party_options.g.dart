// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_options.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active parties of the active business, by name. The full parties
/// repository arrives with the parties screen (step 0.8).

@ProviderFor(partyOptions)
final partyOptionsProvider = PartyOptionsProvider._();

/// Active parties of the active business, by name. The full parties
/// repository arrives with the parties screen (step 0.8).

final class PartyOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PartyOption>>,
          List<PartyOption>,
          Stream<List<PartyOption>>
        >
    with
        $FutureModifier<List<PartyOption>>,
        $StreamProvider<List<PartyOption>> {
  /// Active parties of the active business, by name. The full parties
  /// repository arrives with the parties screen (step 0.8).
  PartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyOptionsHash();

  @$internal
  @override
  $StreamProviderElement<List<PartyOption>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PartyOption>> create(Ref ref) {
    return partyOptions(ref);
  }
}

String _$partyOptionsHash() => r'11eb3bf733a44ca781f1fc53bd59fa665cc858d7';
