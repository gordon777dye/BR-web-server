---
title: LOGGING
file: LOGGING.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [config, BRConfig.sys, commands, BR program, PRINT, TRACE, DISPLAY, 4.3, GUI, MyEditBR]
corrections:
  - "Level table rewritten from BR 5.0 logger.h:16-40, which defines levels 0-3, 5, 6 and 8-15. The page had misnamed levels 3, 4, 5, 8 and 9, and left out 10, 14 and 15. It also said level 11 logs console PRINT output. No such feature exists: level 11 is TRACING_FLOW, used only in sock.cpp and ssl.cpp (socket and TLS internals) and wbs.cpp (entry traces for the ODBC routines WBReadContextFile and WBLinkExternalRecords). Measured: runs at levels 10 and 11, GUI on and off, logged none of a program's PRINT markers. Reported in context/ERRORS.md 2026-09-28."
  - "What level 11 actually adds is the reverse: debug.cpp:561 echoes DEBUG_STR messages to the GUI console when the log level is >= AUTOLOG_CONSOLE (11) or +CONSOLE is set. +CONSOLE had been described as sending all logging messages to the console. g_logToConsole is read only on that DEBUG_STR path, and the client (term.cpp clientMessageLog) sends its log messages to the server's log file, not to the console."
  - "Level 8 row now cites command.cpp:1422 (`Command entered %s` at MINOR_EVENT) in place of the unsupported \"COPY plus shell calls\" wording. The DEBUG_STR clamp is stated from numfunct.cpp:955 (MAKE_BETWEEN(0, 10, level))."
---
As of 4.3, the debug versions of BR now expect you to use a LOGGING configuration statement. This enables BR to post exit messages during unexpected terminations.

The **Logging** `config` statement is provided for logging configuration errors, and should be placed in `BRConfig.sys`:

 LOGGING <loglevel>, <native-OS-logfile-name> [, UNATTENDED] [, DEBUG_LOG_LEVEL=<integer>] [, +CONSOLE]

`IMAGE:Logging.png|700px`

**Loglevel**  is the maximum level of detail to be logged. The Logging Level is meant to specify the level of detail to be logged, with greater detail logged at higher log levels:

{|Border=1
|-
|0
|MAJOR_ERROR
|causes major problems during execution
|-
|1
|NOTABLE_ERROR
|unexpected error likely to cause problems
|-
|2
|MINOR_ERROR
|unexpected error that can be ignored
|-
|3
|MINOR_IO_ERROR
|input-output error that can be ignored (e.g. an `EXTERNAL` file that cannot be opened)
|-
|4
|
|not used — no level-4 constant is defined
|-
|5
|SECURITY_EVENT
|logons, logon attempts
|-
|6
|MAJOR_EVENT
|starting a `BR program`, exiting, shelling; process starts
|-
|8
|MINOR_EVENT
|individual `commands` — each command entered is logged as `Command entered <command>`
|-
|9
|DEBUG_PROBLEM
|detailed logging in critical areas, to help users debug problems (e.g. FORM data dumps)
|-
|10
|DEBUGGING_EVENT
|messages added for debugging purposes
|-
|11
|TRACING_FLOW
|socket and TLS internals (`sock.cpp`, `ssl.cpp`), and entry traces for two ODBC file routines, `WBReadContextFile` and `WBLinkExternalRecords` (`wbs.cpp`). Also the threshold at which `DEBUG_STR` messages are echoed to the GUI console (see **+CONSOLE**)
|-
|12
|TRACING_INFO
|`TRACE` output (`Trace line <nnnnn> in <program>` for every executed line) and `DISPLAY` messages
|-
|13
|OBNOXIOUS_INFO
|information that would make important messages hard to find
|-
|14
|OBNOXIOUS_SIZE
|information that makes big log files (e.g. per-read byte counts)
|-
|15
|OBNOXIOUS_SPEED
|information that takes time to log
|-
|}

**Logfile** denotes where the logging records will be kept. **Note that Logfile is a native OS filename.** Second and subsequent occurrences of the LOGGING statement may omit loglevel and logfile.

