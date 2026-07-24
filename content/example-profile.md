---
title: Ada Whitfield
subtitle: Senior Backend Engineer
author: Serokell OÜ
date: July 2026
tables: full
cover: false
---

# Ada Whitfield

## Senior Backend Engineer

**Location:** Lisbon, Portugal

**Work:** Serokell since March 2021

**Languages:** Haskell, Rust, PostgreSQL, Nix

**Education:** MSc in Computer Science, University of Edinburgh (2017); BSc in Mathematics, University of Warsaw (2015)

> **Areas of expertise**
>
> Distributed systems, formal verification, database internals, build reproducibility

# Key project track

## Northwind Bank

**Role:** Backend Lead &nbsp;&nbsp; **Stack:** Haskell, PostgreSQL

**Overview:** Owned the ledger service behind a retail payments platform, taking it from a single-region deployment to an active-active setup across two data centres.

**Key contributions:**

- Designed the reconciliation pipeline that settles roughly 4 million transactions a day.
- Cut median settlement latency from 900ms to 120ms by reworking the write path.
- Introduced property-based testing for the ledger invariants, now part of CI.

## A European telecom operator

**Role:** Senior Engineer &nbsp;&nbsp; **Stack:** Rust, Kafka

**Overview:** Built the event ingestion layer for a network telemetry product, handling bursty traffic from several hundred thousand devices.

**Key contributions:**

- Implemented back-pressure handling that removed the nightly ingestion backlog.
- Reduced per-event processing cost by about 60 percent through batching.

## Open-source: reproducible builds

**Role:** Maintainer &nbsp;&nbsp; **Stack:** Nix

**Overview:** Maintains a widely used set of Nix overlays for pinning Haskell toolchains.

**Key contributions:**

- Maintains release compatibility across three GHC versions.
- Reviews external contributions and triages issues.

# Engagement summary

| Client | Focus | Duration |
| --- | --- | --- |
| Northwind Bank | Payments ledger | 2 years |
| European telecom operator | Network telemetry | 8 months |
| Open source | Build tooling | Ongoing |

# Domain expertise

> Finance and banking, telecom, developer tooling, formal methods
