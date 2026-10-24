---
title: Multi-spooled_printers
file: Multi-spooled_printers.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [SUBSTITUTE, BRConfig.sys, Fkey]
---
All multi-user versions of Business Rules allow using more than one spooled printer. Printed output can be spooled to different types of printers (dot matrix, letter quality, etc.) or to printers dedicated to different special forms (checks, invoices, etc.). Also, printers can be selected after entering Business Rules. Support for multiple spooled printers allows programmers to intermix PRINT statements for two or more reports or types of forms in the same program.

We recommend designing your programs (even for single-user systems) with the maximum number of different printers. Each different type of printer can be identified by a programmer-assigned class number, which will be explained further below. Consider using different class numbers for each application area, paper form, paper width, volume requirements, color requirements and so forth. 

At installation time, the various printer classes can be reduced or consolidated to the number of printers actually present, either by the operating system or through BRConfig.sys `SUBSTITUTE` specifications. This plan maximizes both power and flexibility; a system-wide change in printer classes does not require any changes in your individual programs, only in the `BRConfig.sys` file.

===Unix / Linux Multiple Printer Support===

A file-ref that begins with PRN: will always designate spooled printer output unless the PRN: has been mapped to something else through a SUBSTITUTE specification. The class number will directly translate to the Unix / Linux printer class that the output will be sent to. As the default printer class is 10, the Unix / Linux operating system must include at least one printer that is a member of printer class 10.<br>
While the printer file is open, the STATUS FILES command will show a name similar to the following where ww is the workstation ID and xx is a number that makes the file name unique:

 PRN:/10 /usr/tmp/WSPOOLww.xx

For local printer support, use a SUBSTITUTE specification that will change one or more printer classes to a Unix / Linux device name:

 SUBSTITUTE PRN:/11,:/dev/tty15

===Definitions and Overview===

Lines printed by PRINT #255 go to the default printer. The default printer name is PRN:/10. Since there is a default OPEN statement for the default printer, PRN:/10 is sometimes called the default printer open.

Based on a Unix / Linux convention, the 10 in PRN:/10 refers to the printer class. The printer class is an arbitrary two-digit number assigned by the programmer. One case where the printer class would be useful is a multi-user system with a letter-quality printer. Printer class 20 could be used in the OPEN statement for output that a customer might want on a letter-quality printer. When installing your software for a customer who decides not to start out with a letter-quality printer, but only has one dot-matrix printer which is used for class 10, insert the following in the BRConfig.sys file:

 SUBSTITUTE /20,/10

This substitutes or replaces all /20 references with /10 in file names. The result of this one change is that all programs sending output to the letter-quality printer now send their output to the dot-matrix printer. Several months later, if the customer decides to add a letter-quality printer, the only change needed would be to remove the SUBSTITUTE specification from the BRConfig.sys file.

===BRConfig.sys Substitute Specifications===

The general purpose of the SUBSTITUTE specification is to replace all or part of a file name or path name in commands and OPEN statements before the command or statement is executed.

When applied to printer control, the SUBSTITUTE specification can change printer output to any other local printer spooled printer or file. SUBSTITUTE can be executed from BRConfig.sys when entering Business Rules, it can also be executed as part of the CONFIG command.

For example, suppose a system has a standard printer connected to PRN: (LPT1:) and another printer attached to LPT2:. If the standard printer is broken, or has a lot of jobs waiting to print, the following command could transfer standard printer output from device PRN: to the printer attached to device LPT2 for all subsequent printer opens:

 CONFIG SUBSTITUTE PRN:/10,LPT2:

Whenever LPT2: is set up for spooling by your operating system, as is common for IBM NetWorks, the above command causes Business Rules to produce spooled output. To make this same change from within a program, perhaps based on an operator's response, the CONFIG command can be executed by the EXECUTE statement. For example:

 100 EXECUTE "CONFIG SUB PRN:/10,LPT2:"

OPEN statements with just PRN: are syntactically acceptable, but can cause problems for printer substitutions, especially when other OPEN statements (in the same program or different programs) explicitly code printer classes with names like PRN:/12. SUBSTITUTE PRN:,PRN:/11 works fine for OPEN statements with just PRN:, but if you also have references to PRN:/12 in your code, then the same SUBSTITUTE will change PRN:/12 to PRN:/11/12. We discourage the use of plain PRN: to avoid these types of problems with SUBSTITUTE. Using PRN:/10 instead of just PRN: eliminates these SUBSTITUTE problems.

