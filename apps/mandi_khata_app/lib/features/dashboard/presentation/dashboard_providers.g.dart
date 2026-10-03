// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider = DashboardRepositoryProvider._();

final class DashboardRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardRepository>,
          DashboardRepository,
          FutureOr<DashboardRepository>
        >
    with
        $FutureModifier<DashboardRepository>,
        $FutureProvider<DashboardRepository> {
  DashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<DashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardRepository> create(Ref ref) {
    return dashboardRepository(ref);
  }
}

String _$dashboardRepositoryHash() =>
    r'c7653ecc567eab4bf6360ac209a874be2f35f822';

/// Today's date on this device; moves on at midnight so a dashboard left open
/// overnight shows the new day.

@ProviderFor(today)
final todayProvider = TodayProvider._();

/// Today's date on this device; moves on at midnight so a dashboard left open
/// overnight shows the new day.

final class TodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<LedgerDate>,
          LedgerDate,
          Stream<LedgerDate>
        >
    with $FutureModifier<LedgerDate>, $StreamProvider<LedgerDate> {
  /// Today's date on this device; moves on at midnight so a dashboard left open
  /// overnight shows the new day.
  TodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayHash();

  @$internal
  @override
  $StreamProviderElement<LedgerDate> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<LedgerDate> create(Ref ref) {
    return today(ref);
  }
}

String _$todayHash() => r'd1e27c4b1d0452d23222d9c8410b8c0aefa9c813';

/// Lots, arhat, payments and receipts of today. Live.

@ProviderFor(daySummary)
final daySummaryProvider = DaySummaryProvider._();

/// Lots, arhat, payments and receipts of today. Live.

final class DaySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DaySummary>,
          DaySummary,
          Stream<DaySummary>
        >
    with $FutureModifier<DaySummary>, $StreamProvider<DaySummary> {
  /// Lots, arhat, payments and receipts of today. Live.
  DaySummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'daySummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$daySummaryHash();

  @$internal
  @override
  $StreamProviderElement<DaySummary> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DaySummary> create(Ref ref) {
    return daySummary(ref);
  }
}

String _$daySummaryHash() => r'dd8f1df1825162833bcd0a8d58253c45b4753c99';

/// Arhat earned on each of the last ten days. Live.

@ProviderFor(earnedDays)
final earnedDaysProvider = EarnedDaysProvider._();

/// Arhat earned on each of the last ten days. Live.

final class EarnedDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DayAmount>>,
          List<DayAmount>,
          Stream<List<DayAmount>>
        >
    with $FutureModifier<List<DayAmount>>, $StreamProvider<List<DayAmount>> {
  /// Arhat earned on each of the last ten days. Live.
  EarnedDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'earnedDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$earnedDaysHash();

  @$internal
  @override
  $StreamProviderElement<List<DayAmount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DayAmount>> create(Ref ref) {
    return earnedDays(ref);
  }
}

String _$earnedDaysHash() => r'2ad88b6e42f8230c06de63c1d9e1bd078b09c4b8';

/// This financial year's sales per crop. Live.

@ProviderFor(cropMix)
final cropMixProvider = CropMixProvider._();

/// This financial year's sales per crop. Live.

final class CropMixProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CropSale>>,
          List<CropSale>,
          Stream<List<CropSale>>
        >
    with $FutureModifier<List<CropSale>>, $StreamProvider<List<CropSale>> {
  /// This financial year's sales per crop. Live.
  CropMixProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cropMixProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cropMixHash();

  @$internal
  @override
  $StreamProviderElement<List<CropSale>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CropSale>> create(Ref ref) {
    return cropMix(ref);
  }
}

String _$cropMixHash() => r'439fdb4710504fedb10a33cf271f0ec86b88fc95';

/// What we owe and are owed. Live.

@ProviderFor(moneyPosition)
final moneyPositionProvider = MoneyPositionProvider._();

/// What we owe and are owed. Live.

final class MoneyPositionProvider
    extends
        $FunctionalProvider<
          AsyncValue<MoneyPosition>,
          MoneyPosition,
          Stream<MoneyPosition>
        >
    with $FutureModifier<MoneyPosition>, $StreamProvider<MoneyPosition> {
  /// What we owe and are owed. Live.
  MoneyPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moneyPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moneyPositionHash();

  @$internal
  @override
  $StreamProviderElement<MoneyPosition> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MoneyPosition> create(Ref ref) {
    return moneyPosition(ref);
  }
}

String _$moneyPositionHash() => r'e5cc518c0e81120ed6eecbef749579c0ea960ee6';

/// Cheques due and munshi changes. Live.

@ProviderFor(attentionCounts)
final attentionCountsProvider = AttentionCountsProvider._();

/// Cheques due and munshi changes. Live.

final class AttentionCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttentionCounts>,
          AttentionCounts,
          Stream<AttentionCounts>
        >
    with $FutureModifier<AttentionCounts>, $StreamProvider<AttentionCounts> {
  /// Cheques due and munshi changes. Live.
  AttentionCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attentionCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attentionCountsHash();

  @$internal
  @override
  $StreamProviderElement<AttentionCounts> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AttentionCounts> create(Ref ref) {
    return attentionCounts(ref);
  }
}

String _$attentionCountsHash() => r'1377ee4210f2920d20e8c91cf248a09922b08e5f';
