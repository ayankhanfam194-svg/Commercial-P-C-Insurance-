# Commercial P&C Insurance — SQL Practice Project

A hands-on SQL portfolio project built around a **Commercial Property & Casualty (P&C) Insurance** dataset. It models a simplified insurance book of business — agents, corporate clients, insured properties, policies, and claims — and works through **105 business questions**, from basic filtering all the way to recursive CTEs and window functions.

Written and tested in **PostgreSQL**.

## Why this project

Insurance analytics is a great sandbox for SQL practice because it naturally requires:
- Multi-table joins (client → property → policy → claim)
- Real KPIs (loss ratio, claim frequency, claim severity, fraud rate)
- Time-series and cohort analysis (renewals, YoY loss ratio, rolling averages)
- Window functions for ranking, running totals, and percentile analysis

## Entity-Relationship Overview

```
PNC_AGENT ───┐
             │
PNC_CUSTOMER ─┼── PNC_SALES (policies) ── PNC_CLAIMS
             │
PNC_PROPERTY ┘
```

| Table | Grain | Description |
|---|---|---|
| `PNC_AGENT` | 1 row / agent | Agent ID, name, type (broker, direct, online, etc.), experience, region |
| `PNC_CUSTOMER` | 1 row / client | Corporate client profile: industry, revenue, employee count, credit rating |
| `PNC_PROPERTY` | 1 row / property | Insured property: type, construction, value, year built, disaster risk zone |
| `PNC_SALES` | 1 row / policy | The policy itself: coverage type/amount, premium, deductible, dates, agent/client/property FKs |
| `PNC_CLAIMS` | 1 row / claim | Claim filed against a policy: loss cause, claimed vs. approved amount, status, fraud flag |

Full DDL (with primary/foreign keys) lives in [`sql/00_schema.sql`](sql/00_schema.sql).

## Repository structure

```
.
├── README.md
├── data/
│   └── README.md                 # how to source/point at the CSVs (not included)
└── sql/
    ├── 00_schema.sql              # CREATE TABLE + COPY (load) + DROP statements
    ├── 01_basic_filtering.sql     # Q1–Q15   — WHERE, LIKE, BETWEEN, ORDER BY, LIMIT
    ├── 02_aggregation.sql         # Q16–Q35  — GROUP BY, HAVING, FILTER, CTE intro
    ├── 03_joins.sql               # Q36–Q55  — INNER/LEFT/CROSS/SELF joins
    ├── 04_subqueries.sql          # Q56–Q75  — scalar, correlated, IN/ANY/ALL/EXISTS
    ├── 05_ctes.sql                # Q76–Q90  — CTEs, chained CTEs, recursive CTE
    └── 06_window_functions.sql    # Q91–Q105 — RANK, LAG/LEAD, NTILE, running totals
```

## How to use

1. Create a PostgreSQL database.
2. Run `sql/00_schema.sql` to create the five tables.
3. (Optional) Load your own CSV data — see [`data/README.md`](data/README.md) — or point the `COPY` statements at your own dataset.
4. Run any of the numbered query files against the database.

```bash
psql -d pnc_insurance -f sql/00_schema.sql
psql -d pnc_insurance -f sql/01_basic_filtering.sql
```

## What's covered, section by section

### 1. Basic Filtering (Q1–Q15)
`WHERE`, `LIKE`/wildcards, `IN`, `BETWEEN`, `IS NULL`, `ORDER BY`, `LIMIT` — e.g. finding under-insured thin-coverage policies, upcoming renewals, and data-quality gaps.

### 2. Aggregation (Q16–Q35)
`GROUP BY`, `HAVING`, `FILTER`, ratio metrics — premium by region, loss ratio by coverage type, fraud rate by loss cause, agent-type profitability.

### 3. Joins (Q36–Q55)
Inner, left, cross, and self joins — full underwriting records, orphaned/data-integrity checks, out-of-territory compliance checks, top loss-cause per region.

### 4. Subqueries (Q56–Q75)
Scalar, correlated, `IN`/`NOT IN`, `ANY`/`ALL`, `EXISTS` — clients above the revenue average, second-highest premium without `LIMIT`, net-profitable clients.

### 5. CTEs (Q76–Q90)
Single, chained, and **recursive** CTEs — client loss-ratio summaries, a generated no-gaps monthly calendar, rolling 3-claim averages, revenue-quartile claim frequency.

### 6. Window Functions (Q91–Q105)
`RANK`/`DENSE_RANK`/`ROW_NUMBER`, `LAG`/`LEAD`, `NTILE`, `PERCENT_RANK`, `CUME_DIST`, running totals, and moving averages — pricing bands, top-N-per-group, YoY comparisons.

## Notes

- All identifiers are written in `UPPER_SNAKE_CASE` to match the original dataset conventions.
- A couple of queries in the CTE section were left incomplete in early drafts and have been completed here (Q82: high-risk client flagging, Q83: coverage-type share of premium).
- Raw data isn't checked into the repo — see [`data/README.md`](data/README.md) for how to supply your own.

## License

Feel free to reuse or adapt this for your own SQL practice or portfolio.

