
# BR 4.33 Release Notes

(Visual Studio Code and Cursor have built-in markdown (.md) 
 structured pretty prints. I suggest reading this with one of those. 
 If you are totally new to this environment, I recommend VS Code, 
 which is destined to become the native editor of BR programs.)

This release covers two separate efforts that landed together:

1. **Toolchain** — the Windows build was moved to **Visual Studio 2026**.
2. **Feature migration** — selected change groups from the `431di` development line
   were forwarded into this tree.

Sections marked ***Behaviour change*** alter how existing programs or configurations run. Please read those before upgrading.

## Short List of Highlights

- No license file required to start — up to **4 concurrent network instances** when `brserial` is absent
- Serial **52000** (former free 1-user license) is no longer valid
- `SET MAX_SORT_MEMORY` default raised to **64 MB** (ceiling **2000 MB**)
- `DATABASE` `USER=` / `PASSWORD=` credentials are now passed to the ODBC driver
- SQL statements gain a **query timeout** (90% of client/server reconnect time)
- Remote `LOCK` / `UNLOCK` retry on transient network errors
- New **[OPTION 76](#option-76-button-bar-minimum-size)** (button-bar scale) and **[OPTION 77](#option-77-enter-closes-a-new-print-preview)** (print-preview ENTER behaviour)
- File handles raised from **500 → 1000** (practical user maximum ~902)
- Session / WSID tracking by process ID; new error **10023**
- Manual reconnect: `CONFIG CLIENT_SERVER RECONNECT`
- Major **ODBC / SQL** reliability work (TIME columns, NVARCHAR binding, warnings, driver containment)
- **AIDX** / **DIDX** and **TIME\$** performance improvements
- Critical GUI fix: wxWidgets event handlers no longer run against the wrong object (VS2026)
- Unattended runs log **why** they stopped (essential for AI / automated BR use)
- Print preview: zoom, search, printer selection, view-as-PDF (32-bit only)
- Login credentials stored in **Windows Credential Manager** (with **Auto Login**)
- Build: **Visual Studio 2026** for `brclient` / `brserver`; wxWidgets 2.6.3 remains on VS2012

## Contents

- [1 Behaviour changes](#behaviour-changes)
  - [1.1 A license file is no longer required to start](#a-license-file-is-no-longer-required-to-start)
  - [1.2 Serial 52000 is no longer valid](#serial-52000-is-no-longer-valid)
  - [1.3 SET MAX_SORT_MEMORY — new default and new ceiling](#set-max-sort-memory-new-default-and-new-ceiling)
  - [1.4 DATABASE credentials are now sent to the ODBC driver](#database-credentials-are-now-sent-to-the-odbc-driver)
  - [1.5 SQL statements now have a query timeout](#sql-statements-now-have-a-query-timeout)
  - [1.6 Remote record locking now retries before failing](#remote-record-locking-now-retries-before-failing)
  - [1.7 Oversized pictures are constrained to the control](#oversized-pictures-are-constrained-to-the-control)
  - [1.8 An unusable PRINTDIR is now reported and ignored](#an-unusable-printdir-is-now-reported-and-ignored)
- [2 New and expanded capabilities](#new-and-expanded-capabilities)
  - [2.1 OPTION 76 — button-bar minimum size](#option-76-button-bar-minimum-size)
  - [2.2 OPTION 77 — ENTER closes a new print preview](#option-77-enter-closes-a-new-print-preview)
  - [2.3 File handles: 500 → 1000](#file-handles-500-1000)
  - [2.4 Session and workstation-ID tracking](#session-and-workstation-id-tracking)
  - [2.5 Mixed client/server releases](#mixed-clientserver-releases)
  - [2.6 Manual client/server reconnection](#manual-clientserver-reconnection)
  - [2.7 ODBC and SQL](#odbc-and-sql)
  - [2.8 Windows Credential Manager login storage](#windows-credential-manager-login-storage)
  - [2.9 New license environment variables](#new-license-environment-variables)
  - [2.10 64-bit lock positions (EXTERNAL huge-file POS=)](#64-bit-lock-positions)
  - [2.11 Formatted output of large values](#formatted-output-of-large-values)
  - [2.12 UNATTENDED runs now log why they stopped](#unattended-runs-now-log-why-they-stopped)
  - [2.13 Diagnostics on RPN stack limit error](#diagnostics-on-rpn-stack-limit-error)
  - [2.14 Short-read reporting](#short-read-reporting)
- [3 Performance](#performance)
  - [3.1 AIDX / DIDX array sorting](#aidx-didx-array-sorting)
  - [3.2 TIME\$](#time-performance)
  - [3.3 Numeric and string functions](#numeric-and-string-functions)
- [4 Fixes](#fixes)
  - [4.1 Print preview crashed on closing, on 64-bit](#print-preview-crashed-on-closing-on-64-bit)
  - [4.2 An unlicensed server faulted on WBPLATFORM\$](#an-unlicensed-server-faulted-on-wbplatform)
  - [4.3 A malformed file name no longer stops BR](#a-malformed-file-name-no-longer-stops-br)
  - [4.4 PRINTDIR failure produced a corrupt file name](#printdir-failure-produced-a-corrupt-file-name)
  - [4.5 Picture handling](#picture-handling)
  - [4.6 Session liveness detection](#session-liveness-detection)
  - [4.7 Reading SQL result data](#reading-sql-result-data)
  - [4.8 Other fixes](#other-fixes)
- [5 GUI and terminal](#gui-and-terminal)
- [6 Build and toolchain](#build-and-toolchain)
  - [6.1 Visual Studio 2026](#visual-studio-2026)
  - [6.2 wxWidgets 2.6.3 is patched locally](#wxwidgets-263-is-patched-locally)

## Behaviour changes

### A license file is no longer required to start

***Behaviour change***

BR previously refused to start unless it could find and validate `brserial.4x` or `brserial.dat` in its system directory. A missing file was a fatal error before the first program could run.

When there is **no license file at all**, BR uses serial number `123456788` and permits up to **4 concurrent instances on the network**. A 5th instance is refused, at which point the missing license is reported.

    Too many users on the system.
    User count is 4.
    A license file is required to run more than 4 concurrent instances on the network.
    OS Error 2 opening C:\BR\brserial.43
    OS Error 2 opening C:\BR\brserial.dat

A **valid license file behaves exactly as before**, including licenses for fewer than 4 users — the 4-instance allowance applies only when no license file exists. OPTION 9 still lowers the limit either way.

If you want to show your copyright and otherwise restrict use of your application, you will need to do so in your application.

The splash screen names the state rather than an absent licensee, and USERID\$ returns an empty string.

This feature pertains to BR itself. The ODBC driver and ONQ have their own licensing paths and are unchanged. The Limited model is no longer supported.

#### Sample: detect unlicensed/empty USERID\$

    00010 ! Detect empty USERID$ (no licensee when running without brserial)
    00020 LET Id$ = USERID$
    00030 IF Id$ = "" THEN !:
    00040    PRINT "Running without a licensee name (no license file, or empty licensee)."
    00050    PRINT "BR allows up to 4 concurrent network instances in this mode."
    00060 ELSE !:
    00070    PRINT "Licensed to: "; Id$
    00080 END IF
    00090 STOP

### Serial 52000 is no longer valid

***Behaviour change***

A license file carrying serial number **52000** (the former free 1-user version) is rejected:

    Serial 52000 is no longer valid.

<a id="set-max-sort-memory-new-default-and-new-ceiling"></a>
### SET MAX_SORT_MEMORY — new default and new ceiling

***Behaviour change***

| Setting        | Before   | Now           |
|----------------|----------|---------------|
| Default        | 8 MB     | **64 MB**     |
| Accepted range | 2–512 MB | **2–2000 MB** |

`MAX_SORT_MEMORY` balances the memory allocated to sorting and index processing against the memory available for caching.

Sorting and index builds will use more memory by default.

**Caution:** Values greater than **512 MB** should be used carefully. Additional memory may improve performance, but the benefit generally has diminishing returns and varies based on the environment, available memory, data size, and other concurrent activity.

#### Sample: raise sort memory for a large INDEX

    00100 ! Raise sort/index memory for a heavy INDEX/SORT job
    00110 EXECUTE "CONFIG MAX_SORT_MEMORY 256 MB"
    00120 EXECUTE "STATUS CONFIG"   ! Confirm MAX_SORT_MEMORY appears as expected
    00130 !
    00140 ! ... INDEX / SORT work here ...
    00150 !
    00160 EXECUTE "CONFIG MAX_SORT_MEMORY 64 MB"   ! restore the default for the session
    00170 STOP

See also CONFIG and STATUS CONFIG.

### DATABASE credentials are now sent to the ODBC driver

***Behaviour change***

**Read this if any DATABASE statement carries `USER=`, `PASSWORD=`, `PASSWORDD=` or `BR_PASSWORD`.**

    DATABASE sales DSN=SalesDSN USER=reports PASSWORD=secret

Credentials on a `DATABASE` statement were previously parsed, range-checked, and — for `PASSWORDD=` and `BR_PASSWORD` — decrypted, and then **discarded**. `SQLConnect` was called with an empty user name and an empty password, and the `CONNECTSTRING=` parameter was passed to the driver exactly as written. Whichever identity you connected as was the one the DSN or the connect string generated on its own.

They are **now used**. The `DSN=` path passes the user name and password to `SQLConnect`; the `CONNECTSTRING=` path appends `;UID=` and `;PWD=` to the string before connecting.

**What this can change**

- If the `USER=` / `PASSWORD=` on the statement are stale or were never real, the connection will now **fail** where it previously succeeded.
- If they are valid but name a *different* account from the one the DSN used, queries will run under the new account. Check that its permissions match what your programs expect.

Where a `CONNECTSTRING=` already contains its own `UID=`/`PWD=`, both now appear in the string. Which one wins is up to the driver — the ODBC specification says the first occurrence, but drivers vary. Do not rely on it: put the credentials in **one place only**.

**Caution:** STATUS `DATABASE` reports the connect string the *driver* returns after connecting. Now that a password can form part of what was sent, check what your driver echoes back before using that output anywhere it might be captured or logged.

#### Sample: DATABASE with explicit credentials

    01000 ! Prefer ONE place for credentials — here, on the DATABASE statement
    01010 DATABASE sales DSN=SalesDSN USER=reports PASSWORD=secret
    01020 !
    01030 DIM Sql$*800, CustName$*40
    01040 LET Sql$ = "SELECT TOP 1 CustomerName FROM Customers ORDER BY CustomerName"
    01050 EXECUTE #sales, Sql$: CustName$ IOERR BadSql
    01060 PRINT "First customer: "; CustName$
    01070 DATABASE CLEAR sales
    01080 STOP
    01090 !
    01100 BadSql: !
    01110 PRINT "SQL/IO error "; ERR; " — "; ERR$
    01120 DATABASE CLEAR sales
    01130 STOP

#### Sample: avoid duplicate UID/PWD on CONNECTSTRING

    01200 ! BAD after 4.33 — credentials in both places can confuse the driver
    01210 ! DATABASE sales CONNECTSTRING="DSN=SalesDSN;UID=old;PWD=old" USER=new PASSWORD=new
    01220 !
    01230 ! GOOD — credentials only on the statement
    01240 DATABASE sales CONNECTSTRING="DSN=SalesDSN" USER=reports PASSWORD=secret
    01250 DATABASE CLEAR sales
    01260 STOP

### SQL statements now have a query timeout

***Behaviour change***

`EXECUTE` and prepared-statement execution now set `SQL_ATTR_QUERY_TIMEOUT` before running, on drivers that support it. Previously, a query ran to completion, which was undesirable because the BRClient would disconnect and the session would crash.

The timeout is **90% of the client/server reconnect time**, which defaults to 120 seconds — so **108 seconds** unless you have changed it. It is set even in local (non-client/server) operation. There is no separate setting for it; it moves with:

    CONFIG CLIENT_SERVER RECONNECT_TIME=<seconds>

A long-running report or bulk `UPDATE` that previously completed after several minutes will now be canceled by the driver and returned to BR as an error. If you have such a query, raise `RECONNECT_TIME=` before upgrading, or move the work off the interactive path.

Drivers that do not implement the attribute are unaffected — support is probed dynamically (see [ODBC and SQL](#odbc-and-sql)).

#### Sample: allow a long interactive report

    02000 ! Allow ~15 minutes of SQL time (90% of 1000s ≈ 900s)
    02010 EXECUTE "CONFIG CLIENT_SERVER RECONNECT_TIME=1000"
    02020 !
    02030 DATABASE sales DSN=SalesDSN USER=reports PASSWORD=secret
    02040 DIM Sql$*1000
    02050 LET Sql$ = "EXEC dbo.usp_YearEndReport"
    02060 EXECUTE #sales, Sql$ IOERR LongFail
    02070 PRINT "Report completed."
    02080 DATABASE CLEAR sales
    02090 STOP
    02100 !
    02110 LongFail: !
    02120 PRINT "Query failed/canceled: "; ERR; " "; ERR$
    02130 PRINT "If this is a timeout, raise RECONNECT_TIME further or run offline."
    02140 DATABASE CLEAR sales
    02150 STOP

### Remote record locking now retries before failing

***Behaviour change***

LOCK and UNLOCK against a file on a remote connection previously failed immediately on a network error. They now retry with exponential backoff: 1 ms, 10 ms, 100 ms, 500 ms, 1 s.

This makes transient network interruptions survivable. The trade-off is latency: an operation against a genuinely dead connection now takes roughly **1.6 seconds** (unlock) to about **6.6 seconds** (lock, where the retry count is derived from the requested timeout) before it reports failure, where it used to report failure at once.

Ordinary lock contention is unaffected. Only *connection* errors retry; a lock that fails because another user holds the record still returns immediately, as before.

#### Sample: lock with explicit error handling

    03000 OPEN #1: "NAME=@:C:\Local_DataFolder\CUST.DAT,KPS=1,KLN=6", INTERNAL, OUTIN, KEYED
    03010 DIM Key$*6, Rec$*128
    03020 LET Key$ = "000100"
    03030 READ #1,USING "FORM C 6,C 122",KEY=Key$: Key$, Rec$ NOKEY NoCust LOCKED Held
    03040 !
    03050 ! HOLD / update path — remote LOCK retries are inside BR on connection errors
    03060 REWRITE #1,USING "FORM C 6,C 122": Key$, Rec$ IOERR IoFail
    03070 CLOSE #1
    03080 STOP
    03090 !
    03100 NoCust: PRINT "Customer not found": CLOSE #1: STOP
    03110 Held:   PRINT "Record locked by another user (immediate)": CLOSE #1: STOP
    03120 IoFail: PRINT "I/O error "; ERR; " "; ERR$: CLOSE #1: STOP

### Oversized pictures are constrained to the control

***Behaviour change***

Previously, when a picture was larger than its control, the positioning calculation did not correctly use the control’s dimensions. The picture remained at its original size and was centered by using negative horizontal and vertical offsets.

As a result, the control displayed the center portion of the picture, while the excess was cropped approximately evenly from the left, right, top, and bottom.

Pictures are now constrained so that their horizontal and vertical offsets cannot be less than zero. An oversized picture therefore begins at the control’s top-left corner. Any portion extending beyond the control is cropped from the right and bottom.

The picture-sizing options behave as follows:

- **No sizing option** stretches the picture to fill the control exactly. The picture’s original aspect ratio is not preserved, so the image may appear distorted.
- `ISOTROPIC` resizes the picture to fit within the control while preserving the picture’s original aspect ratio. The picture is not stretched or distorted.
- `NORESIZE` keeps the picture at its original resolution. If the picture is larger than the control, only the portion that fits within the control is displayed.
- `TILE` keeps the picture at its original size and repeats it horizontally and vertically when the picture is small enough for multiple copies to fit within the control.

The new oversized-picture positioning behaviour applies to `NORESIZE` and `TILE`, where the document’s positioning and clipping rules determine which portion of the picture is displayed.

Pictures using no sizing option are resized to the exact dimensions of the control and therefore do not remain oversized. Pictures using `ISOTROPIC` are resized proportionally to fit within the control and are also unaffected by the oversized-picture positioning change.

Pictures that already fit within the control are unchanged.

### An unusable PRINTDIR is now reported and ignored

***Behaviour change***

A PRINTDIR naming a directory that cannot be resolved — a bad path, or one on a drive that is not there — used to be ignored silently. Printing continued, but the print-directory copy went nowhere and, in this release, could take BR down (see [Fixes](#printdir-failure-produced-a-corrupt-file-name)).

The failure to find PRINTDIR is now logged, and the print directory is not used:

    PRINTDIR "M:\app\prt" is not a directory, so it is not being used.

Printing itself is unaffected — only the archive copy is skipped. BR retries on each print job, so a directory on a disconnected drive starts working again by itself once the drive returns; the trade-off is one log line per print job until it does.

#### Sample: set PRINTDIR from a program

    04000 ! Point PRINTDIR at a reachable path; bad paths are logged and skipped
    04010 EXECUTE "CONFIG PRINTDIR N:\archives\prt"
    04020 EXECUTE "STATUS CONFIG"
    04030 STOP

## New and expanded capabilities

<a id="option-76-button-bar-minimum-size"></a>
### OPTION 76 — button-bar minimum size

A new OPTION scales the **minimum** size of the button bar:

    OPTION 76 150     ! button bar floor at 150% of standard minimum size

It takes a number from **1 to 500**, being a percentage of the standard minimum size. The default is **100**, which is the previous behaviour. It applies to the button-bar row height, the button height, and the space above the buttons, and is coordinated between client and server. STATUS CONFIG reports it.

#### Why a floor exists (tiny buttons on remote VDI)

The button-bar design sizes are expressed in **points** (row 30, button 24, space-above 3), then converted to device pixels with `LogicalToDeviceY` under `wxMM_POINTS`. That conversion depends on the display's DPI mapping.

On some remote VDI / VMware sessions with mismatched DPI scaling, the conversion returned unusably small values (observed around **rowHeight=7** / **buttonHeight=5**). Without a floor, operators saw "tiny buttons."

OPTION 76 supplies that floor:

    effective = max(DPI_converted_pixels, (design_points * OPTION_76) / 100)

At the default of **100**, the floors are 30 / 24 / 3 pixels when DPI conversion undershoots. Raising the option (e.g. 150) raises the floor; lowering it allows a smaller bar, but never below `(points × factor) / 100`.

#### Built-in ceiling (huge buttons)

Independently of OPTION 76, hard pixel **ceilings** clamp the same three metrics after the floor is applied:

| Metric             | Design (points) | Hard max (pixels) |
|--------------------|-----------------|-------------------|
| Row height         | 30              | **50**            |
| Button height      | 24              | **40**            |
| Space above button | 3               | **20**            |

Even `OPTION 76 500` cannot grow past these caps. That is what prevents "huge buttons" when DPI conversion overshoots or when a large percentage is requested.

A final fit check then shrinks button height if it no longer fits in the row:

    while rowHeight < buttonHeight + aboveButton
        buttonHeight = buttonHeight - 1

#### Sizing pipeline

    points  →  LogicalToDeviceY (DPI)
                     ↓
                max(…, OPTION 76 floor)     ← no tiny buttons
                     ↓
                min(…, hard pixel caps)     ← no huge buttons
                     ↓
                shrink button if needed     ← must fit in row

- **Remote VDI, bad DPI (tiny conversion):** the OPTION 76 floor dominates → usable buttons.
- **High DPI / oversized conversion, or a high OPTION %:** the 50 / 40 / 20 caps dominate → no giant bar.
- **Normal local display, OPTION 76 100:** DPI conversion and the 100% floor are usually close; the caps rarely bite.

#### Naming / OPTION numbering discrepancy

**Todo:** this numbering should be resolved in source and docs.

- The implemented control is **OPTION 76** (`g_buttonMinFactor`) — percentage floor for minimum button-bar size.
- Source comments also mention a possible companion OPTION that would define a **maximum** size percentage (default 100, set lower when buttons are giant). That max-size OPTION was **not** implemented.

#### Sample

    05000 EXECUTE "CONFIG OPTION 76 125"
    05010 PRINT "Button bar minimum size set to 125% of standard"
    05020 EXECUTE "STATUS CONFIG"   ! look for OPTION 76 in the listing
    05030 STOP

<a id="option-77-enter-closes-a-new-print-preview"></a>
### OPTION 77 — ENTER closes a new print preview

The print preview control bar was rearranged in this release, and one consequence is that pressing **ENTER** immediately after a preview opens starts a print. Before 4.33 it closed the preview.

    OPTION 77 ON      ! ENTER closes a newly opened preview, as before 4.33

The default is **OFF**, so the new behaviour stands unless you ask for the old one. With it on, the Close button is made the default and given the focus when the preview opens. The setting is coordinated between client and server, and STATUS CONFIG reports it.

#### Sample

    05100 ! Restore pre-4.33 ENTER-closes-preview behaviour for operators who expect it
    05110 EXECUTE "CONFIG OPTION 77 ON"
    05120 STOP

<a id="file-handles-500-1000"></a>
### File handles: 500 → 1000

The active file-handle table was capped at **500**, below the range BR actually supports (handles up to 999, with a gap at 200–299 reserved for printing). The cap is now **1000**, giving a practical user maximum of **902**. Programs that previously ran out of handles on large workloads should no longer do so.

Error **4160** (`WBENOFILES` — out of internal file handles) is still raised if the table is exhausted; the table is simply larger.

#### Sample: open many work files without exhausting handles

    06000 DIM H, Name$*64, Opened
    06010 LET Opened = 0
    06020 FOR H = 1 TO 100
    06030    IF H >= 200 AND H <= 299 THEN GOTO 6070   ! skip print-reserved band
    06040    LET Name$ = "TEMP\WORK" & STR$(H) & ".DAT"
    06050    OPEN #H: "NAME=" & Name$ & ",SIZE=0,REPLACE", INTERNAL, OUTPUT IOERR SkipOpen
    06060    LET Opened = Opened + 1
    06070 SkipOpen: !
    06080 NEXT H
    06090 PRINT "Opened "; Opened; " files (limit is now much higher than ~497)"
    06100 FOR H = 1 TO 100
    06110    IF H >= 200 AND H <= 299 THEN GOTO 6130
    06120    CLOSE #H IOERR 6130
    06130 NEXT H
    06140 STOP

### Session and workstation-ID tracking

Session handling was reworked to track sessions by process rather than by registry entry alone:

- Session liveness is now validated against a real process handle, so a crashed session no longer leaves an entry that looks occupied.
- `WBSERVER.DAT` login records carry a process ID. The record length is unchanged at 64 bytes (the name field is 60 characters, previously 64).
- Registry keys are now per-listener-port, so multiple listeners on one machine no longer collide.
- A new error, **10023** — *"too many sessions - maximum 9 sessions allowed"* — is raised when the session limit is reached, instead of failing less clearly.

The PID recorded is the **BRClient** process. The client stamps its own process ID into the configuration it returns to the server during startup, and the server files it against the WSID. In local (non-client/server) mode the two are the same process, so the value is the same either way.

#### Sample: surface WSID / session identity

    07000 PRINT "WSID="; WSID$; "  LOGIN="; LOGIN_NAME$; "  USERID$="; USERID$
    07010 PRINT "If error 10023 appears at connect, too many sessions are active (max 9)."
    07020 STOP

### Mixed client/server releases

The configuration record exchanged between client and server has gained a process-ID field, taking it from **390 to 394** bytes.

Running a 4.3 server against an older client, or the reverse, remains **unsupported** — upgrade both ends together. When mixed, degradation is more predictable than before, but you should not rely on mixed-version operation.

### Manual client/server reconnection

A new configuration statement (via EXECUTE) forces an immediate reconnect:

    CONFIG CLIENT_SERVER RECONNECT

Reconnect and keep-alive timeouts are coordinated across both ends. BRClient uses the configured (shorter) timeout for frequent retries, while BRServer waits slightly longer, so the two do not give up simultaneously.

Related settings:

    CONFIG CLIENT_SERVER RECONNECT_TIME=<seconds>
    CONFIG CLIENT_SERVER RECONNECT_AFTER=<seconds>

#### Sample: force reconnect after a network hiccup

    08000 ! After detecting a stale connection in application logic:
    08005 EXECUTE "CONFIG CLIENT_SERVER RECONNECT_AFTER=10 RECONNECT_TIME=10" ! Allow 10 seconds to reconnect
    08010 EXECUTE "CONFIG CLIENT_SERVER RECONNECT" IOERR ReconnFail
    08020 PRINT "Reconnect requested."
    8025 EXECUTE "CONFIG CLIENT_SERVER RECONNECT_AFTER=10 RECONNECT_TIME=10" ! Allow 10 seconds to reconnect
    08030 STOP
    08040 !
    08050 ReconnFail: !
    08060 PRINT "Reconnect failed: "; ERR; " "; ERR$
    08065 EXECUTE "CONFIG CLIENT_SERVER RECONNECT_AFTER=120 RECONNECT_TIME=120" ! Allow 120 seconds to reconnect
    08070 STOP

### ODBC and SQL

This is the largest single body of work in the release. The changes fall into four groups.

#### More of SQL Server's type system is usable

- **TIME columns can be read.** SQL Server's `TIME` type is reported over ODBC as the driver-specific type `SQL_SS_TIME2`, which BR did not recognise. Any query returning a `TIME` column failed outright with an undefined-data-type error. It is now bound as a string, like the other time and interval types.
- **NVARCHAR columns are no longer bound short.** A wide variable-length column was bound at the column size the driver reported, which for an `NVARCHAR(MAX)` column is not a usable length — such columns came back empty or truncated. Every `SQL_WVARCHAR` column is now bound at `DATABASE MAX_COLUMN_WIDTH` instead, which defaults to **2000** characters.

  
Note the cost: this applies to *all* `NVARCHAR` columns, not only `MAX` ones, so an `NVARCHAR(20)` now reserves 2000 bytes in the fetch buffer rather than 21. On a query with many narrow wide-character columns the per-row buffer grows accordingly. Lower `DATABASE MAX_COLUMN_WIDTH` if that matters more to you than long values.

- **A column of a type BR does not handle now says which column and which type.** Previously the statement simply failed with no indication of where the problem was.

#### Warnings are no longer treated as failures

ODBC reports "succeeded, with something to tell you" as `SQL_SUCCESS_WITH_INFO`. BR accepted it when connecting, but treated it as an error everywhere else — allocating a statement, preparing, executing, describing and binding columns. Any statement that produced a warning therefore failed.

This matters most against SQL Server, which returns informational messages routinely: a truncation warning, a null eliminated from an aggregate, or output from `PRINT`. `SQL_SUCCESS_WITH_INFO` is now accepted at every call site, and the accompanying diagnostic records are logged rather than thrown away.

Relatedly, SQL Server's `5701` ("changed database context") and `5703` ("changed language setting") notices arrive on every connection and were logged as I/O errors. They are now logged as ordinary events.

#### Long queries no longer break the client connection

The keep-alive timer is reset when a statement finishes. A query that took longer than the keep-alive interval used to leave BRClient believing the connection had gone, producing a spurious reconnect — or a disconnect — immediately after a slow report returned.

#### A badly behaved driver is contained rather than fatal

- **Query-timeout support is probed, not assumed.** A new module, `odbc_query_timeout_support`, sets a timeout on a scratch statement once per driver and caches the answer against the driver name. A driver answering `HYC00` ("optional feature not implemented") is recorded as unsupported and is never sent the attribute again. This replaces maintaining a list of driver names, which goes stale as drivers are updated or renamed.
- **Statements are freed before the connection is dropped.** `DATABASE CLEAR` used to disconnect while statement handles were still open. Some drivers — the Microsoft Access driver in particular — crash when that happens. All statements belonging to a connection are now closed and freed first, then the connection, then the environment handle, with each step logged if it fails and none of them able to prevent the rest from running. Closing a database twice is now harmless.
- **The ODBC entry points most likely to fault are wrapped in structured exception handling** on Windows — `SQLDisconnect`, `SQLFreeHandle`, `SQLDriverConnect`, `SQLCloseCursor`, `SQLEndTran` and setting autocommit. A driver that faults inside one of these is reported as a driver bug, with its diagnostic records, instead of taking BR down. The unix build calls them directly, as before, and is unaffected.
- **Diagnostics are uniform.** A single routine drains and logs every diagnostic record from a failing handle, and is called from all call sites.
- **Separate input and output buffers are used for `SQLDriverConnect`.** Passing one buffer as both is another known way to crash the Access driver.

#### Sample: read a SQL Server TIME column

    09000 DATABASE sales DSN=SalesDSN USER=reports PASSWORD=secret
    09010 DIM Sql$*200, OpenTime$*32, LocName$*40
    09020 LET Sql$ = "SELECT LocationName, OpenTime FROM Stores WHERE StoreId = 1"
    09030 EXECUTE #sales, Sql$: LocName$, OpenTime$ IOERR SqlErr
    09040 PRINT LocName$; " opens at "; OpenTime$
    09050 DATABASE CLEAR sales
    09060 STOP
    09070 !
    09080 SqlErr: PRINT "Error "; ERR; " "; ERR$: DATABASE CLEAR sales: STOP

#### Sample: tune MAX_COLUMN_WIDTH for many NVARCHAR columns

    09100 ! Smaller fetch buffers when every column is a short NVARCHAR
    09110 EXECUTE "CONFIG DATABASE MAX_COLUMN_WIDTH 256"
    09120 DATABASE sales DSN=SalesDSN USER=reports PASSWORD=secret
    09130 ! ... queries with many narrow NVARCHAR columns ...
    09140 DATABASE CLEAR sales
    09150 !
    09160 ! Restore a wider default when reading NVARCHAR(MAX) / long text
    09170 EXECUTE "CONFIG DATABASE MAX_COLUMN_WIDTH 2000"
    09180 STOP

#### Sample: safe DATABASE CLEAR

    09200 DATABASE sales DSN=SalesDSN USER=reports PASSWORD=secret
    09210 ! ... work ...
    09220 DATABASE CLEAR sales
    09230 DATABASE CLEAR sales   ! second clear is now harmless
    09240 STOP

### Windows Credential Manager login storage

BR 4.33 stores client/server **login credentials** in the **Windows Credential Manager**, so operators are no longer forced to re-type them as often after the listener’s in-memory cache is gone.

Note: Todo: The Login screen is displaying "" instead of the label from BR_PARMS.txt

#### Before 4.33

**BRListener** has always been able to cache credentials **in memory** for convenience during a run of the listener process. That cache does not survive listener restarts, machine reboots, or other periods when the in-memory state is cleared. After those events, the user was required to re-enter the user name and password in the login dialog.

#### What 4.33 adds

On Windows, a successful login now **writes** the user name and password to the Credential Manager under the generic target name `Business Rules!` (`CRED_PERSIST_LOCAL_MACHINE`). The next time the login dialog opens, BR **reads** those values and prefills the dialog.

The login dialog includes an **Auto Login** checkbox.

- Checking **Auto Login** remembers the preference (registry) so a later connect can submit automatically when saved credentials are present (after a short delay).
- Completing the dialog with **OK** stores the entered credentials in Credential Manager (whether or not Auto Login is checked).
- A **logoff** clears the Auto Login preference and **deletes** the stored `Business Rules!` credential, so the next connect starts clean.

This is a **client-side Windows** enhancement. It does not replace listener authentication rules; it persists what the operator already typed so BRListener’s temporary in-memory cache is no longer the only place credentials live between prompts.

#### Operator notes

- Inspect or remove the entry with Windows Credential Manager (Control Panel / Settings → Credential Manager → Windows Credentials / Generic credentials) under target **Business Rules!**.
- If Auto Login submits a bad password, BR does not keep retrying in a loop; the operator must correct the dialog (or clear the stored credential / uncheck Auto Login).
- Non-Windows clients are unchanged for this feature.

### New license environment variables

The license environment has been enhanced with the following variables:

| Variable                 | Description                             | Example |
|--------------------------|-----------------------------------------|---------|
| `LICENSE`                | Business Rules serial number            |         |
| `LICENSE.DEALER`         | Dealer number assigned to the reseller  |         |
| `LICENSE.BR`             | Licensed Business Rules version         | `4.31`  |
| `LICENSE.BR_USERS`       | Number of licensed Business Rules users |         |
| `LICENSE.SCREENIO`       | Licensed ScreenIO version               | `2.0`   |
| `LICENSE.SCREENIO.USERS` | Number of licensed ScreenIO users       |         |
| `LICENSE.ODBC`           | Licensed ODBC version                   | `4.31`  |
| `LICENSE.ODBC.USERS`     | Number of licensed ODBC users           |         |

**Note:** ODBC continues to function, but it is not compatible with Client Server.

#### Access Example

    13000 EXECUTE "STATUS ENV LICENSE"
    13010 PRINT "Dealer="; ENV$("LICENSE.DEALER")

<a id="64-bit-lock-positions"></a>
### 64-bit lock positions (EXTERNAL huge-file POS=)

Locking for INTERNAL files uses 1 byte per record. Locking on EXTERNAL files is byte oriented without regard to records. So on an EXTERNAL file the byte at POS= is locked by shared READs. This requires substantially more lock space than record oriented locking. 

The in-memory array of locked positions was widened from **32-bit** to **64-bit** to accomodate large INTERNAL file locking. The current-record / byte position it is compared against was already 64-bit; the lock array was not, so lock tracking could not reliably match positions past the signed 32-bit range.

**INTERNAL files** are otherwise unchanged for this purpose: file size may already be tracked in 64-bit, but the maximum number of records remains a **4-byte signed integer** (about **2 billion** records). INTERNAL record locking does not gain a new “more than 2 billion records” capability from this change.

**EXTERNAL files** are where the wider lock pointers matter. They can use the new 64-bit lock positions to support record locking on **huge files** when addressing with `POS=` values **greater than 2 billion** (byte positions past the old signed 32-bit limit). Without the widened lock array, those locks could not be tracked correctly even when the file position itself was already 64-bit.

#### Sample: EXTERNAL lock with a large POS=

    15000 DIM Line$*255
    15010 OPEN #1: "NAME=@:C:\LocalData\HUGE.TXT,recl=1024", DISPLAY, OUTIN
    15020 !
    15030 ! Byte position beyond 2^31-1 — lock tracking now uses 64-bit positions
    15040 READ #1,POS=3000000000: Line$ LOCKED Held IOERR IoFail
    15050 PRINT "Read and locked at POS=3000000000"
    15060 CLOSE #1
    15070 STOP
    15080 !
    15090 Held:   PRINT "Position locked by another user": CLOSE #1: STOP
    15100 IoFail: PRINT "I/O error "; ERR; " "; ERR$: CLOSE #1: STOP

### Formatted output of large values

STATUS `FILES` printed record numbers and locked-record positions through 32-bit format specifiers, truncating them for large files. Corrected.

### UNATTENDED runs now log why they stopped

This is an essential feature for AI use with Business Rules, and for any unattended / batch automation.

`CONFIG LOGGING ... UNATTENDED` runs with no operator, so anything that puts BR at the command prompt ends the run — the client exits 99 as soon as it blocks for a keystroke. Until now the only trace of this was `Input attempted in unattended mode while processing main keyboard entry routine`, which says what BR was doing at the end but nothing about what went wrong.

BR now logs a `MAJOR_ERROR` naming the cause before the prompt is offered:

    Unattended processing terminated by error 4152 while running a program.  Program PAYROLL, line 1240.  file not found
    Unattended processing terminated by error 1001 while loading a program from source.  Program PAYROLL, line 0.  invalid use of reserved word
    Unattended processing terminated at the command prompt after a program was loaded from source.  Program PAYROLL, line 0.
    Unattended processing terminated at the command prompt with no operator available to respond.  Program PAYROLL, line 0.

The cause is recorded at the three points that can reach the prompt — an untrapped runtime error, a command or immediate-statement error, and the completion of a `LOAD` from source — and logged where the prompt is actually offered, so it is never reported for a run that carries on from a proc file. Loading a program from source is called out separately because an unattended job that does it has nothing left to run: it reaches Ready and dies, with no error to explain itself.

The existing `Input attempted in unattended mode` message still follows and confirms the exit.

#### Sample: enable unattended logging

    14000 ! Typical unattended / AI harness setup (also valid in BRConfig.sys)
    14010 EXECUTE "CONFIG LOGGING FILE=BRUNATTEND.LOG REPLACE UNATTENDED"
    14020 !
    14030 ! Ensure the job ends by STOP/CHAIN/proc flow — not by falling to Ready
    14040 ! after LOAD ... source, or an untrapped error will be named in the log.
    14050 STOP

Note: Todo: This is a new feature for 4.33, and is not included with 4.31hdi

### Diagnostics on RPN stack limit error

When an internal expression-stack limit error is detected, BR now logs a full `STATUS STACKS`-style snapshot — work, flow, RPN and FOR stack usage, plus a program backtrace — before asserting. Previously, it reported two pointer values.

### Short-read reporting

A file read returning fewer bytes than requested is again logged as a diagnostic event. This reporting had been suspended.

## Performance

<a id="aidx-didx-array-sorting"></a>
### AIDX / DIDX array sorting

The internal sorting used by AIDX and DIDX has been rewritten to improve performance and reduce temporary memory use.

`AIDX` and `DIDX` do not rearrange the original array. Instead, they return an array of index numbers showing the order in which the original values should be read.

For example, if the original array contains:

    Delta
    Alpha
    Charlie
    Bravo
    Alpha

`AIDX` returns index numbers that allow the values to be read in alphabetical order.

Internally, the revised implementation:

- Allocates one temporary work area instead of two.
- Reuses a separate work buffer for each processing thread rather than repeatedly allocating and releasing memory.
- Uses the C++ Standard Library sorting routine `std::sort`.
- Allows the compiler to place the comparison logic directly into the sort operation. In C++ this is called an **inlinable comparator**, and it avoids some of the overhead associated with repeatedly calling a separate comparison function.
- Replaces the previous **merge sort** implementation, which performed sorting through C++ function pointers.

These are internal implementation changes. BR programs do not need to be changed.

**Results are unchanged.** The returned index order is compatible with the previous implementation, including when two array elements contain the same value.

When values are equal, BR uses their original array positions as the tie-breaker. This creates a consistent and predictable order for duplicate values.

#### Sample

    10000 DIM Name$(1)*30, Idx(1), N, I
    10010 LET N = 5
    10020 MAT REDIM Name$(N), Idx(N)
    10030 LET Name$(1) = "Delta": LET Name$(2) = "Alpha": LET Name$(3) = "Charlie"
    10040 LET Name$(4) = "Bravo": LET Name$(5) = "Alpha"
    10050 MAT Idx = AIDX(Name$)
    10060 FOR I = 1 TO N
    10070    PRINT Idx(I); " "; Name$(Idx(I))
    10080 NEXT I
    10090 STOP

The output shows the original array positions in sorted order:

    2 Alpha
    5 Alpha
    4 Bravo
    3 Charlie
    1 Delta

The two `Alpha` values remain in their original relative order: element 2 appears before element 5.

<a id="time-performance"></a>
### TIME\$

TIME\$ now caches its formatted result and reformats at most once per second. A tight loop calling `TIME$` repeatedly is substantially cheaper. The returned value is unchanged.

#### Sample

    11000 DIM T$, I, Start
    11010 LET Start = TIMER
    11020 FOR I = 1 TO 100000
    11030    LET T$ = TIME$
    11040 NEXT I
    11050 PRINT "Last TIME$="; T$; "  elapsed="; TIMER - Start
    11060 STOP

### Numeric and string functions

IP, FP and RND now use direct truncation and remainder operations instead of computing both parts of the split and discarding one. Results are identical for all finite inputs. Assorted obsolete `register` declarations were removed.

## Fixes

### Print preview crashed on closing, on 64-bit

Closing a print preview could fail with an access violation while writing through a null `DEVMODE` pointer.

Print preview was debugged, including operator printer selection. Local patches address 64-bit `HGLOBAL` truncation in print-handle storage.

<a id="an-unlicensed-server-faulted-on-wbplatform"></a>
### An unlicensed server faulted on WBPLATFORM\$

With no license file installed, the first WBPLATFORM\$ in a program crashed BRServer.

`platformName` is decoded from a compile-time constant and has nothing to do with licensing, but the only call that populated it sat inside the license-processing routine — which the new unlicensed start path skips. It was therefore null for the whole run. It is now built during static initialisation, which also covers BRODBC and `odbcreset`, neither of which ever called it.

`ENV$("SERVER_PLATFORM")` reached the same null pointer and is fixed by the same change. `WBPLATFORM$` now also range-checks its copy and tolerates the client platform name not having arrived yet.

#### Sample

    12000 PRINT "WBPLATFORM$="; WBPLATFORM$
    12010 PRINT "ENV SERVER_PLATFORM="; ENV$("SERVER_PLATFORM")
    12020 STOP

### A malformed file name no longer stops BR

The routine that translates a BR file name to an operating-system path enforced its "drive letter, colon, backslash" requirement with assertions, which dump core. These were not conditioned on a debug build, so a name that reached it in the wrong form stopped release builds too.

It now reports the name and returns "bad name" to its caller, which every caller already handles — the same treatment the routine already gave to an over-long name:

    "file.cpp wbisdirectory errorshipedit.255" is not a BR filename.  A drive letter, a colon and a backslash are required.

### PRINTDIR failure produced a corrupt file name

`printDirMakePath` signalled failure by returning the *text of the complaint* as though it were a path. Both callers test only for a null return, which therefore never happened, so the message was accepted as the print directory and the program name and channel were appended to it. The result was handed to the name translator above, which is what stopped BR. See [Behaviour changes](#an-unusable-printdir-is-now-reported-and-ignored) for how this is reported now.

### Picture handling

Several faults found while tracing the event-handler defect above, all correct independently of it:

- A picture that fails to decode yields a valid image object with zero dimensions. It was accepted as usable and failed much later inside a paint handler; it is now rejected at load and flows into the existing "picture not found" path.
- A degenerate scaling request killed the client through an assertion. It is now logged as a `MINOR_ERROR` naming the box, the picture and the scaling attributes, and the picture is drawn unscaled or skipped.
- Box-size tests that rejected zero but accepted **negative** extents now reject both, and the isotropic branch no longer divides by an unchecked picture dimension.
- Missing `drawline.bmp` / `drawsunk.bmp` falls back to the thin-line renderer instead of asserting.
- Null checks on picture-size queries, and the line-draw resource type is initialised in its constructor.

### Session liveness detection

While a session is starting — before its window exists — it is identified by process ID. Two faults in that check are fixed:

- **A live session could be declared dead.** The check asked for more access than Windows grants across user accounts and read the refusal as "session gone", so on a shared or terminal-server machine a second user could reclaim the workstation ID of a healthy session owned by **another account, or running elevated**. It now requests only the access Windows does grant across accounts, and treats a refusal as alive.
- **A dead session could be declared live.** Process IDs are recycled, so a number left by a dead session can be reissued to something unrelated. BR now records the process's creation time alongside its ID and compares both.

No action is needed on upgrade: session records written by an earlier release carry no creation time, fall back to the previous check, and are refreshed when the session next registers.

### Reading SQL result data

***Reliability and safety improvements***

Several faults in moving a fetched SQL row into BR variables are fixed.

The SQL interface has been hardened to handle differences between database drivers more safely and consistently.

When BR reads a row returned by SQL, the database driver places each column into a temporary memory buffer. BR then converts that buffered value into a Business Rules variable. Problems in this process could cause valid data to be rejected, truncated data to be copied incorrectly, or internal memory to be mishandled.

These corrections do not change the intended SQL results. They improve compatibility with different ODBC drivers and make error handling safer.

- **Numeric columns now work with more drivers.** Numeric values are stored internally as a C++ `double`, an eight-byte floating-point value. Some older SQL Server drivers report the size of the original database column instead—for example, 4 bytes for an `INT` or 2 bytes for a `SMALLINT`. BR incorrectly compared that reported size with the eight-byte internal buffer and rejected valid rows as unmappable. Similar checks could reject valid date and timestamp values. These checks have been removed because the ODBC binding already guarantees the format of the destination buffer.

<!-- -->

- **Truncated strings can no longer be read past the end of their buffer.** When a string is too large for the available buffer, ODBC may have reported the full length the value would have required, rather than the number of characters actually written. BR previously used that larger value when copying the string. The copy length is now limited to the actual buffer size. The special ODBC value `SQL_NO_TOTAL`, which means that the driver cannot report the full length, is also handled correctly.

<!-- -->

- **Table and column metadata can no longer overflow their buffers.** SQL drivers return descriptive information known as *metadata*, including table names and column names. Previously, the returned length could be used before it was validated, and the length variable itself was not initialized. Lengths are now initialized and checked. An over-length value is safely shortened and recorded in the log instead of being written beyond the available memory.

<!-- -->

- **Qualified table names are now assembled safely.** A qualified table name normally contains both a schema and table name, such as `dbo.Customers`. The previous code combined two fields of up to 1000 bytes inside a 400-byte buffer using the unbounded C++ functions `strcpy` and `strcat`. It now uses a size-limited copy. The resulting name is otherwise unchanged: `ENV$` continues to use only the table name and deliberately omits the schema prefix.

<!-- -->

- **Empty strings can now be passed as SQL parameters.** An empty string was previously described to the driver as having a maximum size of zero. Some drivers reject a parameter with a zero-length definition. Empty strings are now bound with a minimum size of one.

<!-- -->

- **Failed connections are cleaned up correctly.** When an SQL connection failed, BR released the ODBC environment handle but did not clear the stored pointer. A later `DATABASE CLEAR` could attempt to release the same handle again. The pointer is now cleared immediately after the handle is freed.

<!-- -->

- **Column counts and memory positions are validated.** BR now validates the number of returned columns and the location of each column within its internal memory before allocating memory or binding the column. If any step fails, all memory allocated during the operation is released correctly.

### Other fixes

- Crash-dump handling no longer assigns a string literal to a mutable pointer.
- The splash-screen copyright line now reads `(c) Copyright 1983-`*`yyyy`*` Application Development Systems | All Rights Reserved`.
- A failed `LoadLibrary` no longer raises a message box. The failure is still returned to the caller and handled there.
- Session-table diagnostics no longer read uninitialized memory when deciding what to log. Affected log output only, but the session table is now also cleared when the registry cannot be reached, rather than left holding whatever was on the stack.

## GUI and terminal

- Button-bar sizing is driven by [OPTION 76](#option-76-button-bar-minimum-size) and is coordinated between client and server.
- Client-server connection-failure dialogs report the failure and exit cleanly rather than continuing in an indeterminate state.
- Auto-login credentials are read and written through **Windows Credential Manager**.
- Window maximized state is now saved and restored along with size and position.
- Assorted keyboard-buffer and status-line handling corrections.
- The print preview control bar was rearranged, gaining zoom-mode and zoom-percentage controls, print-current-page and printer-selection buttons, and a text search box. [OPTION 77](#option-77-enter-closes-a-new-print-preview) restores the previous ENTER behaviour.
- A **view-as-PDF** button renders the previewed report to a temporary PDF and opens it in the default viewer. It requires pdflib, which is available only as a 32-bit library, so **the button is present but disabled on 64-bit clients** — its tooltip says so. It is usable only from a 32-bit BRClient.
- BRClient now records why it is exiting. Three paths — the crash-dump routine, the client's fatal-error routine, and its exit routine — either logged nothing or logged where it could not be sent. Client log lines are queued until a packet fills, so anything written immediately before exit was discarded; the queue is now flushed on the way out. An orderly shutdown previously left the log stopping mid-sentence, indistinguishable from the process being killed.

## Build and toolchain

### Visual Studio 2026

`brclient`, `brclientexe` and `brserver` build with the **v145** toolset. Building these no longer requires Visual Studio 2012. This required substantial changes to interface with wx263.

The GUI event-handler offset defect (above) became fatal under this compiler; fixing it was a prerequisite for a usable VS2026 GUI build.

### wxWidgets 2.6.3 is patched locally

**wx263 is still built with Visual Studio 2012 (v110) and always will be.**
