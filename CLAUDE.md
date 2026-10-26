# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A web server written in **Business Rules! (BR)**, a BASIC-dialect language. `brserver-x64-Debug.exe` (a BR 5.01 Debug build, with `brclientdll501-x64-Debug-gui.dll` beside it) interprets the programs. There is no npm/make/test tooling; everything runs inside the BR interpreter. Full product docs are `03 BR WEB SERVER.md` (setup of both configurations, INI reference, logins), `05 DATA STORE LIBRARY.md` (the data store and JSON functions) and `REDIRECT.md` (the HTTPS and after-POST redirects, and BR's `REDIRECT-TO`). They are the masters, since the Word originals were deleted. `old\CHANGE_LOG.md` lists what changed in each release from 1.80 on; `old\` is not tracked in git. The tree is an SVN working copy (`.svn/`) and also a git repo (private, github.com/gordon777dye/brweb). Git's `.gitignore` lists the files to include, so a new top-level file needs a `!/<name>` line, and a new file under `context/` needs `git add -f`.

## Source vs. compiled files

- `*.brs` files are BR **source**: plain text with mandatory line numbers (`01000`, `01020`, …). `!:` continues a statement onto the next physical line, and `!` starts a comment.
- `*.br` files are the **compiled** programs that BR actually runs. Editing a `.brs` file has no effect until it is recompiled inside BR, for example `load web_server.br.brs,source` followed by `replace web_server.br`.
- The main program is `web_server.br`, built from `web_server.br.brs` (VERSION$ "2.17"). Earlier releases are kept for reference in `old\`: `web_server.br.2_16`/`.brs.2_16`, `.2_15`, `.2_14`, `.2_13`, `.2_12`, `.2_11`, `.2_10`, `.2_09`, `.2_08`, `.2_07`, `.2_06`, `.2_05`, `.2_04`, and `web_server-<n>.br` objects back to 1.44. `web_server.bak` in the root is 2.04.
- The program masters are the **source** files, and decompiling is not allowed. Every `.br` has current source as of 2026-10-23: `login.brs`, `sample.brs` and `filelay\template\basic.brs` keep their old names, and the rest are `<prog>.br.brs`.
- When you add lines, keep line numbers ascending and use numbers that fall in the gaps. Some code jumps to literal line numbers (`goto 3520`, `ioerr 3380`, `conv 2420`), so do not renumber.

## Running

- Start BR from this directory: `brserver-x64-Debug.exe`. It reads `brconfig.sys`, and that file ends with `execute "run web_server"`.
- **Drive mapping:** `brconfig.sys` maps BR drive `c:` to `C:\ADS_test\gabriel`. So the BR path `C:\brweb\...` (used in the logs and in `web_server.tmp`) is really `C:\ADS_test\gabriel\brweb`. Drive `k:` maps to `c:\ads_test`.
- To run it as a Windows service, use `nssm.exe` with `brconfig.svc` (unattended logging). See `BR_service.txt`.
- The program requires BR 4.32g or later and a workstack of at least 500000. It stops at startup if either check fails.

## Logs and debugging

- `brlog.txt`: the BR interpreter log (level 9). It shows every command BR executes.
- `weblog.txt`: the HTTP engine log (`logfile=` in the ini).
- `webdebug.txt`: the server's own debug output. It is rewritten on each run. The `debugfile=` options `cookies` and `print_all` turn on extra detail.
- `query<session>.txt`: the persisted request counter.

## Architecture

**Configuration (`web_server.ini`):**

| Setting | Purpose |
|---|---|
| `url_base` | Directory being served (here `www`) |
| `cert=` | Base name for `<name>.crt/.key/.phrase` |
| `port` | Port to serve (default 443). It can be a range such as `8081-8084`, and each engine takes the first free port in it. |
| `proxy=` | Address(es) of a reverse proxy, such as NGINX. Turns on proxy mode: plain HTTP with `URL_BASE=NONE`, no `cert=` needed, and `port` defaults to `8081-8084`. It needs a BR build with `PROXY=`/`BIND=` support, which `brserver-x64-Debug.exe` has. Server tests (both modes, logins across engines) are in `context/scratch/ws206/ws206test.py`; JSON tests in `context/scratch/json207/` (`jsontest*.brs` for the data store, `json209test.py` for conversion over HTTP, `json210test.py` for JSON request bodies); the data store on disk in `context/scratch/ds212/ds212test.py` (two engines, NOLOGIN, with `dslib.brs`); parameter splitting and decoding in `context/scratch/url213/url213test.py` (with `urllib.brs`). |
| `bind=` | Address to listen on in proxy mode (default `127.0.0.1`) |
| `nologin` | Turns off authentication |
| `allow=` | URL prefixes that need no auth. `index` and `login` are always added. |
| `relogin_minutes` | Grace window after a session expires |
| `library=<file> [retain], functions=fn1,fn2[,auth][, run_dir=...]` | Each line registers one callable BR library. `,auth` has had no effect since 1.89; with logins on, every function needs a session unless `allow=` matches it. |

On first startup the cert passphrase is prompted for, then stored encrypted in `<cert>.phrase`.

**Library linkage bootstrap.** BR needs libraries to be linked at load time. On first run, `web_server.br.brs` (around line 02900) writes a proc file `web_server<WSID>.tmp`. That proc reloads the server program, injects `10 library_installed = 1`, loads each library `resident`, and adds `library` statements at lines 3021+. It then runs `proc` on that file, which restarts the program with the libraries linked. `web_server.tmp` in the tree is a sample of that generated proc.

**Request loop (`Mainloop`):**

1. One HTTP file, `open #100 ... http=server`, never closes. `linput` returns the POST body, and `FILE$(HTTP_FILE,"PAGE-URL"/"PAGE-COOKIE"/"page-auth")` gives the URL, cookies and auth data.
2. A URL with no query string and no POST serves a static file from `url_base`. A directory request gets its `index.*` file.
3. A URL with `?BR_FUNC=fnName` or a POST is parsed into parallel arrays `MAT KEYS$` / `MAT VALUES$`. The first entry is always `QueryNumber`. Since 2.13 only the URL's path is decoded up front (line 04100). The query string and form body are split on `&` and `=` while still encoded, and `FNADD_PARM` (line 33020) decodes each name and value, so `%26` is data. A relogin replay sets `URL_PREPARED` so its saved path isn't decoded twice. The server then dispatches with `execute "let fnName(mat keys$,mat values$)"`.
4. Output is accumulated in `PAGEBUF$` and flushed at the top of the next loop iteration, with headers built by `FNSEND_HEADER`. A page that brings its own headers (`SUPPRESS_HEADER`) gets its `Content-Length` corrected to the real body length (`Fix_Content_Length`, line 22084). BR sends the response at the next `LINPUT`. Since 2.17 there is no second, empty header pass.

