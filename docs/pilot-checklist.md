# Pilot checklist: installing Mandi Khata at a customer's shop

For the first 2-3 arhtiyas. Allow half a day on site. Bring: a laptop with the
installers, the shop's Windows PC login, a phone with the Android build, a USB
cable, and a printed copy of this page. Record everything odd as you go.

## Before you leave (at home)

- [ ] A **tagged release** exists and its installers were tried on a clean
      Windows PC (installer runs, app starts, sign-in works). Windows is only
      ever built by CI, so the pilot is its first real test.
- [ ] Production Supabase + PowerSync are set up and the sync streams are
      deployed (`docs/ops.md`). Check by signing in on a test device: a party
      added on the laptop must appear on the phone, and **a payment's khata
      entry must come back after sync** (the dev instance once did not).
- [ ] The business and the owner's login exist, or you will create them with the
      owner on site. Know the owner's mobile number (OTP is sent to it) and
      check the phone gets SMS in that area; email + password is the fallback.
- [ ] PITR enabled on the production project (`docs/ops.md`).
- [ ] Printed: the shop's last 10 farmer pages from their paper khata, to
      compare against on day one.

## 1. Install (counter PC, ~15 min)

- [ ] Run `MandiKhata-Setup-X.Y.Z.exe`. Windows SmartScreen may warn ("unknown
      publisher") until the installer is code-signed: More info > Run anyway.
- [ ] Tick **desktop shortcut**. Start the app once.
- [ ] Note the Windows version, screen size and whether it has internet.
- [ ] Android phone (munshi): install the build, allow notifications /
      storage if asked.

## 2. First sign-in (~10 min)

- [ ] Language: pick the owner's language (EN / हिं / ਪੰ) from the top corner.
- [ ] Sign in with the owner's mobile and the SMS code.
- [ ] The device registers itself: it gets a code (`W1` for the first Windows
      PC, `A1` for the first phone). Write the codes down. Receipts and lot
      numbers carry them (`L-W1-0001`).
- [ ] Set an **app PIN** (the counter is shared). Test lock now and unlock.
- [ ] The top bar shows **Synced**. If it says "Offline" with internet on, stop
      and look at Diagnostics (account menu).

## 3. Onboarding (~30 min, owner + you)

- [ ] Run the wizard: business details, mandi and state, the crops they really
      handle, default commission and charges, interest defaults (stored only in
      this version), language, invite the munshi.
- [ ] **Check the charges against a paper bill they trust**: enter one real
      lot and compare gross, commission, palledari, net to farmer to the
      rupee. Fix settings (not code) until it matches. Write the lot number
      and the differences in `docs/decisions.md`.
- [ ] Import opening balances (Parties > Import) from their list. Preview
      first; every total must match their khata book's total.
- [ ] Invite the munshi by mobile; sign in on the phone; confirm the munshi
      sees no bank accounts and no Reverse buttons.

## 4. Printer test (~10 min)

- [ ] Record a small cash payment to a farmer and press **Print receipt** on
      the shop's own printer. Check: Hindi / Punjabi names print (not boxes),
      amount, receipt number, baki after payment, page fits.
- [ ] Print a farmer **statement** (A4) and **Share** it as a PDF to the
      owner's WhatsApp. Open it on the owner's phone.
- [ ] If the printer is a thermal roll printer, note the model: thermal
      layouts are step 6.2 and do not exist yet. Record it.

## 5. Offline test (~15 min)  *must pass before you leave*

- [ ] Unplug the network (Wi-Fi off / cable out). The chip says **Offline**.
- [ ] Add a farmer, receive a lot (weight and rate), post it, pay him cash,
      print the receipt, open his statement: everything works, balance is right.
- [ ] Do the same on the phone in airplane mode.
- [ ] Close and reopen the app while offline: data is still there.
- [ ] Reconnect. The chip goes to **Syncing** then **Synced**. On the other
      device, the farmer, lot, payment and the **same baki** appear.
- [ ] Menu > Diagnostics shows **no rejected changes**.

## 6. Backup and sync check (~10 min)

- [ ] Each device has a full local copy; the server copy is the backup. Confirm
      in the Supabase dashboard (you, not the customer) that today's entries
      are in `ledger_entries` for this business.
- [ ] Explain to the owner: keep the app open and online at least once a day
      so the phone's work reaches the counter PC; nothing is lost if it does
      not, it just syncs later.
- [ ] Show where **Reports** export (Excel / CSV / PDF) lives for his own
      backup of the khata, and that exports need the owner / accountant role.
- [ ] Show **Team > Devices** (revoke a lost phone) and the audit log (owner
      sees every munshi edit).

## 7. Day-one handover

- [ ] Leave the owner a one-page cheat sheet: new arrival, post, pay,
      statement, where the PIN is, who to call.
- [ ] Agree what they will run **in parallel with the paper khata** for the
      first 3-5 days, and when you will compare (Phase 1 exit criterion:
      numbers match their paper khata).
- [ ] Add yourself to their WhatsApp for questions; ask them to screenshot
      anything that looks wrong.

## What to record (in `docs/decisions.md`, one line each, dated)

Use the form `| date | Pilot <shop>: <finding> | <what we changed or will change> |`.

- Setup: OS, printer model, internet quality, SMS arrived? how long did
  install and onboarding take?
- Rules that differed from the code: charge formula, rounding, who bears
  mandi fee, commission on which amount, back-dating habits, how they treat
  advances. **Money-rule differences get a domain doc change first**
  (`docs/domain/`), then code.
- Screens they got stuck on, words in Hindi / Punjabi that read wrong (fix the
  ARB strings and note `TODO(translate)` ones).
- Anything the munshi could or could not do that surprised the owner.
- Every mismatch between the app's balance and their paper khata: party, date,
  both numbers, and the cause once found.
- Missing features they asked for (do not build now: list for Phase 2+).
- Crashes or sync errors: copy the Diagnostics text; check Sentry.
