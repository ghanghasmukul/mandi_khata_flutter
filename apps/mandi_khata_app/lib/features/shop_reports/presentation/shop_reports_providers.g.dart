// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shopReportsRepository)
final shopReportsRepositoryProvider = ShopReportsRepositoryProvider._();

final class ShopReportsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ShopReportsRepository>,
          ShopReportsRepository,
          FutureOr<ShopReportsRepository>
        >
    with
        $FutureModifier<ShopReportsRepository>,
        $FutureProvider<ShopReportsRepository> {
  ShopReportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopReportsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopReportsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ShopReportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ShopReportsRepository> create(Ref ref) {
    return shopReportsRepository(ref);
  }
}

String _$shopReportsRepositoryHash() =>
    r'f1d61ffeb9dfb4a9cdc945554c6e686a3821c92a';

/// The shop module switch (`app.modules.shop`); on until the business turns
/// it off.

@ProviderFor(shopModuleEnabled)
final shopModuleEnabledProvider = ShopModuleEnabledProvider._();

/// The shop module switch (`app.modules.shop`); on until the business turns
/// it off.

final class ShopModuleEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// The shop module switch (`app.modules.shop`); on until the business turns
  /// it off.
  ShopModuleEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopModuleEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopModuleEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return shopModuleEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shopModuleEnabledHash() => r'ba4d45549f31bf01a4efbe8c23b8e07e44619a23';

@ProviderFor(supplierPayables)
final supplierPayablesProvider = SupplierPayablesFamily._();

