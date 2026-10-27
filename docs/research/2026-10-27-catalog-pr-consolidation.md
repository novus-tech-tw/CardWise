# Card catalog consolidation: stale weekly PRs #76, #77, #79, #80 (2026-10-27)

## Summary

Four automated weekly catalog PRs (#76 2026-07-20, #77 2026-08-10, #79 2026-08-31,
#80 2026-09-14) were branched from old bases. They conflicted with `main` (catalog
version 7, 2026-10-17) and reused version 7, so none could merge as-is. Overlapping
changes also disagreed with each other.

This change consolidates them into PR #80:

1. `cards.json` was reset to `main`'s copy (merge commit), so no newer `main` data is lost.
2. Every unique field-level change proposed by any of the four PRs (61 cards) was
   checked against **official issuer sources** as of 2026-10-27. Only verified changes
   were re-applied. Unsupported or stale proposals were rejected, and `main`'s value
   was kept.
3. Errors on `main` found during that review were corrected when an official source
   confirmed them (see "Corrections to existing main data").
4. Catalog `version` 7 → 8, `updatedAt` 2026-10-27.

Decision totals across all groups: 112 apply, 23 partial (applied with corrections),
35 already on main, 36 rejected, 13 unverified (main kept). 66 of 114 cards changed.
No card ids were added, removed or renamed.

## Method

- A structured diff of each PR's `cards.json` against its own merge base lists the
  changes that PR actually proposed. Rewards are keyed by (category, note). Credits are
  keyed by id.
- Proposals were grouped by issuer and verified with live fetches of issuer product
  pages, terms PDFs and press releases. Blogs were used only as leads.
