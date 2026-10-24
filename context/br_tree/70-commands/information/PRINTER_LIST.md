---
title: PRINTER_LIST
file: PRINTER_LIST.md
category: 70-commands
subcategory: 70-commands/information
kind: command
related: [internal function]
---
PRINTER_LIST(<Mat array name>)

The **Printer_List** `internal function` returns the number of elements in A$ after redimensioning A$ to the number of active Windows printers.  The contents of A$ show the printer names used by Windows, and the default printer is the first element.  These names are also suitable OPEN NAME= values to direct output to the respective devices. For example:

 10 DIM A$(1)*100
 20 LET X=PRINTER_LIST(A$)
 30 PRINT MAT A$

This program will display a list of printer names defined on the local machine in the manner the OS 'sees' them.

Also, to make easier use of PRINTER_LIST(A$) returned values, any matching substring of an A$ element will suffice after PRN:/ in the following example:

 10 DIM A$(1)*60, SELECTION$*60
 20 LET X=PRINTER_LIST(A$)       ! Get Windows Printer List
 30 FOR LOOP = 1 TO X
 40    A$(LOOP) = A$(LOOP)(1:POS(A$(LOOP),"@")-1) ! Trim device address
 50 NEXT LOOP
 60 GOSUB USER_SELECT_PRINTER    !  Custom Routine to Select From A$
                                  --- place result into SELECTION$ ---
 70 OPEN #255: "Name=PRN:/"& SELECTION$, DISPLAY, OUTPUT

====Troubleshooting hint when printing under Windows====
From the printers folder, click on the printer that's not working, select properties, details, and spoolsettings.  Then make sure the "spool data format" option is set to "RAW," not "EMP".
