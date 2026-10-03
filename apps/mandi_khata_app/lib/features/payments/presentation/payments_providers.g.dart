// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentsRepository)
final paymentsRepositoryProvider = PaymentsRepositoryProvider._();

final class PaymentsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaymentsRepository>,
          PaymentsRepository,
          FutureOr<PaymentsRepository>
        >
    with
        $FutureModifier<PaymentsRepository>,
        $FutureProvider<PaymentsRepository> {
  PaymentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PaymentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaymentsRepository> create(Ref ref) {
    return paymentsRepository(ref);
  }
}

String _$paymentsRepositoryHash() =>
    r'94483f1610ae03c79bb976bb6838e098962f742d';

@ProviderFor(bankAccountsRepository)
final bankAccountsRepositoryProvider = BankAccountsRepositoryProvider._();

final class BankAccountsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BankAccountsRepository>,
          BankAccountsRepository,
          FutureOr<BankAccountsRepository>
        >
    with
        $FutureModifier<BankAccountsRepository>,
        $FutureProvider<BankAccountsRepository> {
  BankAccountsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankAccountsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankAccountsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<BankAccountsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BankAccountsRepository> create(Ref ref) {
    return bankAccountsRepository(ref);
  }
}

String _$bankAccountsRepositoryHash() =>
    r'827e1c17478fd097afa313fb725b143a69d10cb0';

/// Payments of the active business matching [filter], newest first. Live.

@ProviderFor(paymentList)
final paymentListProvider = PaymentListFamily._();

/// Payments of the active business matching [filter], newest first. Live.

