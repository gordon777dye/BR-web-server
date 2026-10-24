---
title: None
file: None.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [GOSUB, RETURN, On Gosub, On Goto, Parent=none]
---
The optional "NONE line-ref" parameter allows you to specify the line that control should go to when the value of the numeric expression does not fall into the indicated range. This branch is treated as a `GOSUB` branch rather than an error-processing branch. The branched-to subroutine must end with a `RETURN` statement. 

Used with the following statements:
*`On Gosub`
*`On Goto`

For disambiguation purposes, see `Parent=none`.
