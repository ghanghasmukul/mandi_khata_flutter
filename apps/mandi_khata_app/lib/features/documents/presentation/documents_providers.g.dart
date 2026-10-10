// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentsRepository)
final documentsRepositoryProvider = DocumentsRepositoryProvider._();

final class DocumentsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DocumentsRepository>,
          DocumentsRepository,
          FutureOr<DocumentsRepository>
        >
    with
        $FutureModifier<DocumentsRepository>,
        $FutureProvider<DocumentsRepository> {
  DocumentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<DocumentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DocumentsRepository> create(Ref ref) {
    return documentsRepository(ref);
  }
}

String _$documentsRepositoryHash() =>
    r'64ac69e3096ecf7448f527e16478622b99b203dc';

/// Sends a file to Supabase Storage. A provider so tests replace it.

@ProviderFor(documentUploadFn)
final documentUploadFnProvider = DocumentUploadFnProvider._();

/// Sends a file to Supabase Storage. A provider so tests replace it.

final class DocumentUploadFnProvider
    extends
        $FunctionalProvider<
          DocumentUploadFn,
          DocumentUploadFn,
          DocumentUploadFn
        >
    with $Provider<DocumentUploadFn> {
  /// Sends a file to Supabase Storage. A provider so tests replace it.
  DocumentUploadFnProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentUploadFnProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentUploadFnHash();

  @$internal
  @override
  $ProviderElement<DocumentUploadFn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DocumentUploadFn create(Ref ref) {
    return documentUploadFn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentUploadFn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentUploadFn>(value),
    );
  }
}

String _$documentUploadFnHash() => r'246eee8df8c7e1d5648b1000cfd9723b68465dd9';

@ProviderFor(documentUploader)
final documentUploaderProvider = DocumentUploaderProvider._();

final class DocumentUploaderProvider
    extends
        $FunctionalProvider<
          AsyncValue<DocumentUploader>,
          DocumentUploader,
          FutureOr<DocumentUploader>
        >
    with $FutureModifier<DocumentUploader>, $FutureProvider<DocumentUploader> {
  DocumentUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentUploaderHash();

  @$internal
  @override
  $FutureProviderElement<DocumentUploader> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DocumentUploader> create(Ref ref) {
    return documentUploader(ref);
  }
}

String _$documentUploaderHash() => r'dcf27bde817ea5f65bbaaf2ecedf7a9869f07e61';

/// Runs the document uploads whenever sync is connected and a file waits.
/// Watched for the app's lifetime (main.dart).

@ProviderFor(documentUploadRunner)
final documentUploadRunnerProvider = DocumentUploadRunnerProvider._();

/// Runs the document uploads whenever sync is connected and a file waits.
/// Watched for the app's lifetime (main.dart).

final class DocumentUploadRunnerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Runs the document uploads whenever sync is connected and a file waits.
  /// Watched for the app's lifetime (main.dart).
  DocumentUploadRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentUploadRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentUploadRunnerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return documentUploadRunner(ref);
  }
}

String _$documentUploadRunnerHash() =>
    r'd9316cac95f338c09412fc3d81b7039918d81387';

/// Files of the active business waiting for upload on this device. Live.

@ProviderFor(pendingDocuments)
final pendingDocumentsProvider = PendingDocumentsProvider._();

/// Files of the active business waiting for upload on this device. Live.

final class PendingDocumentsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Files of the active business waiting for upload on this device. Live.
  PendingDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingDocumentsHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return pendingDocuments(ref);
  }
}

String _$pendingDocumentsHash() => r'f3b49f6bc9975cf80fdef32e5131e5557dc91854';

/// Documents of one party that the signed-in member may see. Live.

@ProviderFor(partyDocuments)
final partyDocumentsProvider = PartyDocumentsFamily._();

/// Documents of one party that the signed-in member may see. Live.

