# Notifications (WhatsApp & SMS), step 6.1

Messages to farmers, buyers and borrowers. The app never calls a messaging
provider. It writes a row to `notification_queue` (works offline, synced like
any other row) and the Edge Function `send-notifications` sends it once the
row reaches the server.

## Events

| Event key | When it is queued | Body parameters |
|---|---|---|
| `payment_receipt` | a payment is recorded | business, receipt no, amount, mode, baki after |
| `lot_slip` | a lot is posted | business, lot no, crop, net qty (qtl), net amount |
| `statement_link` | user taps "Send statement" | business, baki, link to the PDF |
| `loan_due` | user taps "Remind" on a loan due in ≤ 7 days or overdue | business, loan no, due date, outstanding |
| `interest_posted` | interest posted to a party | business, amount, period, baki after |

Each event has three template languages (en / hi / pa). The language is the
business's `app.default_language` (parties have no language field in v1).

Templates live in `khata_core` (`MessageTemplates`) and are mirrored by the
provider's approved template of the same name (`mk_<event>_<lang>`), because
WhatsApp Business only delivers pre-approved text outside a 24 h window. The
rendered `body` is stored on the row so that the SMS fallback and the
"Messages" screen show exactly what was sent. Money in a body is
written `₹1,55,580.00`.

## Settings (business level)

| Key | Default |
|---|---|
| `notify.whatsapp_receipts` | false (existing key, kept: `payment_receipt`) |
| `notify.lot_slip` | false |
| `notify.statement_link` | true (always user-initiated) |
| `notify.loan_due` | false |
| `notify.interest_posted` | false |
| `notify.channel` | `whatsapp` (`whatsapp`, `sms`, `whatsapp_then_sms`) |

Automatic events (`payment_receipt`, `lot_slip`, `interest_posted`) queue only
when their toggle is on. User-initiated ones (`statement_link`, `loan_due`) are
queued when the user taps the button; their toggle only turns the button off.

## Party opt-out

`parties.notify_opt_out boolean not null default false`. When true nothing is
queued for that party, automatic or manual. The party screen shows a switch.
A party without a valid mobile number is never queued either (the user is told
why).

## Phone numbers

Stored by the app as digits with country code, no `+`: `919876543210`. `parties.mobile` is already 10 digits, so the number is `91` + mobile. Input
of 10 digits starting 6-9 gets `91`; `+91` / `0091` / `091` prefixes and spaces,
dashes are stripped; anything else (not 12 digits starting `91`6-9...) is
invalid. Other countries are out of scope for v1.

## Queue and statuses

`queued → sending → sent → delivered → read`, or `failed`, or `skipped`
(the server found the party opted out / no number / provider off).
Only the server (service role) moves a row past `queued`. The app can:
insert (status `queued`), and set `cancelled` on a row that is still `queued`
(owner or the creator). Retry = a new row with `retry_of`. A failed row keeps
`error`; after 5 attempts (`attempts`) the sender stops.

`dedupe_key` (unique per tenant) makes enqueueing idempotent: for example
`payment_receipt:<payment id>`, so a double tap or a replayed upload never
sends twice. Manual re-sends add a counter to the key.

## Providers

`send-notifications` picks the provider from the secret `NOTIFY_PROVIDER`:
`twilio` (WhatsApp + SMS), `gupshup`, `generic` (POSTs JSON to
`NOTIFY_WEBHOOK_URL`, for Interakt / AiSensy or any BSP behind a small
adapter) or `log` (default; marks rows `skipped` with "no provider
configured"). One small interface:
`send({to, channel, template, language, params, body}) -> {messageId}`.
Delivery receipts arrive at the same function (`?status=1`, signature or shared
secret checked) and update `status`, `delivered_at`, `error`.

## Fallback without an API

"Share via WhatsApp" opens the platform share sheet with the PDF and the
rendered text (Android), or `https://wa.me/<number>?text=<body>` (desktop /
web) plus the PDF saved. Needs no setup and is always available.

## Permissions

Queueing: `payments.create` (receipts, statement, interest) or `arrivals.manage`
(lot slips) or `loans.manage` (loan reminders); the table policy accepts any
active member of the business with at least one of them (the app checks the
specific one). Reading the queue: all members. No client delete.
