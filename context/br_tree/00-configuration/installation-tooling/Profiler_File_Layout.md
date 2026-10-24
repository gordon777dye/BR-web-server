---
title: Profiler_File_Layout
file: Profiler_File_Layout.md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: config-directive
related: []
---
= Profiler Output File Format =

The profiler output file will be a sequence of variable-length records of various types. The first byte of each record provides the record type, while the length and record information are record-type specific. All numbers are in **network byte order**.

== CREATE MODULE MAPPING ==

* **Byte 1:** 1
* **Byte 2–3:** 16-bit module number
* **Byte 4–5:** 16-bit File Name Length
* **Byte 6–end:** File Name

== CURRENT LINE ==
Current line information begins with this record and ends with an **END CURRENT LINE** record.

* **Byte 1:** 3
* **Byte 2–3:** module number
* **Byte 4–7:** line number
* **Byte 8:** clause number

== TIME SPENT IN LINE ==
These records exist only for timed sampling. They always occur between **CURRENT LINE** and **END CURRENT LINE**.

* **Byte 1:** 4
* **Byte 2–9:** 8-byte time spent in line (nanoseconds)

== BACKTRACE INFORMATION ==
These records may or may not exist depending on creation options. They always occur between **CURRENT LINE** and **END CURRENT LINE**.

Note: Apart from the record type identifier, these records have the same format as **CURRENT LINE**.

* **Byte 1:** 5
* **Byte 2–3:** module number
* **Byte 4–7:** line number
* **Byte 8:** clause number

== FUNCTION NAME ==
These records may or may not exist depending on creation options. They follow immediately after either **CURRENT LINE** or **BACKTRACE INFORMATION**.

* **Byte 1:** 7
* **Byte 2:** 8-bit name length
* **Byte 3–on:** function name

== GOSUB ==
These records may or may not exist depending on creation options. They follow immediately after either **CURRENT LINE** or **BACKTRACE INFORMATION**.

* **Byte 1:** 8

== MAIN ROUTINE ==
These records may or may not exist depending on creation options. They follow immediately after either **CURRENT LINE** or **BACKTRACE INFORMATION**.

This indicates that the given line is neither in a GOSUB nor in a function body.

* **Byte 1:** 9

== END CURRENT LINE ==

* **Byte 1:** 6

= Potential Syntax =

* <code>DEBUG PROFILE SAMPLED filename</code>
* <code>DEBUG PROFILE TIMED filename</code>
* <code>DEBUG PROFILE STOP</code>

== Profiler.exe ==
To use the profiler.exe available on the ftp site in /Dll_Distr/profiler to get a nice listing of what is in the log file use.
* profiler.exe filename
or
* profiler.exe filename raw
