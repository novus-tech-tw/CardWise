# MaxRewards REA investigation

Investigation date: 2026-10-26 America/Phoenix (capture/export crossed 2026-10-27 UTC).

## Scope and outcome

REA was actually run against MaxRewards' public browser experience and acquired first-party JavaScript. It reproduced the product-page-to-signup transition and statically parsed seven selected business-related sources. This is a bounded analysis of the public website and account acquisition flow, **not a decompilation of the MaxRewards iOS or Android app**. No mobile binary, logged-in wallet, banking credentials, payment interaction, or recommendation result was acquired.

The strongest finding is a clear separation between the Webflow marketing surface and a React/Next.js account surface, with explicit identity, user-provisioning, session-recovery, and mobile-handoff logic. This supports a meaningful comparison with CardWise's account-free onboarding. It does not establish how MaxRewards computes card rewards or connects to banks.

## Evidence ledger

| ID | REA Evidence ID | Operation and coverage |
|---|---|---|
| R1 | `ev_ea10ac8fd04e2f98a2eebf6f667e47d98d7beb2f1863021bfc1edd94cb37ba01` | Browser scenario: fresh provider-owned headless Chromium 156.0.8078.48; product page to signup; DOM, accessibility, URL, history and network metadata. Three declared actions completed. Owned browser terminated afterward. |
| S1 | `ev_a1ab54ca0e29ba5922c67b4c0bf00f27dcfeae2b2aa23d0407e0b47c22c27584` | Parent JavaScript application analysis: seven selected sources from a 38-file acquired corpus, 286,567 text bytes, 86,722 visited AST nodes, zero parse failures. |
| S1 summary | `ev_e2ba528d655c51541194be6551222f3fcdf491e1fdd9a1e45b0db68f2bf00e6e` | Retained parent summary, including limits and unselected scopes. |
| M1 | `ev_761b3fa2f5568730796b6e0332fc68c8390d54e6f809225a0f40659bdce64177` | Complete 45-entry page of source-module and asset-role identities. |
| A1 | `ev_d777b33790d8ba2fe44a2812c46586c09ef9551e33941bb3fc22c3a7be625f7b` | Auth/business chunk module identity and observations for `2kf2nyxhdvt_4.js`. |
| A2 | `ev_5e06741940a46a846e19984ade097521f6aaa2cf0dbf3690b8370bd47c6adc80` | Signup chunk module identity and observations for `1ilbignihnir-.js`. |

Full records are preserved in `rea-evidence-bundle.json` (6 records; 94,636,146 bytes at export). `scenario-evidence.json` contains the portable runtime Evidence. Raw tool envelopes are also retained.

## Target identity and acquisition

Official product URL: <https://maxrewards.com/app>. The product page links its primary CTA to `/signup` and business-product CTA to `/platinum`.

Official distribution references were obtained from <https://maxrewards.com/download-app>:

- iOS: <https://apps.apple.com/us/app/maxrewards-rewards-cashback/id1435710443>
- Android: <https://play.google.com/store/apps/details?id=com.maxrewards>
- Mobile and QR download handoffs use MaxRewards' app.link domain.

These links resolve product identity; they are not evidence that a native package was downloaded or inspected. Native app versions remain unknown in this investigation.

Acquired artifacts: 30 public Next.js chunks, one public Webflow-component bundle, and seven inline script snapshots, totaling 2,987,794 bytes. Seven `blob:` script references could not be reacquired after the scenario ended; they remain acquisition gaps. The acquired corpus is intentionally not a complete website distribution. Downloaded script bytes were separately refetched from URLs observed in the scenario; their digest identity is established for the saved files, not for the unretained bytes from the earlier browser response.

| Artifact | SHA-256 |
|---|---|
| Initial product HTML | `dbf0fe80259eae2f88e5bb281fbed518c6d6c1cecbb9e1b64b8686f73c3e6e14` |
| Download-page HTML | `53deb31b86fb9fc512724e6ba3dfd45588ee606f177676f54f3233c0e19181f6` |
| Entire acquired JS corpus identity, S1 | `e22363f5777192a31f64604afa9bbc18f15b4fcf251be43ca819aa07a4e1f217` |
| Auth/business chunk `2kf2nyxhdvt_4.js` | `4c0ab2e5fd05cf979b0ee06c4eb3211b8722532b7c4f5b8338e9872e2e1d19a6` |
| Signup chunk `1ilbignihnir-.js` | `d433cacb49eef72938fbb8d8ecac1be56a2bb3e76626334cd2032b6780f20492` |
| Marketing component `production.bundle.js` | `81a6ac50f9838ce04759e311315f10a51d1c104c05d394efa3c9501a8bfbd4f9` |

