// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statements_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statementsRepository)
final statementsRepositoryProvider = StatementsRepositoryProvider._();

final class StatementsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<StatementsRepository>,
          StatementsRepository,
          FutureOr<StatementsRepository>
        >
    with
        $FutureModifier<StatementsRepository>,
        $FutureProvider<StatementsRepository> {
  StatementsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statementsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statementsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<StatementsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StatementsRepository> create(Ref ref) {
    return statementsRepository(ref);
  }
}

String _$statementsRepositoryHash() =>
    r'350a4b773df8fc5e9f93c7f266854170ee055c50';

@ProviderFor(yearCloseRepository)
final yearCloseRepositoryProvider = YearCloseRepositoryProvider._();

final class YearCloseRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<YearCloseRepository>,
          YearCloseRepository,
          FutureOr<YearCloseRepository>
        >
    with
        $FutureModifier<YearCloseRepository>,
        $FutureProvider<YearCloseRepository> {
  YearCloseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yearCloseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yearCloseRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<YearCloseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<YearCloseRepository> create(Ref ref) {
    return yearCloseRepository(ref);
  }
}

String _$yearCloseRepositoryHash() =>
    r'c0279a533f11ab0f75aac6b85e26321705443920';

/// Recomputed whenever the journal changes (journalTickProvider).

@ProviderFor(trialBalance)
final trialBalanceProvider = TrialBalanceFamily._();

/// Recomputed whenever the journal changes (journalTickProvider).