- Where issuer pages could not be fetched directly (Bank of America JS-rendered pages,
  PenFed Akamai blocks, USAA timeouts, Discover's broken calendar widget), the
  decision used the issuer's own page text as returned by a search index. These are
  marked in the ledger and are weaker evidence than a direct fetch.

## Modeling rules applied

- **Conditional rates.** The engine hides rewards that carry a `note` on
  travel/hotels/airlines/dining/wholesale until the user opts in. Brand-only and
  portal-only rates (e.g. "United purchases", "Booked through Capital One Travel")
  must carry a note. Unconditional dining bonuses must not.
- **Combined caps.** Caps are modeled per category entry. When an issuer cap is shared
  across categories, each entry carries the full combined amount. This is more
  conservative than no cap, but it still overstates earning for a user who maxes out
  several categories in one period. Affected cards: Amex Gold, Bevy, Marriott Boundless and
  Bountiful, Southwest Plus and Premier, Ink Cash, BofA Customized Cash, US Bank
  Altitude Connect, Costco Anywhere, Sam's Club, Discover it Chrome.
- **Not modeled, not encoded.** These rates were excluded because the data model can't
  scope them to the merchant without overstating every purchase in the category:
  merchant-only rates on categories where notes are not conditional, such as Disney
  Premier 5% on Disney streaming sites, Costco 5% on Costco gas, and Instacart 5% on
  Instacart; and Capital One Entertainment 8%.
- **Known overestimates kept deliberately.**
  - **Freedom Flex Q4 2026 and Q1 2027 grocery.** These exclude Walmart and Target, but
    the engine's `walmart`/`target` categories fall back to `grocery`, so those merchants
    still match the rotating bonus. A category exclusion needs a model change.
  - **Sapphire Reserve 4x on flights and hotels booked direct.** This has no note, so it
    shows by default, because most airline and hotel purchases are direct bookings.
- **Effective dates.** Future-dated changes are not applied (see follow-ups).
- **Product identity.** New products that launched alongside a legacy card were not
  written over the legacy card id (Navy Federal Flagship Premier, Wyndham Earner
  Premier, OnePay CashRewards, Bilt Card 2.0).

## Corrections to existing main data (official sources in the ledger)

- **Rotating calendars (current quarter affected).**
  - Chase Freedom Flex Q3/Q4 2026 corrected: Q4 is grocery stores (excluding Walmart
    and Target) and dining, not amazon/wholesale/paypal. Q1 2027 added (grocery,
    streaming).
  - Discover it Cash Back and Discover it Student 2026 calendar replaced: Q1
    grocery/wholesale/streaming, Q2 dining/home improvement, Q3 gas/transit/drugstore,
    Q4 dining/entertainment/utilities.
    - **Provenance (weaker evidence; read this).** The calendar comes from discover.com's
      own rendered page text, as returned by a search index for
      <https://www.discover.com/credit-cards/cash-back/cashback-calendar.html> and
      <https://www.discover.com/credit-cards/cash-back/cashback-bonus.html>. That text
      includes the program footnote "Activate to earn 5% Cashback Bonus at Restaurants,
      Entertainment and Utilities from 10/1/26 ... through 12/31/26, on up to $1,500."
    - **Not reproducible by direct fetch.** Direct fetches of those pages return a cached
      2024 snapshot or a broken calendar widget, and the widget's `offers.json` only
      covers 2020–21. The per-card ledger entries below record the subagent's
      `unverified` verdict, made before this text was found. This section supersedes
      them.
    - **Corroboration.** Multiple secondary sources (TPG, CNBC Select, Forbes Advisor and
      others) quote the same term text.
    - **Why ship it.** `main`'s Q3/Q4 2026 (grocery/walmart, amazon/target) has no such
      support and contradicts every source found.
    - **`internet` and `phone`.** These are included because the same Discover footnote
      defines Utilities to include internet, cable, satellite TV and mobile/landline
      phone service paid online or by phone.
    - **Follow-up.** Confirm against a logged-in Discover calendar when possible.
- **Points cards stored as cash-back percentages.** 18 Chase points/miles cards
  (Sapphire Preferred/Reserve, Ink Preferred, United ×4, Southwest ×3, Marriott ×3,
  IHG ×2, World of Hyatt, Aeroplan, British Airways) and Discover it Miles now use
  `rewardType` points/miles with `isPercentage: false`. At the default 1¢/point the
  estimate is unchanged, but users can now set a per-card point value.
- **Base rates.** Hilton Honors 3x, Hilton Surpass 3x, Marriott Bevy 2x, Marriott
  Brilliant 2x, Marriott Boundless 2x, Marriott Bountiful 2x, IHG Premier 3x, IHG
  (Traveler) 2x, Ink Business Premier 2%, Ink Business Unlimited 1.5%, PenFed
  Pathfinder 1.5x.
- **Brand- or portal-only rates now conditional (note added).** Amex Platinum hotels,
  Hilton Aspire hotels, Marriott Bevy and Brilliant hotels, Delta Gold, Platinum and
  Reserve airlines, Capital One Venture X/Venture/VentureOne portal rates, JetBlue
  cards, Atmos Ascent (ex-Alaska) and Hawaiian airlines, Frontier, Priceline, Wyndham
  hotels, BofA Travel Rewards portal 3x.
- **Caps.** Amex Platinum flights $500,000/yr, Amex Gold dining $50,000/yr and grocery
  $25,000/yr.
- **Other.** Sapphire Reserve DoorDash $35/month. Aeroplan 3x travel, 2x gas and a $50
  semiannual Air Canada credit. Marriott Bold 2x internet. Citi Strata Premier 3x is
  air travel and hotels, not all travel. Wyndham Earner 3x EV charging. Wyndham Earner+
  4x gas and EV charging. Sam's Club 5% EV charging (shared $6,000 gas cap). Altitude
  Connect 5x prepaid hotels and car rentals in the U.S. Bank Travel Center.
- **Display names.** Citi Rewards+ → "Citi Strata Card" (Citi's successor product, same
  id). Alaska Airlines Visa → "Atmos Rewards Ascent Visa Signature". IHG Traveler →
  "IHG One Rewards Credit Card". Wells Fargo Bilt → marked retired.

## Follow-ups (not applied; need a dated update or a product decision)

- **2026-11-02:** Navy Federal Flagship Rewards annual fee $49 → $95.
- **2027-01-01:**
  - Aeroplan grocery and dining 3x → 2x.
  - IHG Premier travel 5x narrows to airlines and car rentals.
  - IHG Traveler 3x on utilities and streaming ends.
- **2027 (date not published):** IHG Premier fee $99 → $150 for existing cardholders.
- **Aeroplan:** $195 fee for new applicants since 2026-09-10. The date for existing
  cardholders is not published.
- **Product identity decisions:**
  - SavorOne page now shows a $39 fair-credit product.
  - `citi-citi-premier-card` duplicates Citi Strata Premier.
  - Barclays AAdvantage Aviator Silver may have converted to Citi (unverified).
  - Walmart Rewards (Capital One) vs OnePay CashRewards.
  - Wells Fargo Bilt retired 2026-02-07.
  - Amex Green may be closed to new applicants.
  - U.S. Bank Altitude Reserve is closed to new applicants; earning rates unverified.
- **Model gaps:** combined caps, merchant-scoped conditional rates on non-travel
  categories, and dated term changes.

## Validation

- `python3 Scripts/validate_cards.py --against origin/main`: pass (version 8 > 7).
- `python3 Scripts/diff_cards.py`: SUSPICIOUS (expected; removals of unsupported rates
  are listed in the ledger).
- `python3 -m pytest Scripts/tests`: 14 passed.
- `xcodebuild test` (iOS 26.5 simulator): 123 tests, 0 failures, 1 skipped.

## Per-card decision ledger

### g1-amex


#### `american-express-american-express-green-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| CLEAR Plus credit 209 -> 219 annual | apply | Amex's official CLEAR+ benefit page states Green Card members get up to $219 in statement credits per calendar year. | <https://www.americanexpress.com/en-us/travel/benefits/clear> <https://global.americanexpress.com/card-benefits/detail/hundred-clear-credit/amex-green> |

- **otherFindings:** The public product URL https://www.americanexpress.com/us/credit-cards/card/green/ now redirects to the generic credit-cards listing, and the benefits dashboard calls the card the 'American Express Classic Green Card'. The card may be closed to new applicants; keep it for existing cardholders. The dashboard still lists 3X on restaurants, transit, and travel and 1X on other purchases. I could not re-verify the $150 annual fee from a live official page.

#### `american-express-american-express-platinum-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| CLEAR Plus credit 209 -> 219 annual | apply | The official Platinum product page lists a '$219 CLEAR+ Credit', paid as statement credits per calendar year. | <https://www.americanexpress.com/us/credit-cards/card/platinum/> |
| Add Saks Fifth Avenue credit $50 semiannual | reject | The current official Platinum page has no Saks credit anywhere in its travel, dining, or shopping benefit lists. The shopping benefits listed are lululemon, Walmart+, Oura, and protections. | <https://www.americanexpress.com/us/credit-cards/card/platinum/> |

- **otherFindings:** Per the official page, 5X on flights applies only to flights booked directly with airlines or through American Express Travel, on up to $500,000 per calendar year. 5X on hotels applies only to prepaid hotels booked through American Express Travel. Main encodes hotels 5X as unconditional with no note; it should be portal-only (with a note) and should carry the $500K yearly airline cap. Uber Cash is $15 a month plus a $20 bonus in December ($200 a year). The Equinox credit did not appear on the current public Platinum page, so it should be re-verified. From 2027-01-01, Fine Hotels + Resorts bookings need a minimum two-night stay to qualify for the hotel credit.

#### `american-express-delta-skymiles-gold-american-express-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add delta-gold-flight-credit $200 annual (requires $10,000 calendar-year spend) | apply | The official page says that after $10,000 in eligible purchases in a calendar year, the cardholder can receive a $200 Delta Flight Credit. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-gold-american-express-card/> |
| Add delta-gold-flight $200 annual (duplicate of the above under another id) | partial | This is the same benefit as delta-gold-flight-credit, so it is merged into that single entry instead of being added twice. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-gold-american-express-card/> |
| Add delta-gold-rideshare $10 monthly | apply | The official page lists a NEW $120 Rideshare Credit: up to $10 a month on U.S. rideshare purchases with select providers, starting after the first Card renewal. Enrollment is required. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-gold-american-express-card/> |

- **otherFindings:** The official 2X airline rate applies only to purchases made directly with Delta. Main encodes airlines 2X as unconditional with no note; it should carry a note such as 'Delta purchases'. The annual fee is confirmed as $0 intro for the first year, then $150.

#### `american-express-hilton-honors-american-express-aspire-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| CLEAR Plus credit 209 -> 219 annual | apply | The official Aspire page lists a '$219 CLEAR+ Credit': up to $219 in statement credits per calendar year. | <https://www.americanexpress.com/us/credit-cards/card/hilton-honors-aspire/> <https://www.americanexpress.com/en-us/travel/benefits/clear> |

- **otherFindings:** The official 14X rate applies only to purchases made directly with Hilton-portfolio hotels and resorts. Main's hotels 14X has no note and should be conditional, with a note such as 'Hilton portfolio hotels & resorts'. The official page also lists a $100 Property Credit, which is not on main. The annual fee ($550), the 7X dining and travel rates, and the 3X base rate are confirmed.

#### `american-express-hilton-honors-american-express-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add hotels 7X (proposed with null note) | partial | The official page confirms 7X, but only on purchases made directly with hotels and resorts in the Hilton portfolio. That is a merchant-only rate, so it is added with a note, which makes it conditional. | <https://www.americanexpress.com/us/credit-cards/card/hilton-honors/> |

- **otherFindings:** The official page says '3X Points for each dollar spent on other eligible purchases', but main has baseReward 1. Main is likely wrong. Not changed here because no PR proposed it. 'No Annual Fee' is confirmed. Main had no credits key; finalCard uses an empty list.

#### `american-express-hilton-honors-american-express-surpass-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add hotels 12X (proposed with null note) | partial | The official page confirms 12X, but only on purchases made directly with hotels and resorts in the Hilton portfolio. It is added with a note so the merchant-only rate is conditional. | <https://www.americanexpress.com/us/credit-cards/card/hilton-honors-surpass/> |
| Add onlineShopping 4X | apply | The official page lists '4X Points on U.S. Online Retail Purchases' with no cap. | <https://www.americanexpress.com/us/credit-cards/card/hilton-honors-surpass/> |

- **otherFindings:** The official page says '3X Points for each dollar spent on other eligible purchases', but main has baseReward 1. Main is likely wrong. Not changed here because no PR proposed it. The annual fee is confirmed as $0 intro for the first year, then $150. The property credit is up to $200 a year, which matches main's $50 quarterly.

#### `american-express-marriott-bonvoy-bevy-american-express-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| dining 4X: add $15,000 yearly cap, note null (PR 0831/0914) | apply | The official page gives 4X at restaurants worldwide and at U.S. supermarkets on up to $15,000 in combined purchases per calendar year, then 2X. Per the data-model rules, the combined cap is approximated as a $15,000 yearly cap on each entry. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-bevy/> |
| Add grocery 4X, $15,000 yearly cap, note null (PR 0831/0914) | apply | The official page lists U.S. supermarkets at 4X, sharing the $15,000 combined calendar-year cap with restaurants. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-bevy/> |
| Replace dining/grocery with 'Combined cap shared with ...' noted entries and remove the null-note dining entry (PR 0810) | reject | A note on dining would hide an unconditional reward. The cap is handled by the per-entry approximation instead. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-bevy/> |

- **otherFindings:** The official page gives 2X on all other eligible purchases, but main has baseReward 1. The rate after the dining/grocery cap is also 2X, not 1X. Main is likely wrong; not changed here because no PR proposed it. Hotels 6X applies only at hotels participating in Marriott Bonvoy, so main's unconditional hotels entry should carry a note. The $250 annual fee is confirmed. Main had no credits key; finalCard uses an empty list.

### g2a-chase-airline


#### `chase-aeroplan-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove aeroplan-doordash credit ($10 quarterly) | reject | The Chase Aeroplan page still offers DashPass and up to $10 off one non-restaurant DoorDash order: quarterly for activations from 02/01/2025 to 08/31/2026, and monthly for activations from 09/01/2026 to 12/31/2027. Main's quarterly entry stays. | <https://creditcards.chase.com/travel-credit-cards/aircanada/aeroplan> |
| Add airlines 3x, note 'Air Canada purchases' | apply | The official offer details and Rewards Program Agreement both list 3 points per $1 on purchases made directly with Air Canada. The rate keeps the merchant note so it stays conditional. | <https://creditcards.chase.com/travel-credit-cards/aircanada/aeroplan> <https://asset.chase.com/content/dam/card/rulesregulations/en/RPA0538_Web.pdf> |
| Add airlines 3x, note 'Air Canada purchases made directly' (PR 0810 wording) | partial | This duplicates the entry above. It was applied once, under the note 'Air Canada purchases'. | <https://creditcards.chase.com/travel-credit-cards/aircanada/aeroplan> |
| Add dining 3x, note null | apply | The RPA gives 3 points per $1 on dining, including takeout and eligible delivery, for purchases that post by 12/31/2026. It drops to 2 points starting 2027-01-01. The value is correct as of today but must change to 2 after 2026-12-31. | <https://asset.chase.com/content/dam/card/rulesregulations/en/RPA0538_Web.pdf> |
| Add dining 3x, note 'Restaurants, including takeout and eligible delivery' (PR 0810 wording) | partial | This duplicates the dining entry above. It was applied with note null because the bonus is unconditional. | <https://asset.chase.com/content/dam/card/rulesregulations/en/RPA0538_Web.pdf> |

- **otherFindings:** The card was refreshed on 2026-09-10. The official page now shows a $195 annual fee for new applicants; main has $95. Chase issued no separate product, and I found no official effective date for existing cardholders, so the fee was not changed. Under the current RPA: travel (excluding Air Canada) earns 3x and gas stations earn 2x, but main has neither. Grocery and dining earn 3x through 12/31/2026, then 2x from 2027-01-01, so main's grocery 3 and the new dining 3 must drop to 2 then. A new Air Canada statement credit is not on main: up to $50 per half-year (Jan–Jun, Jul–Dec), $100 a year. The DoorDash discount is monthly for new DashPass activations from 2026-09-01.

#### `chase-british-airways-visa-signature`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove ba-doordash credit ($10 quarterly) | reject | The official page still lists up to $10 off quarterly on DoorDash non-restaurant orders through Dec 31, 2027. | <https://creditcards.chase.com/travel-credit-cards/avios/british-airways> |
| Add airlines 3x for British Airways/Aer Lingus/Iberia/LEVEL flights booked direct | apply | The offer details give 3 Avios per $1 on flights bought directly from British Airways, Aer Lingus, Iberia and LEVEL. I used the most complete wording (PR 0914); the other two wordings are the same entry. | <https://creditcards.chase.com/travel-credit-cards/avios/british-airways> |
| Add hotels 2x booked directly with the hotel | apply | The offer details give 2 Avios per $1 on hotel stays bought directly from the hotel. Added once with a conditional note; the three PR wordings are the same entry. | <https://creditcards.chase.com/travel-credit-cards/avios/british-airways> |

- **otherFindings:** The official page now lists up to $600 a year in Reward Flight statement credits: $100 for Economy or Premium Economy, or $200 for Business or First, up to three times per year, on transatlantic BA reward bookings from the US. Main models only a $100 annual credit. Other perks not on main: a 2,500 Avios anniversary award and a 10% off code for BA flights.

#### `chase-southwest-rapid-rewards-plus`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add sw-plus-doordash credit $10 quarterly | apply | The official page lists up to $10 off quarterly on one DoorDash non-restaurant order for DashPass members, through 12/31/2027. | <https://creditcards.chase.com/travel-credit-cards/southwest/plus> |
| Add sw-plus-instacart credit $10 monthly | apply | The official page lists a $10 monthly Instacart credit (up to $120 a year) for activations from 5/1/2025 to 12/31/2027. | <https://creditcards.chase.com/travel-credit-cards/southwest/plus> |
| Add gas 2x, $5,000 yearly cap (combined with grocery) | apply | The offer details give 2 points per $1 on the first $5,000 per account anniversary year in combined gas station and grocery store purchases. I used note null so the reward isn't hidden; the cap is set per entry to the combined amount. | <https://creditcards.chase.com/travel-credit-cards/southwest/plus> |
| Add grocery 2x, $5,000 yearly cap (combined with gas) | apply | This is the same combined $5,000 anniversary-year cap as gas, entered with note null. | <https://creditcards.chase.com/travel-credit-cards/southwest/plus> |

- **combinedCap:** {"categories": ["gas", "grocery"], "amount": 5000, "period": "account anniversary year (modeled as yearly)"}

#### `chase-southwest-rapid-rewards-premier`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add dining 2x, $8,000 yearly cap (combined with grocery) | apply | The offer details give 2 points per $1 on the first $8,000 per account anniversary year in combined grocery and restaurant purchases. Entered with note null; the cap is set per entry to the combined amount. | <https://creditcards.chase.com/travel-credit-cards/southwest/premier> |
| Add grocery 2x, $8,000 yearly cap (combined with dining) | apply | This is the same combined $8,000 anniversary-year cap, entered with note null. | <https://creditcards.chase.com/travel-credit-cards/southwest/premier> |

- **combinedCap:** {"categories": ["dining", "grocery"], "amount": 8000, "period": "account anniversary year (modeled as yearly)"}

#### `chase-southwest-rapid-rewards-priority`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add gas 2x, uncapped | apply | The offer details give 2 points per $1 at gas stations and restaurants, with no cap stated. | <https://creditcards.chase.com/travel-credit-cards/southwest/priority> |

#### `chase-united-club-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add Avis/Budget credit $100 annual (PR 0914 id united-club-avis) | apply | The official page gives $50 in United TravelBank cash for each of the 1st and 2nd Avis or Budget rentals booked through mileageplustravel.united.com, up to $100 per anniversary year. Modeled as $100 annual. | <https://creditcards.chase.com/travel-credit-cards/united/club-infinite> |
| Add Avis/Budget credit $100 annual (PR 0810 id united-club-avis-budget) | partial | This duplicates the entry above. It was applied once, under id united-club-avis. | <https://creditcards.chase.com/travel-credit-cards/united/club-infinite> |
| Add Avis/Budget credit $50 semiannual | reject | The credit is $50 for each of the first two rentals in an anniversary year, not $50 per half-year. | <https://creditcards.chase.com/travel-credit-cards/united/club-infinite> |
| Airlines (United purchases) 2x -> 5x | apply | The offer details give 5 miles per $1 on United tickets and other United purchases. The 11x headline adds 6x MileagePlus member earning, which does not come from the card. | <https://creditcards.chase.com/travel-credit-cards/united/club-infinite> |
| Add hotels 5x for prepaid Renowned Hotels and Resorts bookings | apply | The offer details give 5 miles per $1 on hotel stays prepaid through Renowned Hotels and Resorts for United Cardmembers via Chase Travel. Added once with a conditional note; the three PR wordings are the same entry. | <https://creditcards.chase.com/travel-credit-cards/united/club-infinite> |
| Remove travel 2x | reject | The offer details still give 2 miles per $1 on travel, excluding United purchases that earn 5x. | <https://creditcards.chase.com/travel-credit-cards/united/club-infinite> |

- **otherFindings:** The rideshare credit is $12 a month for January–November and $18 for December ($150 a year); main's $12 monthly slightly understates December.

#### `chase-united-explorer-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add Avis/Budget credit $50 annual (PR 0914 id united-explorer-avis) | apply | The official page gives $25 in United TravelBank cash for each of the 1st and 2nd Avis or Budget rentals booked through mileageplustravel.united.com, up to $50 per anniversary year. | <https://creditcards.chase.com/travel-credit-cards/united/united-explorer> |
| Add Avis/Budget credit $50 annual (PR 0810 id united-explorer-avis-budget) | partial | This duplicates the entry above. It was applied once, under id united-explorer-avis. | <https://creditcards.chase.com/travel-credit-cards/united/united-explorer> |
| Add Avis/Budget credit $25 semiannual | reject | The credit is $25 for each of the first two rentals in an anniversary year, not $25 per half-year. | <https://creditcards.chase.com/travel-credit-cards/united/united-explorer> |
| Airlines (United purchases) 2x -> 3x | apply | The offer details give 3 miles per $1 on United tickets and other United purchases. The 9x headline adds 6x MileagePlus member earning, which does not come from the card, so 3x is correct and keeps the 'United purchases' note. | <https://creditcards.chase.com/travel-credit-cards/united/united-explorer> |
| Add hotels 2x booked directly with the hotel | apply | The offer details give 2 miles per $1 on hotel stays bought directly from the hotel. Added once with a conditional note; the three PR wordings are the same entry. | <https://creditcards.chase.com/travel-credit-cards/united/united-explorer> |
| Remove travel 2x | apply | The current offer details list only dining and hotels booked direct at 2x. Explorer has no general travel bonus. | <https://creditcards.chase.com/travel-credit-cards/united/united-explorer> |

- **otherFindings:** The annual fee is $0 the first year, then $150, which matches main's $150. There is also a $100 United TravelBank credit after $10,000 in spend per calendar year; it is spend-gated and not modeled. The United Hotels credit is $50 for each of the first two prepaid stays, $100 per anniversary year, which matches main.

#### `chase-united-quest-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add Avis/Budget credit $80 annual (PR 0914 id united-quest-avis) | apply | The official page gives $40 in United TravelBank cash for each of the 1st and 2nd Avis or Budget rentals booked through mileageplustravel.united.com, up to $80 per anniversary year. | <https://creditcards.chase.com/travel-credit-cards/united/united-quest> |
| Add Avis/Budget credit $80 annual (PR 0810 id united-quest-avis-budget) | partial | This duplicates the entry above. It was applied once, under id united-quest-avis. | <https://creditcards.chase.com/travel-credit-cards/united/united-quest> |
| Add Avis/Budget credit $40 semiannual | reject | The credit is $40 for each of the first two rentals in an anniversary year, not $40 per half-year. | <https://creditcards.chase.com/travel-credit-cards/united/united-quest> |
| Add hotels 5x for prepaid Renowned Hotels and Resorts bookings | apply | The offer details give 5 miles per $1 on hotel stays prepaid through Renowned Hotels and Resorts for United Cardmembers via Chase Travel. Added once with a conditional note. | <https://creditcards.chase.com/travel-credit-cards/united/united-quest> |

- **otherFindings:** The official page confirms main's 4x on United purchases and 2x on travel, dining and streaming. The rideshare credit is $8 a month for January–November and $12 for December ($100 a year).

### g2b-chase-hotel-disney


#### `chase-disney-premier-visa-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove disney-premier-doordash credit ($10 quarterly) | reject | The Chase Disney Premier page still lists the DashPass benefit with $10 off a non-restaurant DoorDash order each quarter for members who activated 02/01/2025–08/31/2026, or each month for members who activated from 09/01/2026, through 12/31/2027. | <https://creditcards.chase.com/rewards-credit-cards/disney/premier> |
| Add dining 2% (note null) | apply | Official terms: 2% total on grocery stores and dining at restaurants, including takeout and eligible delivery. | <https://creditcards.chase.com/rewards-credit-cards/disney/premier> <https://disneyrewards.com/compare-credit-cards/> |
| Add gas 2% (note null) | apply | Official terms: 2% on card purchases at gas stations and most U.S. Disney locations. | <https://creditcards.chase.com/rewards-credit-cards/disney/premier> <https://disneyrewards.com/compare-credit-cards/> |
| Add grocery 2% (note null) | apply | Official terms: 2% on card purchases at grocery stores. | <https://creditcards.chase.com/rewards-credit-cards/disney/premier> <https://disneyrewards.com/compare-credit-cards/> |
| Replace disney 'Disney purchases' 2% with disney 'Disney purchases and gas stations' 2% | reject | Disney locations do earn 2%, but gas now has its own gas entry. Main's 'Disney purchases' entry is correct, so it stays. | <https://creditcards.chase.com/rewards-credit-cards/disney/premier> |
| Add streaming 5% (note DisneyPlus.com/Hulu.com/Stream.ESPN.com), both note variants | reject | The 5% rate is verified, but it only applies to purchases made directly at DisneyPlus.com, Hulu.com and Stream.ESPN.com. The engine does not treat a note on streaming as a condition, so this entry would wrongly show 5% for every streaming service, such as Netflix. | <https://creditcards.chase.com/rewards-credit-cards/disney/premier> <https://disneyrewards.com/compare-credit-cards/> |

- **otherFindings:** The verified 5% on direct DisneyPlus.com/Hulu.com/Stream.ESPN.com purchases is not modeled because no merchant-conditional streaming option exists. The annual fee of $49 matches the official page. New DashPass enrollees (09/01/2026 or later) get $10 monthly instead of quarterly; main keeps the conservative quarterly amount.

#### `chase-disney-visa-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add disney-doordash credit $10 quarterly | apply | The Chase Disney Visa page shows DashPass members get $10 off a non-restaurant DoorDash order each quarter (activation 02/01/2025–08/31/2026) or each month (activation from 09/01/2026), through 12/31/2027. Quarterly is the conservative amount and matches how main models this credit on sibling cards. | <https://creditcards.chase.com/rewards-credit-cards/disney/rewards> |

- **otherFindings:** The card earns a flat 1% on all purchases, so the disney 1% entry is redundant but harmless.

#### `chase-ihg-one-rewards-premier`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove ihg-premier-doordash credit | reject | The official page still lists DashPass with $10 off non-restaurant DoorDash orders, quarterly for legacy enrollees and monthly for enrollees from 09/01/2026, through 12/31/2027. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier> |
| Add ihg-premier-instacart credit $10 monthly | apply | The official page lists a $10 monthly Instacart credit, up to $120 per year, ending 12/31/27. It requires an active Instacart+ membership; 3 months are complimentary, then it renews at $99/yr. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier> |
| Remove ihg-premier-travelbank credit | reject | The official page still lists up to $50 in United TravelBank Cash each calendar year ($25 per half-year). | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier> |
| Add dining 5x (note null) | apply | Official terms: 5 points per $1 on dining at restaurants, including takeout and delivery. This rate existed before and after the October 2026 refresh. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier> <https://media.chase.com/news/ihg-premier-select-card-portfolio-updates> |
| Add gas 5x (note null) | apply | Official terms: 5 points per $1 at gas stations. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier> <https://media.chase.com/news/ihg-premier-select-card-portfolio-updates> |
| Add travel 5x (note null) | partial | Official terms give 5x on all travel only for purchases posting through 12/31/2026. After that, 5x applies only to airline tickets bought directly from airlines and to car rental agencies, and other travel earns 3x. An unconditional travel 5x entry was rejected; an airlines 5x entry with a note was added instead. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier> |

- **effectiveDate:** 2027 (annual fee $99 -> $150 for existing cardmembers; exact date not published)

- **otherFindings:** The product was refreshed on 2026-10-01 under the same name and URL (Chase press release). The annual fee is $150 for new applicants; existing cardmembers move to it in 2027 (Chase says 'Annual Fees will be adjusted in 2027'), so main's $99 stays for now. The refreshed card also adds: grocery 5x; car rental 5x; base 3x on all other purchases (main's base of 1 is wrong; the old card was also 3x); up to 24X total at IHG with Gold Elite (main's 26 reflects the old Platinum level); a $100 annual airline credit after $250 spent on flights booked directly with the airline (through 12/31/27); and $25 quarterly IHG Food & Beverage rewards. Per Chase, existing cardmembers were to be notified in October of the effective date for each change. Also note the hotel cards on main use isPercentage=true for points multipliers; new entries follow that convention.

#### `chase-ihg-one-rewards-traveler`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add ihg-traveler-doordash credit $10 quarterly | apply | The official page lists DashPass with $10 off non-restaurant DoorDash orders, quarterly for activations 02/01/2025–08/31/2026 and monthly for activations from 09/01/2026, through 12/31/2027. Quarterly is the conservative amount. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/traveler> |
| Add ihg-traveler-instacart credit $10 monthly | apply | The official page lists one $10 Instacart credit per month for primary cardmembers with an active Instacart+ membership (3 months complimentary) from 5/1/2025 through 12/31/2027. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/traveler> |
| Add dining 3x (note null) | apply | Official terms: 3 points per $1 on dining at restaurants, including takeout and delivery. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/traveler> <https://media.chase.com/news/ihg-premier-select-card-portfolio-updates> |
| Add gas 3x (note null) | apply | Official terms: 3 points per $1 at gas stations. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/traveler> |
| Add streaming 3x (both note variants) | reject | Official terms say 3x on utilities, internet/cable/phone and select streaming applies only to purchases posting through December 31, 2026. The rate ends in about 2 months and is no longer in the card's ongoing earning structure. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/traveler> |
| Add utilities 3x | reject | Same as streaming: 3x on utilities applies only to purchases posting through 12/31/2026 and then ends. | <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/traveler> |

- **otherFindings:** The card was renamed 'IHG One Rewards Credit Card' on 2026-10-01 (formerly the Traveler). The refresh added grocery 3x, which is not on main. Base earning is 2x on all other purchases, so main's base of 1 is understated. Utilities, internet/cable/phone and select streaming earn 3x only through 12/31/2026.

#### `chase-marriott-bonvoy-bold`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add bold-doordash credit $10 quarterly | apply | The official page lists DashPass members getting up to $10 off quarterly on non-restaurant DoorDash orders through Dec 31, 2027. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/bold> |
| Add grocery 2x | apply | Official terms: 2 points per $1 at grocery stores. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/bold> |
| Add phone 2x | apply | Official terms: 2 points per $1 on internet, cable and phone services. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/bold> |
| Add streaming 2x (note 'Select streaming services' / null) | apply | Official terms: 2 points per $1 on select streaming services. The 'Select streaming services' note was used, since the engine does not treat a streaming note as a condition. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/bold> |
| Add transit 2x (note 'Rideshare and select food delivery' / null) | partial | Official terms give 2x on rideshare (the 'taxicabs and limousines' category) and on select food delivery apps, but not on general transit. Added transit 2x with a rideshare note. Food delivery cannot be modeled; it is not dining. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/bold> |

- **otherFindings:** The same official clause also gives 2x on internet/cable services (the separate 'internet' category), which was not proposed and is not on main. The transit entry may overstate earning on public transit, since only taxis/rideshare qualify.

#### `chase-marriott-bonvoy-boundless`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add boundless-airline credit $50 semiannual | apply | Official cardmember offer: a $50 statement credit after $250 spent directly with airlines in each half-year, up to $100. It runs through 12/31/2026 for existing cardmembers who activated, and through 6/30/2027 for new cardmembers. It is limited-time. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/boundless> |
| Add dining/gas/grocery 3x with $6,000 yearly combined cap (note variants) | apply | Official terms: 3 points total per $1 on the first $6,000 spent each year on combined purchases at gas stations, grocery stores and dining. Each entry gets the full combined amount as its cap, with note null, per the data-model rules. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/boundless> |

- **combinedCap:** {"categories": ["dining", "gas", "grocery"], "amount": 6000, "period": "yearly"}

- **otherFindings:** Base earning is 2x on all other purchases, so main's base of 1 is understated. The 3x rate drops to 2x, not 1x, after the cap. The airline credit is a limited-time offer that ends 6/30/2027.

#### `chase-marriott-bonvoy-bountiful`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add dining/grocery 4x with $15,000 yearly combined cap (note variants) | apply | Official terms: 4 points total per $1 on the first $15,000 spent each year on combined grocery store and dining purchases. Each entry gets the full combined amount as its cap, with note null. | <https://creditcards.chase.com/travel-credit-cards/marriott-bonvoy/bountiful> |

- **combinedCap:** {"categories": ["dining", "grocery"], "amount": 15000, "period": "yearly"}

- **otherFindings:** Base earning is 2x on all other purchases, so main's base of 1 is understated. The annual fee of $250 matches the official page.

#### `chase-world-of-hyatt`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add hyatt-doordash credit $10 quarterly | apply | The official page lists DashPass members getting $10 off one non-restaurant DoorDash order each calendar quarter. | <https://creditcards.chase.com/travel-credit-cards/world-of-hyatt-credit-card> |
| Add airlines 2x (purchased directly from airline) | apply | Official terms: 2 Bonus Points per $1 on airline tickets purchased directly with the airline. The note is kept, so the rate is conditional. | <https://creditcards.chase.com/travel-credit-cards/world-of-hyatt-credit-card> |
| Add dining 2x (note null) | apply | Official terms: 2 Bonus Points per $1 at restaurants. | <https://creditcards.chase.com/travel-credit-cards/world-of-hyatt-credit-card> |
| Add fitness 2x | apply | Official terms: 2 Bonus Points per $1 on fitness club and gym memberships. | <https://creditcards.chase.com/travel-credit-cards/world-of-hyatt-credit-card> |
| Add transit 2x | apply | Official terms: 2 Bonus Points per $1 on local transit/commuting. Main's existing note wording ('Local transit & commuting') was used. | <https://creditcards.chase.com/travel-credit-cards/world-of-hyatt-credit-card> |

- **otherFindings:** The official page confirms an annual fee of $95, 1x base and up to 9X total at Hyatt.

### g3-chase-core


#### `chase-amazon-visa`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add amazon 3% (various notes / null note) | already-on-main | Official page: unlimited 3% at Amazon.com, Audible.com, Whole Foods Market and Chase Travel. Main already has amazon 3% (note 'Amazon.com purchases'; amazon is not a conditional category) plus a separate wholeFoods 3% entry. | <https://creditcards.chase.com/cash-back-credit-cards/amazon-rewards> |
| Add dining 2% / gas 2% (note null) | already-on-main | Official 2% at gas stations and restaurants; main already has both with null note. | <https://creditcards.chase.com/cash-back-credit-cards/amazon-rewards> |
| Add grocery 3% note 'Whole Foods Market' | reject | The 3% is Whole Foods-only and must be encoded as wholeFoods, which main already has; a grocery entry would overstate all grocery. | <https://creditcards.chase.com/cash-back-credit-cards/amazon-rewards> |
| Add transit 2% (note null or 'Local transit and commuting, including rideshare') | already-on-main | Official 2% on local transit and commuting incl. rideshare; main has transit 2% (note 'Local transit & commuting'; transit is not a conditional category, so it is effectively unconditional). | <https://creditcards.chase.com/cash-back-credit-cards/amazon-rewards> |
| Add travel 3% 'Booked through Chase Travel' | already-on-main | Official 3% on Chase Travel purchases only; main already has travel 3% with note 'Chase Travel' (conditional, as required). | <https://creditcards.chase.com/cash-back-credit-cards/amazon-rewards> |

- **otherFindings:** None; main matches the official page.

#### `chase-chase-freedom-flex`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| PR 0914: replace Q3 2026 with [gas, transit, evCharging, entertainment] | apply | Chase's official 5% calendar shows JUL-SEP 2026 = Gas Stations, Public Transit, EV Charging, Select Live Entertainment (plus United Way). Main's Q3 2026 omits transit. | <https://www.chase.com/personal/credit-cards/freedom/freedomfive> |
| PR 0720: rotating list containing only Q4 2025 [amazon, target, walmart] | reject | Stale; would drop 2026 quarters. Main already keeps the Q4 2025 entry. | <https://www.chase.com/personal/credit-cards/freedom/freedomfive> |
| Correction not proposed by PRs: main's Q4 2026 [amazon, wholesale, paypal] is wrong | apply | Official calendar shows OCT-DEC 2026 (current quarter) = Grocery Stores (excluding Walmart and Target), Dining, American Red Cross. Corrected Q4 2026 to [grocery, dining]; Walmart/Target exclusion and charity merchant cannot be modeled. | <https://www.chase.com/personal/credit-cards/freedom/freedomfive> |
| Add Q1 2027 [grocery, streaming] (published on official calendar) | apply | Official calendar shows JAN-MAR 2027 = Grocery Stores (excluding Walmart and Target) and Top Streaming Services, activation from 2026-12-15. Added so the app is correct on Jan 1; drop it if the orchestrator prefers not to add future quarters. | <https://www.chase.com/personal/credit-cards/freedom/freedomfive> |

- **otherFindings:** Base earn (5% Chase Travel, 3% dining and drugstores, 1% other, $0 AF, $1,500 combined quarterly cap with activation) matches the official page. Main's Q1/Q2 2026 entries could not be checked because the official page now shows only Q3 2026 onward; they are kept as-is. Main had no 'credits' key, so finalCard uses [].

#### `chase-chase-sapphire-preferred`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add gas 3x (note null) | apply | Official page (marked NEW) and offer terms: 3 points per $1 at gas stations. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred> |
| Add evCharging 3x (note null) | apply | Official offer terms: 3 points per $1 on electric vehicle charging. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred> |
| Remove unconditional grocery 3x | apply | Official terms only give 3x on online grocery (excluding Target, Walmart and wholesale clubs), so an unconditional grocery 3x overstates in-store grocery. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred> |
| Add grocery 3x note 'Online grocery purchases only' | partial | The online-grocery 3x exists, but grocery is not a conditional category, so a grocery entry with a note would still apply to all grocery. Left out of finalCard; orchestrator may add it if overstating in-store grocery is acceptable. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred> |

- **otherFindings:** $95 AF, 5x Chase Travel, 3x dining, 3x top streaming services, 2x other travel, $100 Chase Travel hotel credit (per account anniversary year) and $10/month DoorDash non-restaurant promo all match. Not proposed and not modeled: 3x on vacation homes at top brands; a one-time complimentary year of Apple TV ($180 value) if activated by 2026-12-31; a $120 Global Entry/TSA PreCheck/NEXUS credit every 4 years. Also note that isPercentage=true on a points card follows main's existing convention.

#### `chase-chase-sapphire-reserve`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove unconditional travel 4x | apply | Official terms: 4x applies only to 'flights and hotels booked direct'; other travel earns 1x. Main's unconditional travel 4x overstates rental cars, transit and similar travel. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/reserve> |
| Add airlines 4x 'Flights booked direct' and hotels 4x 'Hotels booked direct' (PR 0914) | partial | Rates verified. Encoded as airlines 4x and hotels 4x with note null: booking directly with the airline or hotel is exactly what those merchant categories cover, and a note would hide the reward by default. Use the PR notes instead if direct booking should be opt-in. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/reserve> |
| Add travel 4x 'Flights and hotels booked direct (not through Chase Travel)' (PR 0720) | reject | Superseded by the separate airlines/hotels entries, which model it more precisely. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/reserve> |
| Add credit csr-apple-tv-music $288 annual | partial | The official page lists complimentary Apple TV and Apple Music subscriptions 'a value of $324 annually' (activate by 2027-06-22), not $288. Added with amount 324. | <https://creditcards.chase.com/rewards-credit-cards/sapphire/reserve> |

- **otherFindings:** $795 AF, 8x Chase Travel, 3x dining, $300 travel credit, $150 semiannual Exclusive Tables, $150 semiannual StubHub (through 2027-12-31), $10/month Lyft and $10/month Peloton match. Discrepancies not proposed by the PRs: (1) DoorDash is now up to $35/month (a $15 monthly promo plus two $10 non-restaurant promos), while main has $25. (2) 'Select hotel credit (2026)' $250 does not appear on the current official product page, so it is unverified. (3) The Edit credit is up to $250 per prepaid booking, max $500 per calendar year; main's semiannual $250 approximates this. Model caveat: if the merchant database maps airline or hotel merchants to 'travel' instead of 'airlines'/'hotels', the 4x direct-booking rate will not be picked up.

#### `chase-ink-business-cash`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| officeSupplies 5%: add cap 25000 yearly (PR 0914) / remove (PR 0810) | apply | Official: 5% on the first $25,000 of combined office-supply-store and internet/cable/phone purchases each account anniversary year. Kept officeSupplies and set the per-entry cap to the combined $25,000; rejected PR 0810's removal. | <https://creditcards.chase.com/business-credit-cards/ink/cash> |
| phone 5% (various notes/caps) | already-on-main | Main already has internet 5% and phone 5%, each capped at $25,000 yearly. | <https://creditcards.chase.com/business-credit-cards/ink/cash> |
| dining 2% / gas 2% with 25000 yearly (or null caps) | already-on-main | Official: 2% on the first $25,000 combined at gas stations and restaurants per anniversary year. Main already has both at $25,000 yearly (dining note 'Restaurants' is exempt from conditional hiding). Null-cap variants are rejected. | <https://creditcards.chase.com/business-credit-cards/ink/cash> |
| Add credit ink-cash-instacart $20 monthly | apply | Official: $20 Instacart credit each month with an active (complimentary) Instacart+ membership; enrollment between 2025-05-01 and 2027-12-31; benefits end 2027-12-31. | <https://creditcards.chase.com/business-credit-cards/ink/cash> |

- **combinedCap:** 5% tier: $25,000 combined per account anniversary year across office supply stores + internet/cable/phone. 2% tier: $25,000 combined across gas stations + restaurants. Modeled per entry.

- **otherFindings:** Not modeled: 5% total on Lyft rides through 2027-09-30.

#### `chase-ink-business-preferred`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| phone / shipping / travel 3x with 150000 yearly caps (various notes) | already-on-main | Official: 3 points per $1 on the first $150,000 combined each anniversary year across shipping, social media/search advertising, travel and internet/cable/phone. Main already has all of these at $150,000 yearly, using points (isPercentage false). | <https://creditcards.chase.com/business-credit-cards/ink/business-preferred> |
| travel 3x 'Booked through Chase Travel' (PR 0914) | reject | The 3x applies to all travel, not just Chase Travel. Main's note 'Travel purchases' is exempt from conditional hiding and is correct. | <https://creditcards.chase.com/business-credit-cards/ink/business-preferred> |
| Remove shipping (PR 0810) / uncapped variants (PR 0831) | reject | Shipping 3x still exists; the cap is $150,000 combined. | <https://creditcards.chase.com/business-credit-cards/ink/business-preferred> |
| Add credit ink-preferred-doordash $10 monthly | apply | Official: once DashPass is activated (by 2027-12-31), $10 off one non-restaurant DoorDash order each calendar month. | <https://creditcards.chase.com/business-credit-cards/ink/business-preferred> |

- **combinedCap:** $150,000 combined per account anniversary year across travel, shipping, social media/search advertising, internet/cable/phone. Modeled per entry.

- **otherFindings:** $95 AF matches. Not modeled: 5x total on Lyft through 2027-09-30. Main's baseIsPercentage=true is inconsistent with the card's points-based category entries (isPercentage false); not changed.

#### `chase-ink-business-premier`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add travel 5% 'Booked through Chase Travel' | apply | Official: unlimited 5% cash back on travel purchased through Chase Travel. | <https://creditcards.chase.com/business-credit-cards/ink/premier> |

- **otherFindings:** IMPORTANT (not proposed by the PRs): the official base rate is 2% cash back on all purchases (2.5% on purchases of $5,000 or more), but main has baseReward 1. finalCard keeps main's 1 per instructions; the orchestrator should correct it to 2. $195 AF matches. Not modeled: 5% on Lyft through 2027-09-30.

#### `chase-ink-business-unlimited`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add credit ink-unlimited-instacart $20 monthly | apply | Official: $20 Instacart credit each month with an active (complimentary) Instacart+ membership; benefits end 2027-12-31. | <https://creditcards.chase.com/business-credit-cards/ink/unlimited> |

- **otherFindings:** IMPORTANT (not proposed by the PRs): the official rate is unlimited 1.5% cash back on every purchase, but main has baseReward 1. finalCard keeps main's 1 per instructions; the orchestrator should correct it to 1.5. Not modeled: 5% on Lyft through 2027-09-30.

#### `chase-instacart-mastercard`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove unconditional grocery 5% | apply | Official: 5% applies only to qualifying Instacart.com/app purchases (first $6,000 per year), not to grocery stores in general. | <https://creditcards.chase.com/cash-back-credit-cards/instacart> |
| Remove unconditional travel 5% | apply | Official: 5% applies only to Chase Travel purchases, which main already models as a separate conditional entry. | <https://creditcards.chase.com/cash-back-credit-cards/instacart> |
| Add streaming 2% | apply | Official: 2% cash back on select streaming services. | <https://creditcards.chase.com/cash-back-credit-cards/instacart> |
| Add grocery 5% note 'Instacart purchases' cap 6000 yearly | partial | Rate and cap verified ($6,000 per year, measured over 12 December-to-December statement cycles). It is a merchant-only rate with no Instacart category, and a grocery entry with a note is not conditional, so it would be an unconditional grocery 5%. Left out of finalCard. | <https://creditcards.chase.com/cash-back-credit-cards/instacart> |

- **otherFindings:** The Instacart-only 5% (first $6,000 per year) cannot be modeled without a dedicated category; consider adding one in a future data-model change. $0 AF, 2% gas and dining match.

#### `chase-prime-visa`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add amazon 5% (various Prime-membership notes) | already-on-main | Official: 5% at Amazon.com, Audible.com, Whole Foods Market and Chase Travel with an eligible Prime membership. Main has amazon 5% (the card requires Prime by definition) and a separate wholeFoods 5%. | <https://creditcards.chase.com/cash-back-credit-cards/amazon-prime-rewards> |
| Add dining 2% / gas 2% (note null) | already-on-main | Official 2% at gas stations and restaurants; main matches. | <https://creditcards.chase.com/cash-back-credit-cards/amazon-prime-rewards> |
| Add grocery 5% 'Whole Foods Market; requires active Prime membership' | reject | This is a Whole Foods-only rate and belongs in wholeFoods, which main already has; a grocery entry would overstate all grocery. | <https://creditcards.chase.com/cash-back-credit-cards/amazon-prime-rewards> |
| Add transit 2% (note null or rideshare note) | already-on-main | Official 2% on local transit and commuting incl. rideshare; main has transit 2% (note on a non-conditional category). | <https://creditcards.chase.com/cash-back-credit-cards/amazon-prime-rewards> |
| Add travel 5% 'Booked through Chase Travel' (various notes) | already-on-main | Main already has travel 5% with note 'Chase Travel' (conditional). | <https://creditcards.chase.com/cash-back-credit-cards/amazon-prime-rewards> |

- **otherFindings:** None; main matches the official page. The rotating 'Prime Card Bonus' promotions (10%+) are not modeled.

### g4-citi-capone-discover


#### `capital-one-capital-one-savor-cash-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add 5% on hotels, vacation rentals and rental cars booked through Capital One Travel (travel, with portal note) | apply | The official Savor page says 'Earn unlimited 5% cash back on hotels, vacation rentals and rental cars booked through Capital One Travel.' This rate applies only through the portal, so it keeps its note and stays conditional. | <https://www.capitalone.com/credit-cards/savor/> |
| Add 5% hotels entry for Capital One Travel bookings (hotels, with portal note) | apply | Same official source. The entry is added under hotels with the portal note so the conditional 5% also shows for hotel lookups. | <https://www.capitalone.com/credit-cards/savor/> |

- **otherFindings:** The official page also lists 'unlimited 8% cash back on Capital One Entertainment purchases'. This is a portal-only rate, so if it is modeled it needs a note (entertainment + note). Annual fee $0 matches main. Main has no credits key, so finalCard.credits = [].

#### `capital-one-capital-one-savorone-cash-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add 5% on Capital One Travel bookings (travel, with portal note) | apply | The official SavorOne page says 'Earn 5% cash back with Capital One Travel' and 'Earn unlimited 5% cash back on hotels, vacation rental[s] and rental car bookings.' This is a portal-only rate, so it keeps the note. | <https://www.capitalone.com/credit-cards/savorone/> |
| Add 5% hotels entry for Capital One Travel bookings (hotels, with portal note) | apply | Same official source; it is a conditional, portal-only entry. | <https://www.capitalone.com/credit-cards/savorone/> |

- **otherFindings:** IMPORTANT, not proposed: the live official SavorOne page (capitalone.com/credit-cards/savorone/) now shows a '$39 annual fee', 'Fair credit' and a 29.24% APR. This appears to be the fair-credit SavorOne product; the former $0 excellent-credit SavorOne seems to have become 'Savor'. Main shows annualFee 0. Product identity needs a human decision: either the existing card's fee is now $39, or main's entry represents a legacy product. annualFee was not changed in finalCard. The page also shows an 8% Capital One Entertainment portal rate.

#### `citi-citi-double-cash-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add 5% travel (hotels, car rentals, attractions booked through Citi Travel) | apply | The official page says 'earn a total of 5% on select travel ... hotels, car rentals, and attractions booked through the Citi Travel portal.' This is portal-only, so it keeps a note. | <https://www.citi.com/credit-cards/citi-double-cash-credit-card> |

- **otherFindings:** Base 2% (1% when you buy + 1% when you pay) and $0 annual fee match main.

#### `citi-citi-rewards-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| grocery 2x -> 3x (no cap) | apply | Citi Rewards+ was replaced by the Citi Strata Card. Citi's press release calls it 'a rich enhancement of the former Citi Rewards+ Card', and the rewards-plus URL now serves the Citi Strata page. That page and the press release list 3x at Supermarkets with no cap. | <https://www.citigroup.com/global/news/press-release/2025/citi-launches-citi-strata-elite-credit-card> <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> |
| gas 2x -> 3x (no cap) | apply | Official sources list '3x points on Select Transit and at Gas & EV Charging Stations' with no cap. | <https://www.citigroup.com/global/news/press-release/2025/citi-launches-citi-strata-elite-credit-card> <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> |
| grocery/gas 2x with $6,000/yr cap (PR 0831) | reject | This is the old Rewards+ structure. The current Citi Strata Card earns 3x with no published cap. | <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> |
| Add evCharging 3x | apply | Official: 3x at Gas & EV Charging Stations. | <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> |
| Add transit 3x (note 'Select transit') | apply | Official: 3x on Select Transit. Transit is not a conditional category, so the note does not hide the reward. | <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> |
| Add dining 2x (unconditional) | apply | Official: 2x points at Restaurants, including restaurant delivery services. | <https://www.citigroup.com/global/news/press-release/2025/citi-launches-citi-strata-elite-credit-card> |
| Add 5x travel (hotels, car rentals, attractions booked on cititravel.com) | apply | Official: 5x on Hotels, Car Rentals, and Attractions booked on cititravel.com. Portal-only, so it keeps the note. | <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> |
| Add selectableConfig: choose 1 of fitness/streaming/entertainment at 3x | apply | Official: 3x on one eligible Self-Select Category (Fitness Clubs, Select Streaming Services, Live Entertainment, Cosmetic Stores/Barber Shops/Hair Salons, Pet Supply Stores). Only the first three map to allowed categories. selectableConfig is included in finalCard as an extra key. | <https://www.citi.com/credit-cards/citi-rewards-plus-credit-card> <https://www.citigroup.com/global/news/press-release/2025/citi-launches-citi-strata-elite-credit-card> |

- **otherFindings:** This is product continuity, not a new product: Citi's official press release says the Citi Strata Card is 'a rich enhancement of the former Citi Rewards+ Card', and citi.com/credit-cards/citi-rewards-plus-credit-card now serves the Citi Strata Card page. The card name on main ('Citi Rewards+ Card') is stale and should become 'Citi Strata Card'; the id stays unchanged. The card name is outside the finalCard keys, so it was not changed here. The Rewards+ 10% points rebate and round-up features no longer exist. Annual fee is $0.

#### `citi-citi-strata-premier-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add evCharging 3x | apply | Official: 3 points per dollar at Gas & EV Charging Stations. | <https://www.citi.com/credit-cards/citi-strata-premier-credit-card> |
| Replace 10x 'Hotels booked through thankyou.com' with 10x 'Hotels, car rentals and attractions booked through cititravel.com' | apply | Official: 10x on Hotels, Car Rentals and Attractions booked on cititravel.com. The thankyou.com hotels-only wording is outdated. The entry keeps a portal note so it stays conditional. | <https://www.citi.com/credit-cards/citi-strata-premier-credit-card> |
| PR 0720 variant note with comma ('Hotels, car rentals, and attractions ...') | reject | This only duplicates the applied entry with different punctuation. A single entry is used. | <https://www.citi.com/credit-cards/citi-strata-premier-credit-card> |

- **otherFindings:** The official 3x travel category is 'Air Travel and Other Hotel Purchases', not all travel. Main's unconditional travel 3x (note null) likely overstates earning on car rentals, cruises, transit and other travel; a more accurate model would be airlines 3x + hotels 3x. Not changed because it was not proposed. The $100 Annual Hotel Benefit is $100 off a single hotel stay of $500+ (excluding taxes and fees) booked via cititravel.com, once per calendar year; this is consistent with main's credit. The annual fee amount did not render in the fetched HTML; main's $95 was kept.

#### `citi-costco-anywhere-visa-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add evCharging 4% with $7,000/yr cap (combined with gas) | apply | Official: 4% on other eligible gas and EV charging. The 5% and 4% rates share a combined $7,000 spend per year, then 1%. Modeled as a per-entry cap of 7000 yearly; the note is left null because it would only describe the cap. | <https://www.citi.com/credit-cards/citi-costco-anywhere-visa-credit-card> <https://www.citi.com/credit-cards/understanding-credit-cards/costco-citi-card-gas-benefits> |
| Remove unconditional gas 4% ($7,000/yr) and replace it with noted gas entries | reject | Main's unconditional gas 4% with a $7,000/yr cap matches the official rate for other eligible gas. Gas is not a conditional category, so a noted 5% gas entry would be applied to all gas purchases and overstate earning. | <https://www.citi.com/credit-cards/citi-costco-anywhere-visa-credit-card> |
| Add gas 5% at Costco gas stations ($7,000/yr combined cap) | partial | The 5% Costco gas rate is officially verified. However, a note does not make gas conditional in the engine, so encoding it under gas would show 5% for all gas stations. It was not added to finalCard; see otherFindings. | <https://www.citi.com/credit-cards/citi-costco-anywhere-visa-credit-card> <https://www.citi.com/credit-cards/understanding-credit-cards/costco-citi-card-gas-benefits> |
| Gas 4% with note '5% at Costco gas stations, 4% at other gas stations and EV charging' (PR 0914) | already-on-main | The 4% rate and $7,000/yr cap are already on main as the unconditional gas entry. The added note is not needed and would duplicate that entry. | <https://www.citi.com/credit-cards/citi-costco-anywhere-visa-credit-card> |

- **otherFindings:** Verified on 2026-10-27, matching the known lead: 5% on gas at Costco, 4% on other eligible gas and EV charging, combined $7,000/yr then 1%; 3% on restaurants and eligible travel, including Costco Travel; 2% on other Costco/Costco.com purchases; 1% on everything else. The annual fee is $0 with a paid Costco membership. The 5% Costco-gas rate cannot be modeled safely: an unconditional gas entry would overstate earning, and a wholesale+note entry would be misleading. It needs a merchant-level/conditional gas entry if the engine adds support for one. The combined $7,000 cap is approximated per entry, so this is a limitation.

#### `discover-discover-it-cash-back`

> **Superseded:** the 2026 rotating calendar below was later replaced from discover.com page text; see "Corrections to existing main data" for provenance and limits.

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| PR rotating Q3 2026 = gas/transit/drugstore and Q4 2026 = dining/entertainment/utilities (replacing main's Q3 grocery/walmart, Q4 amazon/target) | unverified | Discover's official 5% calendar page currently shows 'the rewards calendar is not working at this time'. Its data API requires login (HTTP 401), and the static offers.json is stale (2020-2021). No official 2026 terms page could be fetched, so main is kept under the rules. | <https://www.discover.com/credit-cards/cash-back/cashback-calendar.html> <https://www.discover.com/content/dam/dfs/credit-cards/static/json/cashback-calendar/offers.json> <https://www.discover.com/credit-cards/cash-back/cashback-bonus.html> |

- **otherFindings:** HIGH PRIORITY: main's 2026 calendar appears to be wrong for every quarter. Many independent non-official sources agree, and several quote Discover's term text verbatim ('from 10/1/26 (or the date on which you activate 5%, whichever is later) through 12/31/26, on up to $1,500'). Sources include TPG, CNBC Select, Forbes Advisor, AwardWallet, CardRatings, Doctor-of-Credit-style posts and Slickdeals; none could be confirmed on discover.com. Their 2026 calendar: Q1 = grocery stores, wholesale clubs, select streaming; Q2 = restaurants, home improvement; Q3 = gas stations, transportation (transit), drug stores (CardRatings lists Q3 slightly differently); Q4 = restaurants, entertainment, utilities. Under that calendar, Q4 would map to dining, entertainment, utilities and possibly internet and phone, since Discover's utilities definition includes online/phone payments for internet, cable, satellite TV and mobile/landline phone. Main's current Q4 2026 = amazon/target and Q3 = grocery/walmart. Recommend a human re-check of the logged-in Discover calendar or the activation email terms before shipping, because the current Q4 recommendation is probably wrong. Cap is $1,500/quarter, activation required, 5%.

#### `discover-discover-it-student-cash-back`

> **Superseded:** the 2026 rotating calendar below was later replaced from discover.com page text; see "Corrections to existing main data" for provenance and limits.

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| PR rotating Q3 2026 = gas/transit/drugstore and Q4 2026 = dining/entertainment/utilities | unverified | Same as Discover it Cash Back: the official calendar was unavailable (page error, the data API requires login, offers.json is stale). Main is kept. | <https://www.discover.com/credit-cards/cash-back/cashback-calendar.html> <https://www.discover.com/credit-cards/student/it-card.html> |

- **otherFindings:** Same high-priority finding as discover-discover-it-cash-back. Non-official sources indicate the student card shares the same 2026 calendar (Q4 2026 = restaurants, entertainment, utilities), so main's Q1-Q4 2026 entries are likely all wrong. Human verification against an official Discover source is required.

#### `discover-discover-it-chrome`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Replace dining/gas 2% ($1,000/qtr) entries with versions noted 'Combined cap shared with ...' | reject | The official page confirms '2% cash back at gas stations and restaurants on up to $1,000 in combined purchases each quarter', which main already models. Adding a note to dining would make the unconditional dining reward conditional and hide it. | <https://www.discover.com/credit-cards/cash-back/chrome/> <https://www.discover.com/credit-cards/student-credit-card/chrome-card/> |

- **otherFindings:** Main is correct: per-entry caps of 1000 quarterly approximate the combined $1,000/quarter cap.

### g5a-bofa-barclays


#### `bank-of-america-alaska-airlines-visa-signature`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add evCharging 2x | apply | The card is now the Atmos Rewards Ascent Visa Signature. BofA's product page says it earns 'unlimited 2 points for every $1 spent on eligible gas, EV charging station, cable, streaming services and local transit purchases'. I read this from the official page text in search results because a direct fetch of the JS-rendered page returned no content. | <https://www.bankofamerica.com/credit-cards/products/alaska-airlines-credit-card/> <https://www.alaskaair.com/atmosrewards/content/credit-cards/visa-ascent> |

- **otherFindings:** Main still uses the old product name; the card is now 'Atmos Rewards Ascent Visa Signature', which earns Atmos points, not miles. Main's airlines 3x has no note, but the 3x applies only to eligible Alaska Airlines and Hawaiian Airlines purchases. It should probably carry a note such as 'Alaska/Hawaiian Airlines purchases'. Cable (2x) is not modeled.

#### `bank-of-america-bank-of-america-customized-cash-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Grocery 2%: add $2,500 quarterly cap shared with wholesale and the choice category (with a note) | partial | Officially, the 3%/2% rates apply to 'the first $2,500 in combined purchases each quarter in the choice category, and at grocery stores and wholesale clubs, then … 1%'. I applied cap 2500 quarterly as a conservative per-entry approximation and left the note off to match wholesale (see the wholesale decision). | <https://www.bankofamerica.com/credit-cards/products/cash-back-credit-card/> <https://www.bankofamerica.com/credit-cards/products/cash-back-credit-card/cash-back-category-choices> |
| Wholesale 2%: add $2,500 quarterly combined cap (with a note) | partial | The combined $2,500 quarterly cap is confirmed, so I applied cap 2500 quarterly. I rejected the note because a note on wholesale makes the reward conditional and hides it by default. | <https://www.bankofamerica.com/credit-cards/products/cash-back-credit-card/> |

- **combinedCap:** {"amount": 2500, "period": "quarterly", "categories": ["choice category (3%)", "grocery", "wholesale"]}

- **otherFindings:** The selectableConfig cap of $2,500 quarterly is also part of the same combined cap. New cardholders currently get 6% in the choice category for the first year, which is a temporary offer and is not modeled. NerdWallet describes the gas choice as 'gas/EV charging stations'; I did not confirm this on an official page.

#### `bank-of-america-bank-of-america-travel-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove unconditional travel 3x | partial | BofA says to 'Earn 3 points for every $1 you spend on travel purchases booked through BofA Travel', so main's unconditional travel 3x is wrong. Because the 3x is a portal-only rate, I kept it with the note 'Booked through BofA Travel' (conditional) instead of deleting it. | <https://www.bankofamerica.com/credit-cards/travel-credit-cards/> <https://www.bankofamerica.com/credit-cards/> |

- **otherFindings:** BofA's pages are JS-rendered and returned no reward text to direct fetches. I verified the 1.5x base and the portal 3x from the official page text in search results and the product page's JSON-LD.

#### `barclays-aadvantage-aviator-silver`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| annualFee 149 -> 199 | unverified | Barclays' product page returns 404 and I found no fetchable official source. Blogs report $199, but they cannot be used to verify. | <https://cards.barclaycardus.com/banking/cards/aadvantage-aviator-silver-world-elite-mastercard/> |
| airlines 2x -> 3x | unverified | No fetchable official source (Barclays page returns 404). | — |
| Remove dining 2x | unverified | No fetchable official source. | — |
| Remove gas 2x | unverified | No fetchable official source. | — |
| Add hotels 2x | unverified | No fetchable official source. | — |

- **otherFindings:** Not official, but several reports (CNBC Select, Upgraded Points) say Barclays stopped issuing AAdvantage cards and converted all Aviator accounts to Citi/AAdvantage products starting 2026-04-24. If so, this Barclays card no longer exists for anyone. This needs an official check on Citi or aa.com and a product-identity decision; I left the card unchanged.

#### `barclays-frontier-airlines-world-mastercard`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add credit frontier-flight-voucher $100 annual (after $2,500/year in purchases) | apply | Barclays: 'Earn a $100 Flight Voucher every account anniversary after spending $2,500 or more on purchases with your card during your cardmembership year.' | <https://cards.barclaycardus.com/banking/cards/frontier-airlines-world-mastercard/> |

- **otherFindings:** Barclays now advertises 'up to 17x Miles on eligible Frontier purchases' (earning differs for Basic fares) rather than a flat 5x. Main's airlines 5x has no note even though it applies only to Frontier purchases, so it should probably be conditional. The $99 fee and 3x restaurants are confirmed.

#### `barclays-hawaiian-airlines-world-elite`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add grocery 2x | apply | Barclays' Hawaiian Airlines World Elite Mastercard page lists '2x on gas, dining and eligible grocery store purchases'. Hawaiian's Feb 2026 press release says 'Earn 2 points for every $1 spent on eligible gas, dining, and grocery store purchases.' | <https://cards.barclaycardus.com/banking/credit-card/hawaiian-airlines/child/hbl-control> <https://www.prnewswire.com/news-releases/aloha-to-big-rewards-millions-of-atmos-rewards-points-up-for-grabs-for-hawaiian-airlines-world-elite-mastercard-cardmembers-in-2026-302676839.html> |

- **otherFindings:** The card now earns Atmos Rewards points, not HawaiianMiles. The airlines 3x applies only to eligible Hawaiian and Alaska Airlines purchases but has no note. Barclays' main product URL returns 404; new applications appear to be limited to inflight and Bank of Hawaii channels, while existing cardmembers keep the card.

#### `barclays-priceline-vip-rewards-visa`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add credit priceline-global-entry-tsa $100 annual (requires $10,000/year in purchases) | partial | Barclays' current Priceline page says 'Up to $120 Global Entry or TSA PreCheck application fee statement credit each anniversary year if you spend $10,000 on purchases'. I added the credit at $120 instead of $100. | <https://cards.barclaycardus.com/banking/credit-card/priceline/co_brand_partner_site/prequal/2f96b6b4-79b9-4767-ac5d-26d8ef751cb3?referrerid=PRVmytripsPQ> |

- **otherFindings:** Main's travel 5x is unconditional, but officially it is '5X points for every $1 spent on Priceline bookings'. It should carry a note such as 'Priceline bookings' so it is conditional. The page also lists 10x on Pay Now Priceline Avis/Budget rentals and a $50 cruise statement credit with a Priceline cruise booking; neither is modeled.

#### `barclays-wyndham-rewards-earner`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add dining 2x | partial | Dining does earn a bonus, but at 3x, not 2x. Wyndham's 2026-06-17 refresh press release lists '3x points on dining, grocery, gas and EV charging', and both wyndhamrewardscreditcard.com and the detailed Barclays rewards section say 3x dining. I added dining at 3x. The 2x summary blurb on the Barclays page is stale. | <https://investor.wyndhamhotels.com/news-events/press-releases/detail/422/wyndham-and-barclays-launch-updated-credit-card-suite> <https://www.wyndhamrewardscreditcard.com/> <https://cards.barclaycardus.com/banking/cards/wyndham-rewards-earner-card/> |
| gas 3x -> 2x | reject | The current official earn rate on gas is 3x per the June 2026 press release and the co-brand site. The 2x line on Barclays comes from a stale summary blurb. | <https://investor.wyndhamhotels.com/news-events/press-releases/detail/422/wyndham-and-barclays-launch-updated-credit-card-suite> <https://www.wyndhamrewardscreditcard.com/> |
| grocery 3x -> 2x | reject | Grocery is officially 3x, excluding Target and Walmart, which matches main. | <https://investor.wyndhamhotels.com/news-events/press-releases/detail/422/wyndham-and-barclays-launch-updated-credit-card-suite> <https://cards.barclaycardus.com/banking/cards/wyndham-rewards-earner-card/> |

- **otherFindings:** The press release also lists 3x on EV charging (evCharging is not on main) and 3x on eligible Vacation Club purchases. Main's hotels 5x has no note, but it applies only to Hotels by Wyndham. The Barclays page itself is inconsistent: its detailed section omits gas, while the summary blurb still says 2x on dining, grocery and gas.

#### `barclays-wyndham-rewards-earner-plus`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add credit wyndham-earner-plus-meal-delivery $25 semiannual | apply | Wyndham's 2026-06-17 press release lists 'Up to $50 meal delivery credit (up to $25 every six months)' for the Earner Plus. | <https://investor.wyndhamhotels.com/news-events/press-releases/detail/422/wyndham-and-barclays-launch-updated-credit-card-suite> |
| Add dining 4x | apply | Barclays: 'Earn 4 points per $1 spent on eligible dining, grocery store purchases (excluding Target and Walmart) and travel purchases.' | <https://cards.barclaycardus.com/banking/cards/wyndham-rewards-earner-plus-card/> |
| Add travel 4x | apply | Confirmed by Barclays and the press release. The press release defines travel as gas, EV charging, air, car rental, rideshare, tolls and trains. | <https://cards.barclaycardus.com/banking/cards/wyndham-rewards-earner-plus-card/> <https://investor.wyndhamhotels.com/news-events/press-releases/detail/422/wyndham-and-barclays-launch-updated-credit-card-suite> |

- **otherFindings:** The official 'travel' category includes gas, EV charging, air, car rental, rideshare, tolls and trains. Consider adding gas, evCharging, airlines and transit entries at 4x, since the engine does not map gas to travel. The hotels 6x applies only to Hotels by Wyndham but has no note. A new Wyndham Rewards Earner Premier card ($395) launched 2026-06-17; I did not add it (newProductNotAdded).

### g5b-other


#### `navy-federal-navy-federal-flagship-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add $100 airline incidental credit | reject | The $100 airline credit belongs to the new Flagship Premier card. Legacy Flagship Rewards keeps the Amazon Prime ($139) annual statement credit. | <https://www.navyfederal.org/loans-cards/credit-cards/flagship-upgrade.html> |
| Remove Amazon Prime $139 credit | reject | Navy Federal's comparison table still lists the Amazon Prime ($139) annual statement credit for Flagship Rewards and says all current benefits stay after the fee increase. | <https://www.navyfederal.org/loans-cards/credit-cards/flagship-upgrade.html> |
| annualFee 49 -> 95 | reject | The Flagship Rewards fee rises to $95 effective 2026-11-02, which is after 2026-10-27, so it is not applied yet. effectiveDate: 2026-11-02. | <https://www.navyfederal.org/loans-cards/credit-cards/flagship-upgrade.html> |
| baseReward 2 -> 1 | reject | Legacy Flagship Rewards earns 2X on all other purchases (footnote 4). The 1X rate belongs to Flagship Premier. | <https://www.navyfederal.org/loans-cards/credit-cards/flagship-upgrade.html> |
| Add dining 3x | reject | Legacy Flagship Rewards earns 2X on dining, the same as its base rate. The 3X dining rate belongs to Flagship Premier. | <https://www.navyfederal.org/loans-cards/credit-cards/flagship-upgrade.html> |
| travel 3x -> 4x | reject | Legacy Flagship Rewards earns 3X on travel. The 4X travel rate belongs to Flagship Premier. | <https://www.navyfederal.org/loans-cards/credit-cards/flagship-upgrade.html> |

- **effectiveDate:** 2026-11-02

- **newProductNotAdded:** Navy Federal Flagship Premier Visa Signature: $95 fee; 4X travel, 3X dining, 1X other; $100 annual airline statement credit after $100 in airline spend; Global Entry/TSA PreCheck credit up to $120 every 4 years. Existing Flagship Rewards cardholders can still keep their current card.

- **otherFindings:** Main is correct for the legacy card as of today. On 2026-11-02 the annualFee should change to 95. Flagship Rewards also has a Global Entry/TSA PreCheck credit of up to $120 every 4 years, which the catalog does not model.

#### `penfed-penfed-pathfinder-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| baseReward 1 -> 1.5 | apply | PenFed's Pathfinder FAQ says all purchases earn 1.5X points. | <https://www.penfed.org/credit-cards/pathfinder-rewards-visa> <https://www.penfed.org/credit-cards/pathfinder-honors-advantage> |
| Add dining 2x (PR 0810) | apply | Standard cardholders earn 1.5X base plus a 0.5X dining bonus, for 2X on dining. Honors Advantage members earn 3X. | <https://www.penfed.org/credit-cards/pathfinder-rewards-visa> |
| Add dining 3x (PR 0914) | partial | The 3X dining rate is for PenFed Honors Advantage members only, so it is added as a conditional entry with a note, not as an unconditional rate. | <https://www.penfed.org/credit-cards/pathfinder-rewards-visa> |
| travel 3x -> 4x | partial | Standard cardholders earn 3X on travel and Honors Advantage members earn 4X. The unconditional entry stays at 3X, and 4X is added as a conditional noted entry. | <https://www.penfed.org/credit-cards/pathfinder-rewards-visa> <https://www.penfed.org/credit-cards/pathfinder-honors-advantage> |

- **otherFindings:** The terms PDF (Pathfinder_RWDTC.pdf) and the product pages returned Akamai 'Access Denied' or timed out on direct fetch. The rates above come from the official penfed.org page text (Pathfinder product page FAQ and Honors Advantage page) as returned by a search index. The annual fee was not re-verified, so main's $95 is kept. A PenFed travel-credits PDF mentions either a $100 or an $85 statement credit; I could not fetch it, so the $100 airline credit is kept as on main.

#### `penfed-penfed-platinum-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add dining 3x | apply | PenFed lists 3X points at supermarkets and restaurants, uncapped. | <https://www.penfed.org/credit-cards/platinum-rewards-visa> <https://www.penfed.org/credit-cards/platinum-rewards-visa/comparison> |
| Add evCharging 5x | apply | PenFed lists 5X points on gas paid at the pump and at EV charging stations. | <https://www.penfed.org/credit-cards/platinum-rewards-visa> <https://www.penfed.org/credit-cards/platinum-rewards-visa/comparison> |
| Add streaming 3x | apply | PenFed lists 3X points on TV, radio, cable, and streaming services. | <https://www.penfed.org/credit-cards/platinum-rewards-visa> <https://www.penfed.org/credit-cards/platinum-rewards-visa/comparison> |

- **otherFindings:** The penfed.org page timed out on direct fetch. The rates come from the official penfed.org product and comparison pages as returned by a search index; the comparison page lists all three categories. PenFed says the 3X supermarket rate includes most Target and Walmart locations. Main has no credits key for this card, so finalCard uses an empty list.

#### `robinhood-robinhood-gold-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove travel 5% | apply | The Rewards Program Rules (last updated 2026-09-01) say purchases through the Robinhood Travel Portal 'are no longer eligible for extra Points'. Every eligible purchase earns 3 Points per dollar. | <https://api.robinhood.com/creditcard/legal/reward-terms> |

- **otherFindings:** Earning Points requires an active annual Robinhood Gold membership, which is a separate paid membership. The rules also describe an extra 1 Point (4X total) on 'qualifying dining purchases' through in-app Merchant Offers. That is offer-specific, not a category rate, so it is not modeled. Main has no credits key for this card, so finalCard uses an empty list.

#### `synchrony-sam-s-club-mastercard`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove travel 3% | apply | The official program terms list only 5% gas/EV charging, 3% restaurants, 3% at Sam's Club for Plus members, and 1% on everything else. There is no travel category. | <https://scene7.samsclub.com/is/content/samsclub/sams-cash-with-mastercard> <https://help.samsclub.com/app/answers/detail/a_id/4092/~/sams-cash-faq> |
| wholesale 3% (null note) -> 1% with Plus-member note | partial | The 3% rate applies only at Sam's Club, and only for Plus members; Club members earn the 1% base rate. The entry is kept at 3% but given a note so it is conditional. The proposed multiplier of 1 contradicted its own note and would duplicate the base rate. | <https://scene7.samsclub.com/is/content/samsclub/sams-cash-with-mastercard> |

- **combinedCap:** 5% applies to the first $6,000 per calendar year of combined gas station and EV charging spend.

- **otherFindings:** The terms also give 5% at EV charging stations, sharing the $6,000/yr gas cap. Main has no evCharging entry, and the PRs did not propose one. Main has no credits key for this card, so finalCard uses an empty list.

#### `synchrony-verizon-visa-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add evCharging 4% | apply | The Rewards Program Terms give 4% Verizon Dollars on gas and at EV charging stations (MCC 'Electric Vehicle Charging'). | <https://www.verizon.com/support/verizon-visa-card-rewards-legal/> <https://www.verizon.com/support/verizon-visa-card-faqs/> |

- **otherFindings:** Verizon also gives 4% on Verizon store purchases, excluding bill payment. That is merchant-specific and not modeled; main's phone 1% is consistent with bill payments earning only the base rate. Main has no credits key for this card, so finalCard uses an empty list.

#### `us-bank-us-bank-altitude-connect-visa-signature`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Add dining 2x | apply | U.S. Bank lists 2X points on restaurant, fast-food, and bar purchases. | <https://www.usbank.com/credit-cards/altitude-connect-visa-signature-credit-card.html> |
| gas 4x uncapped -> 4x cap $1,000 quarterly (null note) | apply | 4X applies to the first $1,000 each quarter of combined gas station and EV charging spend. Following the combined-cap rule, the per-entry cap is set to the combined amount. | <https://www.usbank.com/credit-cards/altitude-connect-visa-signature-credit-card.html> |
| evCharging 4x uncapped -> 4x cap $1,000 quarterly (null note) | apply | Same $1,000-per-quarter combined gas/EV cap as above. | <https://www.usbank.com/credit-cards/altitude-connect-visa-signature-credit-card.html> |
| Replace gas/evCharging with 'Combined cap shared with ...' noted entries (PR 0810) | reject | This duplicates the cap change above with notes that only describe the cap. The null-note entries with $1,000 quarterly caps are used instead. | <https://www.usbank.com/credit-cards/altitude-connect-visa-signature-credit-card.html> |

- **combinedCap:** 4X applies to the first $1,000 per quarter of combined gas station and EV charging spend.

- **otherFindings:** The card also earns 5X on prepaid hotels and car rentals booked in the U.S. Bank Travel Center. That is portal-only and not on main; it would need a note. Main has no credits key for this card, so finalCard uses an empty list.

#### `usaa-usaa-cashback-rewards-plus`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| grocery 2% -> 3% (cap $3,000 yearly) | apply | USAA's 2025 Annual Report to Members shows 'NEW UPGRADED REWARDS': 3% on the first $3,000 in grocery purchases yearly, replacing 2%. Existing cardholders received it automatically as of 2025-12-02. usaa.com search snippets show the same rate. | <https://static.usaa.com/content/dam/digital/documents/pdf/brand/2025-annual-report-to-members.pdf> <https://www.usaa.com/banking/credit-cards-public/cash-back/rewards-plus/> |

- **otherFindings:** Gas is now 5% on the first $3,000 per year on its own; military base purchases have a separate 5% on the first $5,000 per year, which has no catalog category. The usaa.com product page timed out on direct fetch. Main has no credits key for this card, so finalCard uses an empty list.

#### `walmart-walmart-rewards-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove dining 2% | unverified | Main reflects the legacy Capital One Walmart Rewards Card. Capital One no longer lists it, and no official source fetched states legacy cardholders' current earn rates. The PR's structure matches a different product, the OnePay CashRewards Card. | <https://investor.capitalone.com/news-releases/news-release-details/capital-one-and-walmart-announce-end-consumer-card-partnership> <https://www.onepay.com/credit-card> |
| Remove grocery 2% | unverified | Same product-identity uncertainty as above. Main is kept. | <https://www.onepay.com/credit-card> |
| Remove travel 2% | unverified | Same product-identity uncertainty as above. Main is kept. | <https://www.onepay.com/credit-card> |
| walmart 5% unconditional -> noted 3%/5% Walmart+ entries | unverified | The 5% with Walmart+ / 3% otherwise / 1.5% elsewhere structure is the OnePay CashRewards Card, a different issuer and product, so it is not applied to the legacy card. | <https://www.onepay.com/credit-card> <https://www.walmart.com/cp/onepay-card/9435689> |

- **newProductNotAdded:** OnePay CashRewards Mastercard (issued by Synchrony): $0 fee; 5% at Walmart for Walmart+ members, 3% at Walmart otherwise, 1.5% everywhere else.

- **otherFindings:** Someone should confirm whether any legacy Capital One Walmart Rewards accounts are still active and on what terms. If none are, the catalog entry may need to be marked discontinued, or the card replaced by a OnePay CashRewards entry under a new id.

#### `wells-fargo-bilt-mastercard`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Remove dining 3x | reject | Bilt support says the Wells Fargo Bilt Mastercard was retired after 2026-02-06. Accounts moved to Bilt Card 2.0 (Column N.A.) or converted to the Wells Fargo Autograph Card. No official source supports a 1X-only version of this card, so the proposal matches no current product. | <https://support.biltrewards.com/hc/en-us/articles/40834037331085-Bilt-Card-2-0-Transition> <https://www.bilt.com/card> |
| Remove travel 2x | reject | Same as above: the product was retired, and the proposal does not reflect any official earn structure. | <https://support.biltrewards.com/hc/en-us/articles/40834037331085-Bilt-Card-2-0-Transition> |

- **newProductNotAdded:** Bilt Card 2.0 (Cardless/Column N.A.): Blue ($0), Obsidian ($95; 3X dining or grocery, 2X other travel, $100 Bilt Travel hotel credit), Palladium ($495; 2X everyday, $400 hotel credit, Priority Pass). Retired Wells Fargo Bilt accounts that stayed open became Wells Fargo Autograph Cards.

- **otherFindings:** The Wells Fargo Bilt Mastercard has been unusable since 2026-02-07. Main's entry is stale; it should be marked discontinued and/or replaced by Bilt 2.0 entries, which needs a separate decision. The catalog does not remove cards.

### g6-portal-brand


#### `american-express-american-express-gold-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Annual fee $325, base 1x | already-on-main | Official page: $325 annual fee; 1X on other purchases. | <https://www.americanexpress.com/us/credit-cards/card/gold-card/> |
| Dining 4x: add cap $50,000/yearly | apply | 4X at restaurants worldwide on up to $50K per calendar year, then 1X. Main has no cap. | <https://www.americanexpress.com/us/credit-cards/card/gold-card/> |
| Grocery 4x: add cap $25,000/yearly | apply | 4X at U.S. supermarkets on up to $25K per calendar year, then 1X. Main has no cap. | <https://www.americanexpress.com/us/credit-cards/card/gold-card/> |
| Airlines 3x note null kept | already-on-main | 3X applies to flights booked directly with airlines or via AmexTravel, i.e. ordinary airline purchases; unconditional is correct. | <https://www.americanexpress.com/us/credit-cards/card/gold-card/> |
| Add hotels 5x note 'Prepaid hotels booked through AmexTravel.com' | apply | Official page lists 5X on prepaid hotels booked through AmexTravel.com/Amex Travel App; portal-only so encoded conditional. | <https://www.americanexpress.com/us/credit-cards/card/gold-card/> |
| Credits (dining $10/mo, Uber $10/mo, Resy $50 semiannual, Dunkin $7/mo) | already-on-main | All four match the official page. | <https://www.americanexpress.com/us/credit-cards/card/gold-card/> |

- **otherFindings:** 2X on prepaid car rentals/cruises via AmexTravel.com not modeled (portal-only, below-value).

#### `american-express-marriott-bonvoy-brilliant-american-express-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Base reward 1 -> 2 | apply | Official page: 2X points on all other eligible purchases. Main's 1x is wrong. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-brilliant/> |
| Hotels 6x: add note 'Marriott Bonvoy hotels' | apply | 6X applies only at hotels participating in Marriott Bonvoy; brand-only rate must be conditional. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-brilliant/> |
| Dining 3x, airlines 3x (note null), annual fee $650 | already-on-main | 3X at restaurants worldwide and on flights booked directly with airlines; $650 fee. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-brilliant/> |
| Dining credit $25/month | already-on-main | Up to $300/yr ($25/month) at restaurants worldwide. | <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-brilliant/> |

- **otherFindings:** $100 Ritz-Carlton/St. Regis property credit is per qualifying 2-night stay, not periodic; not modeled.

#### `american-express-delta-skymiles-platinum-american-express-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Airlines 3x: add note 'Delta purchases' | apply | 3X only on purchases made directly with Delta (flights, Delta Vacations); brand-only rate must be conditional. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-platinum-american-express-card/> |
| Hotels 3x note null kept | already-on-main | 3X on purchases made directly with hotels (any brand), so unconditional is acceptable. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-platinum-american-express-card/> |
| Dining 2x, grocery 2x, base 1x, fee $350 | already-on-main | Matches official page. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-platinum-american-express-card/> |
| Credits: rideshare $10/mo, Resy $10/mo, Delta Stays $150/yr | already-on-main | Matches official page. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-platinum-american-express-card/> |

#### `american-express-delta-skymiles-reserve-american-express-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Airlines 3x: add note 'Delta purchases' | apply | 3X only on purchases made directly with Delta; brand-only rate must be conditional. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-reserve-american-express-card/> |
| Fee $650, base 1x | already-on-main | Matches official page. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-reserve-american-express-card/> |
| Credits: rideshare $10/mo, Resy $20/mo, Delta Stays $200/yr | already-on-main | Matches official page. | <https://www.americanexpress.com/us/credit-cards/card/delta-skymiles-reserve-american-express-card/> |

#### `citi-citi-premier-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Duplicate check vs citi-citi-strata-premier-card | unverified | Citi's press release calls Citi Strata Premier 'an enhancement of the existing Citi Premier Card' with a new name and the same $95 fee, so this entry is a renamed predecessor that duplicates citi-citi-strata-premier-card. Card ids can't be removed under the rules, so main's data is left as-is. Flagged for a maintainer decision (hide or alias). | <https://www.citigroup.com/global/news/press-release/2024/citi-enhances-the-citi-premier-card-with-new-benefits-to-make-travel-adventures-more-rewarding> <https://www.citi.com/credit-cards/citi-strata-premier-credit-card> |
| Annual fee $95, 3x travel/gas/dining/grocery, base 1x | already-on-main | These match the current Strata Premier 3x categories (air travel and other hotels, restaurants, supermarkets, gas/EV) and the $95 fee. No standalone Citi Premier page exists to check against. | <https://www.citi.com/credit-cards/citi-strata-premier-credit-card> |

- **otherFindings:** Renamed predecessor of Citi Strata Premier (same product, rebranded 2024). The Strata Premier offer page says the bonus isn't available to anyone who has or had 'a Citi Strata Premier or a Citi Premier account'. Separately, citi-citi-strata-premier-card on main has 10x note 'Hotels booked through thankyou.com'. Officially it's now 10x on hotels, car rentals and attractions booked on cititravel.com, and the $100 hotel benefit needs a single stay of $500+ via cititravel.com. That is outside this packet.

#### `capital-one-capital-one-venture-x-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Travel 10x: add note 'Hotels & rental cars booked through Capital One Travel' | apply | 10X applies only to hotels and rental cars booked through Capital One Travel. Main encodes it as unconditional travel. | <https://www.capitalone.com/credit-cards/venture-x/> |
| Airlines 5x: add note 'Flights booked through Capital One Travel' | apply | 5X applies only to flights (and vacation rentals) booked through Capital One Travel. | <https://www.capitalone.com/credit-cards/venture-x/> |
| Fee $395, base 2x | already-on-main | Matches official page. | <https://www.capitalone.com/credit-cards/venture-x/> |
| $300 annual Capital One Travel credit | already-on-main | Capital One compare page: $300 annual Capital One Travel credit. | <https://www.capitalone.com/credit-cards/compare/> |

- **otherFindings:** Not modeled: 5X on vacation rentals via Capital One Travel, 5X on Capital One Entertainment, 10,000 anniversary miles.

#### `capital-one-capital-one-venture-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Travel 5x: add note 'Hotels, vacation rentals & rental cars booked through Capital One Travel' | apply | Venture's 5X applies only to hotels, vacation rentals and rental cars booked through Capital One Travel. Main encodes it as unconditional travel. | <https://www.capitalone.com/credit-cards/venture/> |
| Fee $95, base 2x, no credits | already-on-main | Matches official page. | <https://www.capitalone.com/credit-cards/venture/> |

- **otherFindings:** Venture page lists 5X on Capital One Entertainment purchases (not modeled). The $300 stays credit is a limited-time first-year new-cardmember offer, so it isn't added as a recurring credit.

#### `capital-one-capital-one-ventureone-rewards`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Travel 5x: add note 'Hotels, vacation rentals & rental cars booked through Capital One Travel' | apply | VentureOne's 5X applies only to hotels, vacation rentals and rental cars booked through Capital One Travel. Main encodes it as unconditional travel. | <https://www.capitalone.com/credit-cards/ventureone/> |
| Fee $0, base 1.25x, no credits | already-on-main | Matches official page. | <https://www.capitalone.com/credit-cards/ventureone/> |

#### `wells-fargo-wells-fargo-autograph-journey-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Hotels 5x / airlines 4x note null | already-on-main | Earned by merchant category code (any hotel/motel, any airline), not a portal or brand, so unconditional is correct. | <https://creditcards.wellsfargo.com/autograph-journey-visa-credit-card/> |
| Dining 3x, travel 3x, base 1x, fee $95 | already-on-main | 3X on restaurants and other travel, 1X otherwise, $95 annual fee. | <https://creditcards.wellsfargo.com/autograph-journey-visa-credit-card/> |
| $50 annual airline credit | already-on-main | One-time $50 statement credit each year on the first airline purchase of $50+. | <https://creditcards.wellsfargo.com/autograph-journey-visa-credit-card/> |

#### `us-bank-us-bank-altitude-reserve-visa-infinite`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Card status | already-on-main | U.S. Bank lists the Altitude Reserve under 'Personal Credit Cards (no longer accepting new applications)'. Existing cardholders keep it, so the card stays on main. | <https://www.usbank.com/credit-cards/benefits.html> |
| Fee $400, travel 3x / dining 3x (note null), base 1x | unverified | No official product or terms page could be fetched; the product page redirects and the benefits center doesn't render without a login. Main is kept. | <https://www.usbank.com/credit-cards/benefits.html> <https://rewards.usbank.com/benefits/card/AltitudeReserveBenefits> |
| $325 annual travel credit | already-on-main | U.S. Bank's Altitude Reserve benefits center lists a '$325 annual credit' under Travel. The exact eligible purchases weren't viewable. | <https://rewards.usbank.com/benefits/card/AltitudeReserveBenefits> |

- **otherFindings:** Lead to check, not verified from an official source: the card's 3X was historically on travel and mobile-wallet purchases, not dining specifically. The $325 credit may also cover dining, not only the US Bank Travel Center. Re-check against the cardmember agreement before changing anything.

#### `barclays-jetblue-plus-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Airlines 6x: add note 'JetBlue purchases' | apply | 6X applies only to eligible JetBlue purchases; brand-only rate must be conditional. | <https://cards.barclaycardus.com/banking/cards/jetblue-plus-card/> |
| Dining 2x, grocery 2x, base 1x, fee $99 | already-on-main | 2X at restaurants and eligible grocery stores; $99 annual fee. | <https://cards.barclaycardus.com/banking/cards/jetblue-plus-card/> |
| $100 JetBlue Vacations credit (annual) | already-on-main | $100 statement credit after a JetBlue Vacations package of $100+, limit one per year. | <https://cards.barclaycardus.com/banking/cards/jetblue-plus-card/> |

- **otherFindings:** 5,000 anniversary bonus points and 10% points back on award flights are not modeled.

#### `barclays-jetblue-card`

| Proposal | Verdict | Reason | Sources |
|---|---|---|---|
| Airlines 3x: add note 'JetBlue purchases' | apply | 3X applies only to eligible JetBlue purchases; brand-only rate must be conditional. | <https://cards.barclaycardus.com/banking/cards/jetblue-card/> |
| Dining 2x, grocery 2x, base 1x, fee $0 | already-on-main | Matches official page. | <https://cards.barclaycardus.com/banking/cards/jetblue-card/> |