There are two conditions in which SUBSTITUTE does not apply. The default class of 10 is added to a plain PRN: specification after file name substitution processing, thus automatically translating PRN: to PRN:/10. The second case is that //10 (a System/23 convention) is also converted to PRN:/10 after file name substitution processing; this means that you must specify a separate SUBSTITUTE specification for //10 if you wish to redirect this printer output to a non-default printer. (The other System/23 convention, device //11, is translated to AUX:).

Once a file is opened, STATUS FILES or FILE$(file-num) will reveal the full path name of the file or device actually opened. FILE$ without a parameter returns the file name of the last attempted open that was in error; this can be used to debug file name substitutions.

===Use of class printers===

Whenever OPEN statements are added to a program to access a printer (even on single-user systems), we recommend that you use a printer name of the form PRN:/xx where xx is a two-digit class number. This will standardize your printer names and make it easy to use the SUBSTITUTE specification to redirect printer output wherever you want.

On single-user systems, class is ignored. More specifically, all substitutions are processed, then any remaining "/xx" in "PRN:/xx" is discarded leaving simply PRN:. This means no SUBSTITUTE specifications are required to consolidate printer names. However, we still recommend coding multiple printer classes.

 00100 OPEN #255:"name=PRN:/10",DISPLAY,OUTPUT
 00120 OPEN #120:"name=PRN:/20",DISPLAY,OUTPUT ! letter quality

For example, the above two OPEN statements could still be rerouted to two different local printers using the following SUBSTITUTE specification:

 SUBSTITUTE PRN:/20,COM2:

Without the SUBSTITUTE specification on a single-user system, lines 100 and 120 above would both ignore the class information and device PRN: would have intermixed output from PRINT statements using the two file numbers.

On multi-user systems, the class parameter can be very useful because there may be several printers, including more than one type or class of printer. A multi-user system might have three dot-matrix printers, a letter-quality printer, and a laser printer. We recommend the following standards for printer class names:

10-19 primary high speed printers<br>
20-29 letter-quality printers<br>
30-39 laser printers

Use the above class numbers in your programs as if all the printers exist. Then when installing your software at customer sites, if the customer only has one class 10 printer on a multi-user system, insert the following in the BRConfig.sys file:

SUBSTITUTE /20,/10<br>
SUBSTITUTE /21,/10<br>
SUBSTITUTE /30,/10    ! .. and so forth

This will substitute or replace all program class references in file names with the operational class /10. This set of substitutions is not necessary on single- user systems because class is ignored.

Some Unix / Linux programmers may remember that some Unix / Linux releases before 3.0 allowed printer redirection using a name format of PRN:report/class to allow a different name for each report. In 3.0, the report name is ignored. It may be supported in future releases when additional print spooling capabilities are implemented.

The reason for currently ignoring report name is that it sometimes caused problems when using SUBSTITUTE specifications to redirect printer output. If you had a system with many reports and each report had a different PRN: specification with an embedded report name, then it was difficult to get a single SUBSTITUTE specification to redirect all of your reports to another printer. SUBSTITUTE /10,/11 would usually work, but not if you also made use of //10 as a printer name. Therefore, Business Rules has been changed to ignore the report name because it discouraged the use of standard printer names. In future releases, when report name is re-activated, additional substitution options will be provided.

When printing the screen, operators should use Ctrl-P (see `Fkey` for more  information about this key function). Ctrl-P uses Business Rules SUBSTITUTE specifications to redirect output to the desired printer. Screen-printing initiated by the PrtSc key is outside Business Rules control. PrtSc output will be sent to LPT1: where the outcome depends on how the operating system treats LPT1: and whether it is spooled or local. On single-user systems, if there is no printer on LPT1:, there will be no PrtSc output; but if SUBSTITUTE has been used to change PRN:/10 printer output to COM2:, then Ctrl-P will print the screen t
o COM2. Since operators at NetWork workstations have no immediate control over how LPT1: is assigned, using Ctrl-P is preferred for NetWorks because Business Rules does have control over Ctrl-P output and can direct the output appropriately.

