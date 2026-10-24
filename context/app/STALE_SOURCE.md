# Source currency — ONBOARDING STEP 2 audit

**Status (2026-10-23): every `.br` program has current source. Nothing is stale.**

Program masters are kept in **source** form, so decompiling is normally prohibited. On 2026-10-23
the owner authorized a **one-time** decompile of every `.br` program in the app to create or refresh
its source. The owner decompiled `web_server.br` and confirmed that `web_server.br.brs`
matches it; the other ten programs were decompiled headlessly with `LIST <prog.br >file` under
`brconfig.ai_util` (proc: `context/scratch/decompile.prc`). `LIST` restyles source through the
config's `STYLE` lines, so keyword case and comment layout now follow `brconfig.sys`.

| Program | Source | Before the refresh | What the decompile showed |
|---|---|---|---|
| `web_server.br` | `web_server.br.brs` | suspect (18½ min gap) | decompiled by the owner; matches |
| `login.br` | `login.brs` | passed the date check | **the `.br` differed**: timeout is `-15*.00069445` (15 minutes), and the old source said 5 |
| `sample.br` | `sample.brs` | passed | cosmetic only (keyword case) |
| `filelay\template\basic.br` | `filelay\template\basic.brs` | passed | cosmetic only: the old source had no line numbers and different comment styling |
| `cust_inq.br` | `cust_inq.br.brs` | missing | created |
| `fileio.br` | `fileio.br.brs` | missing | created |
| `webform.br` | `webform.br.brs` | missing | created |
| `json_analyze.br` | `json_analyze.br.brs` | missing | created |
| `http_client\get_site.br` | `http_client\get_site.br.brs` | missing | created |
| `http_client\get_site2.br` | `http_client\get_site2.br.brs` | missing | created |
| `tmp\web_server.br` | `tmp\web_server.br.brs` | missing | created (an old 2025 copy of the web server, not a master) |

Backups of the three replaced sources: `context/app/onboarding/backup/source/`.

`login.br` shows the timestamp audit can pass a program whose source is out of date. Equal
timestamps (both files were copied together on 2019-04-22) prove nothing about content.

Every source above passes `brls -check -sema` with 0 errors (warnings only).

Not audited (not BR program extensions): `web_server.bak`, `web_server.br.2_04`,
`web_server.br.brs.2_04`, `http_client\get_site.bak`, `http_client\get_site2.bak`.
