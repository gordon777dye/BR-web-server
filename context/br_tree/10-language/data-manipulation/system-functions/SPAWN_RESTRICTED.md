---
title: SPAWN_RESTRICTED
file: SPAWN_RESTRICTED.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
since: BR 5.0
related: [internal function, restricted session, PROC, SLEEP, WSID$, SESSION$, 4154, 4155, 4156, 4157]
---
`SPAWN_RESTRICTED(command$ [, config$ [, wait]])`

Starts a **new BR session on this workstation ID** — the next free session number — restricted from
its first moment, and runs `command$` as that session's startup command, typically `PROC <file>`.

This is how a session runs something it does not trust **without restricting itself**: the new
session is restricted and disposable; the one that called it is neither.

## Arguments

| Argument | Meaning |
|---|---|
| `command$` | the new session's startup command, e.g. `"PROC report.prc"` |
| `config$` | its configuration file; defaults to **this session's** |
| `wait` | seconds to wait for it to finish; omitted or `0` means do not wait |

## What it returns

- **Without a `wait`, or with `0`:** the new process's **id**, at once.
- **With a `wait`:** the session's **exit code**. The wait yields the way [`SLEEP`](spec.md#system-info)
  does, so the screen keeps repainting and ATTN still works while the child runs.
- A session still running when the wait runs out **is ended**, and the call raises **4157**. A
  disposable session nobody is waiting for has no reason to keep holding a session number.
- Pressing a key that takes the caller elsewhere stops the waiting, raises `BRETRAPSLEEPKEY`, and
  **leaves the child running** to finish its own work.

## Errors

| Code | When |
|---|---|
| `4154` | a **restricted** session called it. Nothing in the child could be less restricted than its parent; the refusal is because a program generated for a user has no business spending the WSID's sessions |
| `4155` | no session is free. **One session per workstation ID is always kept back**, so a spawn can never take the last one a person might need — with eight of nine in use, this is raised |
| `4156` | not local Windows. It is available in local mode on Windows and raises this elsewhere for now |
| `4157` | the session did not finish within `wait` and was ended |

Every refusal is logged as a security event.

## The restriction holds before the configuration is read

The new session is latched **before it reads its configuration file**, and the ordering is the whole
point: `config$` is the *caller's* choice, so the configuration operations a restricted session
refuses are refused **in that file**, not applied and then locked.

Since `LOGGING` and `WBSERVER` are among them, the new session is handed the **current session's**
log and `wbserver.dat` instead, and logs to the same file.

## Example

```text
00100    LET PID = SPAWN_RESTRICTED("PROC "&REPORT$)           ! start it, carry on
00110    LET RC  = SPAWN_RESTRICTED("PROC "&REPORT$, "", 300)  ! or wait 5 minutes
00120    IF RC <> 0 THEN PRINT "the report ended with "; RC
```

## See also

- [system-functions](spec.md#system-info) — `WSID$`, `SESSION$`, `SLEEP`
- [90-reference/error-codes](../../../90-reference/error-codes/_index.md) — 4154 to 4157
