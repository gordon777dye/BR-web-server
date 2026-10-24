---
title: GL
file: GL.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [INPUT FIELDS, RINPUT FIELDS, . If GL is specified with]
---
The **GL (generic, lowercase) format specification** indicates that string data is to be converted to lowercase upon keyboard input. It can be used with `INPUT FIELDS` and `RINPUT FIELDS` processing. (PRINT FIELDS accepts it and treats it the same as `G`. If GL is specified with `FORM`, error `1006` will be generated.)

;Input characteristics:
When GL is used with keyboard input of string data, case conversion automatically occurs as the characters are being typed in. Even if the operator attempts to type uppercase letters, only lowercase letters will appear on the screen. Characters other than the letters A-Z are not affected. Also, data that is already displayed is not changed -on the screen or internally - by a GL specification. When used for input of numeric data, GL operates the same as `G`.

The following example will convert all letters entered to lowercase:

 00100 INPUT FIELDS "1,40,GL 10,r": X$

;Output characteristics:
When GL is used for output in PRINT FIELDS or INPUT FIELDS statements, it is treated the same as G (see the `G` format specification for more information). GL cannot be used for either input or output in a FORM statement.

===See Also===

The letters G and L can also be used as a `Attribute (Screen)#Syntax|Screen Attributes`.