final class SupplierPayablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupplierPayable>>,
          List<SupplierPayable>,
          Stream<List<SupplierPayable>>
        >
    with
        $FutureModifier<List<SupplierPayable>>,
        $StreamProvider<List<SupplierPayable>> {
  SupplierPayablesProvider._({
    required SupplierPayablesFamily super.from,
    required LedgerDate super.argument,
  }) : super(
         retry: null,
         name: r'supplierPayablesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$supplierPayablesHash();

  @override
  String toString() {
    return r'supplierPayablesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SupplierPayable>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupplierPayable>> create(Ref ref) {
    final argument = this.argument as LedgerDate;
    return supplierPayables(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierPayablesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$supplierPayablesHash() => r'43f51960537eb07bc1a9d0cf47151717a3e505a6';

final class SupplierPayablesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SupplierPayable>>, LedgerDate> {
  SupplierPayablesFamily._()
    : super(
        retry: null,
        name: r'supplierPayablesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SupplierPayablesProvider call(LedgerDate today) =>
      SupplierPayablesProvider._(argument: today, from: this);

  @override
  String toString() => r'supplierPayablesProvider';
}

@ProviderFor(customerReceivables)
final customerReceivablesProvider = CustomerReceivablesProvider._();

final class CustomerReceivablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomerReceivable>>,
          List<CustomerReceivable>,
          Stream<List<CustomerReceivable>>
        >
    with
        $FutureModifier<List<CustomerReceivable>>,
        $StreamProvider<List<CustomerReceivable>> {
  CustomerReceivablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerReceivablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerReceivablesHash();

  @$internal
  @override
  $StreamProviderElement<List<CustomerReceivable>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CustomerReceivable>> create(Ref ref) {
    return customerReceivables(ref);
  }
}

String _$customerReceivablesHash() =>
    r'2a840a6a682c8804f655a2319ca88c45fba6d92c';

/// The khata of [partyId] by what created each entry (a snapshot when the
/// dialog opens).

@ProviderFor(khataBreakdown)
final khataBreakdownProvider = KhataBreakdownFamily._();

/// The khata of [partyId] by what created each entry (a snapshot when the
/// dialog opens).

final class KhataBreakdownProvider
    extends
        $FunctionalProvider<
          AsyncValue<KhataBreakdown>,
          KhataBreakdown,
          FutureOr<KhataBreakdown>
        >
    with $FutureModifier<KhataBreakdown>, $FutureProvider<KhataBreakdown> {
  /// The khata of [partyId] by what created each entry (a snapshot when the
  /// dialog opens).
  KhataBreakdownProvider._({
    required KhataBreakdownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'khataBreakdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$khataBreakdownHash();

  @override
  String toString() {
    return r'khataBreakdownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<KhataBreakdown> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KhataBreakdown> create(Ref ref) {
    final argument = this.argument as String;
    return khataBreakdown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is KhataBreakdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$khataBreakdownHash() => r'09f3d2975625508a0f3114547c9cd6c5c8e45faf';

/// The khata of [partyId] by what created each entry (a snapshot when the
/// dialog opens).

final class KhataBreakdownFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<KhataBreakdown>, String> {
  KhataBreakdownFamily._()
    : super(
        retry: null,
        name: r'khataBreakdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The khata of [partyId] by what created each entry (a snapshot when the
  /// dialog opens).

  KhataBreakdownProvider call(String partyId) =>
      KhataBreakdownProvider._(argument: partyId, from: this);

  @override
  String toString() => r'khataBreakdownProvider';
}

@ProviderFor(profitRecords)
final profitRecordsProvider = ProfitRecordsFamily._();

final class ProfitRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SaleLineRecord>>,
          List<SaleLineRecord>,
          Stream<List<SaleLineRecord>>
        >
    with
        $FutureModifier<List<SaleLineRecord>>,
        $StreamProvider<List<SaleLineRecord>> {
  ProfitRecordsProvider._({
    required ProfitRecordsFamily super.from,
    required (LedgerDate, LedgerDate) super.argument,
  }) : super(
         retry: null,
         name: r'profitRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profitRecordsHash();

  @override
  String toString() {
    return r'profitRecordsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<SaleLineRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SaleLineRecord>> create(Ref ref) {
    final argument = this.argument as (LedgerDate, LedgerDate);
    return profitRecords(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfitRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profitRecordsHash() => r'657067ecdc57204899680fa9826e6afb12f06f10';

final class ProfitRecordsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<SaleLineRecord>>,
          (LedgerDate, LedgerDate)
        > {
  ProfitRecordsFamily._()
    : super(
        retry: null,
        name: r'profitRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfitRecordsProvider call(LedgerDate from, LedgerDate to) =>
      ProfitRecordsProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'profitRecordsProvider';
}

/// One month of GSTR-1 data. Waits for the business settings (GSTIN and
/// state decide intra- or inter-state).

@ProviderFor(gstMonth)
final gstMonthProvider = GstMonthFamily._();

/// One month of GSTR-1 data. Waits for the business settings (GSTIN and
/// state decide intra- or inter-state).

final class GstMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<GstMonthData>,
          GstMonthData,
          Stream<GstMonthData>
        >
    with $FutureModifier<GstMonthData>, $StreamProvider<GstMonthData> {
  /// One month of GSTR-1 data. Waits for the business settings (GSTIN and
  /// state decide intra- or inter-state).
  GstMonthProvider._({
    required GstMonthFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'gstMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gstMonthHash();

  @override
  String toString() {
    return r'gstMonthProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<GstMonthData> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GstMonthData> create(Ref ref) {
    final argument = this.argument as (int, int);
    return gstMonth(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GstMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gstMonthHash() => r'7dedf5b34e18dbfaaba0d896daa9dc2e82cd3b60';

/// One month of GSTR-1 data. Waits for the business settings (GSTIN and
/// state decide intra- or inter-state).

final class GstMonthFamily extends $Family
    with $FunctionalFamilyOverride<Stream<GstMonthData>, (int, int)> {
  GstMonthFamily._()
    : super(
        retry: null,
        name: r'gstMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One month of GSTR-1 data. Waits for the business settings (GSTIN and
  /// state decide intra- or inter-state).

  GstMonthProvider call(int year, int month) =>
      GstMonthProvider._(argument: (year, month), from: this);

  @override
  String toString() => r'gstMonthProvider';
}

@ProviderFor(expiryRows)
final expiryRowsProvider = ExpiryRowsFamily._();

final class ExpiryRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpiryRow>>,
          List<ExpiryRow>,
          Stream<List<ExpiryRow>>
        >
    with $FutureModifier<List<ExpiryRow>>, $StreamProvider<List<ExpiryRow>> {
  ExpiryRowsProvider._({
    required ExpiryRowsFamily super.from,
    required LedgerDate super.argument,
  }) : super(
         retry: null,
         name: r'expiryRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expiryRowsHash();

  @override
  String toString() {
    return r'expiryRowsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ExpiryRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ExpiryRow>> create(Ref ref) {
    final argument = this.argument as LedgerDate;
    return expiryRows(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpiryRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expiryRowsHash() => r'adeb56b2a5d6b5844893aba2bb48a0127fc9bca9';

final class ExpiryRowsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ExpiryRow>>, LedgerDate> {
  ExpiryRowsFamily._()
    : super(
        retry: null,
        name: r'expiryRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpiryRowsProvider call(LedgerDate today) =>
      ExpiryRowsProvider._(argument: today, from: this);

  @override
  String toString() => r'expiryRowsProvider';
}

@ProviderFor(reorderSuggestions)
final reorderSuggestionsProvider = ReorderSuggestionsFamily._();

final class ReorderSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReorderSuggestion>>,
          List<ReorderSuggestion>,
          Stream<List<ReorderSuggestion>>
        >
    with
        $FutureModifier<List<ReorderSuggestion>>,
        $StreamProvider<List<ReorderSuggestion>> {
  ReorderSuggestionsProvider._({
    required ReorderSuggestionsFamily super.from,
    required LedgerDate super.argument,
  }) : super(
         retry: null,
         name: r'reorderSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reorderSuggestionsHash();

  @override
  String toString() {
    return r'reorderSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReorderSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReorderSuggestion>> create(Ref ref) {
    final argument = this.argument as LedgerDate;
    return reorderSuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReorderSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reorderSuggestionsHash() =>
    r'a639c82b083d94fad0d84abbfc8207863af0d30e';

final class ReorderSuggestionsFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<ReorderSuggestion>>, LedgerDate> {
  ReorderSuggestionsFamily._()
    : super(
        retry: null,
        name: r'reorderSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReorderSuggestionsProvider call(LedgerDate today) =>
      ReorderSuggestionsProvider._(argument: today, from: this);

  @override
  String toString() => r'reorderSuggestionsProvider';
}