final class TrialBalanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrialBalance?>,
          TrialBalance?,
          FutureOr<TrialBalance?>
        >
    with $FutureModifier<TrialBalance?>, $FutureProvider<TrialBalance?> {
  /// Recomputed whenever the journal changes (journalTickProvider).
  TrialBalanceProvider._({
    required TrialBalanceFamily super.from,
    required ({LedgerDate asOf, bool withAccounts}) super.argument,
  }) : super(
         retry: null,
         name: r'trialBalanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trialBalanceHash();

  @override
  String toString() {
    return r'trialBalanceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TrialBalance?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrialBalance?> create(Ref ref) {
    final argument = this.argument as ({LedgerDate asOf, bool withAccounts});
    return trialBalance(
      ref,
      asOf: argument.asOf,
      withAccounts: argument.withAccounts,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrialBalanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trialBalanceHash() => r'1d6141737cdb11a3515883181d31cf27494dc268';

/// Recomputed whenever the journal changes (journalTickProvider).

final class TrialBalanceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<TrialBalance?>,
          ({LedgerDate asOf, bool withAccounts})
        > {
  TrialBalanceFamily._()
    : super(
        retry: null,
        name: r'trialBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recomputed whenever the journal changes (journalTickProvider).

  TrialBalanceProvider call({
    required LedgerDate asOf,
    bool withAccounts = true,
  }) => TrialBalanceProvider._(
    argument: (asOf: asOf, withAccounts: withAccounts),
    from: this,
  );

  @override
  String toString() => r'trialBalanceProvider';
}

@ProviderFor(profitAndLoss)
final profitAndLossProvider = ProfitAndLossFamily._();

final class ProfitAndLossProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfitAndLoss?>,
          ProfitAndLoss?,
          FutureOr<ProfitAndLoss?>
        >
    with $FutureModifier<ProfitAndLoss?>, $FutureProvider<ProfitAndLoss?> {
  ProfitAndLossProvider._({
    required ProfitAndLossFamily super.from,
    required ({LedgerDate from, LedgerDate to}) super.argument,
  }) : super(
         retry: null,
         name: r'profitAndLossProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profitAndLossHash();

  @override
  String toString() {
    return r'profitAndLossProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProfitAndLoss?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProfitAndLoss?> create(Ref ref) {
    final argument = this.argument as ({LedgerDate from, LedgerDate to});
    return profitAndLoss(ref, from: argument.from, to: argument.to);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfitAndLossProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profitAndLossHash() => r'd5832bc01e2f01c6ac09b9e834c53ef41c83a14c';

final class ProfitAndLossFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProfitAndLoss?>,
          ({LedgerDate from, LedgerDate to})
        > {
  ProfitAndLossFamily._()
    : super(
        retry: null,
        name: r'profitAndLossProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfitAndLossProvider call({
    required LedgerDate from,
    required LedgerDate to,
  }) => ProfitAndLossProvider._(argument: (from: from, to: to), from: this);

  @override
  String toString() => r'profitAndLossProvider';
}

@ProviderFor(balanceSheet)
final balanceSheetProvider = BalanceSheetFamily._();

final class BalanceSheetProvider
    extends
        $FunctionalProvider<
          AsyncValue<BalanceSheet?>,
          BalanceSheet?,
          FutureOr<BalanceSheet?>
        >
    with $FutureModifier<BalanceSheet?>, $FutureProvider<BalanceSheet?> {
  BalanceSheetProvider._({
    required BalanceSheetFamily super.from,
    required LedgerDate super.argument,
  }) : super(
         retry: null,
         name: r'balanceSheetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$balanceSheetHash();

  @override
  String toString() {
    return r'balanceSheetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BalanceSheet?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BalanceSheet?> create(Ref ref) {
    final argument = this.argument as LedgerDate;
    return balanceSheet(ref, asOf: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BalanceSheetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$balanceSheetHash() => r'863adb5fc2c64c9d8ac097d91f4990155129bbca';

final class BalanceSheetFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BalanceSheet?>, LedgerDate> {
  BalanceSheetFamily._()
    : super(
        retry: null,
        name: r'balanceSheetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BalanceSheetProvider call({required LedgerDate asOf}) =>
      BalanceSheetProvider._(argument: asOf, from: this);

  @override
  String toString() => r'balanceSheetProvider';
}

@ProviderFor(accountLedger)
final accountLedgerProvider = AccountLedgerFamily._();

final class AccountLedgerProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountLedger?>,
          AccountLedger?,
          FutureOr<AccountLedger?>
        >
    with $FutureModifier<AccountLedger?>, $FutureProvider<AccountLedger?> {
  AccountLedgerProvider._({
    required AccountLedgerFamily super.from,
    required (String, {LedgerDate? from, LedgerDate? to}) super.argument,
  }) : super(
         retry: null,
         name: r'accountLedgerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountLedgerHash();

  @override
  String toString() {
    return r'accountLedgerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<AccountLedger?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountLedger?> create(Ref ref) {
    final argument =
        this.argument as (String, {LedgerDate? from, LedgerDate? to});
    return accountLedger(
      ref,
      argument.$1,
      from: argument.from,
      to: argument.to,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountLedgerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountLedgerHash() => r'984a9f3e412d47a559c6b1bf084c9ac84f976a5b';

final class AccountLedgerFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AccountLedger?>,
          (String, {LedgerDate? from, LedgerDate? to})
        > {
  AccountLedgerFamily._()
    : super(
        retry: null,
        name: r'accountLedgerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountLedgerProvider call(
    String accountId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => AccountLedgerProvider._(
    argument: (accountId, from: from, to: to),
    from: this,
  );

  @override
  String toString() => r'accountLedgerProvider';
}

@ProviderFor(groupSummary)
final groupSummaryProvider = GroupSummaryFamily._();

final class GroupSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<(ChartEntry, Money)>>,
          List<(ChartEntry, Money)>,
          FutureOr<List<(ChartEntry, Money)>>
        >
    with
        $FutureModifier<List<(ChartEntry, Money)>>,
        $FutureProvider<List<(ChartEntry, Money)>> {
  GroupSummaryProvider._({
    required GroupSummaryFamily super.from,
    required (String, {LedgerDate asOf}) super.argument,
  }) : super(
         retry: null,
         name: r'groupSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupSummaryHash();

  @override
  String toString() {
    return r'groupSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<(ChartEntry, Money)>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<(ChartEntry, Money)>> create(Ref ref) {
    final argument = this.argument as (String, {LedgerDate asOf});
    return groupSummary(ref, argument.$1, asOf: argument.asOf);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupSummaryHash() => r'4019dc9389254c3048f9c6211b075704856f22cb';

final class GroupSummaryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<(ChartEntry, Money)>>,
          (String, {LedgerDate asOf})
        > {
  GroupSummaryFamily._()
    : super(
        retry: null,
        name: r'groupSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupSummaryProvider call(String groupId, {required LedgerDate asOf}) =>
      GroupSummaryProvider._(argument: (groupId, asOf: asOf), from: this);

  @override
  String toString() => r'groupSummaryProvider';
}

/// Financial years from the first entry to today, newest first. Live.

@ProviderFor(financialYears)
final financialYearsProvider = FinancialYearsProvider._();

/// Financial years from the first entry to today, newest first. Live.

final class FinancialYearsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<YearRow>>,
          List<YearRow>,
          Stream<List<YearRow>>
        >
    with $FutureModifier<List<YearRow>>, $StreamProvider<List<YearRow>> {
  /// Financial years from the first entry to today, newest first. Live.
  FinancialYearsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialYearsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialYearsHash();

  @$internal
  @override
  $StreamProviderElement<List<YearRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<YearRow>> create(Ref ref) {
    return financialYears(ref);
  }
}

String _$financialYearsHash() => r'eea47252db5dd6b89e0864cd7372e21d9228fa94';

@ProviderFor(yearClosePreview)
final yearClosePreviewProvider = YearClosePreviewFamily._();

final class YearClosePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<YearClosePreview?>,
          YearClosePreview?,
          FutureOr<YearClosePreview?>
        >
    with
        $FutureModifier<YearClosePreview?>,
        $FutureProvider<YearClosePreview?> {
  YearClosePreviewProvider._({
    required YearClosePreviewFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearClosePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearClosePreviewHash();

  @override
  String toString() {
    return r'yearClosePreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<YearClosePreview?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<YearClosePreview?> create(Ref ref) {
    final argument = this.argument as int;
    return yearClosePreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearClosePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearClosePreviewHash() => r'99a513c47256dbb534ba06498aa599a42289686c';

final class YearClosePreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<YearClosePreview?>, int> {
  YearClosePreviewFamily._()
    : super(
        retry: null,
        name: r'yearClosePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearClosePreviewProvider call(int startYear) =>
      YearClosePreviewProvider._(argument: startYear, from: this);

  @override
  String toString() => r'yearClosePreviewProvider';
}

@ProviderFor(yearCloseWriter)
final yearCloseWriterProvider = YearCloseWriterProvider._();

final class YearCloseWriterProvider
    extends
        $FunctionalProvider<YearCloseWriter, YearCloseWriter, YearCloseWriter>
    with $Provider<YearCloseWriter> {
  YearCloseWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yearCloseWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yearCloseWriterHash();

  @$internal
  @override
  $ProviderElement<YearCloseWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  YearCloseWriter create(Ref ref) {
    return yearCloseWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YearCloseWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YearCloseWriter>(value),
    );
  }
}

String _$yearCloseWriterHash() => r'53b98c22376ab15236201be6be44badda364b92c';
