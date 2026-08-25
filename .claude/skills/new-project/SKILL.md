---
name: new-project
description: Bootstrap a new repository from this sample repo's setup — copies the .planning/ scaffold, the CLAUDE.md skeleton and the .claude/skills/ set into a target project, then fills them in from an interview. Use when starting a new project, when the user says "neues Projekt", "aufsetzen wie hier", or asks to apply this template elsewhere.
---

# New Project From Template

This repo is the reference setup. This skill transplants it into a new project so the
next one starts with working memory, working rituals, and no copy-paste rot.

## The failure this exists to prevent

Copying planning files between projects and forgetting to reset them. It has happened
three times in this setup: `STATE.md` arrived carrying another project's content, the
global `autoMode.environment` block described the wrong repo for months, and this
template itself carried a frozen snapshot of a live project's spec.
**Every copied file gets emptied and refilled, never edited in place.**

## 1. Interview first — before copying anything

Run the interview with the **`AskUserQuestion` tool, one question per call**, in the
order below. Never dump the catalogue as a text list and never bundle several
questions into one call — the user answers a single question at a time, and every
free-text answer arrives through the tool's built-in "Other" field. Each question
gets 2–4 concrete options; where the real answer is free text (name, purpose,
slug), the options are proposals derived from earlier answers, so "Other" is the
escape hatch, not the default path.

Order — later questions build on earlier ones:

1. **Display name and one-line purpose** — what `PROJECT.md` and `CLAUDE.md` call the
   project ("GLM Workbench"); may differ from the slug. Options: 2–3 phrasings if
   the user has already hinted at the purpose, otherwise a short placeholder set
   that makes "Other" the obvious choice.
2. **Repo name** — the slug that becomes both the directory (`~/repos/<name>`) and
   the GitHub repo (`<org-or-user>/<name>`): lower-case, hyphens, no spaces. Offer
   2–3 slugs derived from the display name (`glm-workbench`, `glmworkbench`) and
   let the user confirm one — renaming a repo later touches remotes, clones and the
   auto-mode block.
3. **Stack** — language, framework, storage. Options: Python + uv (the template's
   default), R, TypeScript/Node, Go; framework and storage follow up in a second
   call if the first answer leaves them open.
4. **Deployment** — local only, or a cloud target (which one).
5. **GitHub org/user** — propose the account `gh api user -q .login` reports.
6. **Visibility** — **public or private**. This decides what may ever be committed;
   ask it explicitly as its own question, do not assume private.
7. **User-visible surface** — does the project have a UI (screens, forms, charts,
   a dashboard), or none (a library, a CLI with machine-readable output)? This
   decides whether `docs/ui_screens.md` is a skeleton to fill or a one-line note,
   and whether `change-validation` stays.
8. **Which of this repo's rules carry over** — TDD-mandatory, architecture-first,
   the E2E validation workflow. Multi-select, plus a "none" option.

Close with one summary call: all answers in a single block, with the options
"Confirm" and "Change something". Only a confirmed summary unlocks step 2.

Do not copy anything until these are answered. A template filled in from guesses is
the rot this skill is meant to prevent.

## 2. Copy the structure

**Run this skill from the template repo** (`AA_Sample_Claude_Repo`), not from the new
project — the copy sources are relative to it. The new project does not need to exist
yet; `TARGET` is created.

```bash
TARGET="$HOME/repos/<name>"          # the slug from the interview
mkdir -p "$TARGET"/{.planning/e2e-tests,docs,.claude/skills,.claude/hooks}
touch "$TARGET/.planning/e2e-tests/.gitkeep"   # git drops empty dirs; change-validation expects this one
cp -r .claude/skills/* "$TARGET/.claude/skills/"
cp .claude/hooks/*.sh "$TARGET/.claude/hooks/"
cp .claude/settings.json "$TARGET/.claude/"
cp .gitignore .gitattributes "$TARGET/"
cp docs/architecture.skeleton.md "$TARGET/docs/architecture.md"

# docs/ui_screens.md exists in every project, so its absence is never ambiguous:
cp docs/ui_screens.skeleton.md "$TARGET/docs/ui_screens.md"                    # UI project
printf '# <Projekt> — UI Screens\n\nKein UI. Das Projekt hat keine Oberfläche; `change-validation` ist entfernt.\n' \
  > "$TARGET/docs/ui_screens.md"                                                # no UI
```

