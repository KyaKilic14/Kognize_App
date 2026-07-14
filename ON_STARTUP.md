# On Startup

Run this quick health check at the very start of every new session, before starting any requested
work. Keep it fast and quiet unless something's actually wrong — a one-line "all good" summary is
enough; only go into detail if a check below actually turns something up.

## Checklist

1. **Location.** Confirm the working directory is the current project location. This has moved
   before (started in iCloud Drive, moved to `~/PROJECTS/Kognize` on 2026-07-09 specifically to
   escape an Xcode + iCloud Drive sync conflict that was causing slow saves/quits) — if the stated
   working directory doesn't look like a real project checkout, say so rather than assuming.
2. **Git health.**
   - `git status` — should be clean, or show only expected in-progress work.
   - `git log --oneline -8` — history looks continuous, no surprises.
   - `git remote -v` — still points at `github.com/KyaKilic14/Kognize_App.git`.
   - `git fetch origin`, then check `git status` again / `git rev-list --left-right --count
     main...origin/main` — confirms read/network access works, and catches **divergence**, not
     just "ahead." Kya's Xcode "Integrate" does amend-style commits, which has caused local and
     `origin/main` to diverge (same logical commit, different hash) more than once. If diverged,
     check with `git diff main origin/main --stat` whether it's a real conflict or just one side
     being a superset of the other (usually the latter) before merging — see CLAUDE.md's PM
     section for the push/Integrate workflow this relates to.
   - `git fsck` may show "dangling blob" entries — that's a normal byproduct of the amend-heavy
     Integrate workflow, not corruption. Don't flag it as a problem.
3. **Push reality check.** Don't assume push will fail without checking, but don't be alarmed if it
   does: this session type has no reachable GitHub credentials (confirmed repeatedly across
   sessions). `could not read Username for 'https://github.com'` is the known, expected error —
   note it and move on rather than re-diagnosing it. Kya pushes from his end via Xcode's Source
   Control → Integrate.
4. **File visibility.** Confirm the expected project structure is present: `Kognize.xcodeproj`,
   `Kognize/` (source), `KognizeTests/`, `KognizeUITests/`, `CLAUDE.md`, `docs/session-reports/`.
5. **Read for context**, in this order: `CLAUDE.md` (current-state — team setup, architecture,
   build order, design rules) and the most recent file in `docs/session-reports/` (history — what
   changed last session, known limitations, what was suggested next). CLAUDE.md is the source of
   truth for how the team operates; the reports are the changelog.

## Reporting back

If everything checks out: one short line, e.g. "Repo's healthy, N commits ahead of origin, read
the latest session report — ready when you are." Don't narrate every command that passed. Only
expand into detail (and flag it clearly) when a check actually surfaces something wrong.
