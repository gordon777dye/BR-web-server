---
alwaysApply: true
---

# brweb — house conventions

Derived on 2026-10-23 from the app's own sources: `web_server.br.brs`, `login.brs`, `sample.brs`,
`cust_inq.br.brs`, `webform.br.brs`, `json_analyze.br.brs` and `http_client\get_site.br.brs`. The
third-party FileIO library and template are excluded. Each rule names an exemplar
([`exemplars/README.md`](exemplars/README.md)) that shows it.

## Toolchain

- **Plain BR, no Lexi.** No source uses `/* */`, `&=` or `#Select#`. The one `#Autonumber#` in
  `sample.brs` is a comment pasted from FileIO boilerplate.
- **Masters are source.** Edit the `.brs`, then compile it with `LOAD <src> source` followed by
  `REPLACE <prog>.br`. Decompiling is not allowed (see `../README.md`).
- **Source file names:** `web_server.br.brs` and every source created on 2026-10-23 are
  `<prog>.br.brs`. Older ones are `<prog>.brs` (`login.brs`, `sample.brs`). Keep an existing file's
  name; use `<prog>.br.brs` for a new program.
- **Format is set by `brconfig.sys`:** `style i 3, l mixed, c mixed, k lower` and
  `style indent 3 comments mixed`. Keywords are lower case, variable and function names upper case,
  labels mixed case (`Readloop:`), and bodies indented 3. `LIST` and `REPLACE` reapply this, so
  don't fight it.
- Production runs a BR 5.01 Debug build (`brserver-x64-Debug.exe`), and `brconfig.sys` has `option 60` on.

## Program shape

- **Header:** a `! Rep <Name>` line, a one-line purpose, and dates in `! *****` lines (`login.brs`,
  `cust_inq.br.brs`).
- **Line numbers** go up by **20** in `web_server` and `login`, and by **10** in the SageAX-written
  `sample`, `cust_inq` and `webform`. Follow the file you are in, and insert into the gaps.
  `web_server` jumps to literal line numbers (`goto 3520`, `ioerr 3380`), so **never renumber it**.
- **Section comments** are `! ***** Title` (web_server: 89 of them). Comments inside a function in
  the SageAX files are `! .! text` (sample, cust_inq).
- **`DIM` at the top of the file or just before the function that uses it**, sizing every string
  that receives request or file data (`dim SEARCH_KEY$*30, WORK$*2000`).
- **Names:** upper-case snake case for variables (`SEARCH_KEY$`, `CUST_ID_SUB`), `FN` + upper case
  for functions, mixed-case labels. Constants are set once near the top
  (`let TRUE = 1 : let FALSE = 0`, `ONE_MINUTE = .00069445`).

## Web request handlers (the main thing new code is)

- One handler = **`def library FNX(MAT KEYS$,MAT VALUES$)`** in a library `.br`, registered in
  `web_server.ini` as `library=<file>.br,functions=fnX[,...]`. Browsers call it with
  `?BR_FUNC=fnX`, on a GET or a POST (`cust_inq.br.brs`, `sample.brs`).
- **Request fields:** `SUB = SRCH(KEYS$,"^field")` (`^` = case-insensitive), then
  `VALUES$(SUB)`. Or call `FNREQUESTSUBS(MAT KEYS$)` once to get `R_<field>` subscripts
  (`sample.brs`). `KEYS$(1)` is always `QueryNumber`.
- **Linkage once:** each library has a `FNLIBRARYLINKAGE` guarded by a `LINKAGEESTABLISHED` flag,
  called first in every handler. It holds the `library "fileio" : ...`,
  `library "webform" : ...` and `library : FNSEND_PAGE` (server) statements (`cust_inq.br.brs`).
- **Reply with the server's functions only:**
  - `FNSEND_PAGE("<file in www>", MAT ARGS$, MAT REPL$)` to send a template, replacing
    `^token` placeholders (tokens kept in a `DATA` line and loaded with `read MAT`)
  - `webform`'s `FNHTML` ... `FNSEND` for HTML built in code
  - `FNSEND_STRING` / `FNSEND_OBJECT` for raw or JSON output
  
  Several `FNSEND_PAGE` calls in one request are joined into one response (`cust_inq`). After a
  POST, `FNSEND_PAGE` sends a 303 redirect to the page rather than the page itself.
- **Never** `print` to the screen, `input`, `pause` or `stop` in a handler. The server runs
  unattended as a service, and anything that waits on the keyboard aborts it (`BR_service.txt`).

## Data files

- **FileIO for app data.** All app data access goes through FileIO's `fnOpen` wrapper, which is
  the boilerplate at the end of `sample.brs`/`cust_inq.br.brs`; copy it unchanged. Then read and
  write with `using FORM$(f): MAT F$, MAT F` and address fields by subscript
  (`CUSTOMER$(RCU_CUST_NAME)`, `COMMENTS(C_DATE)`). Raw `open` is used only for the server's own
  files (ini, log, debug, session store) and for non-app files (`get_site`).
- Layouts live in `filelay\` (see [`data-model.md`](data-model.md) and
  [`DATA-MODEL-NOTES.md`](DATA-MODEL-NOTES.md)). Raise a layout's version number on every layout
  change, and keep it equal to the file's `VERSION()` otherwise. Never rename a subscript.
- Open once per library instance (`if CUSTOMERFILE=0 then let CUSTOMERFILE=FNOPEN(...)`), or open
  and `FNCLOSEFILE` within the request (`sample.brs`).

## Error handling

- **Trailing clauses to labels** are the house form: `ioerr`, `eof`, `nokey`, `conv`, `soflow` and
  `error` on the statement itself, each jumping to a named label (web_server: 29 `ioerr`,
  12 `error`, 11 `nokey`, 10 `conv`). `on error goto` is used only around library linkage at
  start-up.
- Loops are a label plus `goto` around a `read ... eof Done` (`sample`, `cust_inq`), or
  `do ... loop` (web_server).
- In the server, report failures to the browser with `print #HTTP_FILE:` and to `#DEBUG` when it
  is open (`Exec_Error:` in web_server).

## Known non-house patterns (don't imitate)

- `X$ = X$ & Y$` inside a loop (`webform.FNHTML`). Use `X$(INF:0) = Y$`.
- `if 1 OR ...` placeholder authentication in `login.brs`.
- Extra 4th and 5th arguments to `FNSEND_PAGE` (`cust_inq`). They are ignored.
