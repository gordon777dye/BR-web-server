---
title: GF
file: GF.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: []
---
The **GF (generic floating-point) format specification** has been added for use by the FORM statement and by the INPUT / PRINT FIELDS. It is the same as `G` in that it can be used with either string or numeric data and in all other ways it is identical to `L` as used with INPUT and PRINT FIELDS. Note the following code fragment:

 00100 PRINT USING " 2*GF 10":333,444.44

;Outputs:

 333 444.44

GF left justifies strings and right justifies numbers. Strings may be any value not exceeding the specified length. Numbers may include a decimal point at any position and may have an exponent.

The following program demonstrates this:
 00010    open #1: "name=xxx,recl=80,replace",internal,outin,relative 
 00020    write #1,using 'form gf 10,c': 1234.56,"X"
 00030    write #1,using 'form gf 10,c': "1234.56","X"
 00040    write #1,using 'form gf 14,c': 123456e-20,"X"

This program produces a file with three records containing the following, where "bbb" represents three blank spaces:
 bbb1234.56X
 1234.56bbbX
 bbb1.23456E-15X   (the normalized form of the value)

===See Also===

The letter G can also be used as a `Attribute (Screen)#Control Attributes|Control Attribute`.