The **UNATTENDED** keyword will cause BR to run in unattended mode, without a startup screen and until a program begins to await operator input, when it will exit. Config LOGGING loglevel logfile [UNATTENDED] is now supported on linux (4.2) and this will exit BR if the program starts to wait for keyboard entry. 

**DEBUG_LOG_LEVEL** (available as of `4.3`) specifies the log level for debugging log messages independently of the standard log level. If not specified, the Debug_Log_Level is set to the standard loglevel.

**+CONSOLE** (4.3) applies only when `GUI` is ON and specifies that `DEBUG_STR()` messages (those within the log level) are also echoed to the console, and that the console is to be left visible when not attached to `MyEditBR`. A log level of 11 or higher turns the same echo on without `+CONSOLE`. System log messages are not echoed; they go only to the log file. (Console logging output is supressed when GUI is OFF.)

====Examples====
 LOGGING 2, logfile
shows unsupported escape sequences encountered.

 LOGGING 5, logfile
shows unsupported escape sequences encountered plus intentionally ignored escape sequences.

 LOGGING 2, logfile ,UNATTENDED
shows unsupported escape sequences encountered, and runs BR in 'Unattended' mode, bypassing start-up screen and terminating BR at the end of processing or when input is required.  Supported in 4.18 in Windows and 4.20 under Linux.

  LOGGING ,,UNATTENDED
runs in `Unattended mode` without log file.

Any config messages that occur after this config statement will be sent only to the logfile, mostly with NOTABLE_ERROR.  It avoids displaying those REMed out statements in front of operators.

Any config messages that occur before the config statement logging will be sent only to the screen.  These will cause BR to pause a few seconds so that the messages can be viewed.

===Logging Messages (4.3)===

Message Levels are compared with Log Levels during the filtering process. Like log levels, there is greater detail logged at higher log levels:

The following types of messages are written to the LOGGING file:

1. Config error messages based on their assigned level of importance.

2. DEBUG_STR() messages where message-level is equal to or less than the DEBUG_LOG_LEVEL:

{|
|- valign="top"
| width="20%" | **Log levels 0, 1, 2 and 3** 
| System generated warning messages such as OS failures and abnormal exits.
|
|- valign="top"
| width="20%" | **Log level 5 or above** 
| User Logon data, including any logon attempts.
|
|- valign="top"
| width="20%" | **Log level 6 or above** 
| Starting a BR program, exiting.
|
|- valign="top"
| width="20%" | **Log level 8 or above** 
| Each command entered (`Command entered <command>`).
|
|}
DEBUG_STR() levels are clamped to 0–10: a level above 10 is logged as 10, and a level below 0 as 0.

====LOGGING PDF printing events====

Logging was added to PDF creation. Logging of minor events that happen during the printing process are logged at log level 8.  Errors are logged at a lower level. Logging was also improved with respect to loading older versions of pdflib.
Note- As a diagnostic, the following command is quite useful: 
DIR >PDF:/READER

The following messages are written to the LOGFILE:

{|
|- valign="top"
| width="20%" | **Log level 11 or above** 
| Socket and TLS internals, and entry traces for two ODBC file routines. `DEBUG_STR()` messages are also echoed to the GUI console. Console `PRINT` output is **not** logged at any level.
|
|- valign="top"
| width="20%" | **Log level 12 or above** 
| TRACE, and DISPLAY messages.
|
|- valign="top"
| width="20%" | **Log level 13 or above** 
| Lots of what the system is doing now messages (levels 14 and 15 add ever larger and slower detail).
|}

;Examples:
Log Level Indication is given in Log Messages The (6) here is the log level:
  (6) - 08/25/2011 11:33:53
Setting logging to log file logfile.txt log level 10.
  (6) - 08/25/2011 11:33:53
The BRConfig.sys file is C:\Users\dan\programs\cygwin\home\dan\br-wx\br\winbuild\dllbuild\output\brconfig.sys

====See Also====
*`Debug_Str` 

====Logging Abnormal Termination====
A logging capability is provided for handling `BRServer` failures. An error log file in the BRServer directory is appended to when a BRServer process is abnormally ended. Also, a `client` `msgbox` is displayed when an `assertion failure` or program crash occurs. On `Unix` systems, the system error log is also updated. `Keepalive` failures are also logged here.
