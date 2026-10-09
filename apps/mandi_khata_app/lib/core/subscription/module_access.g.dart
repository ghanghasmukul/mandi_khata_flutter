// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_access.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether [module] (`khata`, `arrivals`, `karza`, `accounting`, `shop`) is
/// usable: the plan includes it AND the business has not switched it off
/// (`app.modules.<m>`). The switch can only turn a module off, never on.

@ProviderFor(moduleEnabled)
final moduleEnabledProvider = ModuleEnabledFamily._();

/// Whether [module] (`khata`, `arrivals`, `karza`, `accounting`, `shop`) is
/// usable: the plan includes it AND the business has not switched it off
/// (`app.modules.<m>`). The switch can only turn a module off, never on.

final class ModuleEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [module] (`khata`, `arrivals`, `karza`, `accounting`, `shop`) is
  /// usable: the plan includes it AND the business has not switched it off
  /// (`app.modules.<m>`). The switch can only turn a module off, never on.
  ModuleEnabledProvider._({
    required ModuleEnabledFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'moduleEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moduleEnabledHash();

  @override
  String toString() {
    return r'moduleEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return moduleEnabled(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleEnabledHash() => r'483f1c64ef22547811fb70a2325dae368dff1db2';

/// Whether [module] (`khata`, `arrivals`, `karza`, `accounting`, `shop`) is
/// usable: the plan includes it AND the business has not switched it off
/// (`app.modules.<m>`). The switch can only turn a module off, never on.

final class ModuleEnabledFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  ModuleEnabledFamily._()
    : super(
        retry: null,
        name: r'moduleEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [module] (`khata`, `arrivals`, `karza`, `accounting`, `shop`) is
  /// usable: the plan includes it AND the business has not switched it off
  /// (`app.modules.<m>`). The switch can only turn a module off, never on.

  ModuleEnabledProvider call(String module) =>
      ModuleEnabledProvider._(argument: module, from: this);

  @override
  String toString() => r'moduleEnabledProvider';
}
