---
title: D
file: D.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [FORM]
---
The D (double-precision floating-point) format specification should be used where speed and/or floating point are required. All numbers internal to Business Rules stored in this format, so almost no effort is required for Business Rules read or write D format.

D can be used with `FORM` for internal and external files. It is not available with FORM for display files and it cannot be used with full screen processing.

;Input characteristics:
Since D represents a floating-point number, any number with any amount of decimal positions will be accepted when D is specified. Rounding will not occur. A field length or number of decimal positions is never specified when D is coded. Business Rules eight characters of storage for every D-formatted data item.

;Output characteristics:
All significant digits in D-formatted data will be output exactly as they were input.

;Technical Considerations:
:1.) By definition, D is not portable. It is native to the floating-point format of the machine.
:2.) D may be compatible with non-Business Rules, specifically "C" files.
:3.) D is machine dependent, but all machines should support 10e+-307 with up to 15 digits of precision.

===See Also===
The letter D is also used as a `PIC#Insertion Characters|PIC` insertion character.
