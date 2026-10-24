---
title: L
file: L.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [System/23, Form]
---
The **L (long) format specification** is used for `System/23` compatibility only. It identifies a double-precision floating-point number that uses 9 characters of storage space. L may be used with `Form` for internal or external files; it may also be used with full screen processing.

;Input characteristics:
When L is used with FORM for internal and external files, it is identical to the `D` format spec except that L requires nine characters of storage (D requires only eight). When L is used for input with full screen processing, the field length must account for a leading minus sign and decimal point if needed. Fraction length is optional. Numbers are not redisplayed (with the specified number of decimal places) when editing a field. L will retain extra decimal positions if they are entered and if the specified field length allows for them.

;Output characteristics:
All significant digits in L-formatted data will be output exactly as they were input.

;Technical Considerations:
:1.) By definition, L is not portable; it is native to the floating-point format of the machine.

===See Also===

The letter L can also be used as a `Attribute (Screen)#Control Attributes|Control Attribute`.
