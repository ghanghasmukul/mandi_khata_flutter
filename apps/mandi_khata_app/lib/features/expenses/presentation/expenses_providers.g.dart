// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expensesRepository)
final expensesRepositoryProvider = ExpensesRepositoryProvider._();

final class ExpensesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExpensesRepository>,
          ExpensesRepository,
          FutureOr<ExpensesRepository>
        >
    with
        $FutureModifier<ExpensesRepository>,
        $FutureProvider<ExpensesRepository> {
  ExpensesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ExpensesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExpensesRepository> create(Ref ref) {
    return expensesRepository(ref);
  }
}

String _$expensesRepositoryHash() =>
    r'7386871a7b7ceb12f84813cea3c99cbebe71d94d';

/// Sends a bill to Supabase Storage. A provider so tests replace it.

@ProviderFor(billUploadFn)
final billUploadFnProvider = BillUploadFnProvider._();

/// Sends a bill to Supabase Storage. A provider so tests replace it.

final class BillUploadFnProvider
    extends $FunctionalProvider<BillUploadFn, BillUploadFn, BillUploadFn>
    with $Provider<BillUploadFn> {
  /// Sends a bill to Supabase Storage. A provider so tests replace it.
  BillUploadFnProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billUploadFnProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billUploadFnHash();

  @$internal
  @override
  $ProviderElement<BillUploadFn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BillUploadFn create(Ref ref) {
    return billUploadFn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillUploadFn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillUploadFn>(value),
    );
  }
}

String _$billUploadFnHash() => r'235a2d3893e64ff8ec46f10a3a0fd099ff4072e0';

@ProviderFor(billUploader)
final billUploaderProvider = BillUploaderProvider._();

final class BillUploaderProvider
    extends
        $FunctionalProvider<
          AsyncValue<BillUploader>,
          BillUploader,
          FutureOr<BillUploader>
        >
    with $FutureModifier<BillUploader>, $FutureProvider<BillUploader> {
  BillUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billUploaderHash();

  @$internal
  @override
  $FutureProviderElement<BillUploader> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BillUploader> create(Ref ref) {
    return billUploader(ref);
  }
}

String _$billUploaderHash() => r'6236360ed77addd1f77ba6fc37f11478eddb4bb9';

/// Runs the bill uploads whenever sync is connected and a photo waits.
/// Watched for the app's lifetime (main.dart).

@ProviderFor(billUploadRunner)
final billUploadRunnerProvider = BillUploadRunnerProvider._();

/// Runs the bill uploads whenever sync is connected and a photo waits.
/// Watched for the app's lifetime (main.dart).

final class BillUploadRunnerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Runs the bill uploads whenever sync is connected and a photo waits.
  /// Watched for the app's lifetime (main.dart).
  BillUploadRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billUploadRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billUploadRunnerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return billUploadRunner(ref);
  }
}

String _$billUploadRunnerHash() => r'a7361bbec5e9a6aad0df00c85feb8b341ce9932b';

/// Bill photos of the active business waiting for upload on this device.
/// Live.

@ProviderFor(pendingBills)
final pendingBillsProvider = PendingBillsProvider._();

/// Bill photos of the active business waiting for upload on this device.
/// Live.

final class PendingBillsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Bill photos of the active business waiting for upload on this device.
  /// Live.
  PendingBillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingBillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingBillsHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return pendingBills(ref);
  }
}

String _$pendingBillsHash() => r'78c32d834635d451066e8655496bd940d9e81c26';

@ProviderFor(expenseCategories)
final expenseCategoriesProvider = ExpenseCategoriesProvider._();

final class ExpenseCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseCategory>>,
          List<ExpenseCategory>,
          Stream<List<ExpenseCategory>>
        >
    with
        $FutureModifier<List<ExpenseCategory>>,
        $StreamProvider<List<ExpenseCategory>> {
  ExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<ExpenseCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ExpenseCategory>> create(Ref ref) {
    return expenseCategories(ref);
  }
}

String _$expenseCategoriesHash() => r'f0cf0239e3218490477e612d05d8f62b3ebf9f41';

@ProviderFor(expenseList)
final expenseListProvider = ExpenseListFamily._();

