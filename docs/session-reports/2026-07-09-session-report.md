# Kognize — Session Report

**Date:** 2026-07-09
**Team:** Product Manager, Frontend Dev, Backend Dev, DevOps
**HEAD at end of session:** `86c9e9f` (6 commits ahead of `origin/main`, pending push via Xcode Integrate)

---

## 1. Summary

This was the first full working session on Kognize. It covered two tracks: setting up how the team
(Claude Code, operating as four personas) works with Kya, and building out the app itself — from an
empty Xcode template to a navigable app with a real lock screen, a dashboard, goals, a chat stub, and
a working theme system. Nothing talks to a backend yet; everything is frontend-only with static or
in-memory data, by design, matching the build order's "build the fake-data version fully before
connecting anything real."

---

## 2. Team & process set up today

- **CLAUDE.md merged into `main`.** It existed only on an unmerged branch at the start of the
  session — now it's active context for every session going forward.
- **Four-persona team formalized:** Product Manager (new today), Frontend Dev, Backend Dev, DevOps.
  PM is the default addressee, breaks down and delegates work, and is the most vocal voice back to
  Kya. All four speak as separate, clearly labeled voices in every response.
- **Reporting format locked in:** unified pros/cons list per task, tagged by which persona raised
  each point; a short "what broke / how it was fixed / result" write-up only when something actually
  broke.
- **PM owns committing (and attempting to push) after every significant step.** Push from this
  session always fails — no GitHub credentials are reachable here, confirmed repeatedly, not a bug to
  keep re-diagnosing. Kya pushes from his end via **Xcode's Source Control → Integrate**, confirmed
  working from actual outcomes mid-session (some work landed on `origin/main` without an explicit
  push request, meaning Integrate was used at least once today).
- **PM owns cost/spend monitoring** once the project has a real backend and real infrastructure
  costs — explicitly dormant today, since everything is still free-tier/local.
- Looked into AI-usage-percentage monitoring (Kya's request) — not technically possible from this
  session (no tool exposes that data). Agreed instead: Kya shares his usage number when he checks it,
  PM cross-references it against 50/70/90% milestones and flags a checkpoint if something big is
  about to start.

---

## 3. What got built

### 3.1 Core app shell (Build Order Step 1)
- Removed the default Xcode/SwiftData template.
- **Disclaimer splash** — educational-only / read-only copy, single acknowledgment, no skip.
- **Unified unlock screen** — passcode keypad is the primary, always-visible method; Face ID attempts
  automatically in the background on appear (no button press), shown as a small status icon near the
  top. Biometrics-only policy, so a Face ID failure never triggers iOS's own system passcode sheet on
  top of the custom keypad.
- **Passcode keypad** — 4-digit, numeric buttons shuffle position on every appearance and after every
  wrong attempt; Delete is fixed bottom-left, Enter fixed bottom-right (both as SF Symbol icons, not
  text), rest of the grid is shuffled. Green/red glow on the 4 progress dots and the true screen edge
  (rounded to match device corners) on submit. Infinite attempts, no lockout, per Kya's call for now.
  Hardcoded to `1234` — no persistence yet; real storage should be a salted hash in the Keychain, not
  the raw digits, whenever that gets built.
- **Privacy overlay** — full-screen black cover whenever the app isn't in the foreground, so the
  app-switcher snapshot never shows real content. Backgrounding the app also resets the flow back to
  the disclaimer screen (re-lock on every "close," not just cold launch).

### 3.2 Main navigation
- **Bottom tab bar:** Dashboard, Ask Kog, Goals, Journal.
- **Floating hamburger menu** (top-right, fixed across every tab and every pushed screen): Profile,
  Connected Accounts, App Security, Notifications, Themes, Subscription, Send Feedback — plus a red
  pill "Log Out" button, same action as Profile's "Sign Out" (both drop back to the disclaimer/lock
  screen).
- Established rule: any screen-level action button (e.g. a "+") goes top-**left**, never top-right,
  since the hamburger always owns that corner.

### 3.3 Dashboard
- Reorderable, removable widget list (native SwiftUI List edit mode — drag handles + delete circles,
  triggered by a custom "Edit Dashboard" button rather than the system `EditButton`).
- Widgets: Score (circular ring), Kog's 3-line summary, Spending, Income, Score History (+N deltas
  for 1W/1M/3M/6M), Investments (with a quick-add sheet), Accounts (drills into `AccountsDetailView`).
- Time-based greeting header ("Good afternoon, Kya") with today's date.
- Every widget taps into a shared `WidgetDetailView` template (headline stat, static timeframe
  picker, "Kog's take" blurb) instead of a bespoke screen per metric.
- All values are static placeholders — real data arrives with the backend/aggregator/Kog scoring
  endpoint (build order steps 3–5).

### 3.4 Goals
- 3-step MCQ creation flow: pick a type (**Savings**, **Debt Reduction**, or **Emergency Fund** — a
  first-class goal type so the health score can read it like any other goal), then minimal required
  fields (name + amount), then an optional "Advanced" step with type-specific fields, all optional.
- Goal list shows a progress bar per goal; tapping in shows a detail view with a Kog's-take blurb.

### 3.5 Ask Kog
- Real chat bubbles (user right/purple, Kog left/adaptive), a staggered bouncing-dots typing
  indicator, auto-scroll to the latest message. No AI connected yet — always replies with a static
  "Hello world" line after ~1.2s, proving out the UI ahead of the real endpoint.

