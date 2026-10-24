---
title: ODBC
file: ODBC.md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: config-directive
related: [BRConfig.sys, Statements, File I/O, System Limits, BRODBC32.dll, 4.3, Logging]
---
**ODBC** or **Open DataBase Connectivity** is discussed on the following pages:

#`BRConfig.sys`
#`Statements`
#`File I/O`
#`System Limits`

==Installation==

You should use the latest `BRODBC32.dll`

==Configuration==

When setting up ODBC,it is important to understand that some of the parameters are asking for the 'Virtual Path', and others require the 'Actual path'.

The setup has the following information:

* DSN - The name of the ODBC Configuration
* Application - The name of the application from your Context Manager
* BR Location - This is the 'Actual Path' to the folder that contains BR
* BRConfig.sys file (full path) - This is the 'Actual Path' to the WBCONFIG.SYS file 
* Drive Statements from the BRConfig.sys - This will show you how the drives are mapped in your WBCONFIG.SYS file.
* Data Path - This is the Virtual Path to the "Root" of your Data,  Hint:  Start BR, and type "CD". that is probably the correct answer.
* Dictionary Path - This is the Virtual Path to the Context Folder.  Similar to Datapath, but pointing to the context folder.  

=`4.3`=
(documentation from this point on refers to ODBC 2 release with BR! `4.3`.)

===Improved installation routines:===
*Easy to use
*Compatible with Windows Vista/7
*Compatible with 64 Bit Machines (32 Bit Drivers for 64 bit Machines).
*Easily create DNS entries from the CONTEXT using a BR program called CREATE_INI.BR. ( Taylor the resulting INI file to the target setting.  )
*Installation on a client can be done from a command line avoiding the need for human interaction at the client. 

`file:odbcerror.png`

`file:odbc2.png`

*Support for 64 bit Record Locking (No 2GB Limit!)
*Implemented Dynamic Indexes
*The ODBC splash screen has been removed.
*ODBC Logging:

Different levels of detail are provided for log levels 6, 8, 10 and 13. If in doubt, set the log level to a higher level and then check the log results for the types of message you desire.  @ODBC LOGGING may be used following the normal LOGGING statement to override the BR logging level specifically for ODBC. 

Otherwise, set `Logging` to level 6, for example:

 LOGGING 6, C:\ODBC-LOG.TXT

The Log File will provide helpful information to analyze queries. 

*Actual SQL processed by Driver (As opposed to the SQL typed in MS-Access or MS-Excel) Indexes used by the Query. This helps to determine the "BEST Query" for performance.

*More Robust
**Improved Date Handling (Sort/Filter, etc).
**Improved Joins leverage &/or create indexes for performance.
**Improved Group By queries
**Improved "Like" filters.
**Improved Multiple Filters in a single query

==ODBC Licensing And Security==

Licenses will be issued based on number of workstations or number of BR WSIDs.

The price per user for licensing based on the number of BR WSIDs is one half of the price based on the number of ODBC workstations. 

The maximum license fee for ODBC is $4900.

Enforcement-If the ODBC license is based on the number of BR users, then the BRSERIAL.DAT file always specifies 999 users. 

We assign a random number to each machine that uses the ODBC driver and another random number to each user of ODBC. These numbers are stored along with the date, encrypted in a table in the server and client registries.  Each time a session is started, the client is checked for pre-existing control numbers and if they exist then the numbers are used for the session (along with the current date). If a client reports a pre-existing number less than 14 days old that is not in the server table, then an alarm is signaled. This indicates tampering with the server table.

When a control number pair is about to be added to the server table and the table is full then it is searched for an entry more than 14 days old for replacement. If no such entry exists, then a “maximum users exceeded” error message is presented. 

When a computer is replaced, this can leave an unusable entry in the server table for up to 14 days. If this occurs, then the user can run a program on the server that writes an encrypted header with the current date to the server table indicating that the table has been cleared in a licensed manner.  After this has been run, all entries in the table will be available for reuse.  Clients that have pre-existing control numbers will not generate the tamper error when the license file is cleared in this manner unless the client last used date is greater than the encrypted header date. This program requires a password which is an encrypted form of the current date plus the serial number. Only the dealer has the password producing program so only the dealer can obtain the current day’s password. 

When a client machine has more than two ODBC user entries, the entries greater than one are counted as separate workstations. e.g. 1 or 2 ->1, 3->2, 4->3, etc.

==License enforcement has been improved with this release.==
* Note: Older versions of ODBC did a poor job of enforcing Licensing, and would sometimes allowed too many users to use the product. (Accidentally violating the license).

==Utilizing MS Access ODBC Middleware ==

A procedure has been established for greatly expanding the SQL capabilities of the BR ODBC driver by routing ODBC requests through MS Access (4.3). Using this technique one can create reusable queries that combine several tables. This procedure is described in the installation guide. 

==See also==
*`wikipedia:Open DataBase Connectivity`
