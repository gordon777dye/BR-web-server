---
title: Web integration (BR as web server)
file: spec.md
source: §Web Integration; br_tree Connecting_to_browsers_online_Tutorial folded in (2b)
category: 60-integration
subcategory: 60-integration/web
kind: spec
status: 2b           # reference base + br_tree enrichment (BR-as-webserver model); PHP-bridge model removed 2026-07-03; no source conflicts
related: [json-datastore, screenio]
keywords: [WEB_SERVER12, WebForm, HTTP, web-server, BR_FUNC]
---

# Web integration

Running BR programs as the backend of a website: BR's own **`WEB_SERVER12.BR`** serves the pages, a
page names a BR function via a `?BR_FUNC=…` URL, and the **WebForm** library builds the HTML. A BR
program can also reach *out* to web pages/services as an HTTP client — see [Outbound](#http-client).

JSON/data-store services are in [json-datastore](../json-datastore/spec.md).

## BR as web server (`WEB_SERVER12` + WebForm)

<a id="webserver"></a>
### Architecture & the `.ini`
Three parts: the **HTML page** → BR's **`WEB_SERVER12.BR`** (run/restart it after program changes;
errors beep with the error & line number) → your **BR program** (whose functions the server calls).
Point the server at your program via its `.ini`:
```
url_base=www
logfile=weblog.txt
debugfile=webdebug.txt
library=websample.br,functions=fnfirstpage,fntheysavedit
```
Pages, images and CSS live in the `www` folder; `index.html` is the entry page; browse `LOCALHOST`.

<a id="br-func"></a>
### Calling BR from the page — `?BR_FUNC=`
A form or link names a BR function via a **`?BR_FUNC=fn…`** URL (the `?` is required):
```html
<form action="?BR_FUNC=fnTravelSurvey" method="get">      <!-- GET (default, visible) / POST (more secure) -->
   <input type="text" value="name" name="namefield" cols="20">
   <input type="submit" value="Click to Record">
</form>
<a href="?BR_FUNC=fnThankYouPage">Thanks page</a>
```

<a id="webform-program"></a>
### The BR side — WebForm library
The called function is a `DEF LIBRARY` that receives the form's field names and values as two arrays:
```business-rules
00100 DEF LIBRARY FNTRAVELSURVEY(MAT KEYS$, MAT VALUES$)
00200   LIBRARY "webform": FNBUILDSUBSLIST, FNHTML, FNHEADING, FNFOOTER, FNSEND
00210   LET FNREQUESTSUBS(MAT KEYS$)             ! map field names → R_<name> subscripts
00220   IF R_NAMEFIELD THEN LET NAME$ = VALUES$(R_NAMEFIELD)
00300   LET FNHEADING("Thank You")
00310   LET FNHTML("<h1>Thank You</h1>")
00320   LET FNHTML("<p>Recorded " & NAME$ & ".</p>")
00330   LET FNFOOTER : LET FNSEND
00400 FNEND
```
`fnRequestSubs` (built on `fnBuildSubsList` with an `"R_"` prefix) turns the incoming field names
into usable `R_<name>` subscripts into `MAT VALUES$`. Output is composed with the WebForm helpers —
`fnHeading` / `fnHTML` / `fnFooter` / `fnSend` — instead of raw `PRINT`. Full worked walkthrough:
[Connecting_to_browsers_online_Tutorial](Connecting_to_browsers_online_Tutorial.md).

<a id="security"></a>
### Security
- **Escape user output** — HTML-encode (`&`→`&amp;`, `<`→`&lt;`, …) before emitting user data.
- **Validate input** and **check authentication** before acting on a request.
- Keep business logic in BR, presentation in HTML/CSS; use the FileIO library for data.

<a id="http-client"></a>
## Outbound — BR as an HTTP client (`HTTP=CLIENT`)
The inverse of the model above: a BR program can *call* a web page/service by opening a DISPLAY file
with `HTTP=CLIENT` (a curl-backed client). The required sequence is **OPEN → optional `PRINT`(s) →
`LINPUT`**: `NAME=<full URL>`, optional `CONTROL=<display file>`; each `PRINT` accumulates POST data
(the first `LINPUT` then POSTs it and buffers the response; with **no** `PRINT` it does a GET), and
`LINPUT` reads until EOF or the next `PRINT` (which clears the buffer). Out-of-order use errors.
Control statements (case-insensitive) include `USER-AGENT`, `REFERER`, `COOKIE-OUT`/`COOKIE-FILE-IN`,
`DATA <file>` (url-encoded form body; `@file` reads it), `HEADER`, `DUMP-HEADERS`, `HEAD`,
`SSLV2`/`SSLV3`, and `RESULTS` (logs `http_code`, `time_total`, `size_download`, …).
`FILE$(fileno,"HTTPINFO")` returns log info for the last action. Full reference:
[HTTP=CLIENT](HTTP=CLIENT.md). (The `OPEN` mechanics are in
[30-io-file/statements](../../30-io-file/statements/spec.md#open).)

<a id="examples"></a>
## Examples

```business-rules
! HTML-escape helper for user data placed into a page
96100 DEF FNHTML$(X$)
96110    LET X$ = SREPLACE$(X$,"&","&amp;") : LET X$ = SREPLACE$(X$,"<","&lt;")
96160    LET FNHTML$ = X$
96170 FNEND
96200 LET FNHTML("<p>Welcome, " & FNHTML$(NAME$) & "</p>")
```

<a id="see-also"></a>
## See also

- [json-datastore](../json-datastore/spec.md) — JSON/object services for web responses
- [50-libraries/screenio](../../50-libraries/screenio/spec.md) — the GUI alternative to web (and the PhpIO web deployment for ScreenIO)
- [30-io-file/statements](../../30-io-file/statements/spec.md#open) — `HTTP=CLIENT`; FileIO reads for dynamic content
- [10-language/flow-control/functions-udf](../../10-language/flow-control/functions-udf/spec.md) — `DEF FN` helpers (escaping, auth)
- Backing keyword pages: [Connecting_to_browsers_online_Tutorial](Connecting_to_browsers_online_Tutorial.md) (worked example),
  [HTTP=CLIENT](HTTP=CLIENT.md) (outbound HTTP client — relocated from client-server)
