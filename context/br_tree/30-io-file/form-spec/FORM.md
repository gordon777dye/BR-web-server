---
title: FORM
file: FORM.md
category: 30-io-file
subcategory: 30-io-file/form-spec
kind: statement
related: [statement, PRINT, WRITE, REWRITE, READ, REREAD, GF, USING, numeric variable, string]
---
The **Form** `statement` is used in conjunction with `PRINT`, `WRITE`, `REWRITE`, `READ` or `REREAD` statements to format input or output. FORM controls the size, location, field length and format of input or output.

Parenthesis may now be used to repeat sections of a Form statement. The repeat factor may be either a number or a variable. Thus, the following is now valid:

 FORM 3*(C 10,C 1,C 4)
If a variable is used for a repeat factor in a FORM statement and the value of the variable is less than 1, zero will be used by default (same as the System/23), to skip the specification. Previously 1 was used. NOTE the following code fragment:

 00010 A=0
 00020 FORM A*C 5,C 10

The above is now the same as FORM C 10. Previously it was the same as FORM C 5,C 10.

The GF (generic, floating point) format specification has been added for use by the FORM statement and by INPUT/PRINT FIELDS to left justify strings and right justify numbers. See `GF` for more information.

===Comments and Examples===

In the following examples, you will see two different syntax diagrams for the FORM statement. One is valid for both internal and external files (which use the WRITE, REWRITE, READ and REREAD statements); the other is valid only for output with display files (which use the PRINT statement).

The line number or label of a FORM statement must be included in a `USING` clause within the I/O statement that uses it.

The following example shows how a literal (the "character string" parameter) may be specified from a FORM statement:

 00010 WRITE #1,USING 20: A$
 00020 FORM "TYPE A", C 10
 00030 READ #1,USING 20: A$

Form statements may follow the line label reference:

 00500 print #255, using nameform2: A$(1),E$,RF$,"",d1$
 00510 nameform2: form pos 16,c 30,x 9,c 6,x 16,c 7,x 24,c 2,x 16,c 8, skip 3

Or may be included within quotations in the first statement:

 00600 print #255, using "form pos 18,c 5,skip 1": "SAL.","O.T.","ADD'L","HOL.","Vac.","Sick"

===Syntax===

(FORM for internal and external files)

 FORM {{POS|X} {<integer>|<`numeric variable`>}|
      {<integer>|<`numeric variable`>}* {"<`string`>"|`PIC`(<pic spec>)}|{<`internal form spec`><field length>[.<fraction length>]|<`numeric form spec`>< field length>[.<fraction length>]}|<`string form spec`>[ <field length>]|<`floating point form spec`>}[,...]

`file:form1.png|850px`

===Defaults===
:1.) Use 1.
:2.) Zero decimal positions.
:3.) String length (see text).
:4.) Use only once.

===Parameters===

There are two main paths through the FORM syntax for internal and external files. The top path regulates spacing, and the bottom path regulates the format type and length of input or output. Both types of specifications may be intermixed in the same statement (when spacing parameters are used, format parameters must also be used).

The "POS" parameter, in the top path of the diagram, indicates that the cursor is to be positioned to a specific record position. It must be followed by an "integer" or a "num-var" value that represents the desired position. POS can be used to position either forwards or backwards in a record (or, when used with display files, in a print line).

The "X" parameter, also used for spacing, indicates that the specified number of positions should be skipped. It may be followed by an "integer" or a "num-var" value that represents the desired number of positions to skip.

The "integer*" and "num-var*" parameters (in the bottom path of the syntax diagram) provide an easy way to indicate multiple input or output fields of identical formats. The following two statements illustrate the space savings this parameter provides. Line 30 describes four contiguous fields which are identical in their format type and field length; line 40 accomplishes the same thing using FORM's repetition parameter (the asterisk (*) must be included):

 00030 FORM C 30,C 30,C 30,C 30
 00040 FORM 4*C 30

A general definition for the next set of parameters in FORM's syntax is that they allow you to describe the type and length of the information to be printed.

One exception to this is the "string" parameter, which can be any set of characters: this specification (also referred to as a "literal") is the information to be printed. When a "string" is specified for output, Business Rules or prints the literal. When used for input, the "character string" functions the same as X for the length of the literal. The character string must be enclosed within quotation marks.

The "`PIC`(pic-spec)" parameter allows you to specify a picture of the information to be printed. To use this parameter, you must specify the keyword PIC and then, in parenthesis, identify the desired picture of the information to be printed. Each character within the parenthesis is either an insertion character (to be printed as is) or a digit identifier (to be replaced with a digit when printed). See `File I/O` for more information about the PIC specification.

The following numeric format specifications may be used where "num form-spec" is listed as a parameter: G, GZ, N, or NZ. (Variations of the G specification can be used for either numeric or string formats.)

The "internal form-spec" parameter represents one of the following `format specifications`: B, BL, BH, PD or ZD.

If a "num form-spec" or an "internal form-spec" is specified, it must be followed by a "field-length" parameter, which is an integer or numeric variable that identifies the number of characters (including decimal point and decimal positions) to be reserved for the field. If decimal positions are to be included, the ".fraction length" parameter must also be specified. This is an integer or numeric variable that identifies the number of decimal positions. A decimal point (.) must precede this specification.One of the following string format specifications may be specified where the "string form-spec" parameter appears in the diagram: C, CC, CR, G, or V.

