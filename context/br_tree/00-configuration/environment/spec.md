---
title: Environment variables & paths
file: spec.md
source: §Configuration → Environment Variables, §Client Server; br_tree Environmental_variables / Environmental_Variables_Tutorial / Client_Current_Dir / @Login_Name folded in & pruned (2b); DRIVE detail folded into config-directives
category: 00-configuration
subcategory: 00-configuration/environment
kind: spec
status: 2b           # reference base + br_tree enrichment
recovered-fold: Environmental_Variable (redirect-collision page re-fetched; content already fully covered by this spec's SETENV/ENV$/%NAME% sections — pruned; verbatim retained on the BR wiki)
related: [config-directives, client-server]
keywords: [ENV, SETENV, DATADIR, BR_DATA, LOGIN_NAME, WORKPATH]
---

# Environment variables & paths

How OS/session environment values feed BR and how filenames resolve to OS paths. The
configuration *directives* that consume these are in
[config-directives](../config-directives/spec.md); reading them at runtime is via
[`ENV$`](../../10-language/data-manipulation/system-functions/spec.md#system-info).

<a id="syntax"></a>
## Syntax

```bnf
-- OS environment-variable substitution (any BRConfig.sys specification)
%NAME%                                            -- e.g. %USERNAME%, %USERPROFILE%, %COMPUTERNAME%

-- per-user conditional config line
@<login-name> <any BRConfig.sys specification>    -- quote login if it has spaces/periods: @"Joe Tester" ...
[LOGIN_NAME$]                                      -- login-name substitution inside a path
LOGIN_NAME$ <default-login>                        -- BRConfig.sys: default when OS gives none

-- session environment values (runtime)
SETENV(<name$>, <value$>)                          -- write a session variable / special key
LET v$ = ENV$(<name$>)                             -- read OS var, session var, or system setting

-- client working directory (client-server)
CLIENT_CURRENT_DIR { <full-client-path> | SYNC | OFF }
```

<a id="semantics"></a>
## Semantics

<a id="env-substitution"></a>
- **`%NAME%` substitution** — any BRConfig.sys specification may embed an OS environment variable,
  e.g. `DRIVE C:,%USERPROFILE%\data,,` or `%USERNAME%`. Resolved at start-up.
- **`@login_name` prefix** — gate a BRConfig.sys line on the OS (Windows/Linux) login, so one shared
  BRConfig.sys can carry per-user lines instead of one file per client. Quote the name if it
  contains spaces or periods: `@"Joe Tester" WSID 11`.

<a id="path-resolution"></a>
- **Path translation & the colon escape** — pathnames in BRConfig.sys statements (and program
  filenames) are translated through preceding `DRIVE` definitions. To use a *literal OS pathname*
  and bypass translation, begin it with a colon `:` (the colon is stripped when BR uses the path).
  Backslashes separate directories even on Linux; on Linux/Mac program filenames are forced
  lowercase to simulate case-insensitivity (override with `FILENAMES`). A drive-letter reference is
  **drive-relative unless it has a leading backslash**: `X:path` resolves against the drive's current
  directory (base + the 4th-param startup `<subdir>`, moved by `CD`), while `X:\path` is absolute from
  the drive's base — so the two differ when a `<subdir>`/`CD` is in effect (see
  [config-directives](../config-directives/spec.md#paths)).
- **`[LOGIN_NAME$]`** substitutes the current login into a path, e.g.
  `DRIVE G:,G:\HOME\[LOGIN_NAME$],,`; `LOGIN_NAME$ <default>` sets the fallback when the OS supplies
  none. (Full `DRIVE` grammar and file-search order live in
  [config-directives](../config-directives/spec.md#paths).)

<a id="setenv"></a>
- **Session environment variables (`SETENV`)** — set a value in one program and read it from
  another for as long as BR stays open (lost when BR closes). `SETENV("startform$","5,5,C 30")`
  then `ENV$("startform")` returns it. Special keys: `SETENV("clipboard", v$)` writes the Windows
  clipboard (4.17+); `SETENV("SCRN_SIZE_POSN")` saves the current size/position of both consoles
  (unless minimized). A config-statement form (`SETENV (config)`) also exists.

<a id="env-read"></a>
- **Reading with `ENV$`** covers three kinds of value: **OS** variables (`ENV$("temp")`,
  `ENV$("USERNAME")`), **session** variables set via `SETENV`, and **system settings** —
  `ENV$("clipboard")`, `ENV$("color.<component>")` → `#RRGGBB`, `ENV$("font.<component>")`,
  `ENV$("OPEN#<n>.FONT.LABELS")`, and the status-interrogation form
  `ENV$(status-string [, MAT config$ [, search-arg]])` (4.30+). `STATUS ENV` lists all available
  values.

<a id="client-current-dir"></a>
- **`CLIENT_CURRENT_DIR`** (client-server; settable in BRConfig.sys or via the `CONFIG` command):
  - a **path** → passed to Windows as the *Starting Directory* for subsequent client `shell` calls;
    also stops any prior SYNC.
  - **`SYNC`** → mirror every server `CD` onto the client. Requires that each `DRIVE` statement's
    *2nd parameter* match the server OS drive mapping (e.g. Samba root), so a `CD DATA` lands at the
    same place on both sides. Useful for `COPY file @:file2` client transfers, ODBC, SPOOLCMD.
  - **`OFF`** → revert to the startup directory.
  - See [client-server](../client-server/spec.md#cs-operations) for `@:` client-path addressing.

<a id="tables"></a>
## Tables

| `ENV$` argument | Returns |
|---|---|
| `"temp"`, `"USERNAME"`, … | OS environment variable |
| *(name set by `SETENV`)* | session variable (e.g. `"startform"`) |
| `"clipboard"` | Windows clipboard text (4.17+) |
| `"color.<component>"` | color as `#RRGGBB` |
| `"font.<component>"` / `"OPEN#<n>.FONT.LABELS"` | font name |
| `status-string [, MAT config$ [, arg]]` | environment/status interrogation |

| `CLIENT_CURRENT_DIR` value | Effect |
|---|---|
| `<full-client-path>` | set client Starting Directory; cancels SYNC |
| `SYNC` | mirror server `CD`s onto client (needs DRIVE 2nd-param ↔ OS mapping) |
| `OFF` | use the startup directory |

<a id="examples"></a>
## Examples

```text
DRIVE E:,%USERPROFILE%\BR_DATA,,                 ! OS env-var substitution
DRIVE G:,G:\HOME\[LOGIN_NAME$],,                 ! per-login path
@"Joe Tester" WSID 11                            ! per-user config line (quoted login)
@admin LOGLEVEL DEBUG
CLIENT_CURRENT_DIR SYNC                          ! keep client CD in step with server
```
```business-rules
00100 PRINT "User: "; LOGIN_NAME$
00110 LET DATADIR$ = ENV$("BR_DATA")             ! read OS / session var
00120 SETENV("startform$","5,5,C 30")            ! session var, readable elsewhere
00130 LET SF$ = ENV$("startform")
00140 SETENV("clipboard", "Data to copy")        ! Windows clipboard (4.17+)
```

<a id="see-also"></a>
## See also

- [config-directives](../config-directives/spec.md#paths) — full `DRIVE`/`WORKDIR`/`PRINTDIR`/`FILENAMES` grammar + file-search order
- [client-server](../client-server/spec.md#cs-operations) — `@:` client paths, `Client_Current_Dir` transport
- [system-functions](../../10-language/data-manipulation/system-functions/spec.md#system-info) — `ENV$`, `SETENV`, `LOGIN_NAME$`, `USERID$`
