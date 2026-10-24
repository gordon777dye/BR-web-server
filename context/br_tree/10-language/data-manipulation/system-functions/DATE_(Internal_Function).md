---
title: DATE_(Internal_Function)
file: DATE_(Internal_Function).md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
related: [Date (disambiguation), internal function, INPUT FIELDS, Date$, DAYS, INVP, Option, PIC$, Format Specifications]
---
See also `Date (disambiguation)`

 DATE([<DAYS>], [*<order_of_components$>])

The **Date** `internal function` calculates and returns dates in *numeric format*, using no dashes or slashes as separators. Date numeric variables can now represent time of day in the fractional space (to the right of the decimal point), as of 4.3.

The optional "days" parameter represents the desired date as a sequential value in relation to a base date of January 1, 1900. Thus January 1, 1900 would have a days value of 1; January 1, 1901 would have a days value of 366 (1900 was not a leap year).

When **order_of_components$** is specified, the date is printed accordingly. order_of_components$ may be any combination of the four letter M (month, D (day), C (century), Y (year). Including each of these components results in a two-digit corresponding month, day, century, or year. When any of these 4 components is omitted, it is not returned by the function or printed.

If the order_of_components$ parameter begins with an asterisk (*), then the default format is changed. The default format affects results of the Date, Date$ and Days functions. This change applies only to the current computer and stays in effect until you exit BR.

DATE can also be used as an `INPUT FIELDS` specification as of 4.3.

====Examples====

Executing the following statement on July 10, 1992

 PRINT DATE("MDCY")

results in the following output: 

 7101992

**Note** that BR does not print the zero in front of the month July (07), as this is not necessary for numeric calculations. If you do not need the numeric value of the date, use the `Date$` function instead.

Consider another example, in which 33794 is the number of days which passed between January 1, 1900 and July 10, 1992:

 PRINT DATE(33794,"MDY")

with the following output: 

 71092

The DATE function should not be confused with the DATE command, which may be used to reset or display the current system date.

====Comments and Examples====

 00010 PRINT FIELDS "10,10,CR 20": "Enter Posting Date:"
 00020 PRINT FIELDS "10,43,N 6,r": DATE("mdy")
 00030 INPUT FIELDS "10,43,N 6,r3": POSTDATE

Line 20 displays the current system date as a number in the format month, day and year. Line 30 positions the cursor to the third digit and allows the operator the option to change the displayed date by typing over all or part of it.

====Technical Considerations====

The DATE function cannot be used in READY mode unless it includes parameters. If you type in "DATE" and press <ENTER>, you will be using the DATE command, which uses a different default format than the DATE function does.

====Use with Input Fields====

DATE(mask) can be used as an `INPUT FIELDS` specification as of 4.3.

 10 INPUT FIELDS “row, col, DATE(mask),UH” : date-variable

Special keyboard processing:
*Punctuation (commas, colons, slashes, semicolons, and dashes) is skipped during entry, similar to PIC.
*Insert and delete are supported within subfields that are delineated by punctuation.
*Copy includes punctuation.
*Cut is Copy with redisplay of zero date.
*Paste causes BR to translate the date to `DAYS` format and then display the date. Excel and OpenOffice Calc application formats are supported.
*If a string is pasted, it is first converted to DAYS using the provided mask.
*If a zero DAYS value is displayed then Month, M3, Day and D3 mask positions contain dashes.

====Date Picker====

====Sample Program====
A sample program to demonstrate date entry is:
 01000 ! Rep Date_Input
 01020 ! Demonstrate The New Date() Input Format
 01040 ! Skip Punctuation (Commas, Colons, Slashes, Semicolons, And Dashes)
 01060 ! Insert And Delete Within Subfields That Are Delineated By Punctuation
 01080 ! Continue To Support Cut And Paste Including Punctuation
 01100 ! 
 01120    rinput fields "5,10,DATE(mm/dd/yy) ;6,10,c": DATE_VAR
 01140    print fields "8,10,date(Month DD, CCYY)": DATE_VAR
 01160 ! 
 01180    rinput fields "12,10,date(month dd, ccyy)": DATE_VAR
 01200    if NOT DATE_VAR then goto 1180
 01220    print fields "15,10,date(yy/mm/dd)": DATE_VAR 
 01240    print fields "18,10,N 6": DATE_VAR  !Show days format

====Related Functions====
See also `Date$` and `Days` for other date processing functions. To set the system date, use the `Date (Command)|Date command`. For features especially useful in markets outside the United States, see the `INVP` parameter of the `Option` statement and the `PIC$` function in the `Format Specifications`.
