# Redirects in the BR Web Server

How a redirect works, the redirects `web_server.br` sends (version 2.17), why the HTTPS redirect
names a port, and the redirect BR's HTTP engine offers programs of your own. Setup and the INI
are in `03 BR WEB SERVER.md`.

## 1. What a redirect is

A redirect is a response that tells the browser to fetch a different address. It has a `3xx`
status and a `Location` header:

```
HTTP/1.1 303 See Other
Location: https://www.example.com:8443/?BR_FUNC=FNHELLO&NAME=X
```

The browser does not change the connection it has. It treats `Location` as a new address and
goes there: it opens a new connection if it needs one, does the TLS handshake if the address is
`https://`, and sends a new request. Any text in the body is only for a client that does not
follow redirects. With `303` the new request is always a `GET`. With `302`, browsers also use
`GET`.

## 2. The redirects web_server sends

Both are sent from the page file `br_redirect.html`, with its `^new_location` placeholder
replaced by the address:

```
HTTP/1.1 303 See Other
Location: ^new_location
Content-Type: text/html
Cache-Control: no-cache, no-store, must-revalidate
...
<h1>BR Web Server</h1>
Now Redirecting to ^new_location
```

The file brings its own headers, so web_server writes none of its own. A new session's
`Set-Cookie` is added to them. The `Content-Length` is the body's real length: BR adds it, since
the file has none. You can change the wording of the page. Keep the first two lines.

### 2.1 Plain HTTP to HTTPS

When logins are required (no `NOLOGIN`), every request that arrives over plain HTTP gets a
redirect to the same address over `https://`. The session cookie is `Secure`, so a login only
works over HTTPS. With `NOLOGIN`, plain HTTP is served as it is.

The address is `https://` + the request's host name + BR's HTTPS port + the URL as BR received it.
The URL is in upper case, because BR's HTTP engine upper-cases it before web_server sees it. That
loses nothing the original request had not already lost, since function names and file names are
not case sensitive.

### 2.2 After a POST

When a function called by a POST answers with `FNSEND_PAGE("page.html")`, web_server sends a 303
redirect to `page.html` instead of the page. The browser then fetches the page with a `GET`. This
is the usual "Post/Redirect/Get" pattern: the page the user sees came from a `GET`, so refreshing
it, or going back to it, does not send the form again.

Because the browser fetches the page file as it is, the `^placeholder` replacements given to
`FNSEND_PAGE` are not made. A function that answers a POST with replaced values should build
the response with `FNSEND_STRING` or `FNSEND_OBJECT`, which are sent directly.

## 3. Why the HTTPS redirect names a port

BR listens for plain HTTP and for HTTPS on two different ports. A port speaks one or the other:

| Setup | Plain HTTP | HTTPS |
|---|---|---|
| The defaults | 80 | 443 |
| `PORT= 8443` and `PORT= 8085 HTTP` | 8085 | 8443 |

The port in the `Location` address is where the browser connects. An `https://` address with no
port means 443.

- `https://host/x` makes the browser connect to 443.
- `https://host:8085/x` makes it attempt a TLS handshake with the plain-HTTP listener on 8085.
  That fails, and the user sees a connection error instead of the page. Releases before 2.17 sent
  this: they kept the port the plain request came on.
- `https://host:8443/x` reaches BR's HTTPS listener, and the request goes through.

So since 2.17 the redirect takes the host name without the port the request came on, and adds
BR's HTTPS port (the first `PORT=`) unless it is 443. With the default ports nothing is added,
and the redirect is the same as it always was. An IPv6 host keeps its brackets
(`https://[::1]:8443/x`).

**Behind a reverse proxy** (`PROXY=`), the HTTPS port belongs to NGINX, and BR cannot know it.
The redirect names no port, which means 443. With the NGINX setup in `03`, BR never sends this
redirect anyway, because NGINX answers plain HTTP itself:

```
server { listen 80; ... location / { return 301 https://$host$request_uri; } }
```

## 4. BR's own redirect: REDIRECT-TO

A program that opens an `HTTP=SERVER` file itself can let BR's HTTP engine send the redirect:

```
let X$ = FILE$(HTTP_FILE, "REDIRECT-TO-https://www.example.com/next.html")
```

This answers the current request with `302 Found` and `Location:` the address given. Any text
printed for the response and not yet flushed is dropped. It is described in the context kit's
`br_tree/60-integration/web/HTTP_SERVER.md` (in the kit's current copy, not yet in brweb's).

web_server does not use it. Its redirects need headers the engine's redirect does not add (the
session cookie and the no-cache headers), and they come from a page file a site can reword. It
has not been tested in brweb.

## 5. Pages that bring their own headers

`br_redirect.html`, `challenge.html` and `challenge.bootstrap.html` begin with their own status
line and headers. For any such page:

- **Its `Content-Length` is corrected** to the length of the body as sent, after the
  `^placeholder` replacements (since 2.17). Without a `Content-Length` header, BR adds one.