final class ExpenseListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expense>>,
          List<Expense>,
          Stream<List<Expense>>
        >
    with $FutureModifier<List<Expense>>, $StreamProvider<List<Expense>> {
  ExpenseListProvider._({
    required ExpenseListFamily super.from,
    required ({LedgerDate? from, LedgerDate? to}) super.argument,
  }) : super(
         retry: null,
         name: r'expenseListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseListHash();

  @override
  String toString() {
    return r'expenseListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Expense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Expense>> create(Ref ref) {
    final argument = this.argument as ({LedgerDate? from, LedgerDate? to});
    return expenseList(ref, from: argument.from, to: argument.to);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseListHash() => r'c6c45711516d1035beae27733cd4c427857de8aa';

final class ExpenseListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Expense>>,
          ({LedgerDate? from, LedgerDate? to})
        > {
  ExpenseListFamily._()
    : super(
        retry: null,
        name: r'expenseListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseListProvider call({LedgerDate? from, LedgerDate? to}) =>
      ExpenseListProvider._(argument: (from: from, to: to), from: this);

  @override
  String toString() => r'expenseListProvider';
}

@ProviderFor(recurringExpenses)
final recurringExpensesProvider = RecurringExpensesProvider._();

final class RecurringExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringExpense>>,
          List<RecurringExpense>,
          Stream<List<RecurringExpense>>
        >
    with
        $FutureModifier<List<RecurringExpense>>,
        $StreamProvider<List<RecurringExpense>> {
  RecurringExpensesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringExpensesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringExpensesHash();

  @$internal
  @override
  $StreamProviderElement<List<RecurringExpense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecurringExpense>> create(Ref ref) {
    return recurringExpenses(ref);
  }
}

String _$recurringExpensesHash() => r'0397fca52b62c7649b953b1043a0949b914448e5';

@ProviderFor(dueRecurring)
final dueRecurringProvider = DueRecurringProvider._();

final class DueRecurringProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DueRecurring>>,
          List<DueRecurring>,
          Stream<List<DueRecurring>>
        >
    with
        $FutureModifier<List<DueRecurring>>,
        $StreamProvider<List<DueRecurring>> {
  DueRecurringProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dueRecurringProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dueRecurringHash();

  @$internal
  @override
  $StreamProviderElement<List<DueRecurring>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DueRecurring>> create(Ref ref) {
    return dueRecurring(ref);
  }
}

String _$dueRecurringHash() => r'1ab37f3a43745626901dbb399526440e1329281e';

/// Expenses by category and month for [from]..[to].

@ProviderFor(expensePivot)
final expensePivotProvider = ExpensePivotFamily._();

/// Expenses by category and month for [from]..[to].

final class ExpensePivotProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExpensePivot>,
          ExpensePivot,
          FutureOr<ExpensePivot>
        >
    with $FutureModifier<ExpensePivot>, $FutureProvider<ExpensePivot> {
  /// Expenses by category and month for [from]..[to].
  ExpensePivotProvider._({
    required ExpensePivotFamily super.from,
    required ({LedgerDate? from, LedgerDate? to}) super.argument,
  }) : super(
         retry: null,
         name: r'expensePivotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expensePivotHash();

  @override
  String toString() {
    return r'expensePivotProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ExpensePivot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExpensePivot> create(Ref ref) {
    final argument = this.argument as ({LedgerDate? from, LedgerDate? to});
    return expensePivot(ref, from: argument.from, to: argument.to);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensePivotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expensePivotHash() => r'8969e40c1b6b07828027871c130c9a8ef7e22340';

/// Expenses by category and month for [from]..[to].

final class ExpensePivotFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ExpensePivot>,
          ({LedgerDate? from, LedgerDate? to})
        > {
  ExpensePivotFamily._()
    : super(
        retry: null,
        name: r'expensePivotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Expenses by category and month for [from]..[to].

  ExpensePivotProvider call({LedgerDate? from, LedgerDate? to}) =>
      ExpensePivotProvider._(argument: (from: from, to: to), from: this);

  @override
  String toString() => r'expensePivotProvider';
}

/// The photo at [path]: from this device if it still has it, else a short
/// signed link from Storage (online only); null when neither.

@ProviderFor(billImage)
final billImageProvider = BillImageFamily._();

/// The photo at [path]: from this device if it still has it, else a short
/// signed link from Storage (online only); null when neither.

final class BillImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<({Uint8List? bytes, String? url})?>,
          ({Uint8List? bytes, String? url})?,
          FutureOr<({Uint8List? bytes, String? url})?>
        >
    with
        $FutureModifier<({Uint8List? bytes, String? url})?>,
        $FutureProvider<({Uint8List? bytes, String? url})?> {
  /// The photo at [path]: from this device if it still has it, else a short
  /// signed link from Storage (online only); null when neither.
  BillImageProvider._({
    required BillImageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'billImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$billImageHash();

  @override
  String toString() {
    return r'billImageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<({Uint8List? bytes, String? url})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({Uint8List? bytes, String? url})?> create(Ref ref) {
    final argument = this.argument as String;
    return billImage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BillImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$billImageHash() => r'f13fc3933515db92b5090a2c9f447fd50fe6b2e0';

/// The photo at [path]: from this device if it still has it, else a short
/// signed link from Storage (online only); null when neither.

final class BillImageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({Uint8List? bytes, String? url})?>,
          String
        > {
  BillImageFamily._()
    : super(
        retry: null,
        name: r'billImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The photo at [path]: from this device if it still has it, else a short
  /// signed link from Storage (online only); null when neither.

  BillImageProvider call(String path) =>
      BillImageProvider._(argument: path, from: this);

  @override
  String toString() => r'billImageProvider';
}

@ProviderFor(expensesWriter)
final expensesWriterProvider = ExpensesWriterProvider._();

final class ExpensesWriterProvider
    extends $FunctionalProvider<ExpensesWriter, ExpensesWriter, ExpensesWriter>
    with $Provider<ExpensesWriter> {
  ExpensesWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesWriterHash();

  @$internal
  @override
  $ProviderElement<ExpensesWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExpensesWriter create(Ref ref) {
    return expensesWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpensesWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpensesWriter>(value),
    );
  }
}

String _$expensesWriterHash() => r'7b74d211a98830b6a734e5e4f1c1a102e2cc0d77';
