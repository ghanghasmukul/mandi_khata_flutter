# Glossary (mandi terms)

| Term | Meaning | In code |
|---|---|---|
| Arhtiya / Aadhti | Commission agent in the mandi. Our customer (tenant). | `tenant` |
| Munshi | Clerk / accountant working for the arhtiya. | role `munshi` |
| Khata | Ledger / account book of a party. | `ledger_entries` |
| Jama | Credit to the party — **we owe them** (e.g. crop sold on their behalf). | `side = 'jama'` (credit) |
| Udhaar / Naam | Debit to the party — **they owe us** (cash given, inputs sold on credit, interest). | `side = 'udhaar'` (debit) |
| Baki | Running balance. Positive = we owe party (jama). Negative = party owes us (udhaar). | `balance` |
| Bhugtaan | Payment made to a party. | `payment` |
| Karza | Loan / advance given to a farmer. | `loan` |
| Byaj | Interest. | `interest` |
| Chakravardhi byaj | Compound interest. | `compounding != simple` |
| Arhat / Dami | Commission earned by arhtiya on crop sale (e.g. 2.5%). | `commission` |
| Palledari | Labour charge for loading/unloading, per bag. | charge `palledari` |
| Bardana | Gunny bag cost, per bag. | charge `bardana` |
| Tulai | Weighing charge, per quintal. | charge `tulai` |
| Mandi fee / Market fee | Fee to the market committee, % of gross. | charge `mandi_fee` |
| RDF / cess | Rural development fund / other cess, % of gross (state-specific). | charge `cess_*` |
| Lot / Dheri | A farmer's heap of produce in the mandi, auctioned as one unit. | `lot` |
| Aamad | Arrival of produce. | `arrival` |
| J-Form / I-Form | Govt sale receipt (Punjab/Haryana) for the farmer's crop. | `j_form_no` |
| Quintal (qtl) | 100 kg. | `unit = qtl` |
| Party | Any contact: farmer, customer, supplier, vendor, agency, buyer. One record, many roles. | `party` + `party_roles` |
| Price tier | Farmer / Retail / Vendor / Wholesale price level in the input shop. | `price_tier` |
