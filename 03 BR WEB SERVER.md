# BR WEB_SERVER

This document describes **web_server 2.06** running on the BR 5.00 build supplied with it
(`brserver-500-x64-Release-2026-10-24.exe`). Some details, especially certificate handling and
the reverse-proxy settings, depend on that build's HTTP engine.

The Web Server program acts as a complete web server. No other program is required to serve web
pages, run your BR functions, and handle HTTPS and user logins. For higher volumes, several copies
of the Web Server can run behind a reverse proxy such as NGINX. The proxy then handles HTTPS and
static files and shares the BR requests among the BR sessions.

## Contents

- [1. Choosing a configuration](#1-choosing-a-configuration)
- [2. Capacities](#2-capacities)
- [3. Web_Server.INI reference](#3-web_serverini-reference)
- [4. Configuration 1: stand-alone HTTPS server](#4-configuration-1-stand-alone-https-server)
   - [4.1 Get a certificate](#41-get-a-certificate)
   - [4.2 Install it and point the INI at it](#42-install-it-and-point-the-ini-at-it)
   - [4.3 Give the passphrase on the first start](#43-give-the-passphrase-on-the-first-start)
   - [4.4 Ports and firewall](#44-ports-and-firewall)
   - [4.5 Renewal](#45-renewal)
   - [4.6 Check it](#46-check-it)
   - [4.7 Run it as a service](#47-run-it-as-a-service)
- [5. Configuration 2: behind a reverse proxy (NGINX)](#5-configuration-2-behind-a-reverse-proxy-nginx)
   - [5.1 What it needs](#51-what-it-needs)
   - [5.2 Web_Server.INI](#52-web_serverini)
   - [5.3 Start the BR processes](#53-start-the-br-processes)
   - [5.4 nginx.conf](#54-nginxconf)
   - [5.5 Certificates on NGINX](#55-certificates-on-nginx)
   - [5.6 What changes behind the proxy](#56-what-changes-behind-the-proxy)
   - [5.7 Check it](#57-check-it)
- [6. URL Processing](#6-url-processing)
- [7. HTML Parameters](#7-html-parameters)
- [8. FORM/POST Example](#8-formpost-example)
- [9. User Logins and Authentication](#9-user-logins-and-authentication)
   - [9.1 Sessions](#91-sessions)
- [10. Debug Log of Sample Application](#10-debug-log-of-sample-application)
- [11. Miscellaneous](#11-miscellaneous)

## 1. Choosing a configuration

| | 1. Stand-alone | 2. Behind a reverse proxy (NGINX) |
|---|---|---|
| Who talks to browsers | web_server.br, through BR's own HTTP engine | NGINX |
| Who holds the HTTPS certificate | BR (`CERT=` in `Web_Server.INI`) | NGINX (`ssl_certificate` in `nginx.conf`) |
| BR processes | one | one or more, all started from the same folder and `Web_Server.INI` |
| Ports BR listens on | 443 (HTTPS) and 80 (HTTP), on all addresses | a range such as 8081-8084, plain HTTP, on 127.0.0.1 only |
| Static files | served by BR | served by NGINX (`NOLOGIN` sites) or by BR (login sites) |
| Needs | BR 4.32g or later | web_server 2.06 and a BR build with `PROXY=`/`BIND=` support, such as `brserver-500-x64-Release-2026-10-24.exe` |

Start with configuration 1. A BR process answers one BR request at a time, so move to
configuration 2 when one process can no longer keep up. The sections below give the setup for
each.

## 2. Capacities

- The maximum web page or object size that web_server.br sends (other than file downloads) is
  4 MB. The maximum size of a data store object is also 4 MB. The Data Store supports duplicate
  keys provided they are subscripted (e.g. `object-name[3]`). This allows larger objects to be
  split into segments under the same key.
- The maximum URL length, including parameters, is 4096.
- The maximum POST data passed to your function is 100,000 bytes.
- The maximum keyword length is 100 bytes.
- The maximum value referenced by a keyword is 30,000 bytes.
- The maximum request size, uploaded files included, is 64 MB. Larger requests are refused by BR's
  HTTP engine with `413`. Behind NGINX, `client_max_body_size 64m` sets the same limit.

## 3. Web_Server.INI reference

If you simply run the Web Server without an INI file, it says that it needs one and lists what it
should contain:

```
Cannot Open Web_Server.INI
ERR = 4152    file not found
Required Statements:
  URL_BASE= site-full-BR-directory-path ( can be \. )
  CERT= cert-file-base-name
Optional Statements (each on a separate line):
  NOLOGIN
  PORT= https-port  |  PORT= http-port HTTP  (either may be a range: first-last)
  PROXY= proxy-address, ...  (behind a reverse proxy: plain HTTP, no CERT=)
  BIND= listen-address  (with PROXY=, default 127.0.0.1)
  LOGFILE= relative-pathname  |  DEBUGFILE= ...  [, COOKIES]
  LIBRARY= full-BR-pathname [RETAIN], FUNCTIONS= function1, fn2, ... [,AUTH]
       [,RUN_DIR= full-BR-path]
  RELOGIN_MINUTES= Number of minutes to allow a relogin
  SESSION_DIGITS= 0 to 3 low-order session digits naming its file (default 1)
  ALLOW= url-segment, ... (public pages - case insensitive)
```

Keywords, filenames and function names are not case sensitive. A line that begins with `REM `
is ignored.

| Statement | Meaning |
|---|---|
| `URL_BASE=` | The folder of the web site, as a BR path. It can be a subfolder of the Web Server folder (`www`), or a full path elsewhere on the network. In either case, its drive must be defined by a BR `DRIVE` statement. Paths in URLs are relative to it. |
| `CERT=` | Configuration 1 only. The base name of the certificate files `<base>.crt` and `<base>.key` (see section 4). Required unless `PROXY=` is given. |
| `PORT=` | The HTTPS port, 443 if not given. BR also listens for plain HTTP, on port 80 unless a second line `PORT= http-port HTTP` names another. With `PROXY=`, this is a range of plain-HTTP ports, `8081-8084` if not given. |
| `PROXY=` | Turns on configuration 2. Gives the numeric address of the reverse proxy, or several separated by commas. BR then serves plain HTTP only, serves no files of its own, and needs no certificate. |
| `BIND=` | With `PROXY=`: the one address BR listens on. Default `127.0.0.1`, which is right when NGINX runs on the same computer. |
| `NOLOGIN` | Turns off logins. Without it, every page and function except those matched by `ALLOW=` requires a logged-in session. |
| `ALLOW=` | One or more case-insensitive URL segments (substrings) that anyone may reach without logging in. URLs containing `index` or `login` are always allowed. Example: `allow= css, png, jpg`. |
| `RELOGIN_MINUTES=` | How long after a session times out the user may log in again and continue where they left off. A typical setting is 60. See section 9. |
| `SESSION_DIGITS=` | How many low-order digits of the session number name its session file in `sessions\`: 0 to 3, default 1. More digits spread busy sites over more files. |
| `LOGFILE=` | BR's HTTP engine log: start-up, certificate details and errors. With several BR processes, give each its own log with `[WSID]`, e.g. `logfile= httpserver[WSID].log`. |
| `DEBUGFILE=` | The Web Server's own detailed log, replaced at each start. Add `, COOKIES` to log each request's cookies, and `, PRINT_ALL` to log whole pages rather than their first 300 characters. Use `[WSID]` with several processes. |
| `LIBRARY=` | A BR library whose functions web pages may call, followed by `FUNCTIONS=` and the function names. `RETAIN` keeps the library's variables between calls. `RUN_DIR=`, which must come last, is the folder made current while its functions run. A trailing `,AUTH` is accepted, but access is controlled by `NOLOGIN` and `ALLOW=`, not by `,AUTH`. |
| `HTTP_VERSION=` | `0` or `1`: whether HTTP 1.0 or 1.1 is given in the headers web_server.br writes. Rarely needed. The default is 1 (HTTP 1.1). |

The Web Server reads `Web_Server.INI` only when it starts. Restart BR after changing it.

## 4. Configuration 1: stand-alone HTTPS server

BR's HTTP engine talks to browsers directly and holds the certificate.

### 4.1 Get a certificate

BR needs two PEM files with the same base name:

- **`<base>.crt`**: the server certificate **followed by every intermediate certificate**, which
  certificate authorities call the *full chain* (certbot's `fullchain.pem`). Browsers need the
  intermediates, and a file containing only the server certificate fails in most of them. BR does
  not look for the intermediates in other files.
- **`<base>.key`**: the private key, RSA or EC, protected with a passphrase.

Ways to get them:

- **Let's Encrypt on Windows: [win-acme](https://www.win-acme.com/).** Use filesystem validation
  with the path set to the operating-system folder that `URL_BASE=` names, and its PEM-files
  store. Have its post-renewal script copy the certificate-with-chain to `<base>.crt` and the key
  to `<base>.key`. Check the file names win-acme uses in the version you install. Validation is
  done over plain HTTP on port 80. BR always serves `/.well-known/acme-challenge/` from
  `URL_BASE`, even when logins are required.
- **A commercial certificate** usually arrives as a `.pfx`/`.p12` file, or as a certificate plus
  a "CA bundle":

  ```
  openssl pkcs12 -in site.pfx -nokeys -out server.crt      # certificate and chain
  openssl pkcs12 -in site.pfx -nocerts -out server.key     # key, encrypted with a passphrase
  copy /b site.crt + ca-bundle.crt server.crt              # certificate first, then the bundle
  ```

  Check that the server certificate comes first in the `.crt` file. A certificate authority's
  separate root certificate is not needed. The text file **HTTPS Certificate Creation and Use**
  describes making a certificate request with DigiCert's utility. Ignore what it says about BR
  finding the other certificate files: combine them into the `.crt` file as shown here.

### 4.2 Install it and point the INI at it

Put `<base>.crt` and `<base>.key` in the folder BR starts in, normally the Web Server's folder, and
name the base in the INI. A sample INI:

```
url_base= www
cert= site
logfile= weblog.txt
debugfile= webdebug.txt
library= sample.br retain, functions= fnAddComment, fnViewComments, fnSaveComment
library= login.br, functions= fnlogin
library= cust_inq.br, functions= fndisplay_cust
allow= css, png, jpg
relogin_minutes= 50
```

### 4.3 Give the passphrase on the first start

The first time the Web Server starts with a new `CERT=`, it asks:

```
Specify SSL Key File Passphrase:
```

It stores the passphrase, encrypted, in `<base>.phrase` beside the certificate, and reads it from
there on every later start. So start it once at the console before running it as a service, where
nobody can answer the question. To change the passphrase, delete `<base>.phrase` and start the
Web Server at the console again. A wrong passphrase makes the start fail with "Cannot Open HTTP
Port". `LOGFILE` then gives the reason.

### 4.4 Ports and firewall

BR listens on 443 for HTTPS and on 80 for plain HTTP, on every address of the computer. Open both
in the firewall: port 80 carries the certificate authority's validation and is redirected to
HTTPS. If another program already holds port 80 or 443, the Web Server stops with "Cannot Open
HTTP Port". The log then shows, for example, `cannot bind to 80`. Use `netstat -ab`, from an
administrator command prompt, to see which program holds it, or move BR's HTTP port with a second
`PORT= http-port HTTP` line.

When logins are required (no `NOLOGIN`), a request over plain HTTP is redirected to the same URL
over `https://`. With `NOLOGIN`, pages are served over both HTTP and HTTPS.

### 4.5 Renewal

**No restart is needed.** At most once a minute, BR checks whether `<base>.crt` or `<base>.key`
has changed, and uses a changed pair for new connections. A pair caught half-written is not used,
and the previous certificate stays in service until the next check. BR logs each certificate's
subject, issuer and expiry date, and warns in its logs when the certificate expires within 14 days
and when it has expired.

### 4.6 Check it

```
openssl s_client -connect www.example.com:443 -servername www.example.com -showcerts
```

Every certificate of the chain should be listed, followed by `Verify return code: 0 (ok)`.

### 4.7 Run it as a service

`BR_service.txt` describes running BR as a Windows service with `nssm.exe` and `brconfig.svc`.
Give the passphrase at the console first (section 4.3).

## 5. Configuration 2: behind a reverse proxy (NGINX)

```
browser --HTTPS--> NGINX :443 --- static files from the site folder
                     |
                     +--?BR_FUNC=--> 127.0.0.1:8081  BR process 1 (web_server.br)
                                     127.0.0.1:8082  BR process 2
                                     ...             (same folder, same Web_Server.INI)
```

NGINX holds the certificate, talks to browsers, and serves static files. BR serves plain HTTP on
the loopback address, where only NGINX can reach it. Several BR processes can run from the same
folder and INI; each takes the next free port of the range.

### 5.1 What it needs

- web_server 2.06 or later, and a BR build with `PROXY=`/`BIND=` support. The
  `brserver-500-x64-Release-2026-10-24.exe` supplied has it, and an older build fails at the start.
- NGINX, from nginx.org/en/download.html. Check its `.asc` signature against the keys at
  nginx.org/en/pgp_keys.html. There is nothing to install: unzip it, put the configuration in
  `conf\nginx.conf`, and run `nginx.exe`. NGINX's own documentation calls its Windows build beta
  quality, with no high performance or scalability to be expected. A BR site is limited by BR long
  before that matters. NGINX on Linux has no such caveat.
- A BR licence seat for each BR process. Each runs as its own workstation (WSID), so `wsid=unique`
  must be in `brconfig.sys`.

### 5.2 Web_Server.INI

```
url_base= www
proxy= 127.0.0.1
port= 8081-8084
logfile= httpserver[WSID].log
debugfile= webdebug[WSID].txt
library= sample.br retain, functions= fnAddComment, fnViewComments, fnSaveComment
library= login.br, functions= fnlogin
allow= css, png, jpg
relogin_minutes= 50
```

- `proxy=` is NGINX's address. BR trusts the `X-Forwarded-For`, `X-Forwarded-Proto` and
  `X-Forwarded-Host` headers only on requests from these addresses. Requests from anywhere else
  have those headers ignored.
- No `cert=` is needed. If one is present it is ignored, and no `.phrase` file is read.
- `port=` is the range the BR processes share, `8081-8084` if not given. `bind=` defaults to
  `127.0.0.1`.
- Keep `url_base=`. NGINX's `root` must name the same folder, and on a login site web_server.br
  still serves the pages itself (see section 5.4).
- The Web Server sets up BR's HTTP engine itself. Don't put `HTTP` or `HTTPS` lines in
  `brconfig.sys`.

### 5.3 Start the BR processes

Start each one exactly as in configuration 1, from the same folder with the same `brconfig.sys`.
Each takes the next free port of the range. One more than the range holds fails with "Cannot Open
HTTP Port" (error 752). As services, install one `nssm` service per process, with identical
parameters. Give each service its own copy of `brconfig.svc` with its own `LOGGING` file.

All the processes must run the same `web_server.br` from the same folder. Logins are kept in
`sessions\` beside the program, so any process can answer any logged-in browser.

### 5.4 nginx.conf

This is the template from BR's documentation (`br/docs/nginx-br.conf`). Replace:

- `www.example.com` with the site's name
- `C:/nginx/certs/...` with the certificate files
- `C:/site/www` with the folder `URL_BASE=` names
- the port list with your INI's `PORT=` range, which appears twice: in the `map` and in the
  `upstream`

```nginx
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include      mime.types;
    default_type application/octet-stream;
    sendfile     on;

    # requests meant for BR: any query string containing BR_FUNC=, in any case
    map $args $to_br {
        default           0;
        "~*(^|&)br_func=" 1;
    }

    # Each BR process names itself in the BR_NODE cookie of every answer, and the
    # browser's later requests go back to it.  List every BR port here; a cookie
    # naming any other value falls back to the upstream, so it cannot be used to
    # reach other services on the machine.
    map $cookie_BR_NODE $br_backend {
        default br_app;
        8081    127.0.0.1:8081;
        8082    127.0.0.1:8082;
        8083    127.0.0.1:8083;
        8084    127.0.0.1:8084;
    }

    # requests from a browser with no BR_NODE yet: the least busy process
    upstream br_app {
        least_conn;
        server 127.0.0.1:8081;
        server 127.0.0.1:8082;
        server 127.0.0.1:8083;
        server 127.0.0.1:8084;
    }

    # plain HTTP: only the certificate authority's challenge, then HTTPS
    server {
        listen 80;
        server_name www.example.com;
        location /.well-known/acme-challenge/ { root C:/site/www; }
        location / { return 301 https://$host$request_uri; }
    }

    server {
        listen 443 ssl;
        server_name www.example.com;
        ssl_certificate     C:/nginx/certs/fullchain.pem;
        ssl_certificate_key C:/nginx/certs/privkey.pem;
        # ssl_password_file C:/nginx/certs/passphrase.txt;   # only for an encrypted key
        ssl_protocols       TLSv1.2 TLSv1.3;

        root C:/site/www;
        client_max_body_size 64m;    # BR accepts request bodies up to 64 MB

        # --- A site with NOLOGIN: NGINX serves every file, BR the BR_FUNC calls
        location / {
            error_page 418 = @br;
            if ($to_br) { return 418; }   # a location cannot match a query string
            try_files $uri $uri/ =404;
        }

        # --- A site with login: web_server.br checks the session before every
        # page, so send everything to BR, and let NGINX serve only a folder of
        # files anyone may see.  Use these two blocks instead of the one above.
        #
        # location / {
        #     error_page 418 = @br;
        #     return 418;
        # }
        # location /assets/ {
        #     try_files $uri =404;
        # }

        location @br {
            proxy_pass http://$br_backend;
            proxy_http_version 1.1;       # so BR may answer chunked
            proxy_set_header Host              $http_host;
            proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host  $http_host;
            proxy_read_timeout 300s;      # a long BR page is not a dead one
        }
    }
}
```

**Choose the variant that matches the INI.** With `NOLOGIN`, NGINX serves every file and sends
only `?BR_FUNC=` requests to BR. In this mode BR serves no files itself, and a file request that
reaches it directly gets `404`. When logins are required, web_server.br checks the session before
serving any page. A proxy that served the files itself would skip that check, so send every
request to BR, and let NGINX serve only a folder of files anyone may see (`/assets/` above).

Don't add upstream keep-alive. BR's HTTP engine drops idle connections after half a second, and a
reused connection it had just closed would fail a POST.

### 5.5 Certificates on NGINX

The certificate belongs to NGINX. BR's `CERT=` and `.phrase` are not used.

- `ssl_certificate` is the **full chain** (server certificate first, then the intermediates), and
  `ssl_certificate_key` is the private key. These are the same two files as in configuration 1;
  Let's Encrypt calls them `fullchain.pem` and `privkey.pem`.
- If the key is encrypted, put its passphrase in a file and name it with `ssl_password_file`.
  Protect that file. The `.pfx` conversion in configuration 1 works here too.
- **Let's Encrypt:** use webroot (filesystem) validation with the folder that `root` names. The
  port-80 server above answers the challenge from it. For win-acme, use its PEM-files store; for
  certbot on Linux, `certbot certonly --webroot -w <site folder> -d <host>`.
- **Renewal:** NGINX reads its certificates when it starts or reloads. Have the renewal tool's
  post-renewal step run `nginx -s reload`. The BR processes don't need to be touched.

### 5.6 What changes behind the proxy

- **Client addresses, HTTPS and host name.** For requests from `PROXY=` addresses, BR takes the
  client's address, the protocol and the host from NGINX's `X-Forwarded-*` headers. The Web
  Server's redirect to HTTPS therefore sees the browser's `https` and does not loop. The logs show
  real client addresses, and BR's HTTP licence counts real clients.
- **The `BR_NODE` cookie.** Every answer that came through the proxy carries a
  `BR_NODE=<port>` cookie, and the `map` above sends the browser's later requests to the same
  process. Logins don't depend on this, since they are on disk. The **data store** does: objects
  stored with `FNPut_Object` and the JSON functions are in one process's memory. They are lost if
  that process restarts, and are not seen by the other processes.
- **Seats and services.** Plan a BR licence seat for each process. Run NGINX and each BR process
  as services that restart on failure (`nssm` on Windows).

### 5.7 Check it

Browse to the site over `https://`, call a BR function a few times, and check that each
process's `httpserver<wsid>.log` shows requests. A request straight to `http://127.0.0.1:8081/`
for a file should get `404` on a `NOLOGIN` site.

## 6. URL Processing

Paths in URLs are relative to the `URL_BASE` folder. To reach your site, give its address,
optionally followed by a colon and the port, and optionally a subfolder or file name:

```
URL[:port][/path-relative-to-site]
```

You can also call a BR function that is named on a `LIBRARY=` line in the INI:

```
URL[:port][/path-relative-to-site]?BR_FUNC=function-name
    [&MY_PARAM1=data1&ANY_KW=any-data& ...]
```

**Uploaded files** (`multipart/form-data`) are stored by BR's HTTP engine in the `tmp\` folder
under BR's working folder, with the session number appended to the client's file name. The stored
name reaches your function as an `UPLOADFILE` parameter. The form's other fields arrive as usual.

## 7. HTML Parameters

GET is a URL reference that tells the server to send back an HTML object. POST does the same but
includes a data package. GET can follow the URL with parameters. This is done by separating the
"IP-address, port, subfolder and filename" section of the URL from the parameters with a question
mark. Parameters that follow URLs are, by convention, keyword=value pairs separated from each other
by ampersands. The maximum length of a URL with its parameters is 4096 bytes, and it must be all
ASCII. POST parameters are sent in the data section, created by a FORM element in a web page.

**The URL arrives in upper case.** BR's HTTP engine hands the Web Server the URL with its query
string upper-cased. GET parameter names and values therefore reach your function in upper case.
POST data keeps its case, so send any value whose case matters in a POST.

```
e.g.  https://brulescorp.com:8080/qsmrp/index.html?BR_FUNC=fnvendor&ID=PA054&CONTACT=Angelina
```

The parameter `BR_FUNC=fnvendor` in the above example tells the Web Server to call the
**fnvendor** function and pass it two arrays: **KEYS$** and **VALUES$**. The first element of these
arrays is **QueryNumber**, a number unique to this request. It is not the same for each call from
the same browser; it is only guaranteed to be unique for each call. So it is suitable for starting
a series of transactions, but not for tracking one once started.

When logins are required, a **Session** element follows, carrying the browser's session number. It
stays the same for all calls from a user during a login session. The remaining KEYS$ and VALUES$
elements are the calling parameters.

This format of a URL followed by parameters works the same for GET and POST. POST can also send a
data package. If it contains an equal sign, it is taken to be one or more keyword=value pairs,
which the Web Server adds to the KEYS$ and VALUES$ arrays. *You can see what is passed by the
browser in the Web Server's DEBUGFILE.*

## 8. FORM/POST Example

```
https://brulescorp.com:8080/qsmrp/index.html?BR_FUNC=fnvendor&ID=PA054&CONTACT=Angelina
```

The above example would reach the Web Server at brulescorp.com listening on port 8080. It is sent
by the browser as a GET request. The function FNVENDOR would be called with two arrays:

- The first array (KEYS$) would contain:
   - QueryNumber
   - BR_FUNC
   - ID
   - CONTACT
- The second array (VALUES$) would contain:
   - a sequential number assigned by the Web Server to each function call
   - FNVENDOR
   - PA054
   - ANGELINA (upper case, because it came in the URL)

With logins required, a Session element would follow QueryNumber.

GET requests are very visible in browser histories, etc. So sensitive information should NOT be
sent in GET requests. Also, any information that changes data stored on the server should be sent
by POST. This is an Internet standard.

The *only* HTML way to send data by POST is with a FORM. (JavaScript offers other ways.) The
following HTML form would generate a POST request:

```
<form method="post" action="/?BR_FUNC=fnSaveComment" >
  Name:  <input type="text" name="field_name"/></br>
  Comments:  <textarea rows=6  cols=40  type="text"
    name="field_comments"></textarea></br>
  <input type="submit" value="Submit">
</form>
```

The POST request generated by clicking Submit on the above form would be seen by fnSaveComment as:

```
QueryNumber
BR_FUNC
field_name
field_comments
========================
604
FNSAVECOMMENT
Richard
My comments…
```

`BR_FUNC` came in the URL, so its value is upper case. The form fields came in the POST data, so
they keep their case.

## 9. User Logins and Authentication

It can be important to let users log in, check their password against a stored value, and keep
continuity across a login session. However, the Web Server and your application handle each GET
or POST separately from the others. So there must be a way to tell which user and session each
request belongs to. The Web Server provides an authentication procedure and a session store for
this.

The basic login procedure begins with a web page that asks the user to register or log in. If they
register, their information is stored in a BR data file indexed by their login ID (typically their
email address). The example provided (`login.brs`) skips registration and accepts every password.
The best way to register user logins and passwords is in a desktop application, outside web
access. The *important aspects* of the sample login procedure are 1) the *authentication
procedure*, in which the BR application asks the user for a login ID and password, checks the
password, and tells the Web Server the user is authorized to continue the session; and 2) how the
login session *keeps continuity* while it handles many interspersed requests.

The session cookie is marked `Secure`, so browsers send it only over HTTPS. Logins therefore need
HTTPS: from BR itself in configuration 1, or from NGINX in configuration 2.

It is up to the application whether it encrypts passwords before storing them. Some
considerations:

- When a user forgets their password (a common occurrence), do you want to email it to them, or
  let them reset it?
- How secure are your server and the password files?
- How secure is the network where the server is located?

The most secure method is to *store only encrypted passwords*, and to let users reset their
password with security questions and answers set up when they registered.

In summary, authentication and monitoring take place as follows (the names are those of the
sample application):

1. index.html's Login button calls `?BR_FUNC=fnLogin`. URLs containing "login" are always allowed.
2. FNLOGIN, receiving no user name, calls FNAUTHENTICATE with a realm and a challenge page
   (`challenge.bootstrap.html` in the sample).
3. FNAUTHENTICATE sends the challenge page with a `Session` cookie. A browser that has no session
   is given a new random session number. The session is recorded on disk as awaiting
   credentials.
4. The user fills in the challenge page's form, which posts `user_name` and `password` to
   FNLOGIN. (FNAUTHENTICATE's default page, `challenge.html`, asks with the browser's own Basic
   login box instead. The Web Server then adds the user name and password from the browser's
   `Authorization` header to KEYS$ and VALUES$ as `User_Name` and `Password`.)
5. FNLOGIN checks the password, and if it is valid, calls FNAUTHORIZE with a timeout. A positive
   value is an expiry date and time; a negative value is an idle interval, both in days (e.g.
   `-15*.00069445` for 15 minutes).
6. FNAUTHORIZE marks the session authorized on disk, with its expiry time and user name.
7. Every page and function other than those allowed by `ALLOW=` (and `index`/`login`) must come
   with the cookie of an authorized session that has not expired. Otherwise the browser gets the
   `unauthorized.html` page (`401 Unauthorized`).
8. With an idle interval, each function call or page reference moves the session's expiry time on
   by that interval.
9. If a session times out and the user comes back within `RELOGIN_MINUTES` of the expiry, the Web
   Server saves the requested URL and any POST data with the session, and sends `relogin.html`.
   Its "Login to Resume" link calls FNLOGIN with `RELOGIN` among the parameters.
10. FNLOGIN calls FNAUTHENTICATE again (with `challenge.relogin.html` in the sample), which keeps
    the original session number and shows the user name. The user must log in again within one
    hour.
11. When FNLOGIN calls FNAUTHORIZE, the Web Server replays the request saved in step 9, so the user
    continues where they left off.

### 9.1 Sessions

Sessions are kept on disk, in `sessions\sess<g>.dat` beside `web_server.br`. A session's saved
relogin URL and POST data are in `sessions\sesx<g>.dat`. `<g>` is the low-order `SESSION_DIGITS`
digits of the session number. Nothing about a session is kept in memory between requests, so
every BR process running the same `web_server.br` sees every session (configuration 2), and a BR
restart does not log anyone out. Expired sessions are freed every five minutes.

The **data store** is different. Objects stored with the data store functions are in the memory of
the one BR process that stored them (see `05 DATA STORE LIBRARY`).

## 10. Debug Log of Sample Application

> **This log is from an early version (1.x, 2015).** Its flow matches the steps above, with three
> differences. Its login uses the browser's Basic login box (`CHALLENGE.HTML`, `401` with
> `WWW-Authenticate: Basic`) rather than the form in `challenge.bootstrap.html`. Its session
> numbers are four digits, where the current ones are ten letters and digits. And it kept sessions
> in memory, where 2.05 and later keep them in `sessions\`.

To show the control and data flow of this authentication method, here is the Debug log from a
session. The process begins with a user typing in a reference to the web site in the address bar
of the browser. In this case it was LOCALHOST:8000. The web server receives a GET request for the
default web page. The Debug file shows:

```
GET received.
COOKIE Received: Session="1249"
URL= \
========= send page ==========
www\INDEX.HTML
SEND PAGE$  1106  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Maintain Comments</title>
```

Then the browser requests the ICON it should display in the page tab. This is met with a Not Found
response. This sequence will occur on practically every page access until a FAVICON.ICO file is
present:

```
GET received.
COOKIE Received: Session="1249"
URL= \FAVICON.ICO
Application error-
404 Not Found: www\FAVICON.ICO
```

**The index.html page includes a LOGIN button that initiates a call to FNLOGIN**. The current Query
Number and the previous Session Number are passed in. However, the Session Number will soon be
replaced with a new Session Number. The LOGIN program then initiates a Basic Authentication process
by the browser. *The browser will then prompt for User Name and Password.*

```
GET received.
COOKIE Received: Session="1249"
URL= \?BR_FUNC=FNLOGIN
========================
QueryNumber
Session
BR_FUNC
========================
1264
1249
FNLOGIN
========================
execute FNLOGIN
========= send page ==========
.\CHALLENGE.HTML
SEND PAGE$  252  bytes:
HTTP/1.0 401 Not Authorized
Date: Sat, 27 Jun 2015 23:15:40 GMT;
Server: BR Web_Server
Content-Type: text/html
Cache-Control: no-cache
Set-Cookie: Session="1264"; HttpOnly
WWW-Authenticate: Basic realm="Login to Activity Log"
Content-Length: 0
```

The browser sends back the results from the prompting operation. The LOGIN program then verifies
the user name and password, and calls FNAUTHORIZE to tell the Web Server that the session is
approved. In this case the LOGIN program has specified a 30 second timeout for testing purposes.
(This version kept track of active sessions in memory.)

```
Session 1264 now Authorized and Active
```

Next the LOGIN program sends the home_.html page to the browser. **The home_html page transfers
control to the home.html page.** This intermediate step removes the URL reference to the LOGIN
program, in case the user reloads (recycles) the home page.

```
GET received.
COOKIE Received: Session="1264"
URL= \?BR_FUNC=FNLOGIN
========================
QueryNumber
Session
User_Name
Password
BR_FUNC
========================
1265
1264
gordon
testing
FNLOGIN
========================
execute FNLOGIN
========= send page ==========
www\HOME_.HTML
SEND PAGE$  160  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
</head>
<body>
  <script> document.location = "home.html" </script>
</body>
</html>
```

The home page has two hot links: one for adding comments and one for displaying them. Now that
authentication has occurred, and since a time increment was specified by the LOGIN program, *each
new page reference restarts the timeout clock*. So the current time and new expiration time now
appear in the debug file.

```
GET received.
COOKIE Received: Session="1264"
URL= \HOME.HTML
Current Time:   2015/06/27 19:15:54
New Expiration: 2015/06/27 19:16:24
========= send page ==========
www\HOME.HTML
SEND PAGE$  744  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
</head>

<p>Welcome to the BR Web Server demo program. You can use this program to record
comments, which will be displayed when the appropriate button is pressed.</p>
```

The user clicked on Add Comment. This displays a background image, and then displays a FORM asking
for the comment:

```
GET received.
COOKIE Received: Session="1264"
URL= \ADD_COMMENT.HTML?
Current Time:   2015/06/27 19:16:03
New Expiration: 2015/06/27 19:16:33
========= send page ==========
www\ADD_COMMENT.HTML
SEND PAGE$  575  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>Add Comment</title>
   <style>body {background-image:url('bg.jpg'); background-repeat:no-repeat; }</style>
</head>
```

The background image:

```
GET received.
COOKIE Received: Session="1264"
URL= \BG.JPG                 (background image)
Current Time:   2015/06/27 19:16:03
New Expiration: 2015/06/27 19:16:33
========= send page ==========
www\BG.JPG
SEND PAGE$  123445  bytes:
```

A debug message showing that time passed:

```
19:16:18   4145   time out while waiting for input from user or ASYNC file I/O
```

The FORM results are sent to the server in a POST request. The FORM data is sent to FNSAVECOMMENT,
which stores it and links to the Thank You page:

```
POST Received: field_name=gordon&field_comments=testing comment
COOKIE Received: Session="1264"
URL= \ADD_COMMENT.HTML?BR_FUNC=FNSAVECOMMENT
Current Time:   2015/06/27 19:16:24
New Expiration: 2015/06/27 19:16:54
========================
QueryNumber
Session
BR_FUNC
field_name
field_comments
========================
1266
1264
FNSAVECOMMENT
gordon
testing comment
========================
execute FNSAVECOMMENT
========= send page ==========
www\THANK_YOU.HTML
SEND PAGE$  564  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Thank You</title>
   <style>body {background-image:url('BRClogoBold5 - background.jpg'); background-repeat:no-repeat; background-position: center bottom; }</style>
</head>
```

The Thank You page also calls for a background image:

```
GET received.
COOKIE Received: Session="1264"
URL= \BRCLOGOBOLD5 - BACKGROUND.JPG
Current Time:   2015/06/27 19:16:24
New Expiration: 2015/06/27 19:16:54
========= send page ==========
www\BRCLOGOBOLD5 - BACKGROUND.JPG
SEND PAGE$  17833  bytes:
```

Thank You chains back to home.html when the user clicks on the hot link:

```
GET received.
COOKIE Received: Session="1264"
URL= \HOME.HTML
Current Time:   2015/06/27 19:16:30
New Expiration: 2015/06/27 19:17:00
========= send page ==========
www\HOME.HTML
SEND PAGE$  744  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
</head>

<p>Welcome to the BR Web Server demo program. You can use this program to record
comments, which will be displayed when the appropriate button is pressed.</p>
```

This time the user selects View Comments. There is no View Comments page. Instead, FNVIEWCOMMENTS
creates the page on the fly. This is not the recommended way to display variable-length data. The
recommended way is to send a header page, followed by repeated calls to FNSend_String, and ending
with another FNSend_Page call to send the page footer. All send operations except the first should
suppress HTTP headers. See `05 DATA STORE LIBRARY` for details on suppressing HTTP headers.

FNVIEWCOMMENTS is called:

```
GET received.
COOKIE Received: Session="1264"
URL= \HOME.HTML?BR_FUNC=FNVIEWCOMMENTS
Current Time:   2015/06/27 19:16:37
New Expiration: 2015/06/27 19:17:07
========================
QueryNumber
Session
BR_FUNC
========================
1267
1264
FNVIEWCOMMENTS
========================
execute FNVIEWCOMMENTS
```

FNVIEWCOMMENTS outputs the compiled report HTML page:

```
======== send object ============
PRINT WORK$  1269  bytes:
<!DOCTYPE html><html><head><title>Comments and Suggestions</title><style>body {background-color: #A5E8D2;}</style></head><body><h1>Suggestion Box</h1><p>Here's a list of all of the comments we have received so far.</b><ul><li>gordon wrote <em>"This is a fine procedure."</em> - <em><strong>Saturday,
```

The user then clicks on their back button to get to the home page. Then, after 30 seconds have
passed, the user once again clicks on Add Comment. This time, however, the session has expired. The
Web Server saves the requested URL, to go there after the user logs in again. It then issues an
Unauthorized message by sending the unauthorized.html page to the browser:

```
GET received.
COOKIE Received: Session="1264"
URL= \ADD_COMMENT.HTML?
Current Time:  2015/06/27 19:17:11
Expired #####: 2015/06/27 19:17:07
================ Unauthorized ==============
========= send page ==========
.\UNAUTHORIZED.HTML
SEND PAGE$  487  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8" />
   <title>Unauthorized</title>
   <style> body {text-align:center} </style>
</head>
<body>
   <br>
   <h1>401 Unauthorized</h1>
   <br>
   You must sign in before accessing this web page.
   <br><br><br>
<p><button oncl
```

The unauthorized.html page also has a LOGIN button, which calls LOGIN directly. The LOGIN program,
once again, calls FNAUTHENTICATE to ask for the user's ID and password:

```
GET received.
COOKIE Received: Session="1264"
URL= \INDEX.HTML?BR_FUNC=FNLOGIN
========================
QueryNumber
Session
BR_FUNC
========================
1268
1264
FNLOGIN
========================
execute FNLOGIN
========= send page ==========
.\CHALLENGE.HTML
SEND PAGE$  252  bytes:
HTTP/1.0 401 Not Authorized
Date: Sat, 27 Jun 2015 23:17:15 GMT;
Server: BR Web_Server
Content-Type: text/html
Cache-Control: no-cache
Set-Cookie: Session="1268"; HttpOnly
WWW-Authenticate: Basic realm="Login to Activity Log"
Content-Length: 0

19:17:30   4145   time out while waiting for input from user or ASYNC file I/O
```

The Web Server passes these to the LOGIN program for validation. This time, however, the Web
Server also passes the Chain-To URL that the LOGIN program can use to forward control to the
appropriate page. The LOGIN program checks that the URL has no parameters, and then sends the
"transfer to" page instead of the home page:

```
GET received.
COOKIE Received: Session="1268"
URL= \INDEX.HTML?BR_FUNC=FNLOGIN
========================
QueryNumber
Session
User_Name
Password
Chain_URL
BR_FUNC
========================
1269
1268
test user
test pwd
\ADD_COMMENT.HTML
FNLOGIN
========================
execute FNLOGIN
========= send page ==========
www\ADD_COMMENT.HTML
SEND PAGE$  575  bytes:
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>Add Comment</title>
   <style>body {background-image:url('bg.jpg'); background-repeat:no-repeat; }</style>
</head>
```

The Add Comment page calls for a background image:

```
GET received.
COOKIE Received: Session="1268"
URL= \BG.JPG
Current Time:   2015/06/27 19:17:32
New Expiration: 2015/06/27 19:18:02
========= send page ==========
www\BG.JPG
SEND PAGE$  123445  bytes:
```

That completes this demonstration.

## 11. Miscellaneous

The Web Server uses BR's case-insensitive searching with the standard "^" character. Do not
suppress or change that feature. If your library functions need different settings, change them
while they run and restore BR's defaults before returning control to the Web Server.

If the Web Server fails to start with "Cannot Open HTTP Port", look in the `LOGFILE` for the reason
(a wrong passphrase, a missing certificate file, or a port in use). Use the Windows command
`netstat -ab`, from an administrator command prompt, to see which programs hold which ports.
