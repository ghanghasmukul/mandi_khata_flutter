// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one local database. Every screen reads and writes only this; sync to
/// Supabase happens in the background (see SyncController).

@ProviderFor(powerSyncDatabase)
final powerSyncDatabaseProvider = PowerSyncDatabaseProvider._();

/// The one local database. Every screen reads and writes only this; sync to
/// Supabase happens in the background (see SyncController).

final class PowerSyncDatabaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<PowerSyncDatabase>,
          PowerSyncDatabase,
          FutureOr<PowerSyncDatabase>
        >
    with
        $FutureModifier<PowerSyncDatabase>,
        $FutureProvider<PowerSyncDatabase> {
  /// The one local database. Every screen reads and writes only this; sync to
  /// Supabase happens in the background (see SyncController).
  PowerSyncDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'powerSyncDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$powerSyncDatabaseHash();

  @$internal
  @override
  $FutureProviderElement<PowerSyncDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PowerSyncDatabase> create(Ref ref) {
    return powerSyncDatabase(ref);
  }
}

String _$powerSyncDatabaseHash() => r'e8305826ccb6cf3028ca62e442414618f3963afc';

/// Typed Drift access to the same database.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Typed Drift access to the same database.

final class AppDatabaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppDatabase>,
          AppDatabase,
          FutureOr<AppDatabase>
        >
    with $FutureModifier<AppDatabase>, $FutureProvider<AppDatabase> {
  /// Typed Drift access to the same database.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $FutureProviderElement<AppDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppDatabase> create(Ref ref) {
    return appDatabase(ref);
  }
}

String _$appDatabaseHash() => r'd7f17c06854a8f6116990b19e1b4f8083040421a';
