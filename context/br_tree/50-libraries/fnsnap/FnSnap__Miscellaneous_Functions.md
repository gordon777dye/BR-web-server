---
title: FnSnap__Miscellaneous_Functions
file: FnSnap__Miscellaneous_Functions.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: [EMAILMONITOR, EMAILBLASTER, David Blankenship, BRREGISTER2.exe, registry]
---
## Email

### FNEMAIL - creates an email file for email monitor

Creates an email file for `EMAILMONITOR`

```
FNEMAIL(SENDDIR$*80,MAILFROM$*50,SUBJECT$*100,MAT MAILTO$,MAT MESSAGE$;MAT ATTACH$,SMAILQ$*80)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **SENDDIR$** | directory where message will be created |
| '''MAILFROM$ sender's email address |  |
| **SUBJECT$** | subject line of email |
| **MAT MAILTO$** | email addresses of recipients |
| **MAT MESSAGE$** | email text in the form of a matrix |
| **MAT ATTACH$** | matrix containing full path and name of any attachments |

**Comments**:

EMAILMONITOR is available through David Blankenship

### FNEMAILFILE - inserts a text file into an email for email monitor

Inserts a text file into an email for `EMAILBLASTER`

```
FNEMAILFILE(SENDDIR$*80,MAILFROM$*50,SUBJECT$*100,MAT MAILTO$,TEXTFILE$*100;MAT ATTACH$,SMAILQ$*80)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **SENDDIR$** | directory where message will be created |
| **MAILFROM$** | sender's email address |
| **SUBJECT$** | subject line of email |
| **MAT MAILTO$** | email addresses of recipients |
| **MAT MESSAGE$** | email text in the form of a matrix |
| **TEXTFILE$** | name of file containing email message |
| **MAT ATTACH$** | matrix containing full path and name of any attachments |

**Comments**:

## Formatting

### FNLEADZERO$ - obsolete replace with CNVRT$("PIC(###)",x)

Converts a number to a string and fills the leading positions with "0"'s.

```
FNLEADZERO$(NUMBER,LENGTH)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **NUMBER ** | The number to be converted |
| **LENGTH ** | The length of the resulting field |

**Comments:<br>**

Easier done with the CNVRT$("PIC(#####)",number) function.

### FNCHECKAMOUNT$ - returns English words for a dollar amount

Converts a number into a string of English words formatted with the words Dollars and Cents.  Optionally allows the returned string to be left padded with tilde symbols.

```
FNCHECKAMOUNT$(AMOUNT;LENGTH,OPT)
```

**Functions used:<br>**

The routine uses a local function to convert each three number (hundreds, thousands, millions) into words for the final result.

**Variables**:

|  |  |
| --- | --- |
| **AMOUNT ** | The number to be converted. This will be truncated to two decimal places.  Maximum number is 999,999,999.99.  A zero or negative number will return the word VOID. |
| **LENGTH ** | An optional prameter.  If used and greater than 10 the result will be left padded with tilde symbols to the size specified.  If the result is "V O I D" the word VOID will be centered in the padded tildes. |
| **OPT ** | An option parameter to determne whether the words DOLLARS and CENTS are included in the output string. 0 will include these words, 1 will transform the cents to a fraction and include it prior to the final word dollars. 2 will transform the cents to a fraction and append it to the output string, but with no "Dollars" included so that the string can be added to a preprinted check. |

**Comments:<br>**

Designed to be used as check protection verbiage on computer printed checks.  Can als be used as a screen response description.

## Progress

### FNPROG - displays a progress bar for a process

Displays a vertical progress bar that changes color form green to yellow to red as the process approaches 100%

```
FNPROG(PROW,PCOL,PCUR,PTOT)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **PROW ** | Upper left row corner of display |
| **PCOL ** | Upper left column corner of display |
| **PCUR ** | Current record number |
| **PTOT ** | Total record numbers when project is complete |

**Comments:<br>**

If reading a file the file needs to be restored after obtaining the last record number

### FNPROGRESS - displays a progress bar for a process

Similar to FNPROG

```
FNPROGRESS(&PCT_WINDEV,PCT_TOTAL,PCT_DONE;SR$,CAPTION$*55)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **PCT_WINDEV ** |  |
| **PCT_TOTAL ** | Total number of transactions to complete.... |
| **PCT_DONE ** | Number of transactions completed |
| **SR$ ** | Starting row for display |
| **CAPTION$ ** | Optional window caption |

**Comments**:

## Other

### FNCLKBUF - clears the keyboard buffer of extra key strokes

Clears the keyboard buffer

```
FNCLKBUF
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **None ** |  |

**Comments**:

### FNCURDRV$ - returns the current drive and directory

Returns the current drive and directory

```
FNCURDRV$
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **NONE** |  |

**Comments**:

### FNMSEXE$ - return the installed location of a Microsoft compliant program installation

Uses `David Blankenship`'s `BRREGISTER2.exe` to query the `registry` for the installed location of registered software

```
FNMSEXE$(L$)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **L$ ** | executable name as registered in the registry. |

**Comments:<br>**

Will find the location of WINWORD.EXE, EXCEL.EXE or any other executable that i properly registered

### FNX$ - returns X if true BLANK if false

Returns an "X" if L is true or " " if L is false.

```
FNX$(L)
```

**Functions used**:

**Variables**:

- '''None

**Comments**:
