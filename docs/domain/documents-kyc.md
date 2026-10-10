# Party documents and KYC (step 6.3)

Files attached to a party: Aadhaar, PAN, bank passbook, cheque, J-form, loan
agreement, other.

## Access

| Type | Who can see / add | Bucket |
|---|---|---|
| `aadhaar`, `pan` (identity) | **owner only** | `kyc-docs` |
| the rest | `parties.manage` (owner, accountant, munshi) | `party-docs` |

Deleting (soft) needs `master.delete`; an identity document can only be
deleted by the owner. Enforced three ways: UI hides the types, RLS on
`party_documents` and on `storage.objects` (`private.can_use_party_document`),
and sync streams (identity rows only go to owners via `owner_kyc`).

## The number is never stored

For identity documents the person may type the number. The app validates it
(Aadhaar: 12 digits, first 2-9, Verhoeff check digit; PAN: `AAAAA9999A`) and
keeps only a masked form in `id_masked`: `XXXX XXXX 1234`, `XXXXXX234F`. The
full number is not written to the database, the audit log or the queue. SQL
refuses a masked value that looks like a full number.

## Files

- Photos are scaled to 1600 px (longest side), JPEG 80, plus a 240 px
  thumbnail. PDFs are kept as they are. Limit 6 MB after compression
  (bucket limit 10 MB). HEIC that cannot be decoded is kept whole, no thumbnail.
- Path `<tenant>/<party>/<document>/<file>`; the first folder is the business.
  Thumbnail: `<path>.thumb.jpg`.
- Offline: the row and an upload job (`document_uploads`, local only) are
  written in one transaction. The uploader sends the jobs when online and
  retries failures; after upload the local copy of the bytes is dropped.
- Viewing: from the local copy while it is still waiting, otherwise a
  10-minute signed URL (online only).
- Camera capture on Android / iOS (`image_picker`); file picker elsewhere.
- Deleting a document keeps the file in Storage (recoverable by the owner).
