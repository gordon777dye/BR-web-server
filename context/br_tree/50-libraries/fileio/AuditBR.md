---
title: AuditBR
file: AuditBR.md
category: 50-libraries
subcategory: 50-libraries/fileio
kind: concept
related: [library, Sage AX, FileIO]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
---
**Audit BR** is a powerful new `library` from `Sage AX`, created as a part of Sage AX's continuous mission to empower the BR developer with the latest in modern programming tools and techniques.

Audit BR is a library that can be used to accomplish two simple functions, opening a powerful door for debugging your BR programs.

Audit BR builds upon `FileIO`, enabling this powerful technology to work with your existing BR software right out of the box.

More information about Audit BR is available at Sage AX.

= Description of Functions =

== fnBeginAudit ==

*fnBeginAudit(BackupFolder$)*

*BackupFolder$ - the name of a folder to backup the Audit Information to. If it does not exist, it is created.

The fnBeginAudit function makes a backup of your BR data files, essentially creating a restore point that can be compared at any time to your current data files, generating a report indicating clearly everything that has changed in the data files. To use it, simply call fnBeginAudit and give it the name of a folder to back the data up to. This folder should be a new folder, and it should not be used for any other purpose than for your BR datafile Audits.

== fnCompare ==

*fnCompare(BackupFolder$;Logfile$,Printer,DontClose)*

*BackupFolder$ - the name of a folder containing a backup of your datafiles. Use fnBeginAudit to create and to update this folder.
*Logfile$ - The name of a logfile to report all changes to. The logfile is added to each time, so its a good idea to keep a logfile. If you run the audit routine regularly then you can use the logfile to determine not only what data has changed, but exactly when the change occurred. If this field is blank or is not given, then the logfile is not created.
*Printer - This is a boolean flag indicating weather a report should be generated and sent to print preview or not. This report is color coded to make it easier to identify which elements of the data file have changed. When the program is being used and checked by a user or programmer, the printout is the easiest way to quickly make sense of the differences found in your data files.
*DontClose - use this optional boolean flag to force the fnCompare function to leave file #255 (the printer) open. Use this parameter if you want to keep from displaying the report in order to print more information on it before closing it yourself manually to generate the print job later.

= Typical Usage =

To use this library, you may run audit.br directly, or simply call these functions from your existing code. You can script the call to happen automatically, or you can place it on the user interface.

== Example Usage 1 - User/Programmer Manual Trigger ==

In one of my programs, I simply added an option on the menu to run an "Audit Report". This menu option first calls fnCompare, then it calls fnBeginAudit right afterwards to create a restore point for the next comparison. I can run the menu option any time to see what has changed since the last time it was run.

Any time I need to test a program change that modifies one or more data files in my system, I run the Audit Routine, then I run my new code, then I run the Audit Routine again. The Audit routine quickly generates a list of exactly which elements in the data file have changed and I'm able to debug and double check my code in a fraction of the time it took to do so before. And more efficient debugging means fewer mistakes.

== Example Usage 2 - Automatic Trigger (Interval) ==

You might also want to make the Audit routine run automatically on a regular interval by a background process to build a running logfile showing all changes made to your system and the time that those changes were made.

You can use Windows Task Scheduler to trigger the running of a program on a preset time interval.

== Example Usage 3 - Automatic Trigger (Event Driven) ==

It may be necessary to monitor what changes are made by each employee in the system. If you don't have a lot of employees using the system at the same time, one easy way to implement such a change may be to run the Audit routine each time a program is exited. Just prior to running the report, print a line to the logfile yourself saying what program just ran and who ran it. This would enable  you to monitor the logfile to see exactly which user is responsible for a given change made to your system.

= Notes =

== Requires BR 4.1 or Above ==

Because the Audit Report makes extensive use of NWP features, Audit BR requires BR 4.1 or above to run. Please note that your programs don't have to use BR 4.1. You can always just fire up a copy of BR 4.1 in order to run Audit and continue to use an earlier version of BR for the rest of your programs if you desire.

== Workstack Requirements ==

Audit BR requires FileIO, and FileIO requires a high Workstack value. If you receive error 9001, try increasing the Workstack value specified in your brconfig.sys file. You can check your current workstack value at any time by using Status Stacks. The maximum value for Workstack under BR 4.1 and lower is 65535.

== Files using Linux Style ("/") Paths ==

Audit BR is not compatable with using the "/" in your file layouts to describe the path for your data files. If you specify the filename for your data files (the first line of the file layout) using "/" linux style notation, please update your layouts and specify the path and filename for your data files using the "\" style Windows notation.
