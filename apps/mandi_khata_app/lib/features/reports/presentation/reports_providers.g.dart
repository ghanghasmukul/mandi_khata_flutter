// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportsRepository)
final reportsRepositoryProvider = ReportsRepositoryProvider._();

final class ReportsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportsRepository>,
          ReportsRepository,
          FutureOr<ReportsRepository>
        >
    with
        $FutureModifier<ReportsRepository>,
        $FutureProvider<ReportsRepository> {
  ReportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ReportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportsRepository> create(Ref ref) {
    return reportsRepository(ref);
  }
}

String _$reportsRepositoryHash() => r'29132b6df225019299a10cf581a70867c35ea833';

/// Each report is read once per filter (a report is a snapshot; the screen's
/// refresh re-reads it). Empty without an active business.

@ProviderFor(outstandingReport)
final outstandingReportProvider = OutstandingReportFamily._();

/// Each report is read once per filter (a report is a snapshot; the screen's
/// refresh re-reads it). Empty without an active business.

final class OutstandingReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OutstandingRow>>,
          List<OutstandingRow>,
          FutureOr<List<OutstandingRow>>
        >
    with
        $FutureModifier<List<OutstandingRow>>,
        $FutureProvider<List<OutstandingRow>> {
  /// Each report is read once per filter (a report is a snapshot; the screen's
  /// refresh re-reads it). Empty without an active business.
  OutstandingReportProvider._({
    required OutstandingReportFamily super.from,
    required (ReportFilter, LedgerDate) super.argument,
  }) : super(
         retry: null,
         name: r'outstandingReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$outstandingReportHash();

  @override
  String toString() {
    return r'outstandingReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<OutstandingRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OutstandingRow>> create(Ref ref) {
    final argument = this.argument as (ReportFilter, LedgerDate);
    return outstandingReport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is OutstandingReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$outstandingReportHash() => r'972a90d8ca295b9600696cfb4f3224c98067a49d';

/// Each report is read once per filter (a report is a snapshot; the screen's
/// refresh re-reads it). Empty without an active business.

final class OutstandingReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<OutstandingRow>>,
          (ReportFilter, LedgerDate)
        > {
  OutstandingReportFamily._()
    : super(
        retry: null,
        name: r'outstandingReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Each report is read once per filter (a report is a snapshot; the screen's
  /// refresh re-reads it). Empty without an active business.

  OutstandingReportProvider call(ReportFilter filter, LedgerDate today) =>
      OutstandingReportProvider._(argument: (filter, today), from: this);

  @override
  String toString() => r'outstandingReportProvider';
}

@ProviderFor(arrivalsReport)
final arrivalsReportProvider = ArrivalsReportFamily._();

final class ArrivalsReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ArrivalRow>>,
          List<ArrivalRow>,
          FutureOr<List<ArrivalRow>>
        >
    with $FutureModifier<List<ArrivalRow>>, $FutureProvider<List<ArrivalRow>> {
  ArrivalsReportProvider._({
    required ArrivalsReportFamily super.from,
    required ReportFilter super.argument,
  }) : super(
         retry: null,
         name: r'arrivalsReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$arrivalsReportHash();

  @override
  String toString() {
    return r'arrivalsReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ArrivalRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ArrivalRow>> create(Ref ref) {
    final argument = this.argument as ReportFilter;
    return arrivalsReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ArrivalsReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$arrivalsReportHash() => r'4e1b3ee4884feebd6b314bc981a1898df28b1013';

final class ArrivalsReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ArrivalRow>>, ReportFilter> {
  ArrivalsReportFamily._()
    : super(
        retry: null,
        name: r'arrivalsReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArrivalsReportProvider call(ReportFilter filter) =>
      ArrivalsReportProvider._(argument: filter, from: this);

  @override
  String toString() => r'arrivalsReportProvider';
}

@ProviderFor(commissionReport)
final commissionReportProvider = CommissionReportFamily._();

final class CommissionReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommissionRow>>,
          List<CommissionRow>,
          FutureOr<List<CommissionRow>>
        >
    with
        $FutureModifier<List<CommissionRow>>,
        $FutureProvider<List<CommissionRow>> {
  CommissionReportProvider._({
    required CommissionReportFamily super.from,
    required ReportFilter super.argument,
  }) : super(
         retry: null,
         name: r'commissionReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commissionReportHash();

  @override
  String toString() {
    return r'commissionReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CommissionRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommissionRow>> create(Ref ref) {
    final argument = this.argument as ReportFilter;
    return commissionReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CommissionReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commissionReportHash() => r'3ea622e2ecfd8126caaba618e00d997d7b483d2c';

final class CommissionReportFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<CommissionRow>>, ReportFilter> {
  CommissionReportFamily._()
    : super(
        retry: null,
        name: r'commissionReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommissionReportProvider call(ReportFilter filter) =>
      CommissionReportProvider._(argument: filter, from: this);

  @override
  String toString() => r'commissionReportProvider';
}

@ProviderFor(paymentsReport)
final paymentsReportProvider = PaymentsReportFamily._();

final class PaymentsReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentRow>>,
          List<PaymentRow>,
          FutureOr<List<PaymentRow>>
        >
    with $FutureModifier<List<PaymentRow>>, $FutureProvider<List<PaymentRow>> {
  PaymentsReportProvider._({
    required PaymentsReportFamily super.from,
    required ReportFilter super.argument,
  }) : super(
         retry: null,
         name: r'paymentsReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentsReportHash();

  @override
  String toString() {
    return r'paymentsReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentRow>> create(Ref ref) {
    final argument = this.argument as ReportFilter;
    return paymentsReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentsReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentsReportHash() => r'34d5092807175848774d9169f604f45b36693c57';

final class PaymentsReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PaymentRow>>, ReportFilter> {
  PaymentsReportFamily._()
    : super(
        retry: null,
        name: r'paymentsReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaymentsReportProvider call(ReportFilter filter) =>
      PaymentsReportProvider._(argument: filter, from: this);

  @override
  String toString() => r'paymentsReportProvider';
}

@ProviderFor(statementsReport)
final statementsReportProvider = StatementsReportFamily._();

final class StatementsReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PartyStatement>>,
          List<PartyStatement>,
          FutureOr<List<PartyStatement>>
        >
    with
        $FutureModifier<List<PartyStatement>>,
        $FutureProvider<List<PartyStatement>> {
  StatementsReportProvider._({
    required StatementsReportFamily super.from,
    required ReportFilter super.argument,
  }) : super(
         retry: null,
         name: r'statementsReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statementsReportHash();

  @override
  String toString() {
    return r'statementsReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PartyStatement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PartyStatement>> create(Ref ref) {
    final argument = this.argument as ReportFilter;
    return statementsReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StatementsReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statementsReportHash() => r'790e8d21c069e9792fbd77d426aa53e6a712c13c';

final class StatementsReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PartyStatement>>,
          ReportFilter
        > {
  StatementsReportFamily._()
    : super(
        retry: null,
        name: r'statementsReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StatementsReportProvider call(ReportFilter filter) =>
      StatementsReportProvider._(argument: filter, from: this);

  @override
  String toString() => r'statementsReportProvider';
}

@ProviderFor(farmerVillages)
final farmerVillagesProvider = FarmerVillagesProvider._();

final class FarmerVillagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  FarmerVillagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'farmerVillagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$farmerVillagesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return farmerVillages(ref);
  }
}

String _$farmerVillagesHash() => r'311a031816d0995bff70c2e9e8646d4cfdd160f7';

/// Every loan with its figures on the report day (today when null), open
/// ones first.

@ProviderFor(karzaReport)
final karzaReportProvider = KarzaReportFamily._();

/// Every loan with its figures on the report day (today when null), open
/// ones first.

final class KarzaReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<KarzaRow>>,
          List<KarzaRow>,
          FutureOr<List<KarzaRow>>
        >
    with $FutureModifier<List<KarzaRow>>, $FutureProvider<List<KarzaRow>> {
  /// Every loan with its figures on the report day (today when null), open
  /// ones first.
  KarzaReportProvider._({
    required KarzaReportFamily super.from,
    required (ReportFilter, LedgerDate) super.argument,
  }) : super(
         retry: null,
         name: r'karzaReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$karzaReportHash();

  @override
  String toString() {
    return r'karzaReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<KarzaRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<KarzaRow>> create(Ref ref) {
    final argument = this.argument as (ReportFilter, LedgerDate);
    return karzaReport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is KarzaReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$karzaReportHash() => r'0073bacf15b7bdc851f5998fb7b0448faadf7aa4';

/// Every loan with its figures on the report day (today when null), open
/// ones first.

final class KarzaReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<KarzaRow>>,
          (ReportFilter, LedgerDate)
        > {
  KarzaReportFamily._()
    : super(
        retry: null,
        name: r'karzaReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every loan with its figures on the report day (today when null), open
  /// ones first.

  KarzaReportProvider call(ReportFilter filter, LedgerDate today) =>
      KarzaReportProvider._(argument: (filter, today), from: this);

  @override
  String toString() => r'karzaReportProvider';
}

/// Interest posted and waived in the period and accrued, not yet posted
/// (as of today).

@ProviderFor(interestEarnedReport)
final interestEarnedReportProvider = InterestEarnedReportFamily._();

/// Interest posted and waived in the period and accrued, not yet posted
/// (as of today).

final class InterestEarnedReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InterestEarnedRow>>,
          List<InterestEarnedRow>,
          FutureOr<List<InterestEarnedRow>>
        >
    with
        $FutureModifier<List<InterestEarnedRow>>,
        $FutureProvider<List<InterestEarnedRow>> {
  /// Interest posted and waived in the period and accrued, not yet posted
  /// (as of today).
  InterestEarnedReportProvider._({
    required InterestEarnedReportFamily super.from,
    required (ReportFilter, LedgerDate) super.argument,
  }) : super(
         retry: null,
         name: r'interestEarnedReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$interestEarnedReportHash();

  @override
  String toString() {
    return r'interestEarnedReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<InterestEarnedRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InterestEarnedRow>> create(Ref ref) {
    final argument = this.argument as (ReportFilter, LedgerDate);
    return interestEarnedReport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is InterestEarnedReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$interestEarnedReportHash() =>
    r'6e7c19f85668e4164725d4f71db4d58f6714e2e2';

/// Interest posted and waived in the period and accrued, not yet posted
/// (as of today).

final class InterestEarnedReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<InterestEarnedRow>>,
          (ReportFilter, LedgerDate)
        > {
  InterestEarnedReportFamily._()
    : super(
        retry: null,
        name: r'interestEarnedReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Interest posted and waived in the period and accrued, not yet posted
  /// (as of today).

  InterestEarnedReportProvider call(ReportFilter filter, LedgerDate today) =>
      InterestEarnedReportProvider._(argument: (filter, today), from: this);

  @override
  String toString() => r'interestEarnedReportProvider';
}