### 3.6 Journal (merged with Spending Context)
- Segmented screen: **Entries** (free-text, timestamped, in-memory) and **Spending Context** — a
  multiple-choice "what's stressing your spending" prompt (categories grounded in real 2025 survey
  data: unexpected expenses, inflation/rising prices, income/job change, debt repayment, etc.) plus a
  free-text "Other." This is the master plan's "Context input" feature, made concrete — it's meant to
  feed Kog's chat context once that layer exists.

### 3.7 Menu screens
- **Profile** — name/email fields, "Change Passcode" entry point (placeholder), Sign Out.
- **Notifications** — Daily Digest toggle with a real time picker (defaults to 8pm), Score/Goal/
  Spending alert toggles, moved out of Profile into its own screen.
- **Themes** — genuinely functional (see below), not just a settings preview.
- **Send Feedback** — real screen: category picker (Bug / Feature Request / General), free-text
  field, submit with local confirmation. Frontend-only — there's no admin feedback board to send to
  yet, and the screen says so plainly rather than pretending.
- Connected Accounts, App Security, Subscription remain `ComingSoonView` placeholders (no dead ends).

### 3.8 Theming — built twice, second time for real
- First pass: settings UI only (accent swatches + System/Light/Dark picker), nothing functional, by
  design at the time.
- Second pass, later in the session, at Kya's request: **fully functional.** `ThemeManager`
  (`@Observable` singleton) holds the accent choice and appearance mode, persisted via
  `UserDefaults`. `Color.kognizePurple` became a computed property reading live from the manager, so
  every existing call site updates instantly on change. `Color.kognizeBackground` became a real
  adaptive color (near-black in dark, soft off-white in light) instead of a hardcoded constant.
  `AppRootView` drives `.preferredColorScheme` reactively.
- Fixed a real bug along the way: sheets (Menu, Add Goal, Journal compose, Add Investment) don't
  reliably pick up a live `.preferredColorScheme` change from an ancestor — each sheet root now
  declares the modifier itself.
- Added `Color.darkened(by:)` and `Color.kognizeAccentDark` (a solid, ~18% darker version of
  whatever accent is selected) — used for the hamburger icon's lines and the passcode keypad's digit
  and delete-button glyphs, so numbers/symbols inside controls read as a solid theme color against
  their own translucent-accent background, for any of the 5 accent presets.
- **Text color rule established and swept app-wide:** actual text (headings, body, captions, section
  headers) is always `.primary` — full white in dark mode, black in light, never dimmed, never
  accent-tinted. `.secondary` is reserved for icon-only glyphs that aren't text. Converted ~18 files,
  including fixing List section headers (the plain `Section("Title")` form silently defaults to
  dimmed system gray — had to switch to the explicit `header:` closure form to control it). Caught
  and fixed a bug this surfaced: `PrivacyOverlay`'s lock icon would have gone invisible (black-on-
  black) in light mode if swept into the same conversion, since its background is intentionally fixed
  black, never adaptive.

### 3.9 Xcode / tooling fix
- Fixed a corrupted `AppIcon.appiconset/Contents.json` (dangling dark/tinted appearance slots with no
  image assigned) that was making Xcode's asset catalog editor report as empty/broken. Reduced back
  to the one valid slot.

---

## 4. Known limitations / not done yet

- **No backend exists.** Build order steps 2–5 (backend scaffold, aggregator sandbox, manual entry
  endpoints, Kog scoring endpoint) haven't started.
- **Nothing persists across relaunch** except the theme choice (`UserDefaults`). Goals, journal
  entries, chat history, spending context answers, and dashboard widget order/visibility all reset
  every launch. This is the single biggest thing worth prioritizing next.
- **Ask Kog has no real intelligence** — static reply only.
- **Passcode is hardcoded** (`1234`), not hashed, not stored in Keychain.
- **Light mode hasn't been visually verified** — this session has no simulator access. Worth a real
  look in Xcode, especially accent-color contrast against a light background.
- **App icon has an alpha channel** — fine for now, but will need flattening before real App Store
  submission (Apple typically rejects primary icons with transparency).
- **Account creation / sign-in** (so data can sync and persist across devices) is flagged by Kya for
  a later phase — not scheduled into the numbered build order yet.
- **Push always fails from this session** (no reachable GitHub credentials) — confirmed, expected,
  documented in CLAUDE.md. Kya pushes via Xcode's Integrate.

---

## 5. Repo state at end of session

- 6 commits sitting on local `main`, ahead of `origin/main`, pending your next Integrate.
- Working tree clean — nothing uncommitted.
- One thing to double check next time you're in Xcode: mid-session there was evidence of your own
  Xcode/Integrate activity landing in this same synced working directory (an app-icon change you were
  making). Worth a glance to confirm it looks how you left it — nothing on our end touched it
  directly, but it's worth verifying since two things were writing to the same folder concurrently.

---

## 6. Suggested next steps (not decided, for discussion tomorrow)

1. Persistence — pick a starting point (Keychain for the passcode specifically; local storage or a
   real backend for goals/journal/chat).
2. Or: start Build Order Step 2 (backend scaffold) so the aggregator/Kog work can begin in parallel
   with more frontend polish.
3. Visual QA pass in Xcode — light mode, all 5 accent colors, on a real simulator.