**Writing a library function** (examples: `sample.brs`, `login.brs`, `cust_inq.br.brs`; annotated in `context/app/exemplars/README.md`):

- Declare it as `def library fnX(MAT KEYS$, MAT VALUES$)` and register it under `library=` in the ini.
- It produces output by linking back to the server's exported library functions:
  - `FNSEND_PAGE(url$; MAT ARGS$, MAT REPL$)` serves an HTML template from `url_base`. It does a search-and-replace of `^placeholder` tokens, as in `br_redirect.html`'s `^new_location`. When the request was a POST, it sends a 303 redirect (`br_redirect.html`) instead of the page.
  - `FNSEND_STRING` and `FNSEND_OBJECT` send raw content.
  - `FNAUTHENTICATE(realm$; challenge_html$)` and `FNAUTHORIZE(timeout_days)` handle login. Timeouts are fractional days, and a negative value means an idle interval. `login.brs` shows the full flow, including relogin through `challenge.relogin.html`.
  - The JSON helpers include `FNPUT_JSON/FNGET_JSON/FNDELETE_JSON`, `FNPARSE_JSON/FNCOMPILE_JSON` and the `*_OBJECT` variants. They live in the same `web_server.br.brs` file.
  - Inside the data store, a quote within a JSON string is written `""`, and a backslash is ordinary data. Since 2.09 the server converts at the HTTP boundary. A request value that is valid standard JSON is turned into that form before `VALUES$` reaches the handler (`FNJSON_FROM_STANDARD`, called at line 07702). JSON responses from `FNSEND_STRING`/`FNSEND_OBJECT` leave as standard JSON (`FNJSON_TO_STANDARD`, line 03705). Responses that include a `FNSEND_PAGE` file are not touched.
  - Since 2.10, a POST with `Content-Type: application/json` (`JSON_BODY`, set at line 03860) is not URL-decoded or split into pairs. It becomes the parameter `JSON` (empty if over 30,000 characters) and the data store object `POST_BODY` (up to 4 MB, `POST$*4194304`). See `Json_Body_Parm` at line 07664. `POST_BODY` lasts only for its request; it is never saved to disk.
  - Since 2.12 the data store (`MAT OBJECTS$`/`STORAGE$`/`START`/`END`) belongs to the request's session and lives in `sessions\sesd<g>.dat`, one record per `STORAGE$` element (`Sesd_Form`, key = session + 4-digit sequence). `FNINIT` loads it the first time a request uses it (`FNDS_LOAD`, line 11410). `FNINS_OBJECT`/`FNDEL_OBJECT`/`FNSTORE_OBJECT` set `DS_DIRTY`, and the top of `Mainloop` (03670) writes it back (`Ds_Save` → `FNDS_SAVE`) before the response is flushed, then clears it (`FNDS_CLEAR`). With no session (the library used outside the server), it stays in memory as before. The functions are at line 30800 and later.
