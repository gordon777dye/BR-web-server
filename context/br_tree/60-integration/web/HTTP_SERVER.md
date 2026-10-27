---
title: HTTP=SERVER — BR's built-in web server
file: HTTP_SERVER.md
category: 60-integration
subcategory: 60-integration/web
kind: reference
related: [HTTP=CLIENT, Open Display, FILE$, web]
keywords: [HTTP=SERVER, HTTPS, CONFIG HTTP, CONFIG HTTPS, PAGE-URL, POST-VAR, PAGE-FLUSH, REDIRECT-TO, URL_BASE, CERT, PHRASE, "CHUNK=", "PROXY=", "BIND=", "THREADS=", BR_NODE, X-Forwarded-For, reverse proxy, NGINX]
corrections:
  - "Rewritten 2026-10-22 against the BR 5.0 source (br/brs/http.cpp, bopen.cpp, config.cpp, strfunct.cpp, primop1b.cpp) and its test runs, replacing a version written from GoAhead-era source. Changed: the read timeout is the LINPUT's WAIT=, or the OPEN's WAIT= (default 15 s) when the LINPUT has none; URL_BASE= and CERT= take an operating-system path or a BR path; OPTION 66 is the passphrase when PHRASE= is not given; a renewed certificate is used without a restart; error 757 is not raised; response framing, HEAD and PAGE-FLUSH streaming added."
  - "2026-10-26: brought current with web_server.br 2.17 (was 2.03), checked against its source. It writes one header block per response (2.03 followed every page with an empty one) and corrects the Content-Length of page files that bring their own headers; its HTTPS redirect drops the request's port and adds the HTTPS port unless 443, none behind a proxy (2.03 kept the plain-HTTP port); sessions, relogin data and the data store are on disk, so a proxy needs no stickiness for logins and a restart loses nothing (2.03 held sessions in memory); a urlencoded body is split before decoding, and a JSON body is passed whole. History: brweb's old\\CHANGE_LOG.md."
---
# HTTP=SERVER — BR's built-in web server

A BR program becomes a web server by opening a DISPLAY file with `HTTP=SERVER`. BR runs the
server on its own threads. It serves static files by itself, and queues every request meant for
the program until the program reads it. `WEB_SERVER.BR` (`web_server.br.brs`, version 2.17) is
the standard program written to this interface. This page documents the interface between such
a program and BR, how to set up HTTPS, and how to run several BR processes behind a reverse
proxy (§4).

The server is **CivetWeb**, built into `brserver`.

---

<a id="setup"></a>
## 1. Configuration directives

Two config directives (in `brconfig.sys`, or run with `EXECUTE "CONFIG …"` before the `OPEN`)
set up the server. They are parsed by the same code:

```bnf
HTTP  <port>[-<last>] [LOG=<file>] [URL_BASE=<dir>|NONE] [CERT=<basename>] [PHRASE=<passphrase>]
                     [PROXY=<address>[,<address>...]] [BIND=<address>] [THREADS=<n>]
HTTPS <port>[-<last>] (the same keywords)
```

