---
title: FnSnap__Date_and_Time
file: FnSnap__Date_and_Time.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: []
---
## Date formatting

### FNCCYYMMDD_TO_DAYS - converts CYMD to DAYS

Converts CYMD to DAYS

```
FNCCYYMMDD_TO_DAYS(&DAT)
```

Functions used |

**Variables**:

- DAT date to be converted in DAYS format

**Comments**:

### FNDATEFWD

```
FNDATEFWD(DATEIN;CENTURY)- Converts YYMMDD to MMDDYY
```

Description|<br>
Converts YYMMDD to MMDDYY with option of including century

Functions used |None

**Variables**:

|  |  |
| --- | --- |
| **DATEIN** | date in YYMMDD format |

**Comments**:

If century is true then the date is output in MDCY format

### FNDATEREV - converts MMDDYY to YYMMDD

```
FNDATEREV(DATEIN;CENTURY) ! Convert MMDDYY to YYMMDD with optional addition of century MMDDCCYY to YYMMDD if century >0
```

Description|<br>
Converts MMDDYY to YYMMDD with option of including century

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DATEIN** | date in MMDDYY format |
| **CENTURY** | 1 if century is to be included CCYY0 if no century, only year YY |

**Comments**:

### FNDATE$ - Creates a formatted date from DAYS input

Creates a formatted date from a DAYS input. Example January 5,2003 Beginning with 4.17 this can be done directly by BR.

```
FNDATE$(DAYSIN)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DAYSIN** | date to be converted in DAYS format |

**Comments**:

### FNDAYS_TO_MMDDCCYY - Converts DAYS to MDCY

Converts DAYS to MDCY

```
FNDAYS_TO_MMDDCCYY(&DAT)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DAT** | date to be converted in DAYS format |

**Comments**:

### FNDAYS_TO_MMDDYY -  Converts DAYS to MMDDYY

Converts DAYS to MDY

```
FNDAYS_TO_MMDDYY(&DAT)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DAT** | date to be converted in DAYS format |

**Comments**:

### FNMDY2YMD - converts YYMMDD to MMDDYY with century option

Converts YYMMDD to MMDDYY with option of including century

```
FNMDY2YMD(DATEIN;CENTURY)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DAYSIN** | date to be converted in DAYS format |
| **CENTURY** | 1 if century is to be included0 if no century |

**Comments**:

### FNMMDDCCYY_TO_DAYS - converts MDCY to DAYS

Converts MDCY to DAYS

```
FNMMDDCCYY_TO_DAYS(&DAT)
```

Functions used |

**Variables**:

- DAT date to be converted in DAYS format

**Comments**:

### FNMMDDYY_TO_DAYS - Converts MDY to DAYS

Converts MDY to days

```
FNMMDDYY_TO_DAYS(&DAT)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DAT** | date to be converted in DAYS format |

**Comments**:

### FNTIMMILREG - 12 hour time from 24 hour time

Returns regular 12 hour time from 24 hour military time

```
FNTIMMILREG(MILTIM,&HOUR,&MINUTES,&AMPM$) !:
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **MILTIM** | time in military 24 hour format |
| **HOUR** | the hour in 12 hour time to be returned |
| **MINUTES** | minutes to be returned |
| **AMPM$** | designation of AM or PM to be returned |

**Comments**:

### FNYMD2MDY - converts MMDDYY to YYMMDD with century option

Converts MMDDYY to YYMMDD with option of including century

```
FNYMD2MDY(DATEIN;CENTURY)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **DAYSIN** | date to be converted in DAYS format |
| **CENTURY** | 1 if century is to be included, 0 if no century |

**Comments**:

### FNYYMMDD_TO_DAYS - convert YMD to DAYS

Converts YMD to DAYS

```
FNYYMMDD_TO_DAYS(&DAT)
```

Functions used |

**Variables**:

- DAT date to be converted in DAYS format

**Comments**:

## Relative and special dates

### FNBUSINESSDAY - returns the next business day after or including a specified date

increases the given date until it is not a weekend or legal holiday

```
FNBUSINESSDAY(XDATE)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **XDATE ** | Date in days that is the starting point for calculations |

**Comments:<br>**

Useful in determining settlement dates for federal and state tax payments.<br>
The holidays calculated are federal legal banking holidays only, no state or local holidays are included.

### FNDAYOFYEAR - ordinal number of days from beginning of calendar year

Calculates what day any days date is within the calendar year that it is located

```
FNDAYOFYEAR(D)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **D ** | Date in days to be calculated |

**Comments**:

### FNNEXTMONTH - similar date in the following month

Returns a similar date for the following month based on number of days before month end

```
FNNEXTMONTH(INDATE)
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **INDATE ** | date to be converted in DAYS format |

**Comments:<br>**

If the date given is the 29th day of a 31 day month and the following month contains 30 days the returned value will be the 28th day of the following month.

### FNPRIOR BUSINESSDAY - returns the first business day prior to a given date including the given date

Decreases the given date until it is not a weekend or legal holiday

```
FNPRIOBUSINESSDAY(XDATE)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **XDATE ** | Seed date in days |

**Comments:<br>**

Will calculate the available date for a banking transaction prior to or including the seed date.  Useful in determining the settlement date for payroll direct deposit dating and payroll account funding in advance of a payroll.

### FNWEEKDAY$ - Returns the day of the week

Returns the day of the week from a DAYS input

```
FNWEEKDAY$(WEEKDAY) !:
```

Functions used |

**Variables**:

|  |  |
| --- | --- |
| **WEEKDAY** | date to be converted in DAYS format |

**Comments**:

### FNWEEKOFMONTH - number of time a specified day of week has occur ed in the month specified

Returns the week number within a month of a specified date assuming that the first time that that day of the week occurred in the month was the first week of the month.

```
FNWEEKOFMONTH(D)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| **D** | Date for which the calculation is being done |

**Comments:<br>**

Useful in determining what deduction in a payroll system should be activated if the deductions only occur on certain weeks of the month.

### FNWEEKOFYEAR - number of times a specified day of week has occurred in a year up to a specified date

Returns the number of the week of the year for a specified date, assuming that the specified day of the week first occurred in the first week of the year.

```
FNWEEKOFYEAR(D)
```

**Functions used**:

**Variables**:

|  |  |
| --- | --- |
| D ''' | Date to be processed in days |

**Comments**:
