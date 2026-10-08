# Phase 4 translation review (hi / pa)

Machine-first-pass translations of the Phase 4 (input shop) strings. A native speaker should check these first.
Phase 4 keys = keys added since commit 656a0de (prod*, purchase*, pos*, sales*, invoice*, shr*, navSectionShop).

| Key | English | Hindi | Punjabi | Doubt |
|---|---|---|---|---|
| prodUnitBag / prodUnitPc | Bag / Piece | बोरी / नग | ਬੋਰੀ / ਨਗ | Is "bori" right for fertiliser/seed bags, and "nag" for piece? |
| purchaseFreight | Freight | भाड़ा | ਭਾੜਾ | Common word at the mandi? |
| purchaseMfg / prodBatchMfg | Mfg date | बनने की तारीख़ | ਬਣਨ ਦੀ ਤਾਰੀਖ਼ | Shopkeepers may say "mfg date" in English |
| purchaseExpiry / prodAdjExpiry | Expiry date | एक्सपायरी की तारीख़ | ਮਿਆਦ ਖ਼ਤਮ ਹੋਣ ਦੀ ਤਾਰੀਖ਼ | hi uses एक्सपायरी, pa uses ਮਿਆਦ: consistent? |
| purchaseRefundKhata | Credit note on khata | खाते में जमा | ਖਾਤੇ ਵਿੱਚ ਜਮ੍ਹਾਂ | Meaning of supplier credit note |
| purchaseRefundCash | Money back | पैसे वापस | ਪੈਸੇ ਵਾਪਸ | Natural? |
| purchaseCreditDays | Credit days | उधार के दिन | ਉਧਾਰ ਦੇ ਦਿਨ | Or "रियायत के दिन"? |
| purchaseReverse / salesReverseAction | Reverse purchase / bill | खरीद रद्द करें / बिल रद्द करें | ਖਰੀਦ ਰੱਦ ਕਰੋ / ਬਿੱਲ ਰੱਦ ਕਰੋ | "Reverse" mapped to "cancel"; ledger reversal is not a delete |
| prodBatchMovements | Stock book | स्टॉक बही | ਸਟਾਕ ਬਹੀ | Term "bahi" for stock movement list |
| prodBatchRebuild | Repair quantities | मात्रा ठीक करें | ਮਾਤਰਾ ਠੀਕ ਕਰੋ | Technical action, wording unclear to users |
| prodBatchStale | Stored quantity differs from the stock book | दर्ज मात्रा स्टॉक बही से मेल नहीं खाती | ਦਰਜ ਮਾਤਰਾ ਸਟਾਕ ਬਹੀ ਨਾਲ ਮੇਲ ਨਹੀਂ ਖਾਂਦੀ | Long, maybe awkward |
| prodDeactivate / prodActivate | Stop selling / Sell again | बेचना बंद करें / फिर से बेचें | ਵੇਚਣਾ ਬੰਦ ਕਰੋ / ਫਿਰ ਤੋਂ ਵੇਚੋ | |
| prodReasonAdjustment, prodAdjTitle | Adjustment / Adjust stock | सुधार / स्टॉक सुधारें | ਸੋਧ / ਸਟਾਕ ਠੀਕ ਕਰੋ | Hi सुधार vs pa ਸੋਧ differ; fine? |
| prodFieldReorder | Reorder level | दोबारा मंगवाने का स्तर | ਦੁਬਾਰਾ ਮੰਗਵਾਉਣ ਦਾ ਪੱਧਰ | Maybe "कम से कम स्टॉक" / "ਘੱਟੋ-ਘੱਟ ਸਟਾਕ" is more natural |
| prodImp* (import) | Import | इम्पोर्ट | ਇੰਪੋਰਟ | Loan-word; OK for shopkeepers? |
| prodImpHelp | Columns: SKU ... | long sentence | long sentence | Check whole sentence |
| prodTileOut / posOutOfStock | Out of stock | स्टॉक खत्म | ਸਟਾਕ ਖਤਮ | |
| prodErrHasStock | Adjust the stock to zero before deleting | हटाने से पहले स्टॉक सुधारकर शून्य करें | ਹਟਾਉਣ ਤੋਂ ਪਹਿਲਾਂ ਸਟਾਕ ਠੀਕ ਕਰਕੇ ਜ਼ੀਰੋ ਕਰੋ | |
| shrDuesTitle | Payables & receivables | देना और लेना | ਦੇਣਾ ਤੇ ਲੈਣਾ | Replaced formal देय/प्राप्य |
| shrGstTabSummary | Summary | कुल सार | ਕੁੱਲ ਸਾਰ | |
| invoiceThanks | Thank you. Visit again. | धन्यवाद। फिर पधारें। | ਧੰਨਵਾਦ। ਫਿਰ ਪਧਾਰਿਓ। | Punjabi form |
| shr / pos Hindi-Punjabi (existing) | Taxable | कर योग्य | ਟੈਕਸ ਯੋਗ | Formal; may be unfamiliar to shopkeepers |
| posTier* | Farmer / Retail / Vendor / Wholesale | किसान / खुदरा / विक्रेता / थोक | ਕਿਸਾਨ / ਪਰਚੂਨ / ਵਿਕਰੇਤਾ / ਥੋਕ | Already translated (not changed); check |
| salesRefundAuto | Auto | स्वतः (existing) / अपने-आप (purchase) | ਆਪਣੇ-ਆਪ | Slight inconsistency between sales and purchase |

Other changes in the same pass: Devanagari/Gurmukhi spellings of GST, GSTIN, HSN, CGST, SGST, IGST, UPI, PDF in pos*/sales*/shr* were switched to Latin script; "उत्पाद"/"ਉਤਪਾਦ" was changed to "प्रोडक्ट"/"ਪ੍ਰੋਡਕਟ" to match the rest of the app.
