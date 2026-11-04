# BR Web Server

A complete HTTPS web server written in Business Rules! (BR). It serves the files in `www\`, runs
BR library functions called from the browser, and handles logins and sessions. This package
includes the BR runtime and a sample application, so it runs as soon as it is unpacked.

## Run the sample

1. Put this folder anywhere, for example `C:\brweb`. Its name has to be coordinated with the
   `DRIVE` statement in `brconfig.sys`:
   ```
   drive c:,..,\,\brweb
   wbserver c:\brweb
   ```
   `..` makes BR's `c:` the folder above this one, and `\brweb` is the folder BR starts in. If
   this folder has another name, change `brweb` to match it on both lines. A ZIP downloaded
   from GitHub unpacks as `BR-web-access-main`, and `git clone` names the folder
   `BR-web-access`: rename the folder to `brweb`, or change both lines to match it.
2. Start `brserver-x64-Debug.exe` from this folder, for example by double-clicking it. It reads
   `brconfig.sys` and starts `web_server.br`. It listens on ports 443 (HTTPS) and 80 (HTTP),
   which must be free.
3. Browse to `https://localhost/`. The browser warns about the certificate (see below).
   Accept it once.
4. Click **Login**. The sample login accepts any user name and password.

The sample lets you add and view comments, and look up a customer (try customer ID `CH600`).

## What's here

| | |
|---|---|
| `brserver-x64-Debug.exe`, `brclientdll502-x64-Debug-gui.dll` | The BR runtime. Keep the two together. |
| `brconfig.sys` | BR's startup configuration |
| `web_server.ini` | The server's settings: site folder, certificate, logs, and the library functions it may call |
| `web_server.br` (`.br.brs` is its source) | The web server |
| `login`, `sample`, `cust_inq`, `webform` (`.br` and source) | The sample application's library functions |
| `fileio.br`, `fileio.ini`, `filelay\`, `data\` | The FileIO library, the file layouts and the sample data |
| `www\` | The site |
| `*.html` beside the server, `filetypes.txt` | Pages and MIME types the server itself uses |
| `self.crt`, `self.key`, `self.phrase` | A self-signed demo certificate for `localhost` |
| `nssm.exe`, `brconfig.svc`, `BR_service.txt` | Running the server as a Windows service |

The server writes its logs (`brlog.txt`, `weblog.txt`, `webdebug.txt`) and its session files
(`sessions\`) in this folder.

## Before real use

- **Replace the certificate.** `self.crt` is self-signed for `localhost`, and its key is public.
  See section 4 of `03 BR WEB SERVER.md`.
- **Replace the sample login.** `login.brs` accepts every password. See section 9.
- **Turn off the debug log.** Remove the `debugfile=` line from `web_server.ini`; it slows every
  request.

## Documentation

- `03 BR WEB SERVER.md`: setup (stand-alone or behind NGINX), the INI settings, URLs and
  parameters, writing library functions, logins and sessions.
- `05 DATA STORE LIBRARY.md`: the per-session data store and the JSON functions.
- `REDIRECT.md`: the HTTPS and after-POST redirects.