final class PaymentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Payment>>,
          List<Payment>,
          Stream<List<Payment>>
        >
    with $FutureModifier<List<Payment>>, $StreamProvider<List<Payment>> {
  /// Payments of the active business matching [filter], newest first. Live.
  PaymentListProvider._({
    required PaymentListFamily super.from,
    required PaymentFilter super.argument,
  }) : super(
         retry: null,
         name: r'paymentListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentListHash();

  @override
  String toString() {
    return r'paymentListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Payment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Payment>> create(Ref ref) {
    final argument = this.argument as PaymentFilter;
    return paymentList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentListHash() => r'13e26927a9aa4a48ddb1fefd2a118305ffd9bbe9';

/// Payments of the active business matching [filter], newest first. Live.

final class PaymentListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Payment>>, PaymentFilter> {
  PaymentListFamily._()
    : super(
        retry: null,
        name: r'paymentListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Payments of the active business matching [filter], newest first. Live.

  PaymentListProvider call(PaymentFilter filter) =>
      PaymentListProvider._(argument: filter, from: this);

  @override
  String toString() => r'paymentListProvider';
}

/// One payment of the active business; null if missing.

@ProviderFor(payment)
final paymentProvider = PaymentFamily._();

/// One payment of the active business; null if missing.

final class PaymentProvider
    extends
        $FunctionalProvider<AsyncValue<Payment?>, Payment?, Stream<Payment?>>
    with $FutureModifier<Payment?>, $StreamProvider<Payment?> {
  /// One payment of the active business; null if missing.
  PaymentProvider._({
    required PaymentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paymentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentHash();

  @override
  String toString() {
    return r'paymentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Payment?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Payment?> create(Ref ref) {
    final argument = this.argument as String;
    return payment(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentHash() => r'c716a14732e30eb2513c9a33e75e2c953fb577b8';

/// One payment of the active business; null if missing.

final class PaymentFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Payment?>, String> {
  PaymentFamily._()
    : super(
        retry: null,
        name: r'paymentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One payment of the active business; null if missing.

  PaymentProvider call(String id) =>
      PaymentProvider._(argument: id, from: this);

  @override
  String toString() => r'paymentProvider';
}

/// The number the next payment of [direction] on this device will get.

@ProviderFor(nextPaymentNo)
final nextPaymentNoProvider = NextPaymentNoFamily._();

/// The number the next payment of [direction] on this device will get.

final class NextPaymentNoProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The number the next payment of [direction] on this device will get.
  NextPaymentNoProvider._({
    required NextPaymentNoFamily super.from,
    required PaymentDirection super.argument,
  }) : super(
         retry: null,
         name: r'nextPaymentNoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nextPaymentNoHash();

  @override
  String toString() {
    return r'nextPaymentNoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as PaymentDirection;
    return nextPaymentNo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NextPaymentNoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nextPaymentNoHash() => r'48f242153e3f24b9d6898edba9a92da560901230';

/// The number the next payment of [direction] on this device will get.

final class NextPaymentNoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, PaymentDirection> {
  NextPaymentNoFamily._()
    : super(
        retry: null,
        name: r'nextPaymentNoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The number the next payment of [direction] on this device will get.

  NextPaymentNoProvider call(PaymentDirection direction) =>
      NextPaymentNoProvider._(argument: direction, from: this);

  @override
  String toString() => r'nextPaymentNoProvider';
}

/// Cash and bank accounts of the active business (a device without finance
/// access only has Cash). Live.

@ProviderFor(bankAccountList)
final bankAccountListProvider = BankAccountListFamily._();

/// Cash and bank accounts of the active business (a device without finance
/// access only has Cash). Live.

final class BankAccountListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BankAccount>>,
          List<BankAccount>,
          Stream<List<BankAccount>>
        >
    with
        $FutureModifier<List<BankAccount>>,
        $StreamProvider<List<BankAccount>> {
  /// Cash and bank accounts of the active business (a device without finance
  /// access only has Cash). Live.
  BankAccountListProvider._({
    required BankAccountListFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'bankAccountListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bankAccountListHash();

  @override
  String toString() {
    return r'bankAccountListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BankAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BankAccount>> create(Ref ref) {
    final argument = this.argument as bool;
    return bankAccountList(ref, includeInactive: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BankAccountListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bankAccountListHash() => r'2a423145517c221ced0b25d2910c0616d2ad92ed';

/// Cash and bank accounts of the active business (a device without finance
/// access only has Cash). Live.

final class BankAccountListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BankAccount>>, bool> {
  BankAccountListFamily._()
    : super(
        retry: null,
        name: r'bankAccountListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cash and bank accounts of the active business (a device without finance
  /// access only has Cash). Live.

  BankAccountListProvider call({bool includeInactive = false}) =>
      BankAccountListProvider._(argument: includeInactive, from: this);

  @override
  String toString() => r'bankAccountListProvider';
}

/// Book balance (money in − out) of every account. Live.

@ProviderFor(accountBalances)
final accountBalancesProvider = AccountBalancesProvider._();

/// Book balance (money in − out) of every account. Live.

final class AccountBalancesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Money>>,
          Map<String, Money>,
          Stream<Map<String, Money>>
        >
    with
        $FutureModifier<Map<String, Money>>,
        $StreamProvider<Map<String, Money>> {
  /// Book balance (money in − out) of every account. Live.
  AccountBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountBalancesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountBalancesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Money>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Money>> create(Ref ref) {
    return accountBalances(ref);
  }
}

String _$accountBalancesHash() => r'a12788f07968c11a1e3220ee02d8156127467da1';

@ProviderFor(paymentWriter)
final paymentWriterProvider = PaymentWriterProvider._();

final class PaymentWriterProvider
    extends $FunctionalProvider<PaymentWriter, PaymentWriter, PaymentWriter>
    with $Provider<PaymentWriter> {
  PaymentWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentWriterHash();

  @$internal
  @override
  $ProviderElement<PaymentWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaymentWriter create(Ref ref) {
    return paymentWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentWriter>(value),
    );
  }
}

String _$paymentWriterHash() => r'1fe01c8113d75f940d2e605a65a13f0a7d2f405c';