final class PartyDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PartyDocument>>,
          List<PartyDocument>,
          Stream<List<PartyDocument>>
        >
    with
        $FutureModifier<List<PartyDocument>>,
        $StreamProvider<List<PartyDocument>> {
  /// Documents of one party that the signed-in member may see. Live.
  PartyDocumentsProvider._({
    required PartyDocumentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyDocumentsHash();

  @override
  String toString() {
    return r'partyDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PartyDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PartyDocument>> create(Ref ref) {
    final argument = this.argument as String;
    return partyDocuments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyDocumentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyDocumentsHash() => r'039139b996331dcebf23df598ba85511cc9af375';

/// Documents of one party that the signed-in member may see. Live.

final class PartyDocumentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PartyDocument>>, String> {
  PartyDocumentsFamily._()
    : super(
        retry: null,
        name: r'partyDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Documents of one party that the signed-in member may see. Live.

  PartyDocumentsProvider call(String partyId) =>
      PartyDocumentsProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyDocumentsProvider';
}

/// The file (or its thumbnail) at [path]: from this device if it is still
/// waiting to upload, else a short signed link (online only); null when
/// neither.

@ProviderFor(documentImage)
final documentImageProvider = DocumentImageFamily._();

/// The file (or its thumbnail) at [path]: from this device if it is still
/// waiting to upload, else a short signed link (online only); null when
/// neither.

final class DocumentImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<({Uint8List? bytes, String? url})?>,
          ({Uint8List? bytes, String? url})?,
          FutureOr<({Uint8List? bytes, String? url})?>
        >
    with
        $FutureModifier<({Uint8List? bytes, String? url})?>,
        $FutureProvider<({Uint8List? bytes, String? url})?> {
  /// The file (or its thumbnail) at [path]: from this device if it is still
  /// waiting to upload, else a short signed link (online only); null when
  /// neither.
  DocumentImageProvider._({
    required DocumentImageFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'documentImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$documentImageHash();

  @override
  String toString() {
    return r'documentImageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({Uint8List? bytes, String? url})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({Uint8List? bytes, String? url})?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return documentImage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$documentImageHash() => r'761a42f9a83e16f91a4b3fa85626edfb864712dc';

/// The file (or its thumbnail) at [path]: from this device if it is still
/// waiting to upload, else a short signed link (online only); null when
/// neither.

final class DocumentImageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({Uint8List? bytes, String? url})?>,
          (String, String)
        > {
  DocumentImageFamily._()
    : super(
        retry: null,
        name: r'documentImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The file (or its thumbnail) at [path]: from this device if it is still
  /// waiting to upload, else a short signed link (online only); null when
  /// neither.

  DocumentImageProvider call(String bucket, String path) =>
      DocumentImageProvider._(argument: (bucket, path), from: this);

  @override
  String toString() => r'documentImageProvider';
}

@ProviderFor(documentPicker)
final documentPickerProvider = DocumentPickerProvider._();

final class DocumentPickerProvider
    extends
        $FunctionalProvider<
          DocumentPickerFn,
          DocumentPickerFn,
          DocumentPickerFn
        >
    with $Provider<DocumentPickerFn> {
  DocumentPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentPickerHash();

  @$internal
  @override
  $ProviderElement<DocumentPickerFn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DocumentPickerFn create(Ref ref) {
    return documentPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentPickerFn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentPickerFn>(value),
    );
  }
}

String _$documentPickerHash() => r'a05c1aa61b88eb5fe3f24a54486fdaa6421eb348';

@ProviderFor(documentWriter)
final documentWriterProvider = DocumentWriterProvider._();

final class DocumentWriterProvider
    extends $FunctionalProvider<DocumentWriter, DocumentWriter, DocumentWriter>
    with $Provider<DocumentWriter> {
  DocumentWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentWriterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentWriterHash();

  @$internal
  @override
  $ProviderElement<DocumentWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DocumentWriter create(Ref ref) {
    return documentWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentWriter>(value),
    );
  }
}

String _$documentWriterHash() => r'6f1f72d21612c9ec9c087b0af3eb61462a1e55de';