| Item | Meaning |
|---|---|
| `<port>` | `HTTP` sets the plain port (default **80**). `HTTPS` sets the TLS port (default **443**) **and turns HTTPS on** - without an `HTTPS` line there is no TLS listener. |
| `-<last>` | A range of up to 100 ports: the server takes the first one free, so several BR processes can start from one configuration (§4). All taken: **752**. |
| `LOG=` | Server log file, as a **BR name** (resolved through `DRIVE`). See [§3.2 step 5](#tls-steps) for what it records. |
| `URL_BASE=` | Document root for static files: an operating-system path, or a BR path, which is resolved through the `DRIVE` mapping when it is not a directory as written (`web_server.br` passes a BR path). Default: `web`, in BR's working directory. |
| `CERT=` | Base name of the certificate pair: `<basename>.crt` and `<basename>.key` (§3). An operating-system path or a BR path, as for `URL_BASE=`. Required with `HTTPS`. |
| `PHRASE=` | Passphrase for an encrypted `.key`. Quote it if it contains spaces (`web_server.br` always quotes it). When there is no `PHRASE=`, the `OPTION 66` value is used. |
| `URL_BASE=NONE` | No static files at all: every request not meant for the program gets **404**. For a site whose proxy serves the files (§4). |
| `PROXY=` | The IP address of a local reverse proxy such as NGINX, or several separated by commas, written as numbers (`127.0.0.1`). Only requests from these addresses have their `X-Forwarded-*` headers believed (§4.1). |
| `BIND=` | Listen on this one numeric address (IPv4, or IPv6 without brackets) instead of on all of them. |
| `THREADS=` | The most worker threads the server starts, 1 to 1000; default **50**. Each connection being served, and each request waiting for the program, holds one. |

Rules:

- **Any order.** The keywords may be written in any order. A word the directive does not know
  makes the line a configuration error.
- **The values are global.** Both directives set the same settings, so they can go on either
  line. The ports are separate. A `[WSID]` in `LOG=` gives each BR process its own log.
- **They take effect when the first `HTTP=SERVER` OPEN starts the server.** It then keeps
  running until BR exits. Closing the file does not stop it, and later `CONFIG HTTP`/`HTTPS`
  changes are ignored until BR restarts. `web_server.br` says the same: "BR must be restarted to
  effect port or https changes."
- **With HTTPS on, both ports listen**: the HTTP port (80 unless set) and the HTTPS port. There
  is no HTTPS-only setting.

---

<a id="interface"></a>
## 2. The program interface

### 2.1 Statements

| Statement | Effect |
|---|---|
| `OPEN #n: "NAME=<any>, HTTP=SERVER [, AUTH] [, RECL=<n>] [, EOL=NONE] [, WAIT=<sec>] [, CHUNK=<bytes>]", DISPLAY, OUTIN` | Starts the server the first time it is opened, then attaches channel `#n` to the request queue. `NAME=` is required syntax but names nothing; both programs use `name=http_file`. The file must be `DISPLAY`. |
| `LINPUT #n: POST$` (also `INPUT #n:`) | First sends the **previous** request's response, if one is pending. Then it waits for the next queued request, makes it the channel's current request, and returns its body. |
| `PRINT #n: X$` | Appends to the current request's response. Nothing is sent until the next read, a `PAGE-FLUSH`, or `CLOSE` - or, with `CHUNK=`, until a chunk's worth has been printed. |
| `FILE$(n, "<keyword>")` | Reads facts about the current request, or acts on it. See §2.3. |
| `CLOSE #n:` | Sends any pending response. The server keeps running. |

OPEN options that matter:

| Option | Effect |
|---|---|
| `AUTH` | "Authentication mode". Every request, including static files, is queued to the program, not only `?BR_FUNC=` requests. The one exception is `/.well-known/acme-challenge/`, which is always served as a file (§3.2 step 8). `web_server.br` opens with `,auth` unless its INI says `NOLOGIN`, and then serves files itself. |
| `RECL=` | Size of each piece a read takes from the request body. Both programs use `RECL=32000`. A `LINPUT` into a large enough string returns a whole 100,005-byte body in one statement. |
| `EOL=NONE` | Used by both programs, so a `PRINT` adds no line ending and the program controls every byte. |
| `WAIT=` | **How long a read waits for a request** before it fails with error **4145**, unless the read gives its own. Default **15** seconds. `WAIT=0` fails at once when nothing is queued. A `WAIT=` written on the `LINPUT` or `INPUT` statement (`linput #1,wait=300:`) overrides it for that read: `WAIT=0` fails at once, and a negative `WAIT=` (`wait=-1`) waits until a request comes. |
| `CHUNK=` | **Streams large responses in pieces of this many bytes** (256 to 16,777,216). Once that much has been printed and not sent, it is sent as if by `PAGE-FLUSH`, and a program that gets more than four chunks ahead of a slow client waits in `PRINT` until the client catches up - so a page of any size takes only a few chunks of memory. See §2.5. Given on a file that is not `HTTP=SERVER`, or out of range: error **0605**. |

Only **one** channel through one port may hold `HTTP=SERVER` at a time. A second OPEN on any port by the same BR, or an OPEN on the same port by another BR session gives error **740**.

<a id="routing"></a>
### 2.2 Which requests reach the program

- A request whose URL contains `?BR_FUNC=` (any case) is queued for the program. With `AUTH`,
  every request is.
- Everything else is answered by the server **from `URL_BASE=`, without the program**:
  - files are sent with an `ETag` and `Last-Modified`, and `Cache-Control: max-age=1`, so a
    browser revalidates them and an unchanged file answers **304** - a file deployed to
    `URL_BASE=` is seen at once;
  - a directory gives **403**, not a listing; a missing file **404**;
  - `/../` cannot escape the root;
  - no CORS headers are sent, so another site's scripts cannot read these files from a
    visitor's browser.
- The program answers **one request at a time**. The others queue behind it, and static files
  are still served while the program is busy.
- The server has 50 worker threads, and each request waiting for the program holds one, so a
  long queue leaves fewer for static files.

<a id="file-inquiries"></a>
### 2.3 `FILE$(n, keyword)` on an HTTP=SERVER channel

All of these refer to the **current** request, the one the last read returned. Keywords are
case-insensitive.

| Keyword | Returns |
|---|---|
| `"PAGE-URL"` | The request target, path and query, **upper-cased** and still %-encoded: `/APP?BR_FUNC=FNECHO&NAME=JOHN%20SMITH`. Query-string values therefore arrive in upper case; a POST body and `POST-VAR-` values keep their case. On an upload, `&uploadfile=<path>` is appended (§2.6). |
| `"POST-VAR-<name>"` | A decoded form variable, from the query string, a urlencoded body, or a multipart form. The name keeps its case (`POST-VAR-name`). A name given more than once has its values joined with a space. Also answers CGI-style names: `REQUEST_METHOD`, `QUERY_STRING`, `CONTENT_TYPE`, `CONTENT_LENGTH`, `REMOTE_ADDR`, `REMOTE_USER`, `AUTH_TYPE`, `SERVER_PORT`, `SERVER_PROTOCOL`, and every request header as `HTTP_<NAME>` (`POST-VAR-HTTP_USER_AGENT`). |
| `"METHOD"` | `GET`, `POST`, `HEAD`, … |
| `"PROTOCOL"` | `http` or `https`, in lower case. `web_server.br` compares it `== "http"`. Behind a trusted proxy, what the proxy received (`X-Forwarded-Proto`). |
| `"HOST"` | The `Host` header, as the client sent it (with the port, if any). Behind a trusted proxy, `X-Forwarded-Host` when it is sent. |
| `"PAGE-COOKIE"` | The raw `Cookie` header. |
| `"REFERRER"` | The `Referer` header. |
| `"CLIENT-IP"` | The client's address. Behind a trusted proxy (`PROXY=`), the real client's address from `X-Forwarded-For` (§4.1). |
| `"CONTENT-TYPE"` | The request's `Content-Type`. |
| `"PAGE-AUTH"` | `user:password` from HTTP Basic authorization (at most 50 and 100 characters), or `""`. A password may contain `:`. |
| `"PAGE-FLUSH"` | **Action.** Sends what has been printed so far, without ending the response (§2.5). Returns nothing useful: call it as `LET X$ = FILE$(n,"PAGE-FLUSH")`. |
| `"REDIRECT-TO-<url>"` | **Action.** Answers the request with **302** `Location: <url>`. Text printed and not yet flushed is dropped. Returns `""`. |
| `"HTTPINFO"` | Client channels only. On a server channel: error **744**. |

On a channel that is not `HTTP=SERVER` these raise **742**. With no current request they raise
**746**.

<a id="request-body"></a>
### 2.4 Reading a request

- A request with **no body** (a typical `GET`) is still made current by the read. The read
  itself ends with **error 4270 (EOF)**, so the program treats 4270 as "request received" and
  goes on to `FILE$(n,"PAGE-URL")`. Both programs do this.
- A request with a body returns the raw body, still urlencoded, to `LINPUT`. Use `POST-VAR-` for
  decoded values. A chunked request body arrives reassembled. `web_server.br` splits a urlencoded
  body (and the query string) on `&` and `=` first, then decodes each name and value, so an
  encoded `&` is data. It passes a body with `Content-Type: application/json` on whole.
- Reads after the body is used up keep returning 4270. The **next** request is not fetched until
  the program has printed something or closed the channel, so answer every request.
- A body over **64 MB** is refused with **413** before the program sees it. A request that
  carries both `Transfer-Encoding` and `Content-Length` (a request-smuggling technique) is
  refused with **400**.

<a id="response"></a>
### 2.5 Writing a response

**The program writes the HTTP status line and headers itself**, and the bytes go out as written.
`web_server.br` writes `HTTP/1.1 200 OK`, `Content-Type`, `Content-Length` and the rest, then a
blank line, then the body. The server adds only what keeps the connection usable:

| What the program wrote | What the client receives |
|---|---|
| Headers with a `Content-Length` | As written. **Nothing past that length is sent** - the server log notes `<n> bytes written past the Content-Length of <url> were not sent`. |
| Headers without a `Content-Length` | The server adds one. |
| No status line and no headers | A `200` page with `Content-Type: text/html` and a length. For anything else - JSON, another status, cookies, cache control - write the headers yourself. |
| Anything, to a `HEAD` request | The headers only. |

`web_server.br` writes one header block per response. A page file that begins with its own
status line and headers (its redirect page and login challenges) is sent with its
`Content-Length` set to the length of its body as sent, after the `^placeholder` replacements;
with no `Content-Length` in the file, the server adds one.

**Streaming with `PAGE-FLUSH`.** Without it, nothing goes out until the response is finished (at
the next read or `CLOSE`), so a page of any size is held whole and then sent with a length - a
6 MB page written in 200 `PRINT`s arrives byte for byte. `PAGE-FLUSH` sends what has been printed
so far, so the browser can show it at once - a progress line, the first rows of a long report:

- If the headers carry **no** `Content-Length`, the rest goes out as HTTP/1.1
  `Transfer-Encoding: chunked`, normally one chunk per `PAGE-FLUSH` of whatever was printed since
  the last one (two flushes close together may go as one chunk).
- If the headers carry a `Content-Length`, each flush is sent as it is, framed by that length.
- A client that speaks HTTP/1.0 cannot take chunks; it gets the whole response at the end, with a
  length.

**Large responses with `CHUNK=`.** `CHUNK=<bytes>` on the OPEN makes the flushing automatic:
each time that many bytes have been printed, they go to the client, with no `PAGE-FLUSH` in the
program. A response with no `Content-Length` then arrives as chunks of **exactly** that size, the
last one shorter; one with a `Content-Length` streams as written. A response smaller than one
chunk is unaffected - it is sent whole, with a length. If the client reads slowly, the program's
`PRINT` waits once more than four chunks are waiting, so memory stays at a few chunks however
large the page; a client that stops reading for 30 seconds is dropped, and the rest of the
response is discarded. Chunk size costs speed below a few KB: 40 MB took 10 s at `CHUNK=1000` and
under a second at `CHUNK=32768`. An HTTP/1.0 client still gets the whole response at the end.

```
open #1: "name=http_file,http=server,recl=32000,eol=none,chunk=32768", display, outin
```

Write **after** a request is current. Writing before the first read gives **716**, "HTTP
sequence error".

Connections are kept alive between requests, and closed after 500 ms idle.

<a id="uploads"></a>
### 2.6 File uploads

A `multipart/form-data` upload is saved by the server before the program sees the request:

- The file goes in `tmp`, under BR's working directory, which is created if missing.
- The stored name is the client's file name with any directory part removed, followed by the
  16-character session id from the request's `session="…"` cookie: `..\..\report.txt` with
  session `ABCDEFGHIJKLMNOP` is stored as `tmp/report.txtABCDEFGHIJKLMNOP`. Without such a
  cookie, nothing is appended.
- `&uploadfile=<stored path>` is appended to `PAGE-URL`, once per file.
- The other form fields are `POST-VAR-` values. The body `LINPUT` returns is empty.
- An existing file of the same name is replaced. A failed upload is recorded in the server log,
  and the request still reaches the program, without its `&uploadfile=`.

<a id="lifecycle"></a>
### 2.7 Other behaviour

| Situation | Behaviour |
|---|---|
| Client hangs up while the program works on its request | The server carries on, and the next request is answered normally. |
| The program ends, BR stays up | The server keeps running; queued requests wait for the next `HTTP=SERVER` OPEN. |
| BR exits with requests still queued | Each gets **503**. |
| Keyboard during a read | The wait polls the keyboard: an Fkey ends it early (error 4145), Break interrupts it. `web_server.br` uses `on fkey 93` to exit. |
| More client addresses than licences | Licences are counted per client IP address seen within 30 minutes. The count is the larger of the HTTP licence count and the BR user count. A further address gets **503** for every request, static files included. |

<a id="sequence"></a>
### 2.8 Typical sequence

```
00100    dim POST$*200000, URL$*4000, OUT$*32000, CRLF$*2, NAME$*200
00110    let CRLF$ = CHR$(13) & CHR$(10)
00120    execute "CONFIG HTTPS 443 LOG=web.log URL_BASE=C:\site\www CERT=C:\site\certs\server PHRASE=secret"
00130    open #(HF:=100): "name=http_file,http=server,recl=32000,eol=none,wait=300", display, outin ioerr Open_Failed
00140 Main: let POST$ = ""
00150    linput #HF: POST$ error Read_Err                ! sends the previous answer, waits for the next request
00160 Have_Request: let URL$ = FILE$(HF, "PAGE-URL")   ! upper-cased, still %-encoded
00170    let NAME$ = FILE$(HF, "POST-VAR-name")          ! decoded; query or form body
00180    let OUT$ = "<html><body>Hello " & NAME$ & "</body></html>"
00190    print #HF: "HTTP/1.1 200 OK" & CRLF$ & "Content-Type: text/html" & CRLF$ & "Content-Length: " & STR$(LEN(OUT$)) & CRLF$ & CRLF$ & OUT$
00200    goto Main
00210 Read_Err: if ERR = 4270 then goto Have_Request ! a request with no body
00220    if ERR = 4145 then goto Main                 ! no request within the WAIT=
00230    print "HTTP read error "; ERR : close #HF: : stop
00240 Open_Failed: print "HTTP=SERVER open failed "; ERR : stop
```

This is the shape `web_server.br` and the test program `httpsrv.brs` follow. The example itself
passes `brls -check -sema` but has not been run.

<a id="errors"></a>
### 2.9 Errors

| Code | Meaning |
|---|---|
| 0716 | HTTP sequence error: a write with no current request |
| 0740 | The HTTP server is already running (a second `HTTP=SERVER` OPEN) |
| 0742 | Request not valid because this is not an HTTP server |
| 0744 | Request not valid because this is not an HTTP client (`HTTPINFO` on a server channel) |
| 0746 | HTTP server not responding to active inquiry (`FILE$` with no current request) |
| 0750 | Could not start HTTP server - the reason is in the server log: a certificate or key that will not load, a wrong passphrase, `HTTPS` without `CERT=` |
| 0752 | Could not bind to HTTP port - another program has it, or every port of a range is taken |
| 0754 | Failed to process path information for the http server log file |
| 0756 | Failed to open the http server log file |
| 0415 | Bad `FILE$` information type (an unknown keyword) |
| 4145 | No request arrived within the read's `WAIT=`, or the OPEN's when the read has none |
| 4270 | End of file: the current request's body is used up, or it had none |
| 9990 | This version was made without HTTP support. Also returned when there is no HTTP licence |

`STATUS LICENSE` lists the HTTP licence.

---

<a id="tls"></a>
## 3. Setting up TLS (HTTPS)

### 3.1 Prerequisites

| Need | Detail |
|---|---|
| A BR with HTTP support and licence | Without them the OPEN fails with 9990. |
| A certificate file, `<basename>.crt` | PEM. The **server certificate first, then its intermediate certificate(s)**, in one file - what certificate authorities call the *full chain* (certbot's `fullchain.pem`). BR sends the whole chain; browsers need the intermediates, and most refuse a server that sends only its own certificate. |
| A private key file, `<basename>.key` | PEM, beside the `.crt` and with the same base name. RSA or EC (ECDSA), encrypted or not. BR checks that it belongs to the certificate. |
| The passphrase, if the key is encrypted | `PHRASE=`, or the `OPTION 66` value when there is no `PHRASE=`. |
| Names the certificate covers | `subjectAltName` must include the host name clients use. |
| Free ports | The HTTPS port and the HTTP port, because both listen (§1). A port in use gives 752. |
| A client that supports TLS 1.2 or 1.3 | TLS 1.0 and 1.1 are refused. TLS 1.3 is used when the client offers it. |

<a id="tls-steps"></a>
### 3.2 Steps

1. **Get the certificate and key.** From a certificate authority: the server certificate, its
   intermediate(s), and the private key - or automatically from Let's Encrypt (step 8). A
   certificate delivered as a `.pfx` / `.p12` converts with OpenSSL:

   ```
   openssl pkcs12 -in site.pfx -nokeys -out server.crt     # certificate and chain
   openssl pkcs12 -in site.pfx -nocerts -out server.key    # key, encrypted: set PHRASE=
   ```

2. **Build the two files.** Concatenate the server certificate and its intermediate(s), in that
   order, into `<basename>.crt` (on Windows: `copy /b site.crt + ca-bundle.crt server.crt`). Save
   the key as `<basename>.key`. If the key is encrypted, note the passphrase.
3. **Configure BR**, in the config or with `EXECUTE` before the OPEN:

   ```
   HTTP  80
   HTTPS 443 LOG=web\httpserver.log URL_BASE=C:\site\www CERT=C:\site\certs\server PHRASE=<passphrase>
   ```

   Keep the keyword order (§1).
4. **Open the channel** in the serving program (§2.1). The server starts here, so a certificate
   or key that will not load shows up as a failed OPEN: **750**.
5. **Check the log** given by `LOG=`. A good start writes:

   ```
   HTTPS certificate /CN=<subject>, issued by /CN=<issuer>, expires <date>, with <n> chain certificate(s)
   HTTP server started on <http-port>,<https-port>s serving <document root>
   ```

   - `with 0 chain certificate(s)` means the intermediates were left out of `<basename>.crt`.
   - A certificate expiring within 14 days, or already expired, is reported here and in the BR
     log.
   - A failure names its cause, e.g. `cannot read private key … (wrong PHRASE= or OPTION 66?)`.
   - At log level 10 the log also records every request.
6. **Test from a client**, checking the chain and the name, not just the connection:

   ```
   openssl s_client -connect <host>:443 -servername <host> -showcerts
   ```

   Every certificate of the chain should be listed, and `Verify return code: 0 (ok)`.
7. **Redirect plain HTTP if you need to.** BR does not do it for you. `web_server.br` does it
   itself when login is required (`FILE$(n,"PROTOCOL") == "http"`): it sends a page that
   redirects (`303`) to `https://` + `FILE$(n,"HOST")` without its port + the HTTPS port (the
   first `PORT=`, left out when it is 443) + the URL. Behind a proxy it adds no port, which means
   the proxy's 443. A program of your own can use
   `FILE$(n,"REDIRECT-TO-https://…")`.
8. **Plan renewal.** Replace the `.crt` and `.key` files; **no restart is needed**. At most once a
   minute, during a connection, BR checks whether either file has changed, and loads and checks
   the new pair for every connection after that. A pair caught half-written is not used - the
   previous certificate stays in service and the next check tries again. A renewal may change the
   key type (RSA to EC or back).

   Let's Encrypt validates over plain HTTP on **port 80**, by fetching
   `/.well-known/acme-challenge/<token>` from the site. That path is always served from
   `URL_BASE=` as a file, even in `AUTH` mode, so an ACME client using the webroot method works:

   - **Windows**: [win-acme](https://www.win-acme.com/) with filesystem validation pointed at
     `URL_BASE=`, and its PEM files store; have its post-renewal script copy the
     certificate-with-chain to `<basename>.crt` and the key to `<basename>.key`.
   - **Linux**: `certbot certonly --webroot -w <URL_BASE> -d <host>`, with a deploy hook that
     copies `fullchain.pem` to `<basename>.crt` and `privkey.pem` to `<basename>.key`.

### 3.3 Using `web_server.br`

`web_server.br` builds the `CONFIG HTTPS` line itself from `Web_Server.INI` (line 3540). With a
`PROXY=` line it builds a `CONFIG HTTP` line instead and needs no certificate (§4.2):

```
URL_BASE= <BR path of the site>
PORT= 443                      ! the HTTPS port (default 443)
PORT= 80 HTTP                  ! optional: runs CONFIG HTTP 80
CERT= certs\server             ! required, except behind a proxy; the program stops without it
LOGFILE= httpserver.log        ! becomes LOG=
```

Notes:

- **Passphrase file.** The key passphrase is kept in `<CERT base>.phrase`, an INTERNAL file
  holding the passphrase as `ENCRYPT$(phrase, "keY_phrase_key")`, and passed on as `PHRASE=`. If
  the file does not exist, `web_server.br` asks for the passphrase at the console and writes the
  file. The key `"keY_phrase_key"` is a constant in the program source. **Anyone with the source
  can decrypt the `.phrase` file, so protect it like the key itself.**
- **`CERT=` is used twice**: by `web_server.br` as a BR name for the `.phrase` file, and by the
  server for the `.crt`/`.key` pair. A relative name works for both when BR's start folder is its
  working directory, as in a normal install.
- **Other files.** It reads `filetypes.txt` (a `mime-type,.ext` line per file type) from its start
  folder, and stops without it.
- **Version and workstack.** `web_server.br` requires `WBVERSION$ >= "4.32g"` and a workstack of
  at least 500,000. It stops otherwise.

---

<a id="proxy"></a>
## 4. Behind a reverse proxy (several BR processes)

One BR process answers one request at a time, so a page that needs 50 ms of BR caps a process at
about 20 pages a second. A site that needs more runs **several BR processes behind a reverse
proxy** (NGINX here). The proxy serves the static files and the HTTPS, and passes `?BR_FUNC=`
requests to the BR processes. A site that does not need this changes nothing.

There are 2 distict modes of operation... LOGIN which uses web_server.br's 
authentication - somewhat slower, and NOLOGIN which is considerably faster and 
is served prdominately by NGINX or another proxy.

### 4.1 BR's settings

Every BR process starts from the same configuration:

```
HTTP 8081-8084 BIND=127.0.0.1 PROXY=127.0.0.1 URL_BASE=NONE LOG=httpserver[WSID].log
```

| Keyword | Effect |
|---|---|
| `8081-8084` | Each process takes the first free port of the range. When all are taken, the OPEN fails with **752**. |
| `BIND=127.0.0.1` | Listen on that address only, so nothing reaches BR except through the proxy on the same machine. |
| `PROXY=127.0.0.1` | The proxy's address (several: comma-separated). For a request **from that address**, `FILE$` `"CLIENT-IP"` is the real client - the last `X-Forwarded-For` entry, the one the proxy added - `"PROTOCOL"` is `X-Forwarded-Proto`, and `"HOST"` is `X-Forwarded-Host` (else `Host`). The HTTP licences are counted by the real client too. From any other address those headers are ignored, since any client can send them. |
| `URL_BASE=NONE` | BR serves no files: any request not meant for the program gets **404**. The proxy serves them. |
| `[WSID]` in `LOG=` | One server log per process. |

**Each answer names its process.** When a request came through the proxy, BR adds
`Set-Cookie: BR_NODE=<port>; Path=/; HttpOnly; SameSite=Lax` (`; Secure` behind HTTPS) to the
response, unless the request already carries that cookie. The proxy routes on it, so a browser
keeps reaching the process that answered it first. `web_server.br` does not depend on this: it
keeps each session on disk (`sessions\sess<g>.dat`), with its relogin data (`sesx<g>.dat`) and its
data store (`sesd<g>.dat`), and holds nothing in memory between requests. So any process can
answer any request of a session, and a process that restarts loses no logins and no stored
objects.

### 4.2 `web_server.br` behind a proxy

`web_server.br` issues the line above itself when `Web_Server.INI` has a `PROXY=` line:

```
URL_BASE= <BR path of the site>
PROXY= 127.0.0.1                 ! proxy mode: the proxy's address
PORT= 8081-8084                  ! the range (8081-8084 if not given)
BIND= 127.0.0.1                  ! optional; 127.0.0.1 if not given
LOGFILE= httpserver[WSID].log    ! one log per process
DEBUGFILE= webdebug[WSID].txt
```

No `CERT=` is needed and no `.phrase` file is read: the proxy serves HTTPS. Start the same
`web_server` as often as the range has ports, all from the same folder; each keeps its work files
apart (`web_server<wsid>.tmp`), and they share the sessions in `sessions\`. Its HTTPS redirect
works unchanged, because `"PROTOCOL"` reports what the proxy received. It names no port, so it
assumes the proxy serves HTTPS on 443.

**With login, the proxy must not serve the site's files.** `web_server.br` with login (`,AUTH`)
checks the session before every page, files included; a proxy that serves files directly skips
that check. So a `NOLOGIN` site has the proxy serve every file, and a site with login sends every
request to BR except a folder of public assets.

### 4.3 NGINX

The essential part of the NGINX configuration (a complete template, with the login variant and
the port-80 ACME server, is `br/docs/nginx-br.conf` in the BR source):

```nginx
map $args $to_br {                    # requests meant for BR: BR_FUNC= in the query, any case
    default           0;
    "~*(^|&)br_func=" 1;
}
map $cookie_BR_NODE $br_backend {     # back to the process that answered before
    default br_app;                   # no cookie yet, or an unknown value
    8081    127.0.0.1:8081;
    8082    127.0.0.1:8082;
}
upstream br_app {
    least_conn;
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;
}
server {
    listen 443 ssl;
    ssl_certificate     /etc/ssl/site/fullchain.pem;
    ssl_certificate_key /etc/ssl/site/privkey.pem;
    root C:/site/www;                 # the folder URL_BASE= names
    client_max_body_size 64m;         # BR's own limit

    location / {                      # NOLOGIN: NGINX serves the files
        error_page 418 = @br;
        if ($to_br) { return 418; }   # a location cannot match a query string
        try_files $uri $uri/ =404;
    }
    location @br {
        proxy_pass http://$br_backend;
        proxy_http_version 1.1;       # lets BR answer chunked
        proxy_set_header Host              $http_host;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $http_host;
        proxy_read_timeout 300s;
    }
}
```

- **List every BR port in the `map`.** A `BR_NODE` value not listed falls back to the upstream,
  so a forged cookie cannot reach anything else on the machine.
- **Protected downloads**: the program checks the login and answers with the header
  `X-Accel-Redirect: /protected/<name>`; NGINX sends the file from a `location /protected/
  { internal; alias <folder>/; }`, which no URL reaches directly.
- **Streaming**: NGINX holds a BR answer and feeds a slow browser itself, which frees BR sooner.
  A page that streams with `PAGE-FLUSH` sends `X-Accel-Buffering: no` to be passed on at once.
- **Certificates** are NGINX's (certbot, win-acme); BR's `CERT=` is not used in this setup.
- **NGINX on Windows** is documented by nginx.org as beta quality (`select()` only, "high
  performance and scalability should not be expected"). A BR site is limited by BR long before
  that. Run NGINX and each BR process as services that restart on failure (`winsw`, `nssm`, or
  systemd on Linux).
- **Seats**: each BR process is a session with its own WSID.

Tested on Windows with NGINX 1.30.6: two BR processes and two `web_server.br` processes from one
configuration each, over HTTP and NGINX's HTTPS. The login flow itself has not been run through
the proxy.

---

<a id="see-also"></a>
## See also

- [web](spec.md): the WEB_SERVER12/WebForm model and `?BR_FUNC=` dispatch.
- [HTTP=CLIENT](HTTP=CLIENT.md): the outbound side; `FILE$(n,"HTTPINFO")`.
- [json-datastore](../json-datastore/Json.md): `web_server.br`'s data store and headers.
- [4.30 release notes](../../90-reference/limits-constants/4.30.md) and
  [Encryption](../../10-language/data-manipulation/system-functions/Encryption.md): the short
  `CONFIG HTTPS` summary, with a command for a self-signed test certificate.
- Test bed: `context\scratch\http\` (`httpsrv.brs`, `httptest.py`, `makecerts.py`,
  `brconfig.http`, `brconfig.https`, `ws\`; behind NGINX, `proxy\` and `wsproxy\`).
