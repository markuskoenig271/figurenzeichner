---
name: change-validation
description: Derive and execute end-to-end acceptance scenarios for a change, via a BA pass (user-facing scenarios) and a Test pass (concrete E2E cases stored in .planning/e2e-tests/). Use when a change affects user-visible behaviour — a screen, a flow, a produced output, a CLI surface. Skip for pure refactors, internal work with no visible surface, dependency bumps, and documentation.
---

# Change Validation

Acceptance testing from the user's point of view. Unit tests prove the code does what
the developer meant; this proves the change does what the *user* needed.

## When this applies

Run it when the change alters something a user can observe: a screen or widget, a
navigation flow, a number or chart that gets rendered, an exported report, a CLI
surface, an error message they will read.

Do **not** run it for pure refactors, internal work with no surface change,
dependency bumps, or docs. Say once that you are skipping it and why — a
silent skip is indistinguishable from forgetting.

## 1. BA pass — what does the user actually need?

Think as the end user of this application, not as its author. Produce:

- The user-facing **scenarios** the change touches, including the ones it touches
  by accident — a changed shared component affects every screen that renders it.
- **Acceptance criteria** per scenario: observable conditions, not implementation
  claims. "Der Kennwert erscheint im Ergebnis-Panel" — not "die Funktion gibt den
  Kennwert zurück".
- The **negative cases**: empty input, one row, a missing or wrongly typed column,
  a computation that cannot complete. These are where an application actually
  breaks — usually silently.

## 2. Test pass — write the cases down

For each scenario write `.planning/e2e-tests/<kebab-case-name>.md`:

```markdown
# <Scenario>

**Betrifft:** <screen / flow / output>
**Warum:** <the user need behind it>

## Vorbedingungen
- <state the app must be in>

## Schritte
1. <one concrete, executable action>
2. ...

## Erwartetes Ergebnis
- <observable, checkable>

## Negativfall
- <input> -> <expected handling>
```

These files are committed. They are the durable part — the conversation is not.
Before writing a new one, check whether an existing case already covers the
scenario and extend it instead.

## 3. Execute — after the code is done

- Start the app locally (`Rscript -e 'shiny::runApp(port = 3838)'`, then
  `http://localhost:3838`) and drive the written steps through the
  `claude-in-chrome` skill: click, type, read what the canvas / plot shows.
- For scenarios that are only about server state (not what is rendered), a
  `shiny::testServer()` case in `tests/testthat/` is an acceptable executor —
  say so in the report.

Execute the written steps as written. If a step turns out to be unexecutable, fix
the test file — do not quietly substitute a different, easier check.

## Report back

Per scenario: **bestanden / gefallen / nicht ausführbar**, with the actual observed
output for anything that failed. A change is not done until every documented
scenario passes. If you could not execute a scenario, say so explicitly — never
report an unexecuted case as passing.