A "field-length" parameter may follow the "string form-spec" parameter. When no field length is specified, the default differs according to whether the information is being input or output. For input, the maximum dimensioned length is used. For output, the current string length is used (same as from the LEN function).

"Floating point form-spec" represents D, S or L -a set of very fast but hardware-dependent (and non-portable) format specifications. Parameters: Except for one added parameter (SKIP) and no available internal format specifications, the above diagram is identical to the FORM syntax for internal and external files. Please refer to the parameters section of the diagram to get the information which is not included in this section.

The "SKIP" parameter causes Business Rules skip vertical lines during (or after) output. If it is not followed by either an "integer" or a "num-var" that identifies the number of lines to skip, 1 is assumed. When determining the value for SKIP, keep in mind that the current line will be the first line to be skipped. (A specification of SKIP 1 will cause Business Rules skip to the line immediately below the current line. SKIP 2 is double spacing, which is only one blank line between lines.) Unless a SKIP parameter is explicitly specified at the end of the statement, Business Rules default of SKIP 1 at the end of all PRINT statements.

See the `File I/O` for additional information about all the format specifications listed in this section.

===Syntax===
(FORM for display files)

 FORM {POS|X|SKIP <integer>|<numeric variable>,}|
      {<integer>|<numeric variable>* "<string>"|PIC(<pic spec>)|<internal form spec><field length>[.<fraction length>]|<numeric form spec>< field length>[.<fraction length>]|<string form spec>[ <field length>]|<floating point form spec>,}

`File:Form2.png|850px`

===Technical Considerations===
:1.) SKIP 0 causes the printer to do a carriage return, but not a line feed (returns the pointer to the beginning of the current line). This was used for overstrike capability and bold printing on dot matrix printers. For example:

 00010 PRINT USING 20: "BOLD","BOLD"
 00020 FORM C 4,SKIP 0,C 4

The printer output from the above example would be the word "BOLD" (the text would be darkened, or bold, because it would be typed over twice).<br>
The same overstrike capability can also be achieved when the POS parameter is used in the following manner:

 00010 PRINT USING 20: "BOLD","BOLD"
 00020 FORM POS 5,C 4,POS 5,C 4

For details on printing in bold or other styles on modern printers, see `attributes`.

:2.) POS 0 prevents line output and saves the current line position for the next PRINT statement. For example:

 00010 PRINT USING 20: "ALL ON THE SAME"
 00020 FORM C 16,POS 0
 00030 PRINT USING 40: "LINE"
 00040 FORM C 4

outputs:
ALL ON THE SAME LINE

:3.) If the output of data exceeds the end of the record in a display file, the output will continue on the next line. In an internal file, error code 0714 will occur.
:4.) If the data item list of an I/O statement exhausts all items in the corresponding FORM statement, the FORM statement is reused from the beginning. For example:

 00010 PRINT USING 20: 1,2,3
 00020 FORM N 3

outputs:
 1 2 3

:5.) If a "num-var" is used as a repetition factor, it must be a simple (i.e., not subscripted) variable name. It cannot be an array element.
:6.) When the repetition factor (*) is used with string format specifications and the default field length is used, the field length will automatically be set to the length of the first string. Thus if the strings to be printed are of unequal length, the longest should be specified first.

The following code will produce a string overflow error because line 40 will be interpreted as FORM 2*V 6 (based on the length of the first string, "Happy"), and six bytes is too short for the second string:

 00030 PRINT USING 40: "Happy ","Birthday"
 00040 FORM 2*V

This problem can be avoided by either including a field length when using the repetition factor with a string format specification, or by not using the repetition factor with these specifications.

:7.) Field length and fraction length also may be unsubscripted variable names. For example:

 00020 FORM N A.B

:8.) Non-integer values are rounded when a variable is used as a repetition factor, field length or fraction length.
:9.) The G format specification is useful when a data item could be a string or a number; it allows the system to read in either string or numeric data without returning an error.
:10.) ARRAY elements are formatted in row order (see the `READ` statement for more information).
:11.) FORM statements are non-executable and may be placed anywhere in the program.
:12.) A FORM statement must be the only statement on a line or an error `0726` results.
:13.) If a negative number is being output with a PIC specification, there must be a sign specifier in the PIC.
:14.) Using a PIC specification for output with a string variable is the same as C (PIC width).
:15.) For working with date fields there are 3 form types that are supported:
:|DT 3  or DT 4<br>
:|DT 3  or DL 4<br>
:|DT 3  or DH 4

These utilize binary storage formats corresponding to B, BL and BH.  They also perform days() processing utilizing the "current" default date format (mdy/ ymd/ dmy etc.).  These formats are intended to reduce the number of changes required for Y2K compliance, and to ease `ODBC` access to dates stored in 'day of century' format.   However, ODBC also has a much more comprehensive date identification scheme.

The DAYS() function now permits four digit years even if C is not specified in the mask statement.

When days() or DH is used to store a date, normal sorting and indexing becomes Y2K compliant.  The days() function, and the date formats enable BASEYEAR processing
when the values are stored in binary fields. These can subsequently be indexed as character fields so long as they were stored in high-to-low order.

===See Also===
*`File I/O`
*`Format Specification`