Every successful source URL, filename, byte count and digest is in `artifact-manifest.json`; the initial document acquisition is in `acquisition.json`.

## Runtime observations

REA performed these declared actions, without submitting any form:

1. Open `https://maxrewards.com/app` in a fresh owned browser and wait for the primary CTA to become visible.
2. Click the CTA.
3. Wait 2.5 seconds and capture the resulting signup state.

All three completed. The final URL was `https://maxrewards.com/signup`. The signup page presented Google and Apple authentication, an email field, a disabled Continue button while the field was empty, and links to login, terms, privacy and app download. This is directly observed UI, not inferred from a screenshot in marketing material. [R1]

The same scenario observed automatic unauthenticated requests:

| Method and path | Observed response | Interpretation |
|---|---|---|
| GET `/api/public-chrome` | 200 | Public website component/configuration seam; response body was not requested. |
| GET `/api/get-popular-cards` | 200 | Public card-list seam; neither payload nor card coverage was inspected. |
| GET `/sessions/whoami` on the main domain | 401 | Session check while signed out. |
| GET `/sessions/whoami` on `access.maxrewards.com` | 401 | A second identity/session surface was contacted. |
| GET `/api/auth/magic-session` | 401 | Signed-out magic-session check. |

These requests were emitted by the visited page, not manually invoked as API probes. They establish observed paths/statuses only; no request or response bodies, header values, credentials, or storage values were collected. Scenario events lack initiator stacks, so timing does not prove which module initiated each request. Some requests were unfinished when capture ended. [R1]

## Static observations and bounded inferences

### Marketing and account surfaces are separate web implementations

**Observed:** the marketing DOM includes Webflow page/site metadata, Webflow assets, and a loader selecting a first-party production/staging component bundle. The signup page loads first-party `/_next/static/immutable/chunks/` resources, including a Turbopack runtime, with React component syntax in the acquired sources. [R1, S1; `app-inline-2.js` and acquired chunk inventory]

**Inference:** MaxRewards maintains a hybrid marketing/account web surface rather than a single static brochure. Exact Next.js/React versions, deployment topology, and native UI framework are not established. A response header name or shared vendor library is insufficient to establish the mobile application's stack.

### Signup separates identity creation from product-user provisioning

**Observed in inert source:** the auth/business chunk contains an Ory browser-registration flow, registration updates carrying email/password/CSRF fields, identity/session reads, and a separate product-user creation step. Its logic distinguishes an existing product user, a resumable identity without completed provisioning, and a reset path. [S1, A1; `2kf2nyxhdvt_4.js`, approximate character offsets 28,000–31,000; exact excerpts in `static-excerpts.json`]

**Inference:** identity establishment and MaxRewards account provisioning are separate application concerns, with recovery paths to avoid treating every returning identity as a new account. This is a source-level control-flow reading; no account was created and no server enforcement was tested.

### The web signup is designed to hand users to mobile

**Observed in inert source:** the signup chunk branches on phone context and return destination, writes a handoff payload through a storage helper, and navigates eligible users to the app-download page. Other source branches provide a mobile-app interstitial, dismissal state, and deep-return routing. The visible signup flow itself was only observed before submission. [S1, A2; `1ilbignihnir-.js`, approximate offsets 11,000–16,500]

**Inference:** web acquisition and native usage are deliberately connected. Whether every device follows that branch, and whether the handoff preserves signup correctly, remain untested.

### Firebase references are web-push plumbing, not proof of Firebase Auth

**Observed in inert source:** Firebase environment-variable names occur with messaging initialization, a service-worker path, notification-token registration and a web-push endpoint. Ory-related code owns the observed registration/session seams. [S1, A1; auth chunk approximate offsets 22,000–25,000]

**Inference:** the captured web code contains Firebase messaging integration. It would be incorrect to label the native app a Firebase app, or to infer Firebase Authentication from these strings. Service workers were blocked by the deterministic REA scenario configuration, and notification permission was never requested.

### Membership and attribution integration is present in shipped web code

