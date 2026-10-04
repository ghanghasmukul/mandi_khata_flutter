// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loans_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loansRepository)
final loansRepositoryProvider = LoansRepositoryProvider._();

final class LoansRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoansRepository>,
          LoansRepository,
          FutureOr<LoansRepository>
        >
    with $FutureModifier<LoansRepository>, $FutureProvider<LoansRepository> {
  LoansRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loansRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loansRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<LoansRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LoansRepository> create(Ref ref) {
    return loansRepository(ref);
  }
}

String _$loansRepositoryHash() => r'a879204e49c7eae8a8de56a419d03e2e1ed0a34a';

/// Loans of the active business matching [filter], with their figures as of
/// today. Live.

@ProviderFor(loanList)
final loanListProvider = LoanListFamily._();

/// Loans of the active business matching [filter], with their figures as of
/// today. Live.

final class LoanListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LoanSummary>>,
          List<LoanSummary>,
          Stream<List<LoanSummary>>
        >
    with
        $FutureModifier<List<LoanSummary>>,
        $StreamProvider<List<LoanSummary>> {
  /// Loans of the active business matching [filter], with their figures as of
  /// today. Live.
  LoanListProvider._({
    required LoanListFamily super.from,
    required LoanFilter super.argument,
  }) : super(
         retry: null,
         name: r'loanListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loanListHash();

  @override
  String toString() {
    return r'loanListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LoanSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LoanSummary>> create(Ref ref) {
    final argument = this.argument as LoanFilter;
    return loanList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LoanListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loanListHash() => r'8a3930710900ebc3318a9f2aa805da677fade641';

/// Loans of the active business matching [filter], with their figures as of
/// today. Live.

final class LoanListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LoanSummary>>, LoanFilter> {
  LoanListFamily._()
    : super(
        retry: null,
        name: r'loanListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loans of the active business matching [filter], with their figures as of
  /// today. Live.

  LoanListProvider call(LoanFilter filter) =>
      LoanListProvider._(argument: filter, from: this);

  @override
  String toString() => r'loanListProvider';
}

/// One loan of the active business with its entries and rate changes; null
/// if missing. Live.

@ProviderFor(loanDetail)
final loanDetailProvider = LoanDetailFamily._();

/// One loan of the active business with its entries and rate changes; null
/// if missing. Live.

final class LoanDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoanDetail?>,
          LoanDetail?,
          Stream<LoanDetail?>
        >
    with $FutureModifier<LoanDetail?>, $StreamProvider<LoanDetail?> {
  /// One loan of the active business with its entries and rate changes; null
  /// if missing. Live.
  LoanDetailProvider._({
    required LoanDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'loanDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loanDetailHash();

  @override
  String toString() {
    return r'loanDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LoanDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LoanDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return loanDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LoanDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loanDetailHash() => r'547e11b6eacc940a135dd0b28d3122ac73af3381';

/// One loan of the active business with its entries and rate changes; null
/// if missing. Live.

final class LoanDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LoanDetail?>, String> {
  LoanDetailFamily._()
    : super(
        retry: null,
        name: r'loanDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One loan of the active business with its entries and rate changes; null
  /// if missing. Live.

  LoanDetailProvider call(String id) =>
      LoanDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'loanDetailProvider';
}

/// The number the next loan on this device will get.

@ProviderFor(nextLoanNo)
final nextLoanNoProvider = NextLoanNoProvider._();

/// The number the next loan on this device will get.

final class NextLoanNoProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The number the next loan on this device will get.
  NextLoanNoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextLoanNoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextLoanNoHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return nextLoanNo(ref);
  }
}

String _$nextLoanNoHash() => r'7ac423130f4110127b1aaa28c27693af203d174f';

@ProviderFor(loanWriter)
final loanWriterProvider = LoanWriterProvider._();

final class LoanWriterProvider
    extends $FunctionalProvider<LoanWriter, LoanWriter, LoanWriter>
    with $Provider<LoanWriter> {
  LoanWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loanWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loanWriterHash();

  @$internal
  @override
  $ProviderElement<LoanWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoanWriter create(Ref ref) {
    return loanWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoanWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoanWriter>(value),
    );
  }
}

String _$loanWriterHash() => r'3efe0e1e449678ccd4d8455dda8702b29727e762';
