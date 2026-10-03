// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(auditRepository)
final auditRepositoryProvider = AuditRepositoryProvider._();

final class AuditRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuditRepository>,
          AuditRepository,
          FutureOr<AuditRepository>
        >
    with $FutureModifier<AuditRepository>, $FutureProvider<AuditRepository> {
  AuditRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<AuditRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuditRepository> create(Ref ref) {
    return auditRepository(ref);
  }
}

String _$auditRepositoryHash() => r'c248b74d29f6841aac2c783f6716c789b32d6628';

/// Audit entries of the active business for [filter], newest first, at most
/// [limit]. Live.

@ProviderFor(auditEntries)
final auditEntriesProvider = AuditEntriesFamily._();

/// Audit entries of the active business for [filter], newest first, at most
/// [limit]. Live.

final class AuditEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditEntry>>,
          List<AuditEntry>,
          Stream<List<AuditEntry>>
        >
    with $FutureModifier<List<AuditEntry>>, $StreamProvider<List<AuditEntry>> {
  /// Audit entries of the active business for [filter], newest first, at most
  /// [limit]. Live.
  AuditEntriesProvider._({
    required AuditEntriesFamily super.from,
    required (AuditFilter, int) super.argument,
  }) : super(
         retry: null,
         name: r'auditEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$auditEntriesHash();

  @override
  String toString() {
    return r'auditEntriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AuditEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AuditEntry>> create(Ref ref) {
    final argument = this.argument as (AuditFilter, int);
    return auditEntries(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AuditEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$auditEntriesHash() => r'2736dca0550d20352b6fe244b5209e1669d0f8dd';

/// Audit entries of the active business for [filter], newest first, at most
/// [limit]. Live.

final class AuditEntriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AuditEntry>>,
          (AuditFilter, int)
        > {
  AuditEntriesFamily._()
    : super(
        retry: null,
        name: r'auditEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Audit entries of the active business for [filter], newest first, at most
  /// [limit]. Live.

  AuditEntriesProvider call(AuditFilter filter, int limit) =>
      AuditEntriesProvider._(argument: (filter, limit), from: this);

  @override
  String toString() => r'auditEntriesProvider';
}

/// People who wrote to the log, for the user filter.

@ProviderFor(auditWriters)
final auditWritersProvider = AuditWritersProvider._();

/// People who wrote to the log, for the user filter.

final class AuditWritersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({String id, String name})>>,
          List<({String id, String name})>,
          Stream<List<({String id, String name})>>
        >
    with
        $FutureModifier<List<({String id, String name})>>,
        $StreamProvider<List<({String id, String name})>> {
  /// People who wrote to the log, for the user filter.
  AuditWritersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditWritersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditWritersHash();

  @$internal
  @override
  $StreamProviderElement<List<({String id, String name})>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<({String id, String name})>> create(Ref ref) {
    return auditWriters(ref);
  }
}

String _$auditWritersHash() => r'8527943130276841e005ee0bad7031e6c1b936fd';
