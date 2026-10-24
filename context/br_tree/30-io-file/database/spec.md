---
title: Database operations (SQL / ODBC)
file: spec.md
source: 'CONFIG DATABASE (00-configuration/config-directives) + SQL/ODBC error codes (90-reference/error-codes 3002–3015, 4002–4015, 0366, 4270) + wiki DATABASE page + 4.3/4.30 release notes (90-reference/limits-constants: OPEN…SQL inline/file forms, ENVDB.BRS STATUS.DATABASE interrogation). Worked examples derived from the BR "brg_demo" SQL example set (db_connect / mysql_read / mysql_write / sqlite_read / sqlite_write.wbs, dsn.fil — working material, since pruned)'
category: 30-io-file
subcategory: 30-io-file/database
kind: spec
status: 2b           # verified against config-directives (CONFIG DATABASE), error-codes 3002–4270, wiki DATABASE page, and 4.3/4.30 release notes (OPEN…SQL inline/file forms, ENVDB.BRS STATUS.DATABASE demo); no conflicts
related: [config-directives, statements, form-spec, json-datastore]
keywords: [CONFIG DATABASE, OPEN, SQL, DSN, ODBC, CONNECTSTRING, ODBC-MANAGER, PASSWORDD, STATUS.DATABASE]
---

# Database operations (SQL / ODBC)

This explains how a **Business Rules!** program can act as a **SQL client** — connecting to an external relational
database (SQLite, MySQL, SQL Server, MS Access, …) through **ODBC**, submitting SQL statements, and
reading result rows. BR treats a live SQL statement as an ordinary **I/O channel**: you `OPEN` it,
`WRITE` to submit/execute, `READ` to fetch rows, and `CLOSE` when done.

> **Two ODBC directions — don't confuse them.** This page is BR *as a client* reaching **out** to a
> SQL database (via `CONFIG DATABASE` + `OPEN … SQL …`). The reverse — exposing **BR's own** data
> files **to** external tools (Excel, Access, reporting) through the BR ODBC driver — is a separate
> facility documented in [ODBC](../../00-configuration/installation-tooling/ODBC.md).

Requires BR **4.3+** (the `CONFIG DATABASE` connection methods below were introduced in 4.3).

<a id="architecture"></a>
## The three moving parts

| Part | Statement | Role |
|---|---|---|
| **1. Connection** | `CONFIG DATABASE <db-ref> …` | Names a data source (`<db-ref>`) and how to reach it (DSN / connection string / ODBC prompt). Done once. |
| **2. Channel** | `OPEN #h: "DATABASE=<db-ref>", SQL <sql$>, OUTIN` | Binds a file channel `#h` to one SQL statement text, over the named connection. |
| **3. Execute + fetch** | `WRITE #h:` then `READ #h, USING <form>: …` | `WRITE` submits/executes the bound statement; `READ` pulls result rows (for `SELECT`). `CLOSE #h:` finishes. |

The `<db-ref>` string is the glue: the name you give a connection in step 1 is the name you quote in
`DATABASE=<db-ref>` in step 2.

---

<a id="connect"></a>
## 1 · Establishing a connection — `CONFIG DATABASE`

