---
title: FnSnap__Miscellaneous_Functions
file: FnSnap__Miscellaneous_Functions.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: [EMAILMONITOR, EMAILBLASTER, David Blankenship, BRREGISTER2.exe, registry]
---
==Email==
===FNEMAIL - creates an email file for email monitor===

Creates an email file for `EMAILMONITOR`

 FNEMAIL(SENDDIR$*80,MAILFROM$*50,SUBJECT$*100,MAT MAILTO$,MAT MESSAGE$;MAT ATTACH$,SMAILQ$*80)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**SENDDIR$**||directory where message will be created
|-valign="top"
|width="10%"|'''MAILFROM$ sender's email address
|-valign="top"
|width="10%"|**SUBJECT$**||subject line of email
|-valign="top"
|width="10%"|**MAT MAILTO$**||email addresses of recipients
|-valign="top"
|width="10%"|**MAT MESSAGE$**||email text in the form of a matrix
|-valign="top"
|width="10%"|**MAT ATTACH$**||matrix containing full path and name of any attachments
|-valign="top"
|}
<br>
;Comments:

EMAILMONITOR is available through David Blankenship

===FNEMAILFILE - inserts a text file into an email for email monitor===

Inserts a text file into an email for `EMAILBLASTER`

 FNEMAILFILE(SENDDIR$*80,MAILFROM$*50,SUBJECT$*100,MAT MAILTO$,TEXTFILE$*100;MAT ATTACH$,SMAILQ$*80)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**SENDDIR$**||directory where message will be created
|-valign="top"
|width="10%"|**MAILFROM$**||sender's email address
|-valign="top"
|width="10%"|**SUBJECT$**||subject line of email
|-valign="top"
|width="10%"|**MAT MAILTO$**||email addresses of recipients
|-valign="top"
|width="10%"|**MAT MESSAGE$**||email text in the form of a matrix
|-valign="top"
|width="10%"|**TEXTFILE$**||name of file containing email message
|-valign="top"
|width="10%"|**MAT ATTACH$**||matrix containing full path and name of any attachments
|-valign="top"
|}
<br>
;Comments:

==Formatting==
===FNLEADZERO$ - obsolete replace with CNVRT$("PIC(###)",x)===

Converts a number to a string and fills the leading positions with "0"'s.

 FNLEADZERO$(NUMBER,LENGTH)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**NUMBER **||The number to be converted
|-valign="top"
|width="10%"|**LENGTH **||The length of the resulting field
|-valign="top"
|}
<br>
;Comments:<br>
Easier done with the CNVRT$("PIC(#####)",number) function.

===FNCHECKAMOUNT$ - returns English words for a dollar amount===

Converts a number into a string of English words formatted with the words Dollars and Cents.  Optionally allows the returned string to be left padded with tilde symbols.

 FNCHECKAMOUNT$(AMOUNT;LENGTH,OPT)

;Functions used:<br>
The routine uses a local function to convert each three number (hundreds, thousands, millions) into words for the final result.

;Variables:
{|
|-valign="top"
|width="10%"|**AMOUNT **||The number to be converted. This will be truncated to two decimal places.  Maximum number is 999,999,999.99.  A zero or negative number will return the word VOID.
|-valign="top"
|width="10%"|**LENGTH **||An optional prameter.  If used and greater than 10 the result will be left padded with tilde symbols to the size specified.  If the result is "V O I D" the word VOID will be centered in the padded tildes.
|-valign="top"
|width="10%"|**OPT **||An option parameter to determne whether the words DOLLARS and CENTS are included in the output string. 0 will include these words, 1 will transform the cents to a fraction and include it prior to the final word dollars. 2 will transform the cents to a fraction and append it to the output string, but with no "Dollars" included so that the string can be added to a preprinted check.
|-valign="top"
|}
<br>
;Comments:<br>
Designed to be used as check protection verbiage on computer printed checks.  Can als be used as a screen response description.

==Progress==
===FNPROG - displays a progress bar for a process===

Displays a vertical progress bar that changes color form green to yellow to red as the process approaches 100%

 FNPROG(PROW,PCOL,PCUR,PTOT)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**PROW **||Upper left row corner of display
|-valign="top"
|width="10%"|**PCOL **||Upper left column corner of display
|-valign="top"
|width="10%"|**PCUR **||Current record number
|-valign="top"
|width="10%"|**PTOT **||Total record numbers when project is complete
|-valign="top"
|}
<br>
;Comments:<br>
If reading a file the file needs to be restored after obtaining the last record number

===FNPROGRESS - displays a progress bar for a process===

Similar to FNPROG

 FNPROGRESS(&PCT_WINDEV,PCT_TOTAL,PCT_DONE;SR$,CAPTION$*55)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**PCT_WINDEV **||
|-valign="top"
|width="10%"|**PCT_TOTAL **||Total number of transactions to complete....
|-valign="top"
|width="10%"|**PCT_DONE **||Number of transactions completed
|-valign="top"
|width="10%"|**SR$ **||Starting row for display
|-valign="top"
|width="10%"|**CAPTION$ **||Optional window caption
|-valign="top"
|}
<br>
;Comments:

==Other==
===FNCLKBUF - clears the keyboard buffer of extra key strokes===

Clears the keyboard buffer

 FNCLKBUF

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**None **||
|-valign="top"
|}
<br>
;Comments:

===FNCURDRV$ - returns the current drive and directory===

Returns the current drive and directory

 FNCURDRV$

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**NONE**||
|-valign="top"
|}
<br>
;Comments:

===FNMSEXE$ - return the installed location of a Microsoft compliant program installation===

Uses `David Blankenship`'s `BRREGISTER2.exe` to query the `registry` for the installed location of registered software

 FNMSEXE$(L$)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**L$ **||executable name as registered in the registry.
|-valign="top"
|}
<br>
;Comments:<br>
Will find the location of WINWORD.EXE, EXCEL.EXE or any other executable that i properly registered

===FNX$ - returns X if true BLANK if false===

Returns an "X" if L is true or " " if L is false.

 FNX$(L)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|'''None
|-valign="top"
|}
<br>
;Comments:
