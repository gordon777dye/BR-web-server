---
title: PD
file: PD.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [FORM, ZD, PD 4]
---
The **PD (packed decimal) format specification** is commonly used to save space in numeric storage. It is also used for maximum portability between computers. It can be used only with `FORM` statement for internal and external files.

;Input Characteristics:
When PD is used for disk input, a decimal point is inserted to the right of the specified number of digits in the memory representation of the value. Since the decimal point is not stored with a PD- formatted number (it is similarly only implied with `ZD`- and `B`-formatted numbers), the same format specification must be used to retrieve the number as was used to write it. Reading a field with a PD 5 that was written with a PD 5.2 results in a number 100 times larger than was written.

;Output Characteristics:
When PD is used for numeric output, the number is rounded to the specified number of decimal points before writing (like all numeric formats). Business Rules "packs" two numeric digits into each stored character (except for the last stored character, which will hold one digit and the sign). A PD field will hold 2*L-1 numeric digits, where L is the field length.

The range for a PD 5 is +/- 999,999,999. The last 4 bits of the field will be either F or C (hex) for a positive number or D (hex) for a negative number. For example:

 00010 WRITE #1,USING 20: 22.5, -22.5
 00020 FORM 2*PD 3.1

The above outputs the following six bytes to the disk in hexadecimal notation:

  	00 22 5F 00 22 5D

===See also===
`PD 4`
