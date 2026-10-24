---
title: Multi-User_Considerations_Tutorial
file: Multi-User_Considerations_Tutorial.md
category: 30-io-file
subcategory: 30-io-file/file-model
kind: tutorial
related: []
---
In most situations, there will be more than one user accessing the BR programs and files. Also, since most systems eventually move from single-user to multi-user, when you first write programs, its usually a good idea to program them for multi-user situations the first time around, rather than have to go back and update everything when another user is added. There several ways to approach this:

===Sharing===
The most important consideration of multi-user systems is that different programs may attempt to open the same file at the same time. You may have already learned that this creates an error. 

The following four parameters, designated in an OPEN statement, can handle the issue of file sharing:

{|
|NOSHR||indicates that the current workstation has exclusive access to the file. No other OPENs are permitted to the open file until the open file has been closed. NOSHR is the default. Note that other user may attempt to open the file, so you will need to add an error-handling routine.
|-
| 
|-
|SHRI||allows others to use the file for input only (that is, inputting information to the program). It is possible for others to read but not to change a file opened SHRI. Consider what can happen if one user is updating the file while another wishes to make a current report from it. How can the program handle this?
|-
| 
|-
|SHR||allows' others to read, write and update an open file. An individual record within internal and external files may be locked during use by specifying SHR, OUTPUT or SHR, OUTIN and reading the record. An individual record within this file may be locked during use when either OUTPUT or OUTIN is also specified and when the I/O statement utilizes the RESERVE parameter (RESERVE is the default, so explicitly coding it is not necessary). Consider how to handle when several users attempt to make changes to the same file at the same time. 
|}

Since NOSHR is the default, if only one computer at a time needs to access the file, it's very simple, but if several workstations must access the file at once the program must be able to handle it.

===RELEASE vs RESERVE===
In multi-user systems, the RELEASE keyword releases all previous record locks. It removes RESERVE restrictions which have been initiated by the current workstation for the specified file. This parameter can be issued only from the workstation that initiated the RESERVE restrictions. 

**RESERVE** instructs the system to hold all previous record locks, which leaves the file for exclusive use only. 

Unlike NOSHR, which ends the file-locking when the file closes, RESERVE does not. Therefore, it is important to close the file using the RELEASE parameter if it was opened RESERVE, so that all following attempts to use the file are not needlessly limited by this. Exiting BR entirely, however, will undo file-locking of both kinds, but you shouldn't depend on closing BR to handle this, of course. 

===Protect===
A third way to handle this is using the PROTECT command. The syntax is as follows:

 PROTECT file-name parameter 

with the available parameters being: reserve, release, read and write. Reserve and release function as described above, while read allows a different user to open the file for read-only, and write allows other users to open it for both reading and writing. 

===Error Conditions===

It's important to handle relevant error conditions related to shared files so that the program doesn't crash if something is opened twice. LOCKED error condition will handle instances that the file is locked at another workstation or if file-sharing rules are violated. You could have the program go to a “Retry later” window or other warning. Here's a quick review of ON error:

 ON LOCKED goto alreadyopened
 alreadyopened: OPEN #11:"SROW=5,SCOL=5,rows=4,ECOL=50, border=d,CAPTION=File already opened. Try again?",DISPLAY,OUTPUT: kstat$(1): retry

===RETRY=== 

Another way to end an error-handling routine is with the statement RETRY, which will take the program back to the line where the error occurred and try again. 

===WSID$ and WSID===

WSID$ and WSID are internal functions that will return a two or three digit workstation identifier. Possible uses could be record logs or printouts. 

Type WSID$ into BR. It will return your number. 

When two workstations simultaneously run the same program, all output and temporary file names must be unique or at least one of the programs will fail. The use of the workstation ID [WSID] as a suffix to the names of temporary files allows you to create unique file names. [WSID] may appear anywhere that a valid file name may appear. Business Rules workstation identifier, from the function WSID$, replaces [WSID] with the workstation's unique identifying number, when [WSID] is specified in file references as though the program performed the following replacement:

 NAME$=SREP$(NAME$,1,"[WSID]",WSID$)

Here are a few examples:

 INDEX CUSTMR,CUSTKEY.[WSID],1,5,REPLACE
 00010 OPEN #1:"NAME=CUSTMR,KFNAME=CUSTKEY.[WSID]",INPUT,INTERNAL,KEYED

 ! An example of a SORT control file
 3FILE CALL.FIL,,,SORTOUT.[WSID],,,,,A,N,SHR,REPLACE
 RECORD I,34,1,C,'1','1'
 MASK 35,2,C,A,37,3,PD,A

===Security===
Security for your programs can be set by saving them .BRO, which will prevent any access to the codes or editing. But make sure that you save a copy of the code for yourself for editing purposes!

Security for your programs can also be set with OPTION 54 or 70, which will exit Br if for any reason it enters command mode. However, OPTION 70 allows for the 'relaxed' parameter, which will allow some debugging and limited access (however a smart user could gain almost complete access, so its not recommended).

Security within your programs can be written a variety of ways. When the network is set up and is protected with login-names, BR can allow or disallow access accordingly. 

Login names can be set with LOGIN_NAME$("newname"). And in three other ways:

1.) The start-up command, which is run from the operating system, can set login name for BR.

2.) ENV$ LOGNAME will display what login name was used at the Windows/Unix level. IF/THEN structures can determine which usernames can do what in programs. Security levels, which are assigned to usernames in a .DAT file, can determine who can do what. Of course, different ways of accomplishing this can be written into your programs. 

3.) BRConfig.sys can also be used to set login names, for example: 
 
 BR  @myname  run menu 
 @myname WSID 25 
 @myname PRINTER OKIDATA

If the windows login name contains spaces or periods, you must encapsulate it in quotes
 @"Sally Supername"  WSID 11

User security level will determine what access a user has to the program.