**Observed in inert source:** the selected code contains membership/trial conversion tracking, a Stripe-session identifier field, and first-party attribution endpoint calls associated with registration. [S1, A1; approximately offsets 107,000–110,000]

**Inference:** account acquisition includes analytics and paid-membership integration seams. This does not establish a checkout route, payment processor execution, complete billing flow, or transfer of a real user's financial information. No paywall or checkout was opened. Third-party requests seen in the browser window are not all attributed to MaxRewards: the capture includes browser/environment instrumentation, lacks initiator stacks, and records metadata only.

## Vendor statements, separate from verified behavior

The rendered official product page advertises category/location card selection, offer activation, benefits monitoring, spending analysis and account aggregation. Its FAQ lists free core functionality, Gold from US$108/year and Platinum from US$240/year. It describes proprietary issuer connectors, encrypted credential handling and a policy against selling user data. These are **vendor claims**, not verified connector behavior or a security audit. [Official product page](https://maxrewards.com/app); also captured as visible content in R1.

No financial recommendation, offer activation, transaction sync, credential encryption, AI categorization, reward calculation, or membership entitlement was executed or verified.

## Implications for CardWise

These are analyst recommendations, not competitor facts. The CardWise baseline comes from `../cardwise-baseline.md` at repository commit `5f7b9823e053924ee3d353e3198c88738f66af0d`.

1. **Make account-free time-to-first-recommendation visible.** MaxRewards' observed public acquisition path reaches account creation before any wallet result. CardWise can demonstrate adding card names and obtaining a useful recommendation immediately. This is a concrete onboarding distinction; it does not prove MaxRewards lacks guest functionality elsewhere.
2. **Prioritize trustworthy cap-aware recommendations across every surface.** CardWise already has a cap-aware engine, while the baseline identified some callers omitting spending records. Validate the recorded-spending-near-cap scenario before expanding features. MaxRewards' own cap handling is not known from this investigation; this priority follows CardWise source evidence and its core promise.
3. **Improve existing benefit tracking instead of duplicating it.** CardWise already supports manual statement-credit usage and unused-credit aggregation. Make remaining value and the next reset easy to understand; clearly label manual versus automatic state. MaxRewards' automatic tracking is only a vendor claim in this pass.
4. **Explain recommendations and their freshness.** Present active category assumptions, remaining cap, point valuation, signup-bonus priority and catalog freshness near the result. This is compatible with the current local-first model and makes a recommendation easier to trust without account synchronization.
5. **Treat bank synchronization as an architectural product decision.** The web account/provisioning seams and vendor connector claims indicate a different service model from CardWise's private CloudKit approach. Automatic bank-linked features would require scope, ongoing operations and a changed data model; they should not be copied incidentally during UI work.

Do not recommend adding signup tracking, benefit tracking, or widgets as entirely new CardWise features: they already exist in the inspected baseline.

## Coverage checklist and unresolved questions

| Question | Status | Evidence or remaining requirement |
|---|---|---|
| Exact public website/native listing identity | Answered | Official product and download links; saved HTML and manifests. |
| Public product-to-signup behavior | Answered within scenario | R1; no form submission. |
| Public frontend layering | Answered within acquired web scope | R1, S1 and source-bound observations. |
| Identity/provisioning/mobile-handoff design | Partially answered | Inert source reading; server and successful signup behavior untested. |
| Paywall and billing behavior | Unresolved | Source seams and vendor prices only; no checkout capture. |
| Card reward ranking, cap accounting and merchant classification | Unresolved | Requires native artifact or an authorized wallet/runtime with known fixtures. |
| Bank connection and automatic offer behavior | Unresolved | Requires authorized bank/test fixtures; not exercised. |
| Native framework, package version, local database and app privacy implementation | Unresolved | No IPA/APK supplied or acquired from official distribution. |

S1 intentionally leaves 31 inventoried files unanalyzed. Its semantic graph is partial and truncated by the selected 12,000-node per-file and 50,000-node aggregate ceilings, with 19,396 semantic unknowns and 31 application-scope unknowns reported. Turbopack factory internals were not recovered as a complete original module graph. No absence claim should be based on this partial static graph. The analysis had zero syntax parse failures, but that is not proof of semantic completeness.

No repository content, account, bank connection, installed application, or global REA configuration was changed. All deliverables are in this external investigation directory.
