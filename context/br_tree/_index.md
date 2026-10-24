# Business Rules! Documentation — Master Index

Reorganized for segmented application development. **Configuration/platform concerns are
kept separate from coding specifications.** Each folder has its own `_index.md`.

## Top-level map

- **[00-configuration/](00-configuration/_index.md)** (21 docs) — Platform, deployment and environment configuration. **Not coding** — nothing here is needed to reason about program logic.
- **[10-language/](10-language/_index.md)** (21 docs) — In-memory data operations — the core coding language: syntax, flow control, and data manipulation.
- **[20-io-screen/](20-io-screen/_index.md)** (17 docs) — Screen input/output authoring: fields, attributes, controls and windows.
- **[30-io-file/](30-io-file/_index.md)** (18 docs) — File input/output authoring: statements, form specs, keys/indexes and the file model.
- **[40-io-printing/](40-io-printing/_index.md)** (8 docs) — Printing authoring (coding side only; spool/printer config lives under 00-configuration).
- **[50-libraries/](50-libraries/_index.md)** (27 docs) — Reusable library facility and the shipped function packs.
- **[60-integration/](60-integration/_index.md)** (6 docs) — Web & data-exchange integration — JSON/data store and BR as a web server.
- **[70-commands/](70-commands/_index.md)** (9 docs) — Executive/console commands. Integral to coding because they are runnable from program code via `EXECUTE "<cmd>"`.
- **[90-reference/](90-reference/_index.md)** (856 docs) — Lookup-only reference material — not authoring specifications.

## Where do I look for…

| I want to… | Go to |
|---|---|
| Declare a variable or array (DIM) | `10-language/data-manipulation/declaration` |
| Assign / move data (LET, MAT) | `10-language/data-manipulation/assignment` |
| Use a built-in function (CNVRT$, POS…) | `10-language/data-manipulation/system-functions` |
| Write an IF / loop / GOTO | `10-language/data-manipulation/conditionals`, `10-language/flow-control/other-flow` |
| Define a function (DEF/FN) | `10-language/flow-control/functions-udf` |
| Read/write a record | `30-io-file/statements` |
| Build or use an index | `30-io-file/keys-indexes` |
| Lay out a screen / field | `20-io-screen/*` |
| Print a report | `40-io-printing/*` |
| Run a program from code (EXECUTE) | `70-commands` |
| Look up an error code | `90-reference/error-codes/_index.md` |
| Configure BR / deploy | `00-configuration/*` |

_Provenance: `_migrate/MANIFEST.csv` maps every file's original location to its new path._

