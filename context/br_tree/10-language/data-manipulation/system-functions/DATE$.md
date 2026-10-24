---
title: DATE$
file: DATE$.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
related: [internal function, Date, Days, Date (Command), Pic$]
---
Date$
 Date$(<days>)
 Date$([*]<format$>)
 Date$(<days>,[*]<format$>)

The **Date$** `internal function` returns the date as a formatted string which includes optional punctuation marks as separators between the month, day, and year. DATE$() works with day-of-century values along with an optional time fraction (use of fractions, 4.3+). 

====Comments and Examples====

The four examples below all change the date format temporarily so that the month will print before the day of the month, which will print before the year. For a system date of December 25, 1988, the printed output is given as a comment at the end of the line for each example.

 00010 PRINT DATE$("mm-dd-yy")    ! 12-25-88
 00020 PRINT DATE$("m.d.y")       ! 12.25.88
 00030 PRINT DATE$("DD/MM/YY")    ! 25/12/88
 00040 PRINT DATE$("MMDDYY")      ! 122588
 00050 PRINT DATE$                ! 88/12/25

NOTICE in line 50 that the output automatically returns to the default format. When BR is started, the default format is yy/mm/dd. Other possible uses of Date$ include returning *only* the day, month, year or century.

 00050 PRINT DATE$("m")           ! 12
 00060 PRINT DATE$("D")           ! 25
 00070 PRINT DATE$("y")           ! 88
 00080 PRINT DATE$("m-d-cy")      ! 12-25-1988
 00090 PRINT DATE$("C")           ! 19

The optional numeric parameter (days) allows specifying a day of the century. The following example assumes the system date is Christmas, 1988.

 00010 PRINT DATE$("*mm-dd-ccyy") ! 12-25-1988
 00020 PRINT DATE$(1)             ! 01-02-1900
 00030 PRINT DATE$(366)           ! 01-01-1901
 00040 PRINT DATE$(Days(DATE))    ! 12-25-1988
 00050 PRINT DATE$(Days(DATE)+10) ! 01-04-1989

Lines 10 and 20 above could be combined into line 500 below.

 00500 PRINT DATE$(1,"*mm-dd-ccyy") ! 01-02-1900

As the above specification includes the asterisk, the default format for all future uses of the `Date`, Date$ and `Days` functions is changed to mm-dd-ccyy, as specified.

The following is a short program that will center "July 4, 1988" (or any other value set by the Date command) at the top of a report. Note that this example is for illustrative purposes only, because the extended formats below eliminate the need for this code snippet. 

 00010 DIM MONTH$(12)*9
 00020 READ MAT MONTH$
 00030 DATA "January ","February ","March ","April ","May "
 00040 DATA "June ","July ","August ","September ","October "
 00050 DATA "November ","December "
 00060 PRINT #255,USING 70: MONTH$(DATE("m")) & DATE$("d, cy")
 00070 FORM CC 132

====Extended Date Formats That May Include Time of Day====

DATE$(days, "day month, ccyy") ->  23 January, 2007<br>
DATE$(days, "d3 m3 dd, ccyy")  ->  Tue Jan 10, 2005<br>
DAYS("January 17, 1945", "month dd, ccyy") -> 16435    (numeric days)

DATE$( days, “Month dd, ccyy at H#.##”)  ->  September 12, 2011 at 14.58 hours<br>
DATE$( days, “mm/dd/yy at H:M AM”)  ->  09/15/11 at 2:35 PM<br>
DATE$( days, “mon dd cy at H#:M# PM”)  ->  Sep 15 2011 at 02:35 PM

====Parameter Rules====

When the Date$ function is used without parameters, it returns the current system date in the current default format, which is yy/mm/dd when Business Rules is started.

The optional "days" parameter represents the desired date as a sequential value in relation to a base date of January 1, 1900. Thus January 2, 1900 would have a days value of 1. January 2, 1901 would have a days value of 366, since 1900 was not a leap year.

The optional "format$" parameter is a string expression which identifies the format of the value to be returned. When the first character of the string expression is an asterisk (*), it identifies the default format which should be used by the Date, Date$ and Days parameters until the computer exits Business Rules or until the format is changed again. Format changes affect the current computer only.

The format$ parameter may include editing characters and any of the following date specifications: D (day), M (month), Y (year) or C (century). Consecutive repetitions (DDD, YY, etc.) of the date specifications count as just one specification, but consecutive repetitions of other editing characters do not use this rule.

The following rules apply to the format$ parameter for the Date$, Date and Days functions:

# The D, M, Y and C specifications may be specified in either uppercase or lowercase letters.
# Consecutive repetitions of the D, M, Y or C specifications count as just one specification. Thus DDDD is one specification, and cc is one specification.
# All characters other than D, M, Y or C are considered editing characters, and are ignored for the numeric Date function.
# If the string parameter begins with an asterisk (*), then the default format is changed. The default format affects results of the Date, Date$ and Days functions. This change applies only to the current workstation and stays in effect until you leave Business Rules.

And as of 4.3:

<ol start="5">
<li>M, to the right of H always denotes minutes, so H:M:S is sufficient.</li>
<li>Either AM or PM, to the right of H denotes AM / PM output.</li>
<li>The absence of AM and PM denote military hours (0 – 23).</li>
<li>The maximum significant digits that can be represented in a numeric variable are 15. So if century, year, month and day are stored as a 5 digit day of century, then internally up to ten digits to the right of the decimal are available for time of day.</li>
</ol>

====Related Functions====

See also `Date` and `Days` for other date processing functions. To set the system date, use the `Date (Command)`. For other features especially useful in markets outside the United States, see the `Option (Config)|INVP` parameter of the Option statement and the `Pic$` function

===Saving Dates===
When storing date/time combinations in a data file, you should allow for all of the significant digits that your date mask supports on each side of the decimal point. A “BH 4.4” form supports nine significant digits, which is suitable for day of century plus a four digit fraction. To exceed that you can use either PD 6.6, PD 7.6, PD 8.6 or D 8 (double floating point) to store these values. Note that BR rounds internally at six digits by default.
