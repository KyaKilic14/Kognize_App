# Kognize — Session Report

**Date:** 2026-08-16 (covers all work since the last report, 2026-07-09)
**Team:** Product Manager, Frontend Dev, Backend Dev, DevOps
**HEAD at end of session:** `12d2b98` — up to date with `origin/main`, working tree clean

---

## 1. Summary

No session report was written between 2026-07-09 and today, even though four real work sessions
happened in that gap. This report closes that gap in one pass — condensed for the two earlier
sessions (already documented in `CLAUDE.md`'s Architecture section as they were built), full detail
for the two most recent ones, which added six substantial features and were never written up
anywhere until now.

Headline for tonight in particular: **the app was built and run in Xcode for the first time all
session**, and a real bug was found and fixed as a direct result — everything before that point had
only ever been verified structurally (braces, `pbxproj` validity, grep checks), never compiled.

---

## 2. 2026-07-14 — More hub, Portfolio Breakdown, History (condensed)

Already fully documented in `CLAUDE.md`'s Architecture section — see there for detail. Summary:
added the **More** tab as a scalable home for lower-frequency features (replacing the old Journal
tab slot), un-nested Journal and Spending Context into their own cards, built **Portfolio
Breakdown** (upload → canned Q&A → results, with the "Things to look into" generic-education
compliance correction — a personalized investment suggestion Kya originally wanted got walked back
to generic concepts since it would otherwise read as a regulated personal recommendation), and
added **History** as a read-only record in the hamburger menu.

## 3. 2026-07-16 — Receipt Scanner, Profile bio, Subscription Centre, More reorder (condensed)

Also documented in `CLAUDE.md`. Summary: built **Receipt Scanner** (camera/upload capture →
editable breakdown → canned Q&A → confirmation, introducing `FinanceStore` as the first shared
live data source behind Dashboard widgets), then in the same session added a **Profile bio box**,
**Subscription Centre** (list, edit/remove, add flow with simulated recognition Q&A), and a
reorder-only edit mode for the More hub.

---

## 4. 2026-08-07 — Net Worth and Smart Transaction Sorting

### 4.1 Net Worth
New Dashboard card → bespoke `NetWorthDetailView`. Breakdown of cash/investments/manual
entries/liabilities, a progression section (illustrative history deltas + descriptive trend
commentary, deliberately no fabricated forecast number), and **life events** (new business/car/
house/etc.) that can adjust the Net Worth figure — but only after a transparent 4-rule relevance
checklist and explicit user confirmation, per Kya's specific ask for a rules-and-confirmation
mechanic rather than a silent auto-apply. `FinanceStore` gained real (illustrative) balance
components (`cashTotal`, `investmentsTotal`, `manualAssetsTotal`, `liabilitiesTotal`) and a
computed `netWorth`.

### 4.2 Smart Transaction Sorting
New "Transactions" More-hub card. Kog proactively asks about uncategorized transactions, learns a
merchant → category pairing from each answer, and auto-sorts future matches without asking again —
but always through a dismissible banner with a **"Return to normal"** undo, never silently. Sorting
something into Subscriptions offers (never forces) registering it in Subscription Centre too,
guarded against duplicates by merchant name. Introduced a "Simulate New Transaction" button since
there's no real transaction feed to demonstrate the loop against yet.

---

## 5. 2026-08-16 — Can I Afford This?, a menu polish, an analytics pipeline, Credit Score, and a real bug fix

### 5.1 "Can I Afford This?"
The session's biggest compliance conversation. Kya's original ask ("determine if this is a
worthwhile purchase") read closer to advice than anything built so far. Resolved via clarifying
questions into: a More-hub feature returning a human-style **"X/10" affordability comfort score**
(Kya's own framing — not silent, not a blunt yes/no either) computed from four transparent,
visible factors (disposable income fit, cash buffer impact, goal impact, proportionality vs.
typical spending) — the score answers one narrow question, "how comfortably does this fit your
money and goals," never "should you buy this" or "is this a good investment," even for
investment-framed purchases, which run the identical pipeline per Kya's explicit call. Required a
real prerequisite fix: **Goals were promoted from `GoalsView`'s local `@State` into a new shared
`GoalsStore`**, since nothing outside `GoalsView` could previously read goal data at all.

### 5.2 Hamburger menu swipe indicator
Small, standalone: a subtle `chevron.compact.down` under the "Menu" title, purely decorative (no
button, per Kya's explicit "no exit button"), reinforcing the swipe-to-close gesture.

### 5.3 Lightweight analytics/feedback pipeline
Kya asked for a backend to store data and "customised md files" for Kog's AI — the second
correction of that exact markdown-memory misconception this session (see `CLAUDE.md`'s "Kog memory
tiering" note; the real design is Postgres, not per-user markdown files). Once clarified, the real
ask was an admin-visible way to see usage/feature-adoption/feedback across every install. Built as
a **lightweight interim pipeline** rather than the full backend: `AnalyticsService.swift` posts
anonymous events (app opens, feature taps, feedback submissions — never financial data) to a real
Supabase project Kya created and configured himself (free tier, anonymous-insert-only RLS
policies). Supabase's own Table Editor/SQL Editor/Reports serve as the "admin dashboard" for now —
no custom website built, since Supabase already provides one for free. Subscriber counts were
explicitly flagged as **not deliverable yet** — there's no subscription/paywall feature in the app
at all.

### 5.4 Credit Score (TransUnion design shell)
New Dashboard card, explicitly **design/UI only, not connected** per Kya's instruction — an
illustrative score (0–710 scale), band, 6 months of history, and a hedged trend-based projected
range ("illustrative estimate, not a guarantee"). Named TransUnion directly and labeled "Not
Connected," following the same honest placeholder convention `AccountsDetailView` already uses for
Trading212. Kept visually and textually distinct from Kognize's own internal health Score so the
two concepts don't get conflated.

### 5.5 Bug fix: More-hub cards stopped opening
The one real bug of the whole session, and the first thing caught by an actual build. Root cause:
`.simultaneousGesture(TapGesture())` had been attached directly to each More-hub card's
`NavigationLink` (added for feature-tap analytics tracking) — a known SwiftUI gotcha where a tap
gesture on a `NavigationLink` inside a `List` can interfere with the List's own tap handling on a
real device, even though `simultaneousGesture` is meant to be non-blocking. Fixed by moving the
tracking call to `.onAppear` on the destination view instead, which can't interfere with
navigation at all. Confirmed working by Kya after rebuilding.

---

## 6. Known limitations / not done yet

- **`CLAUDE.md`'s Architecture/Navigation sections are now stale.** They don't yet document
  Subscription Centre, Transactions, Can I Afford This?, Net Worth, Credit Score, or the analytics
  pipeline — all six shipped without a corresponding documentation pass. Worth doing before the gap
  grows further.
- **Nothing persists across relaunch except theme** — still true for every feature built across all
  four sessions. The single biggest standing gap, flagged repeatedly and still not started.
- **No backend exists.** The analytics pipeline is a real, working, but deliberately lightweight
  substitute — not Build order step 2. Aggregator integration, Kog scoring, and the real Ask Kog
  endpoint all still depend on that not-yet-started work.
- **Subscriber counts still aren't trackable** — needs a real subscription/paywall feature
  (explicitly last in build priority) plus RevenueCat/App Store Connect.
- **Credit Score has zero real connection** — by design, per tonight's explicit instruction.
- **The analytics pipeline has no data in it yet** — Supabase's tables were empty as of this
  report; they'll populate as the app gets used for real going forward.
- **Passcode is still hardcoded** (`1234`), not hashed, not in Keychain.
- Most of tonight's six new screens (Net Worth, Transactions, Can I Afford, Credit Score,
  Subscription Centre) have only been build-verified via the navigation fix, not individually
  visually QA'd — worth a proper pass now that a real build finally exists.

---

## 7. Repo state at end of session

- HEAD: `12d2b98`, up to date with `origin/main`, working tree clean.
- 47 Swift files (was 34 at the last report).
- 21 commits landed since `2026-07-09-session-report.md` was written.

---

## 8. Suggested next steps (not decided, for discussion next session)

1. Update `CLAUDE.md`'s Architecture/Navigation sections to document the six features that
   shipped without a doc pass.
2. Visual QA across the newer screens now that a real build exists and the navigation bug is
   fixed — Net Worth, Transactions, Can I Afford, Credit Score, Subscription Centre.
3. Persistence — still the standing top priority; touches nearly everything built so far.
4. Backend scaffold (Build order step 2) — the analytics pipeline proves the Postgres-via-Supabase
   direction works, but it isn't the real thing.
5. Build the Supabase Reports/charts (offered, not yet built) once there's real usage data worth
   visualizing.
