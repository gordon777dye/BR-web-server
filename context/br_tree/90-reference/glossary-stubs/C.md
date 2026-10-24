---
title: C
file: C.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [FORM, CC, CR, CL, CU]
---
The **C (character) format specification** identifies string data. It can be used with both types of `FORM` statements (for internal/external files and for display files), and it can be used with the full screen processing statements.

;Input characteristics:
For string input, C format specification retains all trailing spaces when reading in a value with a specified field length. If the field length is not specified, the field length defaults to the maximum dimensioned length of the variable.

;Output characteristics:
When C is used for output, the string value is printed with blanks padded on the right (leading spaces are retained), as in the following example:

 00010 PRINT USING 20:"ABC","DEF"
 00020 FORM C 8,C 3

Output from the above example prints to the screen as:

 ABC   DEF

If the field length is not specified, the field length defaults to the current string length (the value from the LEN function) of the variable, as in the following example:

 00010 PRINT USING 20:"ABCDE","fgh"
 00020 FORM C,C

Output from the above example prints to the screen as:

 ABCDEfgh

;Technical Considerations:
:1.) When used for string output, the C, V and G specifications behave identically. On string input, V and G differ from C in that they remove all trailing spaces.

The following example illustrates reading the same string three different ways:

 00010 READ #1,USING 20: A$
 00020 FORM C 18
 00030 REREAD #1,USING 40: B$
 00040 FORM V 18
 00050 REREAD #1,USING 60: C$
 00060 FORM G 18
 00070 PRINT USING 80: A$, LEN(A$),LEN(B$),LEN(C$)
 00080 FORM C 20,3*N 5

This example outputs the following:

 12345         18  5  5

The output indicates that the string length (determined by the LEN function) is shorter for the strings read with the V and G specification. Input is the same for all three.

:2.) See the `CC` Format Specification, `CR` Format Specification, `CL` Format Specification and `CU` Format Specification format specifications for information on the variations of C.

===See Also===
The letter C can also be used as a `Attribute (Screen)#Control Attributes|control attribute` to control cursor position upon entering the screen.
