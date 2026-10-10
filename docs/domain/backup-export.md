# Backup, restore and export (step 6.4)

Owner only (`Backup & export` in Settings). Read-only/locked businesses can
still export (it only reads).

## Download all my data

ZIP: `xlsx/<table>.xlsx` for every table that has rows (all business tables of
this business, nothing of other businesses), `statements.pdf` (every party's
khata, one party per page, in the app language) and a `README.txt`. Money
columns are in paise (`*_paise`). Built from the local database, works offline.

## Encrypted local backup (Windows / macOS)

- File `MandiKhata-<business>-<yyyyMMdd-HHmm>.mkbak` in a chosen folder / USB
  stick, once a day while the app is open (checked every 15 min; also 30 s
  after start). Newest 14 are kept. Written as `.part` then renamed.
- Format: `MKBAK1` + PBKDF2 iterations (120 000) + salt + nonce + AES-256-GCM
  ciphertext of the gzip'd snapshot JSON. The snapshot lists every business
  table with its columns and rows.
- Not saved (server owns them, a sign-in brings them back): members, devices,
  invites, subscription, plan requests, support sessions, platform tables.
- **The passphrase is stored in the app's preferences file on that PC** so the
  backup runs unattended. It protects a copied/lost backup file, not a PC that
  is already compromised. If the owner forgets the passphrase the file cannot
  be opened.

## Restore

Into a fresh install of the **same business** (signed in, device registered)
that has no parties, ledger entries or lots yet. One transaction, one audit
row (`backup_restore`); the rows then upload like normal writes (client UUIDs,
so nothing duplicates). Refused: other business, non-empty install, newer
format. If the server still has the data, a restore is not needed: just sign in.