Only **one** of the two `ui_screens.md` lines runs — the interview decides which.
Replace `<Projekt>` in the no-UI note with the project name.

Then adapt them — copying is not the job, de-projecting them is.

| Skill | Action |
| --- | --- |
| `session-start`, `session-save`, `new-project` | carry over unchanged — they only touch `.planning/` |
| `change-validation` | **delete it** if the project has no user-visible surface (a library, a pure CLI with machine-readable output) |
| `tdd-cycle` | rewrite the stack-specific parts: test runner command, fixture names, and any framework named in it |
| `pre-commit-check` | rewrite the gate commands for the new language/toolchain, and the list of files that must never land |
| `.gitignore` | keep the generic base (secrets, OS/editor noise, planning archive); **replace the stack section** — it ships for Python + uv, a Go/R/TypeScript project needs its own (`renv/library/`, `node_modules/`, `.Renviron`, `target/`) |
| `.claude/settings.json` | the `permissions.allow` list ships for Python + uv (`uv run pytest/ruff/mypy`) — rewrite it for the new stack's test/lint/format commands, so the gate runs without a prompt; the `git status/diff/log` entries stay |

`tdd-cycle` and `pre-commit-check` are the two that carry the source project's stack
in their prose, not just in a path. Read them end to end and rewrite; do not
search-and-replace.

If the new stack's toolchain is installed, run each gate command once against the
empty scaffold so a typo fails now, not in the first real session. If it is not
installed, say so and add a TODO item "Skill-Kommandos gegen die Toolchain
verifizieren" — commands written blind are a guess, and the next session must know
that.

Do **not** copy `CLAUDE.md`, `.planning/*` or `docs/*` — those are written fresh in
step 3 and 4. Copying them is exactly the rot this skill exists to prevent.

## 3. Create the planning files empty

Write them fresh from the interview — never copy the source project's content.

- **`.planning/PROJECT.md`** — definition, scope, non-goals, key decisions
- **`.planning/TODO.md`** — the real first work items, starting with the scaffold
- **`.planning/STATE.md`** — headline "neues Repo, noch kein Code", the absolute
  date, and the first concrete next step

Then check the result for leftovers — in **two** layers, because they rot differently:

```bash
# Layer 1: template placeholders that were never filled in.
# docs/ is deliberately NOT in this list — its <Komponente> placeholders are the
# architecture-first signal and are handled in 3b, not grepped away.
grep -rniE '<Projekt>|<Komponente>|AA_Sample_Claude_Repo|Template-Repo'   "$TARGET/.planning" "$TARGET/CLAUDE.md"   --include='*.md' 2>/dev/null

# Layer 2: the TEMPLATE's default stack, still sitting in the copied skills.
# The skills ship pre-loaded for Python + uv. If the new project is not that,
# every one of these hits is a wrong instruction. The pattern is wider than the
# four tool names on purpose: fixture names and paths rot just as quietly.
grep -rniE 'uv run|pytest|ruff|mypy|tmp_path|--cov|playwright|src/'   "$TARGET/.claude/skills" "$TARGET/.gitignore" 2>/dev/null   | grep -v '/new-project/'
```

A hit that names the template's tool only to say it does *not* apply ("R has no
`mypy` equivalent") is fine. A hit that mentions the origin on purpose (a probe run
documenting what it probes) is fine. Everything else is rot.

Layer 2 is not optional. A Go or TypeScript project that inherits `uv run pytest` has
working files and rotten instructions — the worst combination, because nothing fails
loudly. If the new project *is* Python + uv, the hits are correct and you skip them;
that is a judgement, not a pass. Exclude `new-project/` itself: it names these
patterns on purpose and will always match.

Every hit that is not genuinely about the new project gets fixed now, not noted.

## 3b. State the architecture-first status honestly

The template repo starts with an approved design already in `docs/`. A new project
almost never does — so the "Architecture first" rule is **not** satisfied, and that
difference must be written down, not inherited silently.

