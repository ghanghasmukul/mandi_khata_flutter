// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(journalBackfill)
final journalBackfillProvider = JournalBackfillProvider._();

final class JournalBackfillProvider
    extends
        $FunctionalProvider<
          AsyncValue<JournalBackfill>,
          JournalBackfill,
          FutureOr<JournalBackfill>
        >
    with $FutureModifier<JournalBackfill>, $FutureProvider<JournalBackfill> {
  JournalBackfillProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'journalBackfillProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$journalBackfillHash();

  @$internal
  @override
  $FutureProviderElement<JournalBackfill> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<JournalBackfill> create(Ref ref) {
    return journalBackfill(ref);
  }
}

String _$journalBackfillHash() => r'ad87ba613eb42e9d1054125129c683790081823d';

@ProviderFor(booksInvariants)
final booksInvariantsProvider = BooksInvariantsProvider._();

final class BooksInvariantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BooksInvariants>,
          BooksInvariants,
          FutureOr<BooksInvariants>
        >
    with $FutureModifier<BooksInvariants>, $FutureProvider<BooksInvariants> {
  BooksInvariantsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksInvariantsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksInvariantsHash();

  @$internal
  @override
  $FutureProviderElement<BooksInvariants> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BooksInvariants> create(Ref ref) {
    return booksInvariants(ref);
  }
}

String _$booksInvariantsHash() => r'928a430ab04e2645c25310d59fa6d35d8ef56c24';

/// Documents of the active business that have no journal entry yet.

@ProviderFor(booksStatus)
final booksStatusProvider = BooksStatusProvider._();

/// Documents of the active business that have no journal entry yet.

final class BooksStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackfillStatus?>,
          BackfillStatus?,
          FutureOr<BackfillStatus?>
        >
    with $FutureModifier<BackfillStatus?>, $FutureProvider<BackfillStatus?> {
  /// Documents of the active business that have no journal entry yet.
  BooksStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksStatusHash();

  @$internal
  @override
  $FutureProviderElement<BackfillStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackfillStatus?> create(Ref ref) {
    return booksStatus(ref);
  }
}

String _$booksStatusHash() => r'30fcb4068d0fafd77635e72899d7e475ca33a99c';

@ProviderFor(booksChecks)
final booksChecksProvider = BooksChecksProvider._();

final class BooksChecksProvider
    extends
        $FunctionalProvider<
          AsyncValue<BooksChecks?>,
          BooksChecks?,
          FutureOr<BooksChecks?>
        >
    with $FutureModifier<BooksChecks?>, $FutureProvider<BooksChecks?> {
  BooksChecksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksChecksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksChecksHash();

  @$internal
  @override
  $FutureProviderElement<BooksChecks?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BooksChecks?> create(Ref ref) {
    return booksChecks(ref);
  }
}

String _$booksChecksHash() => r'f0d977a9c0511c0fa1f3de919667fc0c23a2c3a2';