- `sample.brs` uses the **FileIO** library (`fileio.br`, with `fnOpen`/`fnCloseFile`). FileIO opens data files in `data/` using the layout definitions in `filelay/`.

**Sessions (stateless across requests):**

- Sessions live on disk in `sessions\sess<g>.dat`, with relogin URL and POST data in `sessions\sesx<g>.dat` and the session's data store in `sessions\sesd<g>.dat`. `<g>` is the low-order `Session_digits` digits of the session ID. `FNSESS_OPEN` opens all three; `FNSESS_FREE` frees all three.
- Nothing about a session, its data store included, is kept in memory between requests. That means several BR engines (`wsid=unique`) can serve the same site.
- Since 2.12 sessions are kept under `NOLOGIN` too. There, a session starts only when the data store first has something to save (`No_Session`/`Ds_Save`). The cookie omits `Secure` when the request's `PROTOCOL` is `http`.
- Session statuses: `N` new, `A` authorized, `X` ended, `F` free.
- The browser gets a `Session=` cookie (`Secure; HttpOnly; SameSite=strict`).
- `Sweep_Sessions` frees expired records every five minutes.
- Plain-HTTP requests are redirected to HTTPS whenever auth is required.

## Tests

`test\jsonsuite.brs` is the self-checking suite for the data store and JSON library (about 150 checks, a few seconds, no server). Run `brserver-x64-Debug.exe "PROC test\jsonsuite.prc" -context\dev\tools\brconfig.ai_util` from the app root and read `test\jsonsuite_result.txt`. The master is `test\jsonsuite.src` (no line numbers), numbered by `test\number.py`. `test\README.md` explains the PASS/FAIL/KNOWN results and lists the open findings, and the HTTP tests are listed there too. Run the suite after any change to the data store or JSON functions.

## Other directories

- `www/`: the site being served.
- `http_client/`: separate demos of BR's HTTP *client* (`get_site.br`, CA bundles). They are unrelated to the server.
- `json_analyze.br` with `dim.proc`: a standalone JSON-analysis utility.

@context/README.md
