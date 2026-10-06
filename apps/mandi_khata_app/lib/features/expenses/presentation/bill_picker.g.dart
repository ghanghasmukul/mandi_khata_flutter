// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(billPicker)
final billPickerProvider = BillPickerProvider._();

final class BillPickerProvider
    extends $FunctionalProvider<BillPickerFn, BillPickerFn, BillPickerFn>
    with $Provider<BillPickerFn> {
  BillPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billPickerHash();

  @$internal
  @override
  $ProviderElement<BillPickerFn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BillPickerFn create(Ref ref) {
    return billPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillPickerFn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillPickerFn>(value),
    );
  }
}

String _$billPickerHash() => r'79387a309a72abce9e745ce7b9219fbda6bda5cf';
