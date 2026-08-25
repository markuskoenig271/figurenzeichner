---
name: session-start
description: Load the project's rolling state at the beginning of a work session — reads .planning/STATE.md, .planning/TODO.md and (if needed) .planning/PROJECT.md, then reports where the work stands and what the next step is. Use when starting a session, resuming after /clear, or when the user asks "where did we leave off", "was ist offen", or "status".
---

# Session Start

Restores working context from the committed planning files. These files are the
project's memory — the conversation is not.

## Steps

1. Read `.planning/STATE.md` — the rolling "where I left off" snapshot.
   If it does not exist, say so and offer to create it from the current repo state.
2. Read `.planning/TODO.md` — the canonical list of open work items and technical debt.
3. Read `.planning/PROJECT.md` **only if** STATE + TODO leave the scope or the goal
   unclear. It is the spec, not a status file — skimming it every time wastes context.
4. Check for drift between what STATE claims and what the repo actually contains
   (e.g. STATE says "no code yet" but a source directory exists). Cheap check, catches stale state:

   ```bash
   git -C . log --oneline -5 2>/dev/null; git -C . status --porcelain 2>/dev/null | head
   ```

## Report back

Four short sections, no preamble:

- **Stand** — one or two sentences from STATE's headline.
- **Offen** — the open TODO items, highest-value first. Do not paste the whole file.
- **Nächster Schritt** — the single concrete next action.
- **Drift** — only if STATE and the repo disagree. Say what disagrees; do not fix it silently.

Then stop and wait. Do not begin implementation work off the back of this skill —
loading context is the whole job.
