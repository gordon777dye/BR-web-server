---
title: Client-server
file: spec.md
source: §Client Server
category: 00-configuration
subcategory: 00-configuration/client-server
kind: spec
status: 2b           # reference base + br_tree fold (reconnect/keepalive, service install, troubleshooting); HTTP=CLIENT relocated to 60-integration/web; no conflicts
recovered-fold: BRListener.Conf, BRListener.exe, BRListener.Log, Client_Server, MultiSession (5 redirect-collision pages folded from re-fetched source — Security section, TLS, 64/32-bit install + /ALTERNATE, SHELL LIMIT/DEFAULT + flags, CLIENT_CURRENT_DIR modes, conf-read-fresh; verbatim retained on the BR wiki)
related: [config-directives, platform, environment]
keywords: [CLIENT_SERVER, BRSERVER, SERVER, CONFIG]
corrections:
  - "Client-file COPY examples changed from the `COPY \"x\" TO \"@:C:\\...\"` form to `COPY <from> <to>`: no TO, unquoted names, and `@::` for a client absolute path, as file-directory documents. BR 5.0's console refuses the TO form. The unquoted form was confirmed to copy a file to the client (ERRORS.md, 2026-10-01). The Examples line now also runs COPY through EXECUTE, because a command cannot be a numbered program statement (program-management#command-vs-statement), and no longer reuses line number 10100. The same bullet's `EXISTS(\"@:C:\\...\")` changed to `@::` for the same absolute-path reason (confirmed by the user, 2026-10-02)."
---

# Client-server

Deploying BR with a separated UI (client) and business logic/data (server) over TCP/IP.
**Configuration/deployment, not coding.** OS-specific server setup is in
[platform](../platform/spec.md); start-up directives in
[config-directives](../config-directives/spec.md).

<a id="architecture"></a>
## Architecture

`BRClient` (Windows/Mac) ⇄ TCP/IP (default **port 8555**) ⇄ `BRListener` (connection agent) →
`BRServer` (runs the application). Clients and servers can be cross-platform (Windows client ↔
Linux/Mac server).

- **Server**: `BRListener.exe`/`brlistener` (manages connections, `BRListener.conf`),
  `BRServer.exe`/`brserver` (executes business logic).
- **Client**: `BRClient.exe`, optional `BR_Parms.txt`.

<a id="config"></a>
## Configuration

```ini
# BRListener.conf — global settings
logfile=/path/log    
loglevel=6    
port=8555

# Session definition
[ LABEL=BR STARTDIR=/u/myapp EXECUTABLE=/u/myapp/br/brserver 
   - optional -
CONFIG=/u/myapp/brconfig.svr 
CAPTION=<client login prompt window caption> 
ANONYMOUS=<username@password>    -- use with caution
MULTISESSION                     -- once logged in credentials are saved in listener memory
STDERR=/u/myapp/errorlog.txt
]
```
Session parameters: `LABEL` (client references it), `STARTDIR`, `EXECUTABLE`, `CONFIG`, `CAPTION`,
`ANONYMOUS` (user@password auto-login), `MULTISESSION`, `STDERR`. `BRListener` re-reads
`BRListener.conf` **fresh on every session launch** — no `install /release`+reinstall is needed for
conf edits — and `BRClient`↔`BRListener` traffic is **TLS-encrypted**. `MULTISESSION` stores a client
session ID in the client registry keyed to the login, so the listener reuses saved credentials for
subsequent sequential sessions (omit it if your app can't run multiple sessions).

```bash
BRclient 192.168.1.100 BR          # client connects to server + label
BRclient myserver.com:7543 BR      # custom port
```
`BR_Parms.txt` (must sit beside `BRClient.exe`) supplies the connection: `host=<ip|dns|localhost>`,
`label=<BRLISTENER.CONF label>`. The **`BRSERVER`** (a.k.a. legacy **`WBSERVER`**) BRConfig.sys
statement names the server data file (`BRServer.dat`/`WBServer.dat`) and needs **no drive letter**.

<a id="reconnect"></a>
## Reconnect & keepalive
`BRClient` sends a keepalive every **10 s**; `BRServer` self-terminates if none arrives for **100 s**
(failures are logged to an error file in the BRServer directory). To survive transient drops:
```text
CLIENT_SERVER RECONNECT_AFTER=20  RECONNECT_TIME=300
```
The client retries after `RECONNECT_AFTER` seconds (default 20) for up to `RECONNECT_TIME` seconds
(default 120) before aborting; while retrying it shows its **session number**, and the login window
offers a session-number box so you can **reconnect from another workstation**. On an unrecoverable
disconnect the session does the normal `Exit_After` exit — a BR error then unattended mode (no client
I/O; exits at the next keyboard wait; default 240 s). Raising the values (e.g. `999`) helps long/slow
commands, but the workstation appears to "lock up" while waiting.

<a id="cs-operations"></a>
## Client-side operations

- **Shell calls** route by flag: `-s` server, `-@` client (`EXECUTE "SYSTEM -@ dir"`); `-c`
  continue, `-r` restore screen, `-w` no shell, `-t###` timeout, `-p` page output (Linux server),
  `-m`/`-M` minimized (Windows; `-M` also off the taskbar). `-w`/`-r`/`-c` are mutually exclusive
  (error 2222); **Ctrl-]** *always* does a client shell call. Config: **`SHELL LIMIT <sec>`** sets the
  child-process timeout (default **240**; `-1` = never unless `-t`), and **`SHELL DEFAULT
  {CLIENT|SERVER}`** sets where shells run and what `WBPLATFORM$` reports (so a Mac/Linux CS app can
  present as `WINDOWS`).
