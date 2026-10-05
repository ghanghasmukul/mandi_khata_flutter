// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest_posting_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(interestPostingRepository)
final interestPostingRepositoryProvider = InterestPostingRepositoryProvider._();

final class InterestPostingRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<InterestPostingRepository>,
          InterestPostingRepository,
          FutureOr<InterestPostingRepository>
        >
    with
        $FutureModifier<InterestPostingRepository>,
        $FutureProvider<InterestPostingRepository> {
  InterestPostingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interestPostingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interestPostingRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<InterestPostingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InterestPostingRepository> create(Ref ref) {
    return interestPostingRepository(ref);
  }
}

String _$interestPostingRepositoryHash() =>
    r'7fd37a14b0e3e0837ad8169e13fabc608988cdfb';

/// Postings and waivers of one party (khata and loans). Live.

@ProviderFor(partyPostings)
final partyPostingsProvider = PartyPostingsFamily._();

/// Postings and waivers of one party (khata and loans). Live.

final class PartyPostingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostingRow>>,
          List<PostingRow>,
          Stream<List<PostingRow>>
        >
    with $FutureModifier<List<PostingRow>>, $StreamProvider<List<PostingRow>> {
  /// Postings and waivers of one party (khata and loans). Live.
  PartyPostingsProvider._({
    required PartyPostingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyPostingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyPostingsHash();

  @override
  String toString() {
    return r'partyPostingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostingRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostingRow>> create(Ref ref) {
    final argument = this.argument as String;
    return partyPostings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyPostingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyPostingsHash() => r'd0700111991545caee1d69b16626163d248a4f4d';

/// Postings and waivers of one party (khata and loans). Live.

final class PartyPostingsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostingRow>>, String> {
  PartyPostingsFamily._()
    : super(
        retry: null,
        name: r'partyPostingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Postings and waivers of one party (khata and loans). Live.

  PartyPostingsProvider call(String partyId) =>
      PartyPostingsProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyPostingsProvider';
}

/// Accounts with interest to post as of [asOf] (one party only when
/// [partyId] is given). Read again when the postings or entries change.

@ProviderFor(postingCandidates)
final postingCandidatesProvider = PostingCandidatesFamily._();

/// Accounts with interest to post as of [asOf] (one party only when
/// [partyId] is given). Read again when the postings or entries change.

final class PostingCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostingCandidate>>,
          List<PostingCandidate>,
          FutureOr<List<PostingCandidate>>
        >
    with
        $FutureModifier<List<PostingCandidate>>,
        $FutureProvider<List<PostingCandidate>> {
  /// Accounts with interest to post as of [asOf] (one party only when
  /// [partyId] is given). Read again when the postings or entries change.
  PostingCandidatesProvider._({
    required PostingCandidatesFamily super.from,
    required (LedgerDate, {String? partyId}) super.argument,
  }) : super(
         retry: null,
         name: r'postingCandidatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postingCandidatesHash();

  @override
  String toString() {
    return r'postingCandidatesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PostingCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PostingCandidate>> create(Ref ref) {
    final argument = this.argument as (LedgerDate, {String? partyId});
    return postingCandidates(ref, argument.$1, partyId: argument.partyId);
  }

  @override
  bool operator ==(Object other) {
    return other is PostingCandidatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postingCandidatesHash() => r'c65a0030e6e993ed208b25d59634cd749b28c5cb';

/// Accounts with interest to post as of [asOf] (one party only when
/// [partyId] is given). Read again when the postings or entries change.

final class PostingCandidatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PostingCandidate>>,
          (LedgerDate, {String? partyId})
        > {
  PostingCandidatesFamily._()
    : super(
        retry: null,
        name: r'postingCandidatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Accounts with interest to post as of [asOf] (one party only when
  /// [partyId] is given). Read again when the postings or entries change.

  PostingCandidatesProvider call(LedgerDate asOf, {String? partyId}) =>
      PostingCandidatesProvider._(
        argument: (asOf, partyId: partyId),
        from: this,
      );

  @override
  String toString() => r'postingCandidatesProvider';
}

/// The day the bulk run proposes: the end of the last period of
/// `interest.post_frequency` (today for on demand).

@ProviderFor(suggestedPostingDay)
final suggestedPostingDayProvider = SuggestedPostingDayFamily._();

/// The day the bulk run proposes: the end of the last period of
/// `interest.post_frequency` (today for on demand).

final class SuggestedPostingDayProvider
    extends $FunctionalProvider<LedgerDate, LedgerDate, LedgerDate>
    with $Provider<LedgerDate> {
  /// The day the bulk run proposes: the end of the last period of
  /// `interest.post_frequency` (today for on demand).
  SuggestedPostingDayProvider._({
    required SuggestedPostingDayFamily super.from,
    required LedgerDate super.argument,
  }) : super(
         retry: null,
         name: r'suggestedPostingDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$suggestedPostingDayHash();

  @override
  String toString() {
    return r'suggestedPostingDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<LedgerDate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LedgerDate create(Ref ref) {
    final argument = this.argument as LedgerDate;
    return suggestedPostingDay(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LedgerDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LedgerDate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SuggestedPostingDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$suggestedPostingDayHash() =>
    r'27d3dabd5a5d265bf1023a0e8c56b4a040fba438';

/// The day the bulk run proposes: the end of the last period of
/// `interest.post_frequency` (today for on demand).

final class SuggestedPostingDayFamily extends $Family
    with $FunctionalFamilyOverride<LedgerDate, LedgerDate> {
  SuggestedPostingDayFamily._()
    : super(
        retry: null,
        name: r'suggestedPostingDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The day the bulk run proposes: the end of the last period of
  /// `interest.post_frequency` (today for on demand).

  SuggestedPostingDayProvider call(LedgerDate today) =>
      SuggestedPostingDayProvider._(argument: today, from: this);

  @override
  String toString() => r'suggestedPostingDayProvider';
}

@ProviderFor(interestPostingWriter)
final interestPostingWriterProvider = InterestPostingWriterProvider._();

final class InterestPostingWriterProvider
    extends
        $FunctionalProvider<
          InterestPostingWriter,
          InterestPostingWriter,
          InterestPostingWriter
        >
    with $Provider<InterestPostingWriter> {
  InterestPostingWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interestPostingWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interestPostingWriterHash();

  @$internal
  @override
  $ProviderElement<InterestPostingWriter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterestPostingWriter create(Ref ref) {
    return interestPostingWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterestPostingWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterestPostingWriter>(value),
    );
  }
}

String _$interestPostingWriterHash() =>
    r'010339dc10d56024d536cac08d1b6e04a216bc33';
