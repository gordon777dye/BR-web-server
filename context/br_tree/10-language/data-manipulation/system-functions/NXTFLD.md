---
title: NXTFLD
file: NXTFLD.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
corrections:
  - "This page documented NXTFLD as taking parameters — \"4 possible combinations of syntax\", a `NXTFLD([<New_current_field>][,<attribute$>][,`FKEY`])` setter, ListView/Grid two-parameter forms, worked examples writing `LET NXTFLD(NXTFLD,FKEY)` and `LET NXTFLD(1,\"RX\")`, a \"Previously, the NxtFld statement supported 3 parameters\" list, and several paragraphs of prose about what the first, second and third parameters mean. **NXTFLD never supported parameters.** All of it is removed. Evidence: ck_num_sysfn (command3.cpp) lists NXTFLD_FN under `// 0 parameters` alongside NXTROW/NXTCOL/CURPOS/TIMER and returns -1 for any subcount; both the bare form (command3.cpp:524) and any parenthesised form (:653) are checked by that one function, and its only escape, NOT_FN_REF, is guarded by EXTENDED_USER_FUNCTION and so is reachable only by FN… names; numfunct.cpp implements `case NXTFLD_FN:` as a read of fieldsdata.tnxtFld that never pops an argument; and syn.txt has no NXTFLD, so there is no statement form either. The parameterised behaviour described here is CURFLD's — `case CURFLD: // 0-3 parameters if 2 or more numeric, string, numeric` in the same checker, implemented in numfunct.cpp as `// curfld(pos,attr$,firstkey)`, which is the (field, attribute$, FKEY) signature this page claimed for NXTFLD. This page's own prose gave it away: it explained its `LET NXTFLD(NXTFLD,FKEY)` example with the sentence \"The CURFLD function in line 40 is then used to reenact the operator's field exit operation.\" Corroborated by the reference corpus, where 696 files call CURFLD with 1-3 arguments and not one of 1,107 files writes NXTFLD with any. Determined by the maintainer, who states NXTFLD never took parameters; found in brls phase 5."
related: [internal function, Curfld, FKEY, cursor, INPUT FIELDS, RINPUT FIELDS, INPUT SELECT, RINPUT SELECT, Array]
---
The **NxtFld** `internal function` is similar to `Curfld` except that it returns the relative position of the next control to be occupied during an INPUT operation (the one the user clicked on or attempted to move to).

**NXTFLD takes no arguments and is not assignable.** It is written bare, like `ERR` or `CNT`. To *set* the next input field — or its attributes, or an FKEY value to be applied before the next INPUT — use [`CURFLD`](spec.md#screen-query), which takes those three parameters; see also [20-io-screen/windows-cursor](../../../20-io-screen/windows-cursor/spec.md#semantics).

Two methods are used to identify clicked controls: Fkey numbers and NXTFLD. This will keep track of which control was clicked when a user clicks on a hot control (a control that has an Fkey assigned). If the control is a GRID or LIST then it keeps track of where the user clicked within the control.

If a control that is part of an active Input Fields operation is double clicked, then NXTFLD will identify the relative position of the control within the Fields operation. However, for hot field identification it is necessary to use Fkey values to identify the respective controls.

===Interrogating the Next Control===

It is desirable to know which control was clicked when a user clicks on a hot control (a control that has an Fkey assigned). Furthermore, if the control is a GRID or LIST then it can be useful to know where the user clicked within the control. Two methods are used to identify clicked controls: Fkey numbers and NXTFLD.

The **NxtFld** function returns the number of the field containing the `cursor` from the last `INPUT FIELDS`, `RINPUT FIELDS`, `INPUT SELECT`, or `RINPUT SELECT` operation.

===Comments and Examples===

 00100 DIM SF$(3)
 00110 LET SF$(1)="10,30,c 10,r"
 00120 LET SF$(2)="12,30,c 10,r"
 00130 LET SF$(3)="14,30,c 10,r"
 00140 INPUT FIELDS MAT SF$: A$, B$, C$
 00150 PRINT "Cursor ended on FIELD"; NXTFLD
 00160 PRINT "Cursor ended on ROW"; NXTROW
 00170 PRINT "Cursor ended on COLUMN"; NXTCOL

In the sample program above, the there are three fields available for input. The operator can move the cursor in any direction, but only within these three fields. After the operator hits the <ENTER> key, line 150 will print the number 1, 2 or 3 depending on which field the operator left the cursor on. In addition, line 160 will print the row number (10, 12, or 14) containing the cursor when input was ended. Also, line 130 will print the column number (30 through 39).

NXTFLD provides valuable information when several fields are entered in one statement through an array, specifically, when `INPUT FIELDS`, `RINPUT FIELDS`, `INPUT SELECT`, or `RINPUT SELECT` is used with an `Array`.

As NXTFLD returns the subscript in the field definition array of the field containing the cursor from the last `INPUT FIELDS`, `RINPUT FIELDS`, `INPUT SELECT`, or `RINPUT SELECT`, NXTFLD can be especially useful with the on-line help facility. By using NXTFLD in the HELP$ function in line 990 for the value of the "mark", the operator can be directed to the most relevant portion of the text under the topic HOURS.ENTRY in the help file that explains the valid entries for that field. For example:

 00810 INPUT FIELDS MAT FLD$: HRS,OT,DT,SICK HELP 90
 00820 STOP
 00990 HELP$("HOURS.ENTRY", NXTFLD) : RETRY

`Option` 43 Use old style Input Select with respect to setting CURFLD to the `NXTFLD` value when a selection is made.