- **Remote printing**: printer targets pick client vs server by suffix and `OPTION 30` —
  `PRN:/` vs `PRN:@/`, `WIN:/` vs `WIN:@/`, `DIRECT:/`, `PREVIEW:/`. Client spooling via
  `SPOOLCMD @ …` and `SPOOLPATH @ …`.
- **Client files** use the `@:` prefix (`@::` for a client absolute path): `COPY data.txt @::C:\ClientData\data.txt`,
  `EXISTS("@::C:\Config\settings.ini")`.
- **`CLIENT_CURRENT_DIR`** sets where `@:` (single-colon) client references resolve: a **full path**,
  **`SYNC`** (mirror each server `CD` onto the client, per-DRIVE), or **`OFF`** (default — use the client
  startup dir). The **third `DRIVE` parameter** supplies a per-drive client full path (must begin `\\`
  or `X:`) and is honored only in client-server.

<a id="examples"></a>
## Examples

```business-rules
10100 EXECUTE "SYSTEM -s ls -la"                 ! run on server
10200 EXECUTE "SYSTEM -@ dir"                     ! run on client
10300 EXECUTE "COPY report.pdf @::C:\Upload\report.pdf"   ! send to client
```

<a id="service-install"></a>
## Service install & troubleshooting
On Windows the server side is a service: `install.exe` registers `C:\Windows\System32\BRListener.exe`,
and the **"BR Service was successfully started"** message means it will auto-launch each reboot until
`install.exe /release`. Install the **64-bit** `BRListener.exe` in `System32` (or the **32-bit** in
`SysWOW64`) and run the matching `BRListenerInstaller.exe` as administrator (InstallShield is no longer
used). Two listener versions can coexist for production testing — install the second with
**`/ALTERNATE <name>`** (→ service `BR_Listener-(name)`) and tag conf statements with
`@release=<ver> PORT=…`. On Linux the listener is a self-installing **`brlist`** daemon script
(`brlist install|start|stop|restart`; link `brlistener.conf`→`/etc`, `brlistener`→`/usr/sbin`). Common
errors:

| Message | Cause / fix |
|---|---|
| *Couldn't find BRLISTENER.exe in the specified (or SYSTEM) directory* | place `BRListener.exe` in `C:\Windows\System32` |
| *Couldn't open wbserver at BR Path=… / OS Path=…* | bad `DRIVE` statement in `BRConfig.sys` (or no write permission) |
| *OPTION 33 mismatch using wbserver.dat* | client/server [`OPTION 33`](../config-directives/spec.md) record-locking level differs |

<a id="security"></a>
## Security
- **`BRserver` inherits `BRListener`'s OS privileges**, then narrows them to the logging-in user's
  permissions (or the `ANONYMOUS=` user's). **`ANONYMOUS=` logs everyone in as one OS user, with no WSID
  and no password prompt — use with caution**: give that account restricted OS rights and let the
  application authenticate (remember any path is reachable under BR by prefixing it with a colon).
- **Lock down interrupts**: remap `Ctrl-A` to null and reserve a line-draw key for support staff (e.g.
  `KEYBOARD 01 41`, `KEYBOARD C0 01`, so only `Ctrl-\ 1 Ctrl-\` interrupts).
- **Windows Server**: the login account needs **"Allow log on locally"** (default admin-only on Server
  2003 — grant via Domain Controller Security Policy → User Rights Assignment).
- **Firewall/router**: change the default **port 8555**, add an inbound rule for
  `…\system32\brlistener.exe` on that port, and use NAT/port-forwarding to reach it across the internet.

<a id="see-also"></a>
## See also

- [platform](../platform/spec.md) — Windows/Linux/Mac server setup
- [config-directives](../config-directives/spec.md) — `OPTION 30`/`33`, `SPOOLPATH @`, `DRIVE` client paths
- [environment](../environment/spec.md) — `Client_Current_Dir`, `@:` client access
- [60-integration/web](../../60-integration/web/spec.md) — **`OPEN … HTTP=CLIENT`** (BR as an HTTP
  GET/POST client) — relocated there as a web-integration feature

*(Backing keyword pages — `BRClient.exe`, `BRServer_(client_server)`, `BRServer_(config)`,
`BR_Parms.txt`, `BR_Service_was_successfully_started`, `Client_Server_Reconnect`, `Exit_After`,
`Keepalive`, the two `Couldn't_…` pages, and `OPTION_33_mismatch…` — were folded into this spec and
pruned; `HTTP=CLIENT` was relocated to 60-integration/web. The 2b redirect-collision pages
`Client_Server`, `BRListener.Conf`, `BRlistener.exe`, `BRListener.Log` and `MultiSession` were likewise
folded here and pruned; verbatim wikitext remains on the BR wiki.)*
