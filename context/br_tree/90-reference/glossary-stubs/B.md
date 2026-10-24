---
title: B
file: B.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [BH, BL, . B is also used in]
---
The **B (binary) format specification** is used for fast and efficient internal numeric storage. Binary format is machine specific. There are two types: `BH` stores the most significant byte first, and `BL` stores the least significant byte first. B format defaults to BH or BL, whichever is the native format of the hardware. When portability is desired, BH or BL should be used. When speed is desired, B should be used. In general, systems that utilize Intel chips will use a native format of BL, and those that don't will use BH. The following chart indicates the format native to several hardware/operating system combinations:

{| class="wikitable"
| **COMPUTER**|| **NATIVE FORMAT**
|-
| AT&T with UNIX|| BH
|-
| IBM PC, XT, AT, with DOS || BL
|-
| IBM AT with LINUX || BL
|-
| NCR Tower with UNIX || BH
|}

The field length for a B-formatted number can be 1, 2, 3 or 4. The value range for each field length is as follows:
{|
|-valign="top"
|width="10%"|**FIELD**||**VALUE**
|-valign="top"
|width="10%"|**LENGTH**||**RANGE** 
|-valign="top"
|width="10%"|**1**||+ / - 127
|-valign="top"
|width="10%"|**2**||+ / - 32, 767
|-valign="top"
|width="10%"|**3**||+ / - 8, 388,607
|-valign="top"
|width="10%"|**4**||+ / - 2, 147, 483, 647
|-valign="top"
|}
<br>

;Technical Considerations:
1.) As with ZD and PD, the decimal point is implied for B format specifications; it is not stored with the number. To retrieve the same number as was written, the same format specification must be used. Reading a field with a B 4 that was written with a B 4.2 results in a number 100 times larger than was written. The number is rounded to the specified number of decimal positions before writing.

===See Also===
The letter B can also be used as a `Attribute (Screen)|screen attribute` for string or numeric values. See the category, `:Category:Field Specifications|field specifications`. B is also used in `PIC#Insertion Characters|PIC`
