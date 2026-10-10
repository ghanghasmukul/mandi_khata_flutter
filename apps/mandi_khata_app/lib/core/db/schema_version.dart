/// Version of the local database layout (`powerSyncSchema`), bumped by hand
/// on EVERY change to it: a new table, column or index.
///
/// PowerSync keeps the data in generic tables and exposes each table as a
/// view, so changing the schema never rewrites or loses rows: the app opens
/// an old file with the new schema and the views simply change. What can go
/// wrong is the other direction (an old app reading a newer layout) and
/// forgetting to tell anyone. So:
///
/// * `test/core/db/schema_version_test.dart` pins a fingerprint of the
///   schema to this number and fails when the schema changes without a bump;
/// * the same test opens a database written with the previous layout and
///   checks the data survives and new tables work;
/// * a release that changes the layout in a way older apps cannot sync with
///   raises `min_supported` in `latest.json` (docs/release.md), which makes
///   older apps show the non-dismissable update banner.
const int localSchemaVersion = 1;
