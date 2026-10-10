// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackupService>,
          BackupService,
          FutureOr<BackupService>
        >
    with $FutureModifier<BackupService>, $FutureProvider<BackupService> {
  BackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $FutureProviderElement<BackupService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackupService> create(Ref ref) {
    return backupService(ref);
  }
}

String _$backupServiceHash() => r'069d867ec8b072771e9db1503f3ed975ee687266';

/// Time of the last backup of the active business on this PC; refreshed by
/// [backupRunNow] and the scheduler.

@ProviderFor(LastBackup)
final lastBackupProvider = LastBackupProvider._();

/// Time of the last backup of the active business on this PC; refreshed by
/// [backupRunNow] and the scheduler.
final class LastBackupProvider
    extends $NotifierProvider<LastBackup, DateTime?> {
  /// Time of the last backup of the active business on this PC; refreshed by
  /// [backupRunNow] and the scheduler.
  LastBackupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastBackupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastBackupHash();

  @$internal
  @override
  LastBackup create() => LastBackup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$lastBackupHash() => r'e9af9eeb689677a98c46be627d4f9a90121f768b';

/// Time of the last backup of the active business on this PC; refreshed by
/// [backupRunNow] and the scheduler.

abstract class _$LastBackup extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Writes a backup now with the saved folder / passphrase. Returns the file
/// path, or null when the backup is not set up.

@ProviderFor(backupRunNow)
final backupRunNowProvider = BackupRunNowProvider._();

/// Writes a backup now with the saved folder / passphrase. Returns the file
/// path, or null when the backup is not set up.

final class BackupRunNowProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Writes a backup now with the saved folder / passphrase. Returns the file
  /// path, or null when the backup is not set up.
  BackupRunNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRunNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRunNowHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return backupRunNow(ref);
  }
}

String _$backupRunNowHash() => r'352d7e4c5803fe888af565898158b74b999915cc';

/// Checks every 15 minutes whether the daily backup is due and runs it.
/// Watched for the app's lifetime (main.dart); does nothing off desktop or
/// when the owner has not turned it on.

@ProviderFor(backupScheduler)
final backupSchedulerProvider = BackupSchedulerProvider._();

/// Checks every 15 minutes whether the daily backup is due and runs it.
/// Watched for the app's lifetime (main.dart); does nothing off desktop or
/// when the owner has not turned it on.

final class BackupSchedulerProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Checks every 15 minutes whether the daily backup is due and runs it.
  /// Watched for the app's lifetime (main.dart); does nothing off desktop or
  /// when the owner has not turned it on.
  BackupSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSchedulerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return backupScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$backupSchedulerHash() => r'879d8939e7819e32763b4ade5bdd88302a68611d';