`CONFIG DATABASE` is a **configuration command**, so from inside a program it is issued through
[`EXECUTE`](../../70-commands/program-management/spec.md#execute) (or placed in `BRConfig.sys`). It
supports three connection methods (full directive syntax in
[config-directives](../../00-configuration/config-directives/spec.md)):

```bnf
CONFIG DATABASE <db-ref> { DSN=<dsn-ref>
                         | CONNECTSTRING="<odbc-connection-string>"
                         | ODBC-MANAGER }
                         [ , USER= { <department> | LOGIN_NAME | ? } ]
                         [ , { PASSWORD= { <dept-password> | BR_PASSWORD | ? }
                             | PASSWORDD=<encrypted-password> } ]
```

- **`DSN=`** — use a pre-configured ODBC **Data Source Name** (set up in the Windows ODBC manager).
- **`CONNECTSTRING="…"`** — **DSN-less**: give the full ODBC connection string inline (driver,
  server, database, credentials). This is the most portable form for shipped apps.
- **`ODBC-MANAGER`** — pop the Windows ODBC dialog so the **end user picks** the data source at
  runtime. ⚠️ **Not usable in Client/Server mode** — the selection happens on the server and depends
  on the user's local ODBC settings (guard with `IF Env$("br_model")="CLIENT_SERVER" …`).
- **`?`** on `USER=`/`PASSWORD=` prompts the operator. `USER=LOGIN_NAME` and `PASSWORD=BR_PASSWORD`
  reuse the current BR login / Active-Directory credentials. `PASSWORDD=` supplies an **encrypted**
  password as hex — BR [`UnHex$`](../../10-language/data-manipulation/system-functions/spec.md)es then
  [`Decrypt$`](../../10-language/data-manipulation/system-functions/spec.md)s it before handing it to
  the server. When `USER=`/`PASSWORD=` accompany a `CONNECTSTRING`, BR augments the string with
  `UID=`/`PWD=` (don't also put `UID`/`PWD` in the string itself).

**Connecting at runtime:**

```business-rules
! DSN-less connect to a MySQL source
49001 EXECUTE 'CONFIG database BRG_DEMO CONNECTSTRING="DSN=BRG_DEMO;SERVER=127.0.0.1;UID=dbadmin;PWD=2BorNot2B;DATABASE=brg_demo;PORT=3306"'
```

Sample connection strings by target:

| Target | `CONNECTSTRING=` |
|---|---|
| MySQL | `DSN=BRG_DEMO;SERVER=127.0.0.1;UID=dbadmin;PWD=…;DATABASE=brg_demo;PORT=3306` |
| SQLite | `DSN=SQLite3 Datasource;Database=C:\demo\brg_demo.sqlite;SyncPragma=NORMAL;Timeout=100000;…` |
| SQL Server (SQL login) | `DRIVER=SQL Server;SERVER=server;Initial Catalog=database;UID=username;PWD=password` |
| SQL Server (Windows auth) | `DRIVER=SQL Server;Initial Catalog=database;SERVER=server` with trailing `, USER=LOGIN_NAME, PASSWORD=BR_PASSWORD` |
| MS Access | `Driver={Microsoft Access Driver (*.mdb)};DBQ=C:\path\Contact.mdb` |

<a id="discover-connstring"></a>
### Discovering / capturing the resolved connection string

After a connection is configured, its effective connection string is readable through `Env$`:

```business-rules
PRINT Env$("STATUS.DATABASE.BRG_DEMO.CONNECTSTRING")
```

This is how the **ODBC-MANAGER → capture → reuse** pattern works: let the user pick the source once,
read back the resolved string, and save it so later runs can connect **DSN-less** without prompting.

Connection names in `STATUS.DATABASE` paths are **uppercased** by BR — a connection configured as
`DemoConn` is addressed as `DEMOCONN` in `Env$` lookups. Substitute the bare name directly; there are
**no brackets** in the path string.

```business-rules
00010 PRINT Newpage
00011 IF Env$("br_model")="CLIENT_SERVER" THEN PRINT "Cannot use ODBC-MANAGER in Client/Server mode"
00020 EXECUTE "Config Database Test_DB ODBC-MANAGER" ERROR CONNECT_ERROR
00030 PRINT "Connection String is:" !:
      PRINT Env$("STATUS.DATABASE.TEST_DB.CONNECTSTRING")
00040 OPEN #1: "NAME=dsn.fil,replace,recl=4096", display, output
00050 PRINT #1: Env$("STATUS.DATABASE.TEST_DB.CONNECTSTRING")   ! save for reuse
00060 CLOSE #1:
00099 STOP
00100 CONNECT_ERROR: !
00110 PRINT "Error Connecting - Err:"; Err; " Line:"; Line; " Syserr:"; Syserr$
```

---

<a id="open"></a>
## 2 · Opening a SQL channel — `OPEN`

```bnf
OPEN #<channel>: "DATABASE=<db-ref>", SQL <string-expression>, OUTIN
```

- **`"DATABASE=<db-ref>"`** — the NAME string points the channel at the connection made in step 1.
- **`SQL <string-expression>`** — the SQL statement text to bind to this channel (a literal or, more
  usually, a string variable built beforehand). Because SQL text is often long, size the buffer
  generously: `DIM C_SQL$*4096`.
- **`OUTIN`** — open for both output (submit) and input (fetch). Used for **both** queries and DML.
- **`#<channel>`** — any free channel number (BR's usual file-channel ranges). The examples grab a
  number with an inline **forced assignment** so the same handle can be reused:
  `OPEN #(DB_HANDLE:=21): …` opens channel 21 and stores `21` in `DB_HANDLE`.

```business-rules
48001 DIM C_SQL$*4096, C1$*4096, C2$*4096
48002 LET C_SQL$="SELECT firstname, lastname FROM tbl_names"
49002 OPEN #(DB_HANDLE:=21): "DATABASE=BRG_DEMO", SQL C_SQL$, OUTIN
```

The statement text is **bound at OPEN time**. To run a different statement, build a new string and
`OPEN` a fresh channel (the examples re-`OPEN` per operation).

<a id="open-sql-file"></a>
### Opening SQL from an external file

Instead of passing SQL text in a string variable, you can point `OPEN` at a file containing SQL text:

```business-rules
OPEN #H: "DATABASE=MyConn,NAME=Setup_Tables.sql/MyFolder", SQL, OUTIN
```

This is useful for long setup scripts (create/alter statements) and keeps large SQL blocks out of
program source. The BR 4.3 release notes document both `OPEN … SQL` forms — SQL text inline
(`SQL "<statement>"`) or from a file (`NAME=<file>` with a bare `SQL`).

---

<a id="execute"></a>
## 3 · Executing the statement — `WRITE`

A **`WRITE` with no data list executes the bound SQL statement**:

```business-rules
49003 WRITE #DB_HANDLE:
```

- For a **`SELECT`**, `WRITE` runs the query and makes the **result set** ready — it must be done
  **before** the first `READ`.
- For **`INSERT` / `UPDATE` / `DELETE`**, `WRITE` performs the change; no `READ` follows.

<a id="parameters"></a>
### Parameterized statements

A `WRITE` **with** a data list binds those values to parameter markers in the prepared SQL, in order:

```business-rules
WRITE #DB_HANDLE: FIRST$, LAST$      ! bind two parameters
```

The data-element count must match the statement's parameters, or BR raises **3007/4007**
("WRITE to SQL with incorrect number of data elements"); a type/bind problem raises **3011/4011**.
Parameter binding is preferable to string-concatenating user input into the SQL (safer, and reused
plans are faster).

---

<a id="fetch"></a>
## 4 · Reading result rows — `READ`

```bnf
READ #<channel>, USING '<form-spec>': <var> [, <var>]*  EOF <line-ref>
```

Each `READ` fetches **one result row**; a **`FORM`** maps result columns to variables by position and
width. Loop until `EOF`:

```business-rules
49005 RD: READ #DB_HANDLE, USING 'form POS 1,C 50,C 50': C1$, C2$ EOF DONE
49006     PRINT C1$ & "," & C2$
49007     GOTO RD
49008 DONE: CLOSE #DB_HANDLE:
```

- The columns of the `SELECT` list map left-to-right onto the `FORM` fields. Here two text columns
  are each read as `C 50` (fixed 50-char, space-padded); size fields to your column widths.
- Use the FORM to control numeric vs. character interpretation (`N`, `PD`, `C`, dates, …) exactly as
  for a native BR record — see [form-spec](../form-spec/spec.md).
- `EOF` fires when the result set is exhausted.
- For wide `SELECT` lists, arrays and composite FORMs are usually easier to maintain than long
  variable lists.

---

<a id="close"></a>
## 5 · Closing — `CLOSE`

```business-rules
CLOSE #DB_HANDLE:
```

Releases the channel and the associated statement/result set. Always close, especially in loops that
re-open per operation, to avoid leaking ODBC handles.

<a id="clear-connections"></a>
### Clearing configured connections

You can remove one configured database reference or clear all references:

```business-rules
EXECUTE "CONFIG DATABASE CLEAR MyConn"
EXECUTE "CONFIG DATABASE CLEAR ALL"
```

Clearing can help long-running routines reset stale or no-longer-needed connection references.

---

<a id="examples"></a>
## Complete worked examples

<a id="ex-sqlite-read"></a>
### SQLite — query and print rows

```business-rules
48001 DIM C_SQL$*4096, C1$*4096, C2$*4096
48002 LET C_SQL$="SELECT firstname,lastname FROM tbl_names"
49001 EXECUTE 'CONFIG database brg_demo CONNECTSTRING="DSN=SQLite3 Datasource;Database=C:\demo\2018\brg_demo.sqlite;SyncPragma=NORMAL;Timeout=100000;NoCreat=0;PWD="'
49002 OPEN #(DB_HANDLE:=21): "DATABASE=brg_demo", SQL C_SQL$, OUTIN
49003 WRITE #DB_HANDLE:                                    ! run the query
49005 RD: READ #DB_HANDLE, USING 'form POS 1,C 50,C 50': C1$, C2$ EOF DONE
49006     PRINT C1$ & "," & C2$
49007     GOTO RD
49008 DONE: CLOSE #DB_HANDLE:
```

<a id="ex-sqlite-write"></a>
### SQLite — parameterized insert

```business-rules
48001 DIM C_SQL$*4096, FIRST$*50, LAST$*50
48002 LET FIRST$="EVETS" : LET LAST$="REGOK"
48003 LET C_SQL$="INSERT INTO tbl_names (firstname,lastname) VALUES (?, ?)"
49001 EXECUTE 'CONFIG database brg_demo CONNECTSTRING="DSN=SQLite3 Datasource;Database=C:\demo\2018\brg_demo.sqlite;SyncPragma=NORMAL;Timeout=100000;NoCreat=0;PWD="'
49002 OPEN #(DB_HANDLE:=21): "DATABASE=brg_demo", SQL C_SQL$, OUTIN
49003 WRITE #DB_HANDLE: FIRST$, LAST$                      ! bind parameters and INSERT
49008 DONE: CLOSE #DB_HANDLE:
```

If you do inline literal string values in SQL text, remember that inside a BR `"…"` string,
`""` is a literal `"`.

<a id="ex-mysql"></a>
### MySQL — same pattern, different connection string

```business-rules
! READ
48002 LET C_SQL$="SELECT firstname, lastname FROM tbl_names"
49001 EXECUTE 'CONFIG database BRG_DEMO CONNECTSTRING="DSN=BRG_DEMO;SERVER=127.0.0.1;UID=dbadmin;PWD=2BorNot2B;DATABASE=brg_demo;PORT=3306"'
49002 OPEN #(DB_HANDLE:=21): "DATABASE=BRG_DEMO", SQL C_SQL$, OUTIN
49003 WRITE #DB_HANDLE:
49005 RD: READ #DB_HANDLE, USING 'form POS 1,C 50,C 50': C1$, C2$ EOF DONE
49006     PRINT C1$ & "," & C2$
49007     GOTO RD
49008 DONE: CLOSE #DB_HANDLE:
```

Only the `CONNECTSTRING` changes between SQLite and MySQL — the `OPEN`/`WRITE`/`READ`/`CLOSE`
mechanics are identical across ODBC back ends. That portability is the whole point of the ODBC layer.

<a id="ex-sqlserver-winauth-error"></a>
### SQL Server (Windows authentication) — select with explicit error labels

```business-rules
00010 DIM C_SQL$*4096, FIRST$*50, LAST$*50, EMAIL$*100
00020 EXECUTE 'CONFIG DATABASE DemoConn CONNECTSTRING="DRIVER=SQL Server;Initial Catalog=mydb;SERVER=myserver", USER=LOGIN_NAME, PASSWORD=BR_PASSWORD' ERROR CONNECT_ERR
00030 LET C_SQL$="SELECT FirstName, LastName, Email FROM dbo.Customers ORDER BY LastName"
00040 OPEN #(H:=21): "DATABASE=DemoConn", SQL C_SQL$, OUTIN ERROR OPEN_ERR
00050 WRITE #H: ERROR EXEC_ERR
00060 RD: READ #H, USING 'FORM POS 1,C 50,C 50,C 100': FIRST$, LAST$, EMAIL$ EOF DONE ERROR READ_ERR
00070     PRINT TRIM$(LAST$); ", "; TRIM$(FIRST$); "  <"; TRIM$(EMAIL$); ">"
00080     GOTO RD
00090 DONE: CLOSE #H:
00100 STOP
00110 CONNECT_ERR:
00120 OPEN_ERR:
00130 EXEC_ERR:
00140 READ_ERR:
00150     PRINT "Error:"; ERR; " Line:"; LINE; " Syserr:"; SYSERR$
00160     STOP
```

---

<a id="errors"></a>
## Error handling & codes

Trap connection and statement failures with an `ERROR`/`IOERR` clause (or `ON ERROR`), and report
`Err`, `Line`, and `Syserr$` (the driver's message). BR reports SQL/ODBC failures in two parallel
ranges — roughly **3002–3015** and **4002–4015** (the 4xxx range largely mirrors the 3xxx one for a
second processing context; the two lists run parallel through 3012/4012, then diverge at the tail):

| 3xxx | 4xxx | Meaning |
|---|---|---|
| 3002 | 4002 | SQL create statement failed (bad syntax in a CREATE) |
| 3003 | 4003 | SQL free statement failed |
| 3004 | 4004 | SQL prepare failed |
| 3005 | 4005 | SQL clear-old-results failed *(4.30+)* |
| 3006 | 4006 | SQL execute-direct failed |
| 3007 | 4007 | `WRITE` to SQL with **incorrect number of data elements** (parameter count mismatch) |
| 3008 | 4008 | SQL describe-result-set-columns failed |
| 3009 | 4009 | SQL bind-result-set-columns failed |
| 3010 | 4010 | SQL fetch-row failed |
| 3011 | 4011 | SQL bind-parameter failure |
| 3012 | 4012 | Prepared-SQL execution failure |
| 3014 | 4014 | Error converting a timestamp to/from a string value |
| 3015 | — | Undefined SQL data type |
| — | 4015 | The specified database has not been opened |

Also relevant: **0366** (`brvbCommandMissing`) — no SQL command was supplied with the submit/fetch
statement (i.e., the channel had no bound SQL to run).

Also common: **4270** — `EOF` on `READ` when no `EOF` clause was provided. This is normal end-of-
result-set behavior, not a driver failure.

Common first checks when a connect or query fails: the ODBC DSN/driver name, server reachability and
port, credentials, and (for `ODBC-MANAGER`) that you are **not** in Client/Server mode. Turning up
ODBC logging helps — `LOGGING 6, C:\ODBC-LOG.TXT` records the **actual SQL** sent to the driver (see
[ODBC](../../00-configuration/installation-tooling/ODBC.md)).

<a id="status-database"></a>
## `STATUS.DATABASE` introspection

BR extends [`Env$("STATUS…")`](../../10-language/data-manipulation/system-functions/spec.md#system-info)
to walk a configured connection's schema — connections, tables, columns, and their types. A scalar
lookup returns a string; a lookup ending in **`.LIST`** paired with a `MAT` array **redimensions and
loads** that array (the `LET Env$(…, MAT arr$)` form).

> **Notation.** `<db-ref>`, `<table>`, `<column>` below are **placeholders** — substitute the actual
> name (BR uppercases connection names), with **no brackets** in the real string. Each name is exactly
> what the corresponding `.LIST` call returned.

```business-rules
LET   Env$("STATUS.DATABASE.LIST", MAT DBS$)                                  ! all connected databases
PRINT Env$("STATUS.DATABASE.<db-ref>.DSN")                                      ! the DSN
PRINT Env$("STATUS.DATABASE.<db-ref>.CONNECTSTRING")                            ! resolved connect string
LET   Env$("STATUS.DATABASE.<db-ref>.TABLES.LIST", MAT TABLES$)                 ! table names
PRINT Env$("STATUS.DATABASE.<db-ref>.TABLES.<table>.TYPE")                      ! e.g. TABLE / VIEW
PRINT Env$("STATUS.DATABASE.<db-ref>.TABLES.<table>.REMARKS")
LET   Env$("STATUS.DATABASE.<db-ref>.TABLES.<table>.COLUMNS.LIST", MAT COLS$)   ! column names
PRINT Env$("STATUS.DATABASE.<db-ref>.TABLES.<table>.COLUMNS.<column>.TYPE")
PRINT Env$("STATUS.DATABASE.<db-ref>.TABLES.<table>.COLUMNS.<column>.LENGTH")
PRINT Env$("STATUS.DATABASE.<db-ref>.TABLES.<table>.COLUMNS.<column>.DECIMALS")
```

Because the path is an ordinary string, real code builds it by **concatenation** — dropping in the name
a `.LIST` returned rather than a literal placeholder:

```business-rules
LET ST$ = "STATUS.DATABASE." & CONN$                          ! CONN$ from STATUS.DATABASE.LIST
LET Env$(ST$ & ".TABLES.LIST", MAT TABLES$)
LET Env$(ST$ & ".TABLES." & TABLE$ & ".COLUMNS.LIST", MAT COLS$)
```

This metadata drives diagnostics and **dynamic FORM-building** that adapts to discovered column types,
lengths, and decimals. A complete schema-walking program is the `ENVDB.BRS` demo in the
[4.30 release notes](../../90-reference/limits-constants/4.30.md).

---

<a id="security"></a>
## Security notes

- **Credentials live in the connection string.** A `CONNECTSTRING` with `UID=`/`PWD=` (or a saved
  `dsn.fil`) is sensitive — protect the file, and prefer **encrypted** passwords (`PASSWORDD=` hex,
  BR-`Decrypt$`ed at connect) or **`BR_PASSWORD`/`LOGIN_NAME`** (reuse the AD/BR login) over literal
  passwords in source.
- **Prefer parameter binding** (`WRITE #h: v1, v2, …`) over concatenating operator input into the SQL
  string — it avoids SQL-injection-style breakage and quoting bugs.
- Treat a saved connection string (e.g. the `dsn.fil` capture pattern) like any other secret.

<a id="troubleshooting"></a>
## Troubleshooting checklist

When a connection fails:

- Confirm the ODBC driver is installed on the machine where BR is running.
- Confirm the driver name in the connection string exactly matches the installed driver.
- Confirm server/host, database name, credentials, and firewall/network reachability.
- Confirm `ODBC-MANAGER` is not used in Client/Server mode.
- Print `Syserr$` for the driver-specific failure text.

When a query fails:

- Print/log the SQL text (keep the last statement in a variable so it can be logged on failure).
- Confirm parameter-marker count matches `WRITE` data-element count.
- Confirm selected columns match the `READ ... USING` FORM layout.
- Increase character field widths if truncation/mismatch is suspected.
- Use `STATUS.DATABASE` metadata to verify table/column types and lengths.

---

<a id="see-also"></a>
## See also

- [config-directives](../../00-configuration/config-directives/spec.md) — the full `CONFIG DATABASE`
  directive (DSN / CONNECTSTRING / ODBC-MANAGER, USER/PASSWORD/PASSWORDD)
- [ODBC](../../00-configuration/installation-tooling/ODBC.md) — the **reverse** direction: exposing
  BR data files to external tools via the BR ODBC driver; ODBC logging
- [statements](../statements/spec.md) — `OPEN`/`WRITE`/`READ`/`CLOSE` general semantics
- [form-spec](../form-spec/spec.md) — `FORM` field types used to map result columns
- [ENV$](../../10-language/data-manipulation/system-functions/spec.md#system-info) — the `STATUS`
  interrogation function used for `STATUS.DATABASE` introspection
- [json-datastore](../../60-integration/json-datastore/spec.md) — BR's other structured-data integration facility
- 4.3 / 4.30 release notes ([limits-constants](../../90-reference/limits-constants/4.30.md)) — the
  `OPEN … SQL` inline/file forms and the `ENVDB.BRS` `STATUS.DATABASE` schema-walk demo
- `CONFIG DATABASE CLEAR` examples: [config-directives](../../00-configuration/config-directives/spec.md)
- SQL/ODBC error codes: [3002](../../90-reference/error-codes/3002.md)–[3015](../../90-reference/error-codes/3015.md),
  [4002](../../90-reference/error-codes/4002.md)–[4015](../../90-reference/error-codes/4015.md),
  [0366](../../90-reference/error-codes/0366.md),
  [4270](../../90-reference/error-codes/4270.md)
