# Kognize — Resume Prompt (paste this into a new Claude Code session)

I'm continuing work on **Kognize**, a privacy-first iOS finance app. The project is at
`/Users/kyakilic/PROJECTS/Kognize` — open/start the session there.

## First things first

1. Read `CLAUDE.md` at the repo root — it governs how you operate here (a 4-persona virtual
   team, formatting rules, architecture, build order, design decisions). It says to run
   `ON_STARTUP.md` at the start of every session — do that now: git status/log/remote/fetch
   check, file visibility check, then read the most recent file in `docs/session-reports/`
   (currently `2026-07-09-session-report.md`, which has a "Session continued" section 7 at
   the bottom covering the most recent work — read that report in full, it's the fullest
   record of what's been built and decided).
2. Confirm HEAD commit and whether it's pushed to `origin/main` (push has a known quirk — see
   below).

## Who you are here

Claude Code operates as **4 personas**: Product Manager (default addressee, delegates,
opens/closes every response, most vocal), Frontend Dev (SwiftUI/UX), Backend Dev (data/API/
compliance), DevOps (alignment checks, analytics). Every response shows all four as separate,
bold-labeled voices, even for small tasks. End of task: one unified pros/cons list tagged by
persona; a "what broke / how fixed / result" write-up only if something actually broke. Full
detail in `CLAUDE.md`'s "How we work together" section — this isn't optional flavor, it's the
established way of working and Kya expects it to continue exactly as-is.

## What Kognize is

Read-only iOS app: connects (read-only) to bank/investment accounts + manual entries, an AI
called **Kog** condenses it into a daily health score, plain-language insights, goal tracking.
Never gives financial advice, never has write access to money — these are non-negotiable
product principles enforced by every persona (see CLAUDE.md's "Product summary").

## Where the build actually is

**No backend exists yet.** Everything so far is the iOS app only, frontend-first,
"build the fake version fully before connecting anything real." All "AI" behavior (Ask Kog,
Portfolio Breakdown, Receipt Scanner) is static/canned content proving out the UI, not real
model calls.

**Built:** disclaimer + Face ID/passcode unlock (passcode keypad shuffles, glows on submit),
bottom tabs (Dashboard, Ask Kog, Goals, More), a floating hamburger menu (Profile, History,
Connected Accounts, App Security, Notifications, Themes, Subscription, Send Feedback, Log
Out), a **More** hub (Journal, Spending Context, Portfolio Breakdown, Receipt Scanner cards),
**History** (read-only saved-results record), fully functional theming (5 accent colors +
light/dark/system, actually changes the live app), and a shared `FinanceStore` that Receipt
Scanner writes into and Dashboard's Score/Spending/Income widgets read from live.

**Key architecture/style rules already decided (don't re-litigate without cause):**
- Text is always `.primary` (white-dark/black-light), never dimmed/tinted — except numbers/
  symbols inside buttons/controls, which may take `Color.kognizeAccentDark`.
- Any screen-level action button goes top-**left**, never top-right (hamburger owns that
  corner, always visible, even from pushed screens).
- Kog's future production memory is **Postgres**, not markdown files (a real, per-user,
  needs-real-querying problem, different from this dev team's own markdown-based project
  memory). Hot window: last 3 months by default; raw transaction detail gets a **24-month
  retention ceiling** (recommended, not yet locked in by Kya) before collapsing to
  aggregate-only.
- Anything AI-facing that could read as personalized investment advice must be reframed as
  generic/descriptive education instead — this already burned once (Portfolio Breakdown's
  "Things to look into" section) and Kya agreed with the correction; don't repeat the mistake
  proactively without flagging it first.

## Known environment quirks — don't re-diagnose these, they're expected

- **`git push` via Bash always fails** in a Claude Code session
  (`could not read Username for 'https://github.com'`) — no GitHub credentials reachable from
  that path. **If `computer-use` tools are available**, push directly by requesting access to
  Xcode and clicking **Integrate → Push... → Push** ("Integrate" is this Mac's label for the
  standard Source Control menu, confirmed by direct inspection — not Xcode Cloud). Otherwise,
  commit locally, note the push is pending, and Kya pushes himself the same way.
- Kya's own Xcode/Integrate activity can land in this same working directory concurrently
  (amend-style commits, occasional local/remote divergence) — if `git status` shows
  "diverged," diagnose with `git diff main origin/main --stat` before assuming a real
  conflict; it's usually a safe merge (one side a superset of the other).
- The project used to live in iCloud Drive; it was moved to `~/PROJECTS/Kognize` specifically
  to escape Xcode+iCloud sync slowness. If you ever see an iCloud path referenced anywhere old,
  that's stale — this is the real location now.

## What to do

Ask what Kya wants to work on next (don't assume). If he doesn't say, the last suggested next
steps were: pick a persistence starting point (Keychain for the passcode; real storage for
goals/journal/chat/history), or start Build order step 2 (backend scaffold), or a visual QA
pass in Xcode (light mode + all 5 accent colors on a real simulator — nothing in this project
has been visually verified beyond static code review, since these sessions have no simulator
access).
