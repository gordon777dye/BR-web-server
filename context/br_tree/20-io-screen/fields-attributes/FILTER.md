---
title: FILTER
file: FILTER.md
category: 20-io-screen
subcategory: 20-io-screen/fields-attributes
kind: statement
related: [PRINT FIELDS, RINPUT FIELDS, Grid_and_List, POS, MASK, FILTER_DELIMITERS]
---
Grid and list **filter** search fields are available as of BR! `4.3` for
[grids and lists](../controls/Grid_and_List.md).

A new field type is defined (similar to `SEARCH`):

*(Diagram of the FILTER field — the source's `Filter.png` image is not available in this tree
and could not be recovered.)*

```
RINPUT FIELDS "nn,nn,15/FILTER 10,leading-attributes,row,col,grid column to search [, filter-type] [, CASE]": string-value
```

For example:

```
RINPUT FIELDS "4,50,15/FILTER 10,,10,10,2,ALL": Findfield$
```

This example combines a filter box (which will search everything in the list) and the rinput fields for a list selection:

```
rinput fields "4,8,78/FILTER 30,/w:w,5,6,Fullrow,all;5,6,list 21/80,rowsub,selone": foundvar$,selection
```

### Parameters

| Parameter | Description |
|---|---|
| **nn and nn** | The row and column to position the field on the screen. |
| **Size/ and Characters** | How large the filter field will be in columns, and how many characters can be entered into it. In the example, `15/` and `10` provide a 15 column field where the operator can enter 10 characters. |
| **Leading attributes** | Any attributes desired (optional). |
| **Row and col** | The starting row and column of the grid or list you wish to search. |
| **Grid column to search** | The number of the grid column the filter will test against. `FULLROW` can be used here to search all the columns in each row. |

#### Filter Types

- **LEADING** — Filter searching is done left justified using only leading characters (default).
- **WORD** — Each word is leading matched.
- **ALL** — The entire string is searched for a match (similar to `POS`).

**CASE** may optionally be used to make all searching case sensitive. Case insensitivity is the default.

**String-value** is the variable name which will apply to whatever the operator enters into the field for searching.

For both FILTER and `SEARCH`, the up and down arrows now affect only the selection bar in the grid/list being presented.

#### Note

- MASK can be used to query the Filter display, with a value of 1.

## See Also

- [Filter_Delimiters](../../00-configuration/config-directives/spec.md#appearance)

<!-- br_tree-audit -->
> **br_tree audit:** Folded into br_tree spec → [spec.md](spec.md).
