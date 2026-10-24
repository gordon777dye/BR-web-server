---
title: PIC
file: PIC.md
category: 20-io-screen
subcategory: 20-io-screen/fields-attributes
kind: statement
related: [format specification, INPUT FIELDS, GRIDs and LISTs, OPEN DISPLAY, FMT]
---
PIC({Z|#|$|*|+|-|^|B|D|CR|DR|DB|,|.}[...])

The **PIC** `format specification` converts a number into characters according to the "picture" specified within parenthesis. The "pic-spec" parameter consists of **PIC()** and one or more characters, which are either insertion characters to be printed as is, or digit identifiers to be replaced with a digit when printed. 

PIC may be used with both types of FORM statements (for internal and external files or for display files), and may be used with full screen processing statements. Unlike all other format specifications, PIC has its own set of specifications. These specifications generally fall into two groups: digit identifiers and insertion characters.

As of 4.3, #PIC can be used to process numeric data from a string variable. Similar to #FMT and #G, #PIC indicates that string data should be processed numerically.  This works for `INPUT FIELDS` as well as `GRIDs and LISTs`.

For example, when used in conjunction with the strings "231.45", "430", etc.:

 #pic($##,##0.00-)

will be able to use the numeric values. 

===Digit identifiers===
Digit identifiers indicate that the position they mark should be replaced with digits on output. The symbols that operate as digit identifiers include Z, #, $, *, -, +, ^, ( and ). In some cases (as noted in the following descriptions), these characters act both as digit identifiers and as insertion characters.

;Z
The Z (zero suppress) identifier is used to suppress a digit of zero. Zs that are placed to the left of the decimal point will suppress zeros on a digit-by-digit basis. In the following example, the left-most zero is suppressed but the next four are printed:
 00010 PRINT USING 20: 000.00
 00020 FORM 2*PIC(Z##.##)
The output from this example would be as follows:
 00.00
If Zs are to have any effect on the right side of the decimal, all specified positions to the right must contain a Z. Suppression will occur only when the value of the entire number to be output is zero and, in such a case, a blank value will be output. The Zs to the right of the decimal will take precedence over any other digit identifiers or insertion characters in the PIC specification. Output from the following example would be a blank line:
 00010 PRINT USING 20: 000.00
 00020 FORM PIC(###.ZZ)

;<nowiki>#</nowiki>
The # identifier is used for zero fill, for example:
 00010 PRINT USING 20: 1000,0
 00020 FORM 2*PIC(ZZZ,ZZ#)
Outputs:
 1,000 0
When the # symbol is used for numeric input with PIC specifications in INPUT FIELDS or RINPUT FIELDS statements, the cursor will automatically skip over non-numeric characters displayed in the field. (The # symbol must be the only digit identifier in the specification.) For example, when slashes are used in inputting a date, the following line 20 will create an output field eight  positions long, but the operator will only be able to key into the six numeric positions:
 00010 LET D = 112588
 00020 RINPUT FIELDS "5,10,PIC(##/##/##),r": D

;$
The dollar symbol ($) character operates as both an insertion character and a digit identifier, with the added rule that only one dollar symbol will be printed. The right-most specified dollar symbol, which is not replaced with a digit, will be output as a dollar sign. Any dollar symbols in PIC positions to the left of this one are output as blanks.

In the following example, the first value is output with no spaces between the dollar sign and the value because the PIC specification is designed to use a floating dollar symbol. In contrast, the second PIC specification identifies only one position where the dollar symbol is allowed: all other characters must either be digits or blanks.
 00010 PRINT USING 20: 1000,1000
 00020 FORM PIC($$$,$$$),X 2,PIC($ZZ,ZZZ)
Output from the above example would look as follows:
 $1,000 $ 1,000

;<nowiki>*</nowiki>
The asterisk (*) character operates as both a digit identifier and an insertion character, and it is normally used for printing check amounts. Any specified positions, which are not replaced with a digit, will be output as asterisks. Asterisks may be placed either to the left or to the right of the decimal, as in the following example:
 00010 PRINT USING 20: 523.50
 00020 FORM PIC($********.**)
Output from this example would appear as follows:
 $*****523.50
If the amount to be printed in line 10 were 0 rather than 523.50, the output would appear as follows:
 $********.**

;-
The minus (-) symbol operates as both a digit identifier and an insertion character, with the added rules that the minus sign will be output only when the value to be printed is negative and that only one minus sign (the one closest to the printed value) will be output per value. (Additional minus symbols will be output as blanks.) The minus symbol can be used to indicate either a leading or a trailing sign, as in the following example:
 00010 PRINT USING 20: -100,100,-100,100
 00020 FORM 2*PIC( - - -),2*PIC(ZZZZZ-)
Output from the above example would look as follows:
 -100 100 100- 100

;+
The plus (+) symbol operates as both a digit identifier and an insertion character, with the added rules that plus signs will be output only when the value to be printed is positive, and only one plus sign (the one closest to the printed value) will be output per value. (Additional plus symbols in the PIC specification will be output as blanks; a minus sign will be output in the position specified by the plus symbol when the value to be printed is negative.) The plus symbol can be used to indicate either a leading or a trailing sign, as in the following example:
 00010 PRINT USING 20: -100,100,-100,100
 00020 FORM 2*PIC(++++++),2*PIC(ZZZZZ+)
Output from the above example would appear as follows:
 -100 +100 100- 100+

;^
The carat (^) symbol is used to input and output data in exponential format. The
carat must occupy the three, four or five rightmost positions in the PIC specification. The output positions will be the mantissa value, the letter E, the exponent sign (+ or -) and the exponent value. Values are rounded before printing. The following examples show the output when the number 1.2345E+20 is printed using the following PIC specifications:

{|
|-valign="top"
|width="75%"|**Specifications**||**Output**
|-valign="top"
|width="20%"|PIC (# # # # # # # # ^ ^ ^ ^)||1234500E-14
|-valign="top"
|width="20%"|PIC (# #. # # #^ ^ ^ ^ )||12.345E+19
|-valign="top"
|width="20%"|PIC (# # . # # ^ ^ ^ ^ ^)||12.35E+019
|-valign="top"
|width="20%"|PIC (. # # # # # # ^ ^ ^ ^ )||.12345E+21
|-valign="top"
|width="20%"|PIC (ZZZ.# # ^ ^ ^ ^)||123.45E+18
|-valign="top"
|width="20%"|PIC (# # .^ ^ ^ ^ ^)||2. E+019
|-valign="top"
|}

;Parentheses - ( )
PIC((ZZZ,ZZZ.##)) now supports parentheses as digit identifiers (left side of the number only) and insertion characters, with the rule that parentheses will be output only if the number is negative. The left parenthesis that is closest to the number but not replaced with a digit will be output when the number is negative.

 00100 PRINT USING "FORM C 4,PIC((((ZZ,ZZZ.##))":"XXXx",-200

;output:
 XXXx   (  200.00)

 00100 PRINT USING "FORM C 4,PIC((((ZZ,ZZZ.##))":"XXXx",-200000

;output:
 XXXx (200,000.00)

===Insertion Characters===
Insertion characters are output exactly where they appear in the PIC  specification. The five special insertion characters are: B, D, CR, DR and DB. Any keyboard character other than the digit identifiers listed above is treated as an insertion character. The following example shows two typical uses of insertion characters. The first PIC specification in line 20 prints slashes between the month, day and year of a date. The second prints a colon between the hours and minutes of a time, and it prints the letters "AM" after the time.
 00010 PRINT USING 20: 102088,1130
 00020 FORM PIC(ZZ/ZZ/ZZ),PIC(BB##:##AM)
The above example outputs:
 10/20/88 11:30AM

;B Insertion Character
B is a special insertion character: it is always replaced with a blank when formatted. It is used only for System/23 compatibility (a space may be used to accomplish the same result). In the following example, B occupies the second position in the PIC specification.

 00010 PRINT USING 20: 100
 00020 FORM PIC(ZBZZ)

Output from the above example would look as follows:

 1 00

;D Insertion Character
D is a special insertion character: it is always replaced with a dash when formatted. This feature is useful for formatting social security numbers and phone numbers, as in the following example<br>

 00010 PRINT USING 20: 123456789
 00020 FORM PIC(###D##D####)

Output from this example would appear as follows:

 123-45-6789

;CR, DR and DB
CR, DR and DB are special insertion characters: they print only if the sign of the number is negative.<br>
The following three examples show each of these insertion characters in use:

 00010 PRINT USING 20: -100,100
 00020 FORM 2*PIC(ZZZZCR)

;Output:
 100CR 100

 00010 PRINT USING 20: -100,100
 00020 FORM 2*PIC(ZZZZDR)

;Output:
 100DR 100

 00010 PRINT USING 20: -100,100
 00020 FORM 2*PIC(ZZZZDB)

;Output:
 100DB 100

Conversion errors on G, N, and PIC formats can now be avoided on output to display files when the CONV=parameter is used in the OPEN DISPLAY statement. Also when CONV=is used, PIC processing will first try removing the commas from the output if doing so will prevent an overflow condition.

====Other====

See the `OPEN DISPLAY` statement for more information.

See also `FMT`, a similar method for formatting fields.

When PIC is used with non-numeric data it is processed very similar to the character string specifications C, V and G. Output is not formatted with insertion characters, but during keyboard entry insertion character positions are skipped.
