# Exemplars — blessed programs for this app

These are real programs from this app, picked as the patterns to imitate. Each one is **referenced
in place** (path from the app root), not copied, so the exemplar can never drift from the live
source. All sources were refreshed by decompile on 2026-10-23 (see `../STALE_SOURCE.md`), so they
match the running `.br`. Read the whole file before imitating it.

**Shortfall:** the kit asks for 10–20 exemplars. This app has only seven programs of its own, so
there are six exemplars and one counter-example. `fileio.br.brs` and
`filelay\template\basic.brs` are the third-party FileIO library and its code template, not house
style. `tmp\web_server.br.brs` is an old copy, and `http_client\get_site2.br.brs` is an
unfinished experiment that stops at line 110.

| # | Archetype | File | Imitate it for |
|---|---|---|---|
| 1 | Web request handler: keyed FileIO search, streamed HTML template rows | `cust_inq.br.brs` | Any `BR_FUNC=` function that reads data and fills an HTML template |
| 2 | Web request handlers: FileIO write and sequential list, pages built in code | `sample.brs` | Form → save → thank-you page; list a whole file; building HTML with `webform` |
| 3 | Authentication handler | `login.brs` | The login / re-login flow through `FNAUTHENTICATE` / `FNAUTHORIZE` |
| 4 | Support library of small `DEF LIBRARY` helpers | `webform.br.brs` | How a shared helper library is laid out and linked |
| 5 | Main program: server loop, config file, dispatcher | `web_server.br.brs` | Error trapping, `!:` multi-statement style, label and section-comment layout |
| 6 | HTTP client call | `http_client\get_site.br.brs` | `OPEN ... http=client` and chunked output to a `DISPLAY` file |
| — | Console utility (counter-example) | `json_analyze.br.brs` | Only for calling the web server's JSON functions from another program |

## 1. `cust_inq.br.brs` — `FNDISPLAY_CUST`

Blessed pattern for **a web request handler that reads a FileIO file and streams template rows**.
- Entry point `def library FNDISPLAY_CUST(MAT KEYS$,MAT VALUES$)`, registered in `web_server.ini`
  (`library=cust_inq.br,functions=fndisplay_cust`) and called as `?BR_FUNC=FNdisplay_cust` from
  `www\cust_inquiry.htm`.
- Request fields come from `SRCH(KEYS$,"^cust_ID")`; the value is at the same row of `VALUES$`.
- FileIO: the `FNOPEN` wrapper (lines 1080-1130, standard FileIO boilerplate) opens `customer`
  once (`if CUSTOMERFILE=0`) and executes the subscript assignments, so fields are addressed as
  `CUSTOMER$(RCU_CUST_NAME)`. Reads use `FORM$(CUSTOMERFILE)`.
- Keyed scan: `restore #f, search>=KEY$: nokey Label`, then a `read ... eof Label` loop with a
  label-and-`goto` loop and a prefix test to stop.
- Output: one `FNSEND_PAGE` for the page head (`customer_list1.htm`), one per row
  (`customer_list2.htm`, its `^cust_id`-style tokens replaced from `MAT ROW_ARGS$`/`MAT ROW_VALUES$`),
  one for the foot (`customer_list3.htm`). The server appends each to its page buffer and sends
  the whole response once.
- Linkage: `FNLIBRARYLINKAGE` with a once-only flag, linking `fileio` and the server's
  `FNSEND_PAGE`, and loading the template tokens from a `DATA` statement.
- **Don't copy:** the 4th and 5th `FNSEND_PAGE` arguments (`0,1` / `1`) and their "suppress
  header" comments. In the current server those positions are the function's own scratch locals,
  so the values do nothing (see `../architecture.md`).

## 2. `sample.brs` — `FNADDCOMMENT`, `FNSAVECOMMENT`, `FNVIEWCOMMENTS`