- `docs/architecture.md` is the copied **skeleton**: fill in the project name and the
  repository layout for the new stack, leave the component sections as `<Komponente>`
  placeholders. Say in `STATE.md` under its own heading that architecture-first is
  **not** satisfied, and make writing the design the first TODO item — before any
  implementation.
- `docs/ui_screens.md` follows the interview: for a UI project it is the copied
  skeleton with the project name filled in and `<Screen>` placeholders left standing —
  the screens are designed together with the architecture, and `change-validation`
  derives its scenarios from them. For a project without UI it is the one-line note,
  and `change-validation` is deleted (see the table in step 2).
- Do not copy anything from `docs/examples/` — those are filled-in design docs of a
  different application, kept only to show what a finished skeleton looks like.

## 4. Write the new CLAUDE.md

Keep it under ~120 lines. It is loaded into context on every single turn, so
anything that only matters sometimes belongs in a skill instead — that is the whole
reason the rituals in this repo live in `.claude/skills/`.

Sections worth keeping: Project Overview, Tech Stack, Commands, Architecture pointer,
Rules, Git conventions, Documentation Paths, Session Continuity.

## 5. Project settings, not user settings

Put project-scoped permissions in `$TARGET/.claude/settings.json`.

**Do not put an `autoMode` block there** — auto mode is read only from the *user*
settings file (`~/.claude/settings.json`), so a project-level one is silently
ignored. The global block is structured as an Org-wide part plus one
`### Per-repo: <name>` section per active repo. Draft the new project's section
(what it is, remote and visibility, cloud/CLIs, sensitive data locations, routine
operations) as a complete copy of `~/.claude/settings.json` in the scratchpad and
hand the user the `cp` command; an agent editing its own auto-mode config is blocked
by design, and correctly so.

### Optional: auto-format on every edit

`.claude/hooks/post-tool-format.sh` is copied but **not wired**. It formats the file
Edit/Write just touched, if it recognises the extension and the formatter is
installed (`ruff` via uv, `styler`, `prettier` from `node_modules`, `gofmt`,
`rustfmt`); otherwise it does nothing and always exits 0. Enable it only when the
stack has one of those formatters — a hook that silently does nothing is worse than
no hook. Add to `$TARGET/.claude/settings.json` next to `SessionStart`:

```json
"PostToolUse": [
  {
    "matcher": "Edit|Write",
    "hooks": [
      { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-format.sh\"" }
    ]
  }
]
```

If the stack's formatter is not in the script's `case`, add a branch — do not enable
the hook and hope.

## 6. Create the GitHub repo and hand over

**You run this — do not hand the user a list of commands.** Only once the files are
filled in: an empty repo on GitHub invites a `git pull` that overwrites local work.

Precondition, checked before anything else:

```bash
gh auth status
```

If `gh` is not logged in, stop here and tell the user to run `! gh auth login` in this
session (interactive, opens a browser); then continue. Do not fall back to a manual
recipe — the whole point of this step is that the user does not have to.

```bash
cd "$TARGET"
git init -b main && git add -A && git commit -m "chore: initial project scaffold from template"
gh repo create <org-or-user>/<name> --private --source=. --remote=origin --push
```

`<org-or-user>` and `<name>` come from the interview, `--private`/`--public` from
its visibility answer — confirm that flag once more right before running, because it
decides what may ever be committed there. Default to `--private` if the user does not
say. If the user explicitly wants no remote (a throwaway run), skip `gh repo create`,
keep the local commit, and say so in the report.

Afterwards verify what actually landed — `git status -sb` shows `main...origin/main`,
`gh repo view --json visibility` shows the visibility the user chose.

For a throwaway run: `gh repo delete` needs the `delete_repo` scope, which the default
`gh auth login` does not grant. The user has to run
`gh auth refresh -h github.com -s delete_repo` (interactive, opens a browser) before
the repo can be removed from the CLI — say so up front instead of failing at the end.

Report what was created (with the repo URL), what still needs the user's input (the
`cp` for the auto-mode block, unverified toolchain commands), and the one command to
run next:

```
cd "$TARGET" && claude
```

Then stop — scaffolding the new project's code is its own session, started in the new
directory where the `SessionStart` hook and `session-start` skill take over.
