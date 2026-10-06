import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_backfill.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_providers.g.dart';

@Riverpod(keepAlive: true)
Future<JournalBackfill> journalBackfill(Ref ref) async =>
    JournalBackfill(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<BooksInvariants> booksInvariants(Ref ref) async =>
    BooksInvariants(await ref.watch(powerSyncDatabaseProvider.future));

/// Documents of the active business that have no journal entry yet.
@riverpod
Future<BackfillStatus?> booksStatus(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  final backfill = await ref.watch(journalBackfillProvider.future);
  return await backfill.status(tenantId);
}

/// How many entries and accounts the books checks flag (0 everywhere is
/// healthy).
class BooksChecks {
  const BooksChecks({
    required this.unbalanced,
    required this.partyDifferences,
    required this.bookDifferences,
  });

  final int unbalanced;
  final int partyDifferences;
  final int bookDifferences;

  bool get isHealthy =>
      unbalanced == 0 && partyDifferences == 0 && bookDifferences == 0;
}

@riverpod
Future<BooksChecks?> booksChecks(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  final books = await ref.watch(booksInvariantsProvider.future);
  return BooksChecks(
    unbalanced: (await books.unbalancedEntries(tenantId)).length,
    partyDifferences: (await books.partyDifferences(tenantId)).length,
    bookDifferences: (await books.bookDifferences(tenantId)).length,
  );
}
