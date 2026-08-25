---
name: session-save
description: Persist the session's outcome into the committed planning files — updates .planning/TODO.md, overwrites .planning/STATE.md, and checks whether the change made docs/ out of date. Use at a natural stopping point, before the user exits, or when they say "save session", "Session speichern", or "wir machen Schluss".
---

# Session Save

Writes this session's outcome to disk so the next session can start cold. All three
steps run — step 3 is the one that gets skipped under time pressure and is the one
that causes doc rot.

## 1. Update `.planning/TODO.md`

- Tick off what was completed. Delete finished items rather than keeping a done-list —
  TODO.md is a backlog, not a log. Completed work is described in STATE.md.
- Add items discovered during the session, including technical debt taken on knowingly.
- Keep open items at the top. If the file is drifting past ~150 lines, say so and
  propose moving closed sections to `.planning/archive/`.

## 2. Overwrite `.planning/STATE.md`

Overwrite — do not append. Keep the existing section structure:

- `## Last updated:` absolute date + a short session label
- `## Headline` — what changed this session, in two or three sentences
- `## What exists` — the current factual state of the repo
- `## Next steps` — the concrete next action, specific enough to act on cold

Write absolute dates, never "yesterday" or "last week".

## 3. Documentation drift check

Ask whether this session's changes made the approved design in `docs/` untrue —
that is the "Architecture first" rule's baseline, so silent drift breaks the rule.

```bash
git diff --name-only HEAD~1 2>/dev/null | head -30
ls docs/
```

If the code no longer matches `docs/architecture.md` (or another design doc):

- **Add a TODO item** naming the file and exactly what drifted.
- **Do not rewrite the design doc as part of saving.** Changing an approved baseline
  is its own decision and needs the user in the loop.

## Report back

One line per step: what was ticked off, what STATE now says, and whether drift was
found. If nothing drifted, say "keine Drift" — the absence is worth stating.