===Novell NetWork Printer Support===

On a Novell NetWork version of Business Rules, a file-ref that begins with PRN: will always designate spooled printer output unless the PRN: has been mapped to something else through a SUBSTITUTE specification. For local printer support, use a SUBSTITUTE specification that will map one or more PRN: specifications to a DOS device name:

 SUBSTITUTE PRN:/11,LPT2:

The last digit of the class number specifies the Novell spooled printer number that you want the job sent to. Class 10 goes to printer 0, class 21 goes to printer 1, and so on. Using the first-digit of the class is still recommended for portability and readability (e.g., classes 10-19 for dot-matrix printers, classes 20-29 for letter-quality printers, etc.). SUBSTITUTE specifications can be used to change class numbers at Installation time. Class numbers can also be changed at execution time with the CONFIG command.

Business Rules creates its own disk files for spooling. The file names are formatted as follows: WSPOOLww.xxwhere ww is the workstation ID and xx is the first number between zero and 99 that makes the file name unique. No leading zeroes are included in ww or xx. While the printer file is open, the STATUS FILES command will show a name similar to:

 PRN:/10 C:\WB\WSPOOLww.xx

Business Rules creates this file in the current directory without a leading path name. If using the default directory becomes a problem, then you can direct Business Rules to use a consistent directory for Novell spool files by using a SUBSTITUTE specification like the following:

 SUBSTITUTE WSPOOL,C:\WBSPOOL\SPOOL

This will replace the WSPOOL in WSPOOLww.xx so that the file opened will be C:\WBSPOOL\SPOOLww.xx; thus, all spool files will be created in the C:\WBSPOOL directory.

The Novell spooler requires that these files be located on a sharable drive and that the user has both open and read permissions for the file. If either one of these conditions is not met, then Business Rules will return error code 4205 (access denied) when the printer file is closed. The disk file will be closed successfully and will remain intact on the default drive, but the file will not be sent to the printer.

In summary, OPEN file names are processed by the active list of SUBSTITUTE specifications. If after that processing, the name begins with PRN:, a spool file is created. The spool file name is also processed against the SUBSTITUTE list before the file is created.

===IBM NetWork Printer Support===

On the file server, use the IBM NetWork NET SHARE command to designate which ports on the server (LPT1:, LPT2:, etc) should be reserved for spooled (sharable) printers.

 NET SHARE SPRINT=LPT1  ! Server LPT1: is spooled printer

On the workstations, use the NET USE command to designate which ports on the workstation should be logically connected to the spooled printers.

 NET USE LPT2 \\SERVER\SPRINT ! workstation spooled printer

For each node on the NetWork (including the server) uses the Business Rules SUBSTITUTE specification to map PRN: names to the devices you would like to use.

 SUBSTITUTE PRN:/11,LPT3: ! workstation local printer
 SUBSTITUTE PRN:/10,LPT2: ! workstation spooled printer

When the printer is open, the STATUS FILES command or the function FILE$(file-num) will show the device name that PRN: has been mapped to.

===Background Processing===

Business Rules can now run as a background task on Unix and Xenix versions. The background mode capability allows you to run any Business Rules code that does not require keyboard interaction. Since the code runs in the background, you can run another process in the foreground at the same time.<br>
To initiate background mode processing, be sure Business Rules is loaded as another session, then start the background Business Rules with one of the following commands:

 BR "proc procname" -wsid >output.fil &
or
 BR "run progname" -wsid >output.fil &

A new Unix session will be started in which Business Rules will begin executing the specified procedure or program without occupying the screen. All output that would normally be sent to the screen, including control codes, will instead be sent to the specified output file. Business Rules will remain active until it enters READY mode or until it encounters any need for input (including an error) from the keyboard, at which time it will automatically terminate.

If you must terminate the background process before it completes executing, use the Unix/Xenix kill and ps commands. See also (in your Unix documentation) the sh command's & parameter for information on initiating new processes.

If you are starting two or more background Business Rules processes in succession and the applications use the same files, you need to be aware that the second process can "overtake" the first since it does not have to reload code in memory. This may introduce file sharing problems which did not exist when the programs were run from two separate workstations.

Introducing a delay between starting the first and second processes will solve this problem. If two simultaneously executing applications do not share files, you should not experience this problem.