Blessed pattern for **form → save → confirmation, and listing a file**.
- `FNSAVECOMMENT`: `FNREQUESTSUBS(MAT KEYS$)` turns request field names into `R_` subscripts
  (`VALUES$(R_FIELD_NAME)`), then a FileIO `write`, then `FNCLOSEFILE`, then a template reply
  (`thank_you.html`) with `^token` replacement.
- `FNVIEWCOMMENTS`: sequential FileIO read loop (`read ... eof Label` / `goto`) building HTML
  with `webform`'s `FNHTML`, then `FNSEND`.
- `FNADDCOMMENT`: a page built entirely in code with `webform` (`FNHEADING`, `FNFORMSTART`,
  `FNFIELD`, `FNSUBMIT`, `FNFORMEND`, `FNFOOTER`, `FNSEND`). `www\add_comment.html` is a static
  copy of the same form, and is the one the site links to.
- The `! #Autonumber# 99000,10` line is a comment from FileIO-generated boilerplate. This app does
  not use Lexi; the lines after it are numbered 970-1130 by hand.

## 3. `login.brs` — `FNLOGIN`

Blessed pattern for **authentication**.
- First call (no `User_Name` key): `FNAUTHENTICATE(realm$, challenge-page)`. Uses
  `challenge.relogin.html` when the request has `RELOGIN`.
- Second call: check the password, then `FNAUTHORIZE(-15*.00069445)` (a negative value = idle
  timeout in days, here 15 minutes), then `FNSEND_PAGE("home.html")` unless it's a re-login.
- **Placeholder:** `if 1 OR PASSWORD$ == STORED_PASSWORD$` accepts any password, and
  `STORED_PASSWORD$` is never loaded. Real code must look the user up. MD5 via
  `ENCRYPT$(...,"","MD5")` is what's there; it is not a recommendation.

## 4. `webform.br.brs` — HTML builder library

Blessed pattern for **a library of small helpers**: a header comment that lists the
`library "webform" : ...` line to use, short `def library` functions with optional parameters
after `;` and `___` locals, and a `FNLIBRARYLINKAGE` that links back to the server.
- **Don't copy:** `FNHTML` grows `DOCUMENT$` with `DOCUMENT$=DOCUMENT$&HTML$`. Use
  `DOCUMENT$(INF:0)=HTML$` in new code (`../../dev/essentials.md` §4: repeated self-concatenation
  corrupts past about 120 KB). `FNFORMSTART`'s `LIBRARY$` argument emits `BR_LIB=`, which the
  server ignores.

## 5. `web_server.br.brs` — the server

Not a template for a new program (there's one server), but the reference for **this app's
low-level style**:
- section comments `! ***** Title`, mixed-case labels on their own statements (`Readini:`,
  `Mainloop:`, `Not_Found:`)
- trailing error clauses to labels (`ioerr Ini_Error`, `eof Readini_Done`, `error Exec_Error`)
- several statements per line joined with `!:` continuations
- every exported `def library` function's signature, which handlers must call correctly:
  `FNSEND_PAGE`, `FNAUTHENTICATE`, `FNAUTHORIZE`, `FNSEND_STRING`, `FNSEND_OBJECT`, and the JSON
  helpers `FNPUT_JSON`, `FNGET_JSON`, `FNPARSE_JSON`, `FNCOMPILE_JSON` and their variants

## 6. `http_client\get_site.br.brs`

Blessed pattern for **an outbound HTTP request**: `open #n: "NAME=<url>,http=client",display,outin`,
a `print` to send the request, a `linput ... eof` loop to read the response, and output written in
30,000-byte chunks to a `DISPLAY` file opened `eol=none`. The target URL is demo data.

## Counter-example: `json_analyze.br.brs`

A console test program for the server's JSON functions (`library "web_server": FNPARSE_JSON,
FNCOMPILE_JSON`). It writes `dim.proc` and generates variable names with `execute`, prompts with
`print`/`rinput`, and waits on keys. None of that belongs in a web handler.
