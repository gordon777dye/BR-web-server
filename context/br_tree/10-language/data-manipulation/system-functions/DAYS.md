---
title: DAYS
file: DAYS.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
related: [internal function, BaseYear, BRConfig.sys, Date$, Date]
---
DAYS (<date>[,<format$>])

**DAYS** `internal function` returns the absolute, sequential value which is assigned to dates beginning January 1, 1900.

BaseYear is used to determine the century for a date if the format specification used does not specify a century. See `BaseYear` in the `BRConfig.sys` specifications section for complete information.

===Comments and Examples===
The Days function returns the specified date as a sequential value in relation to a base date of January 1, 1900. As an example of using this parameter for date arithmetic, line 300 would print "PAST DUE" if the date of an invoice **IDATE** is over 30 days from the current date.

 00030 IF Days(DATE)>Days(IDATE)+30 THEN PRINT "Past Due"

The DAYS function can now be used to store and perform date arithmetic on dates beginning with year 1700.  Negative numbers are used to denote such dates.

Notice that the number of days in a month, leap year, etc. do not have to be coded in your program because they are built into this function.

If the numeric date parameter is invalid, the Days function will return zero. Therefore, the Days function can also be used to check the validity of dates entered from the keyboard. For example,

 00010 LET DATE$("*y/m/d") ! be sure default format is year/month/day
 00020 LET M$="14"         ! month is invalid
 00030 LET D$="31"
 00040 LET Y$="88"
 00050 LET D=VAL(Y$&M$&D$) ! D = 881431
 00060 PRINT Days(D)       ! invalid date = 0
 00070 LET M$="12"         ! month is valid
 00080 LET D=VAL(Y$&M$&D$) ! D = 881231
 00090 PRINT Days(D)       ! valid date = 32507
 00095 LET DATE$("*m/d/y") ! change default format to month/day/year
 00096 PRINT Days(D)       ! invalid date = 0 (does not fit format)

The value of D in line 96 is invalid because line 95 changes the default format for dates (note the * at the start of the date string). The optional second parameter of the Days function can be used to temporarily change the date format. Line 97 will print a nonzero value because the date is valid in the format specified in the optional string parameter.

 00097 PRINT Days(D,"y/m/d") ! valid date = 32507
 00098 PRINT Days(D)         ! invalid date = 0 (does not fit format specified  in line 95)

Line 98 returns zero because the format in line 97 only applies to that one function call. Since there is no asterisk in the date string, line 97 does not change the default date format, whereas line 95 does.

===Parameters===
The "date" parameter is a numeric expression that represents the date for which the number of days should be calculated. If "date" is not valid according to the current default format, Days will return 0.

The optional "format$" parameter is a string expression which identifies the format of the value to be returned. When the first character of the string expression includes an asterisk (*), it identifies the default format which should be used by the Date, Date$ and Days parameters until the workstation exits Business Rules or until the format is changed again. Format changes affect the current workstation only.

The format$ parameter may include separating characters and any of the following date specifications: D (day), M (month), Y (year) or C (century). The total number of separating characters and date specifications may not exceed 6. Consecutive repetitions (DDD, YY, etc.) of the date specifications count as just one specification, but consecutive repetitions of separating characters do not use this rule. See the Date$ function for additional information about format$.

===Handling Input===
(4.2+) BR does not require that the entered value conform to the specified mask to avoid the entry of incorrect dates using unforeseen valid expressions. If a date format mask omits month, day, year and/or century, BR assumes the first day of the current month for the respective omitted mask components. Values must conform to masks with the following exceptions:

* Any valid format for month or day is accepted on input where the mask requests the respective month or day.
* Any valid separator will be accepted where any separator is specified by the mask.

Otherwise, BR requires that the entered value conform to the specified mask to 
avoid the entry of incorrect dates using unforeseen valid expressions.

Examples:
   days("Tuesday 23 January, 2007",'day dd month, ccyy') -> 39104
   days("January, 2007",'day dd month, ccyy') -> 39082  (day 1 assumed)
   days("Tuesday 23 Jan; 07",'day dd m3, yy') -> 39104  (note mm yy separator)
   days("Tuesday 23 Jan/ 07",'day dd m3, yy') -> 39104
   days("Tuesday 23 Jan; 07",'day dd m3, yy') -> 39104
   days("Tuesday 23 Jan- 07",'day dd m3, yy') -> 39104
   days("23 Jan;",'dd m3,')                   -> 40200  (current year and century)

BR allows a null mask, but the omission of a mask does not denote a null mask. It denotes whatever the system default mask is currently set to, which could be the system default.

*As of 4.3, numeric variables can now represent time of day in the fractional space (to the right of the decimal point) to include the following:
   H#.## or H denotes hours (with fractions).
   M#.### or M#.# denotes minutes.
   S#.####, S or S# denotes seconds.
M, to the right of H always denotes minutes, so H:M:S is sufficient.
Either AM or PM, to the right of H denotes AM / PM output.
The absence of AM and PM denote military hours (0 – 23).
The maximum significant digits that can be represented in a numeric variable are 15. So if century, year, month and day are stored as a 5 digit day of century, then internally up to ten digits to the right of the decimal are available for time of day.

Examples:
   DAYS("7/13/15 03:10:57 AM","M/D/Y H:M:S AM")     -> 42197.1326042
   DAYS("03:10:57 AM","H:M:S AM")                   -> 42185.1326042   
   DAYS("7/13/15 03.1825","M/D/Y H#.####")       -> 42197.1326042
Notes: 
* When using H:M:S, the time Component must be HH:MM:SS, so for example 3:10:57 PM will not work properly 
* When providing a time without a date, the function will return the days value for the 1st day of THIS month. In the Above examples, the date was 7/13/15
* When using H#.#### the Hours must be 2 Digits "03" not "3", and the # of decimals must at least match the mask provided.

===Saving Dates===
When storing date/time combinations in a data file, you should allow for all of the significant digits that your date mask supports on each side of the decimal point. A “BH 4.4” form supports nine significant digits, which is suitable for day of century plus a four digit fraction. To exceed that you can use either PD 6.6, PD 7.6, PD 8.6 or D 8 (double floating point) to store these values. Note that BR rounds internally at six digits by default.

===Related Functions===

See also `Date$` and `Date` for other date processing functions.
