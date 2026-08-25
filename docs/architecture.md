# Figurenzeichner — Architecture

> Skelett. Vom `new-project`-Skill übernommen und auszufüllen, **bevor** implementiert
> wird (Architecture-first). Leere Abschnitte sind ein Signal, kein Schönheitsfehler.

## Overview

<Was das System tut, in drei Sätzen.>

## Goals / Non-Goals

- <Ziel>
- **Non-Goal:** <was ausdrücklich nicht gebaut wird>

## High-Level Architecture

<Diagramm oder Textskizze: Komponenten und Datenfluss.>

## Repository Layout

```text
figurenzeichner/
├── .claude/              # skills, hooks, settings
├── .planning/            # PROJECT / TODO / STATE, e2e-tests/
├── docs/                 # dieses Dokument, ui_screens.md
├── app.R                 # Einstieg: shiny::shinyApp(ui, server)
├── R/                    # Geometrie (reine Funktionen), Shiny-Module — Shiny lädt R/ automatisch
├── tests/testthat/       # helper-source.R lädt R/; test-<topic>.R je Datei in R/
├── renv.lock, .Rprofile  # renv-Projektlibrary (renv/library/ ist gitignored)
└── .lintr
```

## Components

### <Komponente>

<Verantwortung, Schnittstelle, Abhängigkeiten.>

## Key Decisions

| Entscheidung | Gewählt | Warum | Datum |
| --- | --- | --- | --- |
