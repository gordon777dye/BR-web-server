# brweb — architecture

A Business Rules! **HTTPS web server** (`web_server.br`, v2.16) and the demo request handlers it
serves. It runs stand-alone (BR holds the certificate) or, with `proxy=` in the ini, as one or
more BR processes behind NGINX; `03 BR WEB SERVER.md` describes both. BR starts in the app root (`C:\ADS_test\gabriel\brweb`). The app's `brconfig.sys` runs
`web_server` at start-up, and `brconfig.svc` plus `nssm.exe` run it as a Windows service
(`BR_service.txt`).

## Directory map

| Path | What |
|---|---|
| `web_server.br` / `.br.brs` | The server: ini, HTTPS listener, dispatcher, sessions, and the exported page and JSON functions |
| `web_server.ini` | Server config: `url_base=www`, `cert=self`, log and debug files, `library=` handler registrations, `allow=`, `relogin_minutes` |
| `login.br`, `sample.br`, `cust_inq.br` | Request-handler libraries (`def library FNx(MAT KEYS$,MAT VALUES$)`) |
| `webform.br` | HTML-builder helper library used by `sample` |
| `fileio.br`, `filelay\`, `data\` | FileIO library (third-party), its layouts, and the data files (`customer`, `comments.ind`) |
| `www\` | Static site and HTML templates with `^token` placeholders |
| `challenge*.html`, `relogin.html`, `unauthorized.html`, `br_redirect.html` | Pages the server itself sends: login challenge, re-login, 401, 303 redirect |
| `self.crt/.key/.phrase` | TLS certificate; `.phrase` holds the key passphrase, encrypted |
| `sessions\` | Session store, created at run time: `sess<g>.dat` (sessions), `sesx<g>.dat` (relogin data), `sesd<g>.dat` (each session's data store, since 2.12) |
| `http_client\`, `json_analyze.br` | Stand-alone utilities, not part of the server |
| `old\`, `tmp\`, `web_server.bak` | Old copies, not masters. `old\` holds earlier releases (`web_server.br.2_04` to `.2_15`, `web_server-<n>.br` back to 1.44) and `CHANGE_LOG.md`; it is not tracked in git |

## Entry points

- **`run web_server`.** It reads `web_server.ini`. The first time, it writes and `proc`s
  `web_server<WSID>.tmp`, which reloads the server with every `library=` program resident and
  linked, and sets `library_installed`. Then it opens `http=server` and loops in `Mainloop`.
- **`?BR_FUNC=<fn>`** on any URL, by GET or POST, calls the registered handler with
  `execute "let fn(mat keys$,mat values$)"`. `BR_LIB=` (which `webform.FNFORMSTART` can emit) is
  ignored.
- Any other URL is served as a static file from `url_base` (a directory gets its `index.*`).

## Core flows

1. **Request dispatch:** HTTPS request → session cookie looked up or created (`Establish_Session`;
   nothing stays in memory, so several engines can share a site) → auth check (`FNCK_AUTH`; URLs
   starting with an `allow=` entry, `index` or `login` skip it) → query string and POST body split
   into pairs, then each name and value decoded, into `KEYS$`/`VALUES$` (row 1 = `QueryNumber`) → handler runs → whatever it put in `PAGEBUF$`
   is sent with one header at the top of the next loop. A data store function reads the session's
   objects from `sesd<g>.dat` the first time the request uses one, and if the request changed
   them, they are written back at the top of the loop, before that response goes out.
2. **Login:** `index.html` → `?BR_FUNC=fnLogin` → `FNAUTHENTICATE` sends `challenge.bootstrap.html`
   → the posted user and password come back as `User_Name`/`Password` → `FNAUTHORIZE(-15 min)`
   marks the session `A` → `home.html`. When the session expires within `relogin_minutes`, the
   server keeps the pending URL and POST in `sesx<g>.dat`, sends `challenge.relogin.html`, and
   replays the request after a successful re-login.
3. **Customer inquiry:** `cust_inquiry.htm` form (`Cust_ID`, `Cust_Dest`) →
   `FNDISPLAY_CUST` → FileIO `customer`, `restore search>=` on key 1 (customer + type + destination;
   the handler fixes the type to `ST`) → `customer_list1.htm` head, one `customer_list2.htm` row
   per match with `^cust_id ^dest ^name ^contact ^phone` replaced, `customer_list3.htm` foot → sent
   as one response.
4. **Comments:** `add_comment.html` posts to `fnSaveComment` → FileIO `write` to `comments.ind` →
   303 redirect to `thank_you.html`. `home.html` → `fnViewComments` → HTML list built with `webform`.

## Server functions handlers may call

`FNSEND_PAGE(url$; MAT args$, MAT repl$)` (only 3 parameters are meaningful; the 4th and 5th
are scratch locals), `FNSEND_STRING`, `FNSEND_OBJECT`, `FNAUTHENTICATE`, `FNAUTHORIZE`, and the
JSON group (`FNPUT/GET/DELETE/INSERT/APPEND_JSON`, `FNPARSE/COMPILE_JSON`, and the `*_OBJECT`
variants). Their signatures are in `web_server.br.brs` lines 08060-19160.

## Gotchas

- An ini `library=` line **without `retain`** is linked with `LIBRARY RELEASE`, which clears that
  library's variables after each function call
  ([library-facility](../br_tree/50-libraries/library-facility/spec.md)). So flags such as
  `cust_inq`'s `CUSTOMERFILE` and `LINKAGEESTABLISHED` start at 0 on every request. Only
  `sample.br` is registered with `retain`.
- `customer` layout version and positions: see [`DATA-MODEL-NOTES.md`](DATA-MODEL-NOTES.md).
- Logs: `weblog.txt` (HTTP engine), `webdebug.txt` (server debug, rewritten every run),
  `brlog.txt` (BR, level 9).
